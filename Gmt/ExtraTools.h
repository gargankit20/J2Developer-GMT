//
//  U.h
//  GetFollower
//
//  Created by lzsm on 14-12-8.
//  Copyright (c) 2014年 lzsm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExtraTools : NSObject{
    
}

//+(NSString*) getCode;  //false
//+(NSString*) wrongMsg;  //real

+ (NSString *)escapeQueryString:(id)string;

+(NSString*) getOneCode:(NSString*)_pa;  //password
+(NSString*) getOnesCode:(NSString*)_k k:(NSString*)_kk; //hmac

+(NSString*) getFkCode:(NSString*)_fc;
+(NSString*) getFkKey:(NSString*)_fk;
+(NSString*) getFkLongKey:(NSString*)_fk;

-(NSString*) getFkMd; //MID
-(NSString*) getFkBoundary;
-(NSString*) getFkCountryCode;
-(NSString*) getCk; //get Cookies
-(NSString*) getCk_27; //get Cookies

//new add 20170410
+(NSString*) forOwnUsage:(NSString*)_kkk;  //reverse back the fucklongkey

@end
