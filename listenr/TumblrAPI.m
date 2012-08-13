//
//  TumblrAPI.m
//  
//
//  Created by Ethan Sherbondy on 8/11/12.
//
//

#import "TumblrAPI.h"
#import "Secrets.h"
#import "AppDelegate.h"
#import "NSManagedObjectContext+Additions.h"
#import "Blog.h"

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



- (void)blogInfo:(NSString *)blogName success:(BlogSuccessBlock)successBlock
                                      failure:(FailureBlock)failureBlock {
    
    NSSet *results = [[AppDelegate moc] fetchObjectsForEntityName:@"Blog" withPredicate:@"name == %@", blogName];
    NSLog(@"%@", results);
    
    if (results.count == 0){
        NSString *blogURL = [NSString stringWithFormat:@"blog/%@/info", [TumblrAPI blogHostname:blogName]];
        [self getPath:blogURL parameters:[self apiDict] success:^(AFHTTPRequestOperation *operation, id responseObject){
            NSDictionary *blogData = [[responseObject objectForKey:@"response"] objectForKey:@"blog"];
            Blog *blog = [Blog blogForData:blogData];
            NSLog(@"%@", blog);
            
            successBlock(blog);
            
        } failure:failureBlock];
    } else {
        successBlock([results anyObject]);
    }
}

@end
