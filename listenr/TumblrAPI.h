//
//  TumblrAPI.h
//  
//
//  Created by Ethan Sherbondy on 8/11/12.
//
//

#import <AFNetworking/AFNetworking.h>

static NSString *const kTumblrAPIBaseURLString = @"http://api.tumblr.com/v2/";

typedef void (^SuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^FailureBlock)(AFHTTPRequestOperation *operation, NSError *error);

@interface TumblrAPI : AFHTTPClient

+ (TumblrAPI *)sharedClient;
+ (NSString *)blogHostname:(NSString *)blogName;

- (void)blogInfo:(NSString *)blogName success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
