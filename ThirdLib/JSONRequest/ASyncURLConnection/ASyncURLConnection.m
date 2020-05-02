#import "ASyncURLConnection.h"
#import "JSON.h"
@implementation AsyncURLConnection

//NEW CODE
@synthesize imageTag=_imgTag;
- (id)initWithPostRequest:(NSURL *)requestUrl withMethodBody:(NSDictionary *)params completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{

	SBJsonWriter *p = [[[SBJsonWriter alloc] init] autorelease];
	NSString *jsonStr = [p stringWithObject:params];
    jsonStr = [NSString stringWithFormat:@"data=%@",jsonStr];
    NSLog(@"jsonStr=%@",jsonStr);
    

	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc]init]autorelease];
	[request setURL:requestUrl];
	[request setHTTPMethod:@"POST"];
    [request setHTTPBody:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue: @"*" forHTTPHeaderField: @"Accept-Language"];
    
	AsyncURLConnection *conn = [[AsyncURLConnection alloc] initWithRequest:request delegate:self];
	if (conn)
	{
		data_ = [[NSMutableData alloc] init];
		
		completeBlock_ = [completeBlock copy];
		errorBlock_ = [errorBlock copy];
		self = conn;
		[self start];

	}

	return self;
}


+ (id)postRequest:(NSURL *)requestUrl withMethodBody:(NSDictionary *)params completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[[self alloc] initWithPostRequest:requestUrl withMethodBody:params completeBlock:completeBlock errorBlock:errorBlock]autorelease];
}


//Image
- (id)initWithImagePostRequest:(NSURL *)requestUrl withMethodBody:(NSDictionary *)params completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	

	UIImage *img = [params objectForKey:@"image"];
    //size will be doubled when applied like for 320 it will be 640
    img = [img imageWithImage:img scaledToSize:CGSizeMake(320, 320)];
    
	NSData * imgData = UIImageJPEGRepresentation(img, 1.0);
    
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc]init]autorelease];
	[request setURL:requestUrl];
	[request setHTTPMethod:@"POST"];
	NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];

	//	
	NSMutableData *body = [NSMutableData data];
    
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", @"abc.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imgData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:body];
	

	
	AsyncURLConnection *conn = [[AsyncURLConnection alloc] initWithRequest:request delegate:self];
	if (conn)
	{
		data_ = [[NSMutableData alloc] init];
		
		completeBlock_ = [completeBlock copy];
		errorBlock_ = [errorBlock copy];
		self = conn;
		[self start];
		
	}
	
	return self;
}


+ (id)postImageRequest:(NSURL *)requestUrl withMethodBody:(NSDictionary *)params completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[[self alloc] initWithImagePostRequest:requestUrl withMethodBody:params completeBlock:completeBlock errorBlock:errorBlock]autorelease];
}


+ (id)request:(NSURL *)requestUrl completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[[self alloc] initWithRequest:requestUrl
							completeBlock:completeBlock errorBlock:errorBlock] autorelease];
}

+ (id)request:(NSURL *)requestUrl  withTag:(int)tag completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[[self alloc] initWithRequest:requestUrl withImageTag:(int)tag
							completeBlock:completeBlock errorBlock:errorBlock] autorelease];
}




- (id)initWithRequest:(NSURL *)requestUrl completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    [request setTimeoutInterval:10.0];
	if ((self = [super
			initWithRequest:request delegate:self startImmediately:NO])) {
		data_ = [[NSMutableData alloc] init];
        _imgTag=-1;
		completeBlock_ = [completeBlock copy];
		errorBlock_ = [errorBlock copy];
		
		[self start];
	}

	return self;
}
- (id)initWithRequest:(NSURL *)requestUrl withImageTag:(int)tag completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    [request setTimeoutInterval:10.0];
	if ((self = [super
                 initWithRequest:request delegate:self startImmediately:NO])) {
		data_ = [[NSMutableData alloc] init];
        self.imageTag=tag;
		completeBlock_ = [completeBlock copy];
		errorBlock_ = [errorBlock copy];
		
		[self start];
	}
    
	return self;
}




- (void)dealloc
{
	[data_ release];

	[completeBlock_ release];
	[errorBlock_ release];
	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

	[data_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[data_ appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    completeBlock_(data_);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	errorBlock_(error);
}

@end
