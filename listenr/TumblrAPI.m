//
//  TumblrAPI.m
//  
//
//  Created by Ethan Sherbondy on 8/11/12.
//
//

#import "TumblrAPI.h"
#import "Secrets.h"
#import "DataController.h"
#import "NSManagedObjectContext+Additions.h"
#import "Blog.h"
#import "Song.h"

@implementation TumblrAPI

+ (TumblrAPI *)sharedClient {
    static TumblrAPI *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TumblrAPI alloc] initWithBaseURL:[NSURL URLWithString:kTumblrAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];    
	[self setDefaultHeader:@"Accept" value:@"application/json"];
        
    return self;
}

- (NSMutableDictionary *)apiDict {
    return [NSMutableDictionary dictionaryWithDictionary: @{@"api_key": kTumblrAPIKey}];
}

+ (NSString *)blogHostname:(NSString *)blogName {
    if ([blogName rangeOfString:@"."].location == NSNotFound){
        blogName = [blogName stringByAppendingString:@".tumblr.com"];
    }
    return blogName;
}

- (Blog *)blogWithName:(NSString *)blogName
{
    return [[[[DataController sharedController] moc] fetchObjectsForEntityName:@"Blog" withPredicate:@"name == %@", blogName, nil] anyObject];
}

- (void)blogInfo:(NSString *)blogName success:(BlogSuccessBlock)successBlock
                                      failure:(FailureBlock)failureBlock {
    
    Blog *existingBlog = [self blogWithName:blogName];
    
    if (!existingBlog){
        NSString *blogURL = [NSString stringWithFormat:@"blog/%@/info", [TumblrAPI blogHostname:blogName]];
        [self getPath:blogURL parameters:[self apiDict] success:^(AFHTTPRequestOperation *operation, id responseObject){
            NSDictionary *blogAttrs = [[responseObject objectForKey:@"response"] objectForKey:@"blog"];
            Blog *blog = [Blog blogForAttrs:blogAttrs];
            NSLog(@"%@", blog);
            
            successBlock(blog);
            
        } failure:failureBlock];
    } else {
        successBlock(existingBlog);
    }
}

- (void)blogPosts:(NSString *)blogName success:(PostsSuccessBlock)successBlock
                                       failure:(FailureBlock)failureBlock {
    
    NSString *postsURL = [NSString stringWithFormat:@"blog/%@/posts", [TumblrAPI blogHostname:blogName]];
    NSMutableDictionary *params = [self apiDict];
    [params setObject:@"audio" forKey:@"type"];
    [params setObject:@"0" forKey:@"offset"];
    
    [self getPath:postsURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {        
        NSDictionary *response = [responseObject objectForKey:@"response"];
        
        NSDictionary *blogData = [response objectForKey:@"blog"];
        Blog *blog = [self blogWithName:[blogData objectForKey:@"name"]];
        if (!blog){
            blog = [Blog blogForAttrs:blogData];
        }
        
        NSArray *postData = [response objectForKey:@"posts"];
        
        NSMutableSet *postIDs = [NSMutableSet set];
        for (NSDictionary *post in postData){
            [postIDs addObject:[post objectForKey:@"id"]];
        }
        
        NSMutableArray *songs = [NSMutableArray new];
        
        // prune existing postIDs from the set of post IDs
        NSPredicate *existingPredicate = [NSPredicate predicateWithFormat:@"blog.name == %@", blogName];
        NSSet *existingPosts = [[[DataController sharedController] moc] fetchObjectsForEntityName:@"Song" withPredicate:existingPredicate];
        for (Song *song in existingPosts){
            if ([postIDs containsObject:song.post_id]){
                [postIDs removeObject:song.post_id];
            } else {
                [songs addObject:song];
            }
        }

        // Only add songs that don't already exist in the database
        for (NSDictionary *post in postData){
            if ([postIDs containsObject:[post objectForKey:@"id"]]){
                Song *song = [Song songForAttrs:post];
                // Spotify ruins the fun :(
                if ([[song valueForKey:@"audio_url"] rangeOfString:@"spotify.com"].location == NSNotFound){
                    song.blog = blog;
                    [songs addObject:song];
                }
            }
        }
                
        // need to associate blogs with songs...
        successBlock(songs);
        
    } failure:failureBlock];
}

@end
