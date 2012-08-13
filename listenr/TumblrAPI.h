//
//  TumblrAPI.h
//  
//
//  Created by Ethan Sherbondy on 8/11/12.
//
//

#import <AFNetworking/AFNetworking.h>

@class Blog;

static NSString *const kTumblrAPIBaseURLString = @"http://api.tumblr.com/v2/";

typedef void (^SuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^FailureBlock)(AFHTTPRequestOperation *operation, NSError *error);
typedef void (^BlogSuccessBlock)(Blog *blog);

@interface TumblrAPI : AFHTTPClient

+ (TumblrAPI *)sharedClient;
+ (NSString *)blogHostname:(NSString *)blogName;

- (void)blogInfo:(NSString *)blogName success:(BlogSuccessBlock)successBlock failure:(FailureBlock)failureBlock;

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
