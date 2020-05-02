//
//  AbstractFetcher.h
//  iceapp1
//
//  Created by Yunas Qazi on 12/13/11.
//  Copyright (c) 2011 Style360. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AbstractFetcherCompletion)(NSData *rawWebData);
typedef void (^AbstractFetcherError)(NSError *error);

@interface AbstractFetcher : NSObject



@property (nonatomic,retain) id container;

- (void)fetchWithUrl:(NSURL *)url completionBlock:(AbstractFetcherCompletion)objects errorBlock:(AbstractFetcherError)errorBlock;
- (void)fetchWithUrl:(NSURL *)url withMethodType:(NSString *)methodType withMethodyBody:(NSDictionary *)params completionBlock:(AbstractFetcherCompletion)completed errorBlock:(AbstractFetcherError)errored;

- (void)postImageToUrl:(NSURL *)url withMethodType:(NSString *)methodType withMethodyBody:(NSDictionary *)params completionBlock:(AbstractFetcherCompletion)completed errorBlock:(AbstractFetcherError)errored;
@end
