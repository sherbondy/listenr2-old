//
//  TumblrAPI.m
//  
//
//  Created by Ethan Sherbondy on 8/11/12.
//
//

#import "TumblrAPI.h"
#import "Secrets.h"


static NSString *const kTumblrAPIBaseURLString = @"http://api.tumblr.com/v2/";

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

- (void)blogInfo:(NSString *)blogName {
    if ([blogName rangeOfString:@"."].location == NSNotFound){
        blogName = [blogName stringByAppendingString:@".tumblr.com"];
    }
    
    NSString *blogURL = [NSString stringWithFormat:@"blog/%@/info", blogName];
    [self getPath:blogURL parameters:[self apiDict] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
