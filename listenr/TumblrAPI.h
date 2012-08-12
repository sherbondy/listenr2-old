//
//  TumblrAPI.h
//  
//
//  Created by Ethan Sherbondy on 8/11/12.
//
//

#import <AFNetworking/AFNetworking.h>

@interface TumblrAPI : AFHTTPClient

+ (TumblrAPI *)sharedClient;
- (void)blogInfo:(NSString *)blogName;

@end
