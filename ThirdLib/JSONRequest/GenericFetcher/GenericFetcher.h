

#import "AbstractFetcher.h"
typedef void (^GenericFetcherCompletion)(NSDictionary *dict);
typedef void (^GenericFetcherError)(NSError *error);

typedef enum {
	GET_REQUEST,
    POST_REQUEST
} RequestType;

@interface GenericFetcher : AbstractFetcher

- (void)fetchWithUrl:(NSURL *)url withMethod:(RequestType)requestType withParams:(NSDictionary *)params completionBlock:(GenericFetcherCompletion)completed errorBlock:(GenericFetcherError)errored;

- (void)PostImageToUrl:(NSURL *)url withMethod:(NSString *)methodType withParams:(NSDictionary *)params completionBlock:(GenericFetcherCompletion)completed errorBlock:(GenericFetcherError)errored;

//- (void)makeRequestWithUrl:(NSURL *)url withParams:(NSDictionary *)params completionBlock:(GenericFetcherCompletion)completed errorBlock:(GenericFetcherError)errored;
//- (void)makeRequestWithUrl:(NSURL *)url withMethod:(NSString *)methodType withParams:(NSDictionary *)params completionBlock:(GenericFetcherCompletion)completed errorBlock:(GenericFetcherError)errored;

//- (void)PostImageToUrl:(NSURL *)url withMethod:(NSString *)methodType withParams:(NSDictionary *)params completionBlock:(GenericFetcherCompletion)completed errorBlock:(GenericFetcherError)errored;

@end
