
#import "GenericFetcher.h"
#import "JSON.h"

@implementation GenericFetcher
- (id) init {
	if (self = [super init]) {
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)fetchWithUrl:(NSURL *)url withMethod:(RequestType)requestType withParams:(NSDictionary *)params completionBlock:(GenericFetcherCompletion)completed errorBlock:(GenericFetcherError)errored{
    AbstractFetcher *fetcher = [[[AbstractFetcher alloc]init] autorelease];
    if (requestType == GET_REQUEST) {
        [fetcher fetchWithUrl:url completionBlock:
         ^(NSData *webRawData){
             
             NSObject *result=nil;
             NSString *responseString = [[NSString alloc] initWithData:webRawData encoding:NSStringEncodingConversionAllowLossy];
             SBJsonParser *parser=[[SBJsonParser alloc]init];
             NSLog(@"%@",responseString);
             result =  [parser objectWithString:responseString];
             completed((NSDictionary*)result);
             [responseString release];
         } errorBlock:^(NSError *error){
             errored(error);
         }];
    }else if (requestType == POST_REQUEST){
        NSLog(@"%@",params);
        [fetcher fetchWithUrl:url withMethodType:@"POST" withMethodyBody:params completionBlock:
         ^(NSData *webRawData){
             NSObject *result=nil;
             NSString *responseString = [[NSString alloc] initWithData:webRawData encoding:NSStringEncodingConversionAllowLossy];
             SBJsonParser *parser=[[SBJsonParser alloc]init];
             NSLog(@"%@",responseString);
             result =  [parser objectWithString:responseString];
             completed((NSDictionary*)result);
             [responseString release];
         } errorBlock:^(NSError *error){
             errored(error);
         }];

    
    }
        

}

- (void)PostImageToUrl:(NSURL *)url withMethod:(NSString *)methodType withParams:(NSDictionary *)params completionBlock:(GenericFetcherCompletion)completed errorBlock:(GenericFetcherError)errored{
	
	
	if ([methodType isEqualToString:@"POST"]) {
		
		[super postImageToUrl:url 
			   withMethodType:methodType
			  withMethodyBody:params
			  completionBlock:^(NSData *webRawData){
                  NSObject *result=nil;
                  NSString *responseString = [[NSString alloc] initWithData:webRawData encoding:NSStringEncodingConversionAllowLossy];
                  SBJsonParser *parser=[[SBJsonParser alloc]init];
                  NSLog(@"%@",responseString);
                  result =  [parser objectWithString:responseString];
                  completed((NSDictionary*)result);
                  [responseString release];
			  
              }
				   errorBlock:^(NSError *error){
					   errored(error);
				   }];
		
	}else{//it will be get
		
	}
	
}

//- (void)makeRequestWithUrl:(NSURL *)url withMethod:(NSString *)methodType withParams:(NSDictionary *)params completionBlock:(GenericFetcherCompletion)completed errorBlock:(GenericFetcherError)errored{
//	
//
//	if ([methodType isEqualToString:@"POST"]) {
//		
//		[super fetchWithUrl:url 
//			 withMethodType:methodType
//			withMethodyBody:params
//			completionBlock:^(NSData *webRawData){
//				GenericParser *parser = [[[GenericParser alloc]init] autorelease];
//				[parser getParsedDataFrom:webRawData completionBlock:^(NSDictionary *dict){
//					completed(dict);
//				} 
//				errorBlock:^(NSError *error)
//				 {
//					 errored(error);
//				 }];
//				} 
//			 errorBlock:^(NSError *error){
//				 errored(error);
//			 }];
//	}
//	else {
//		[self makeRequestWithUrl:url withParams:params completionBlock:completed errorBlock:errored];
//	}
//	
//}

//- (void)makeRequestWithUrl:(NSURL *)url withParams:(NSDictionary *)params completionBlock:(GenericFetcherCompletion)completed errorBlock:(GenericFetcherError)errored{
//	
//	NSLog(@" %s, url %@",__PRETTY_FUNCTION__,url);
//	[super fetchWithUrl:url
//		completionBlock:^(NSData *webRawData){
//			//parse data and send back
//			GenericParser *parser = [[[GenericParser alloc]init] autorelease];
//			[parser getParsedDataFrom:webRawData completionBlock:^(NSDictionary *dict){
//				completed(dict);
//			} 
//			errorBlock:^(NSError *error)
//			 {
//				 errored(error);
//			 }];
//		} 
//	 errorBlock:^(NSError *error){
//		 errored(error);
//	 }];
//}




@end
