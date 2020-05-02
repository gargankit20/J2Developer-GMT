//
//  AbstractFetcher.m
//  iceapp1
//
//  Created by Yunas Qazi on 12/13/11.
//  Copyright (c) 2011 Style360. All rights reserved.
//

#import "AbstractFetcher.h"
#import "ASyncURLConnection.h"
#import <UIKit/UIKit.h>

@implementation AbstractFetcher
@synthesize container;


- (id) init {
	if (self = [super init]) {
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)fetchWithUrl:(NSURL *)url withMethod:(NSString *)methodType withParams:(NSDictionary *)params completionBlock:(AbstractFetcherCompletion)completed errorBlock:(AbstractFetcherError)errored{

}



- (void)fetchWithUrl:(NSURL *)url completionBlock:(AbstractFetcherCompletion)completed errorBlock:(AbstractFetcherError)errored
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[AsyncURLConnection request:url completeBlock:^(NSData *data) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

		if (data) 
		{
            
			completed(data);
		}
		else
		{
			errored(nil);
		}
		
		
	} errorBlock:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"ERROR in request");
		errored(error);
	
	}];
}


- (void)fetchWithUrl:(NSURL *)url withMethodType:(NSString *)methodType withMethodyBody:(NSDictionary *)params completionBlock:(AbstractFetcherCompletion)completed errorBlock:(AbstractFetcherError)errored{
	
    
    
    
	[AsyncURLConnection postRequest:url withMethodBody:params completeBlock:^(NSData *data) {
        NSString *responseStr  = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"responseStr = %@",responseStr);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (data) 
		{
			completed(data);
		}
		else
		{
			errored(nil);
		}
		
		
	} errorBlock:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		errored(error);
		
	}];
}

//Image Code

- (void)postImageToUrl:(NSURL *)url withMethodType:(NSString *)methodType withMethodyBody:(NSDictionary *)params completionBlock:(AbstractFetcherCompletion)completed errorBlock:(AbstractFetcherError)errored{
	
	[AsyncURLConnection postImageRequest:url withMethodBody:params completeBlock:^(NSData *data) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (data) 
		{
			completed(data);
		}
		else
		{
			errored(nil);
		}
		
		
	} errorBlock:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		errored(error);
		
	}];
}

@end
