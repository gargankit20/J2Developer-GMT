#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^completeBlock_t)(NSData *data);
typedef void (^errorBlock_t)(NSError *error);

@interface AsyncURLConnection : NSURLConnection
{
	NSMutableData *data_;
	completeBlock_t completeBlock_;
	errorBlock_t errorBlock_;
    
    int _imgTag;
}
@property (nonatomic,assign)int imageTag;
+ (id)postRequest:(NSURL *)requestUrl withMethodBody:(NSDictionary *)params completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;

+ (id)request:(NSURL *)requestUrl completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
+ (id)request:(NSURL *)requestUrl  withTag:(int)tag completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
- (id)initWithRequest:(NSURL *)requestUrl completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;

+ (id)postImageRequest:(NSURL *)requestUrl withMethodBody:(NSDictionary *)params completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;

@end
