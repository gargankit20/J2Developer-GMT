//
//  U.m
//  GetFollower
//
//  Created by lzsm on 14-12-8.
//  Copyright (c) 2014年 lzsm. All rights reserved.
//

#import "ExtraTools.h"
#import "Global.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation ExtraTools

- (id) init
{
    if (self = [super init])
    {
        
    }
    return self;
}

-(NSString*) getCk{
    NSString* s_cookie = [[[NSUserDefaults standardUserDefaults] valueForKey:kConstant_Cookie] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString* s_ccode = [NSMutableString string];
    NSMutableString* s_csrftoken = [NSMutableString string];
    NSMutableString* s_ds_user = [NSMutableString string];
    NSMutableString* s_ds_user_id = [NSMutableString string];
    NSMutableString* s_igfl = [NSMutableString string];
    NSMutableString* s_mid = [NSMutableString string];
    NSMutableString* s_sessionid = [NSMutableString string];
    NSMutableString* returnCookie = [NSMutableString string];
    
    if([[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_MID] == nil){
        [s_mid setString:[u getFkMd]];
    }else{
        [s_mid setString:[[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_MID]];
    }
    
    if([[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_Token] == nil){
        [s_csrftoken setString:@"missing"];
    }else{
        [s_csrftoken setString:[[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_Token]];
    }
    
    if([[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_Code] == nil){
        [s_ccode setString:[u getFkCountryCode]];
    }else{
        [s_ccode setString:[[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_Code]];
    }
    
    NSString* ds_user_string = @"ds_user";
    NSRange tokenRange = [s_cookie rangeOfString:ds_user_string];
    NSInteger tokenIdx = tokenRange.location + tokenRange.length;
    
    int tokenStartIdx = (int)tokenIdx + 1;
    int tokenEndIdx = 0;
    bool tokenFoundStartIdx = false;
    bool tokenFoundEndIdx = false;
    
    do{
        if(!tokenFoundStartIdx){
            NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenStartIdx, 1)];
            
            if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                tokenStartIdx++;
            }else{
                tokenFoundStartIdx = true;
                tokenEndIdx = tokenStartIdx;
            }
        }else{
            NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenEndIdx, 1)];
            if(tokenFoundStartIdx){
                if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                    tokenFoundEndIdx = true;
                }else{
                    tokenEndIdx++;
                }
            }
        }
        
    }while(!tokenFoundEndIdx);
    
    [s_ds_user setString:[s_cookie substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
    
    
    //-------------------------------------------------------------------------------------------------
    
    NSString* ds_user_id_string = @"ds_user_id";
    tokenRange = [s_cookie rangeOfString:ds_user_id_string];
    tokenIdx = tokenRange.location + tokenRange.length;
    
    tokenStartIdx = (int)tokenIdx + 1;
    tokenEndIdx = 0;
    tokenFoundStartIdx = false;
    tokenFoundEndIdx = false;
    
    do{
        if(!tokenFoundStartIdx){
            NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenStartIdx, 1)];
            
            if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                tokenStartIdx++;
            }else{
                tokenFoundStartIdx = true;
                tokenEndIdx = tokenStartIdx;
            }
        }else{
            NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenEndIdx, 1)];
            if(tokenFoundStartIdx){
                if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                    tokenFoundEndIdx = true;
                }else{
                    tokenEndIdx++;
                }
            }
        }
        
    }while(!tokenFoundEndIdx);
    
    [s_ds_user_id setString:[s_cookie substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
    
    //-------------------------------------------------------------------------------------------------
    
    NSString* sessionid_string = @"sessionid";
    tokenRange = [s_cookie rangeOfString:sessionid_string];
    tokenIdx = tokenRange.location + tokenRange.length;
    
    tokenStartIdx = (int)tokenIdx + 1;
    tokenEndIdx = 0;
    tokenFoundStartIdx = false;
    tokenFoundEndIdx = false;
    
    do{
        if(!tokenFoundStartIdx){
            NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenStartIdx, 1)];
            
            if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                tokenStartIdx++;
            }else{
                tokenFoundStartIdx = true;
                tokenEndIdx = tokenStartIdx;
            }
        }else{
            NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenEndIdx, 1)];
            if(tokenFoundStartIdx){
                if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                    tokenFoundEndIdx = true;
                }else{
                    tokenEndIdx++;
                }
            }
        }
        
    }while(!tokenFoundEndIdx);
    
    [s_sessionid setString:[s_cookie substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
    
    [s_igfl setString:[NSString stringWithString:s_ds_user]];
    
    //[returnCookie setString:@"ccode="];
    //[returnCookie appendString:s_ccode];
    //[returnCookie appendString:@"; csrftoken="];
    [returnCookie appendString:@"csrftoken="];
    [returnCookie appendString:s_csrftoken];
    [returnCookie appendString:@"; ds_user="];
    [returnCookie appendString:s_ds_user];
    [returnCookie appendString:@"; ds_user_id="];
    [returnCookie appendString:s_ds_user_id];
    [returnCookie appendString:@"; igfl="];
    [returnCookie appendString:s_igfl];
    [returnCookie appendString:@"; mid="];
    [returnCookie appendString:s_mid];
    [returnCookie appendString:@"; sessionid="];
    [returnCookie appendString:s_sessionid];
    //[returnCookie appendString:@";"];
    
    return returnCookie;
}

-(NSString*) getCk_27{
    NSString* s_cookie = [[[NSUserDefaults standardUserDefaults] valueForKey:kConstant_Cookie] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString* s_csrftoken = [NSMutableString string];
    NSMutableString* s_ds_user = [NSMutableString string];
    NSMutableString* s_ds_user_id = [NSMutableString string];
    NSMutableString* s_igfl = [NSMutableString string];
    NSMutableString* s_mid = [NSMutableString string];
    NSMutableString* s_sessionid = [NSMutableString string];
    NSMutableString* s_urlgen = [NSMutableString string];
    NSMutableString* returnCookie = [NSMutableString string];
    
    if([[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_MID] == nil){
        [s_mid setString:[u getFkMd]];
    }else{
        [s_mid setString:[[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_MID]];
    }
    
    if([[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_Token] == nil){
        [s_csrftoken setString:@"missing"];
    }else{
        [s_csrftoken setString:[[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_Token]];
    }
    
    int searchIdx;
    int searchLength;
    bool hasFoundToken;
    int tokenStartIdx;
    int tokenEndIdx;
    int preventLoopForever;
    
    searchIdx = 0;
    searchLength = 0;
    hasFoundToken = false;
    tokenStartIdx = 0;
    tokenEndIdx = 0;
    preventLoopForever = 0;
    
    
    while (searchIdx < (int)[s_cookie length] && !hasFoundToken){
        NSString* ds_user_string = @"ds_user";
        searchLength = (int)[s_cookie length] - searchIdx;
        NSRange searchRange = NSMakeRange(searchIdx, searchLength);
        NSRange tokenRange = [s_cookie rangeOfString:ds_user_string options:0   range:searchRange];
        NSInteger tokenIdx = tokenRange.location + tokenRange.length;
        
        tokenStartIdx = (int)tokenIdx + 1;
        tokenEndIdx = 0;
        bool tokenFoundStartIdx = false;
        bool tokenFoundEndIdx = false;
        
        do{
            if(!tokenFoundStartIdx){
                NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenStartIdx, 1)];
                
                if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                    tokenStartIdx++;
                }else{
                    tokenFoundStartIdx = true;
                    tokenEndIdx = tokenStartIdx;
                }
            }else{
                NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenEndIdx, 1)];
                if(tokenFoundStartIdx){
                    if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                        tokenFoundEndIdx = true;
                    }else{
                        tokenEndIdx++;
                    }
                }
            }
            
            if(tokenEndIdx - tokenStartIdx > 10){
                hasFoundToken = true;
            }
            searchIdx = tokenStartIdx;
            preventLoopForever++;
            
            if(preventLoopForever > 100){
                break;
            }
            
        }while(!tokenFoundEndIdx);
    }
    
    [s_ds_user setString:[s_cookie substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
    
    
    //-------------------------------------------------------------------------------------------------
    
    searchIdx = 0;
    searchLength = 0;
    hasFoundToken = false;
    tokenStartIdx = 0;
    tokenEndIdx = 0;
    preventLoopForever = 0;
    
    
    while (searchIdx < (int)[s_cookie length] && !hasFoundToken){
        NSString* ds_user_id_string = @"ds_user_id";
        searchLength = (int)[s_cookie length] - searchIdx;
        NSRange searchRange = NSMakeRange(searchIdx, searchLength);
        NSRange tokenRange = [s_cookie rangeOfString:ds_user_id_string options:0   range:searchRange];
        NSInteger tokenIdx = tokenRange.location + tokenRange.length;
        
        tokenStartIdx = (int)tokenIdx + 1;
        tokenEndIdx = 0;
        bool tokenFoundStartIdx = false;
        bool tokenFoundEndIdx = false;
        
        do{
            if(!tokenFoundStartIdx){
                NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenStartIdx, 1)];
                
                if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                    tokenStartIdx++;
                }else{
                    tokenFoundStartIdx = true;
                    tokenEndIdx = tokenStartIdx;
                }
            }else{
                NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenEndIdx, 1)];
                if(tokenFoundStartIdx){
                    if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                        tokenFoundEndIdx = true;
                    }else{
                        tokenEndIdx++;
                    }
                }
            }
            
        }while(!tokenFoundEndIdx);
        
        if(tokenEndIdx - tokenStartIdx > 13){
            hasFoundToken = true;
        }
        searchIdx = tokenStartIdx;
        preventLoopForever++;
        
        if(preventLoopForever > 100){
            break;
        }
        
    }
    
    [s_ds_user_id setString:[s_cookie substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
    
    //-------------------------------------------------------------------------------------------------
    
    searchIdx = 0;
    searchLength = 0;
    hasFoundToken = false;
    tokenStartIdx = 0;
    tokenEndIdx = 0;
    preventLoopForever = 0;
    
    while (searchIdx < (int)[s_cookie length] && !hasFoundToken){
        NSString* sessionid_string = @"sessionid";
        searchLength = (int)[s_cookie length] - searchIdx;
        NSRange searchRange = NSMakeRange(searchIdx, searchLength);
        NSRange tokenRange = [s_cookie rangeOfString:sessionid_string options:0   range:searchRange];
        NSInteger tokenIdx = tokenRange.location + tokenRange.length;
        
        tokenStartIdx = (int)tokenIdx + 1;
        tokenEndIdx = 0;
        bool tokenFoundStartIdx = false;
        bool tokenFoundEndIdx = false;
        
        do{
            if(!tokenFoundStartIdx){
                NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenStartIdx, 1)];
                
                if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                    tokenStartIdx++;
                }else{
                    tokenFoundStartIdx = true;
                    tokenEndIdx = tokenStartIdx;
                }
            }else{
                NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenEndIdx, 1)];
                
                if(tokenFoundStartIdx){
                    if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                        tokenFoundEndIdx = true;
                    }else{
                        tokenEndIdx++;
                    }
                }
            }
            
        }while(!tokenFoundEndIdx);
        
        if(tokenEndIdx - tokenStartIdx > 13){
            hasFoundToken = true;
        }
        searchIdx = tokenStartIdx;
        preventLoopForever++;
        
        if(preventLoopForever > 100){
            break;
        }
    }
    
    [s_sessionid setString:[s_cookie substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
    
    [s_igfl setString:[NSString stringWithString:s_ds_user]];
    
    
    //-------------------------------------------------------------------------------------------------------
    
    searchIdx = 0;
    searchLength = 0;
    hasFoundToken = false;
    tokenStartIdx = 0;
    tokenEndIdx = 0;
    preventLoopForever = 0;
    
    while (searchIdx < (int)[s_cookie length] && !hasFoundToken){
        NSString* ds_urlgen_string = @"urlgen";
        searchLength = (int)[s_cookie length] - searchIdx;
        NSRange searchRange = NSMakeRange(searchIdx, searchLength);
        NSRange tokenRange = [s_cookie rangeOfString:ds_urlgen_string options:0   range:searchRange];
        NSInteger tokenIdx = tokenRange.location + tokenRange.length;
        
        tokenStartIdx = (int)tokenIdx + 1;
        tokenEndIdx = 0;
        bool tokenFoundStartIdx = false;
        bool tokenFoundEndIdx = false;
        
        do{
            if(!tokenFoundStartIdx){
                NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenStartIdx, 1)];
                
                if([fuckfuckString isEqualToString:@"="]){
                    tokenStartIdx++;
                }else{
                    tokenFoundStartIdx = true;
                    tokenEndIdx = tokenStartIdx;
                }
            }else{
                NSString* fuckfuckString = [s_cookie substringWithRange:NSMakeRange(tokenEndIdx, 1)];
                if(tokenFoundStartIdx){
                    if([fuckfuckString isEqualToString:@";"]){
                        tokenFoundEndIdx = true;
                    }else{
                        tokenEndIdx++;
                    }
                }
            }
            
        }while(!tokenFoundEndIdx);
        
        if(tokenEndIdx - tokenStartIdx > 12){
            hasFoundToken = true;
        }
        searchIdx = tokenStartIdx;
        preventLoopForever++;
        
        if(preventLoopForever > 100){
            break;
        }
    }
    
    [s_urlgen setString:[s_cookie substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
    //-------------------------------------------------------------------------------------------------
    
    //[returnCookie setString:@"ccode="];
    //[returnCookie appendString:s_ccode];
    //[returnCookie appendString:@"; csrftoken="];
    [returnCookie appendString:@"csrftoken="];
    [returnCookie appendString:s_csrftoken];
    [returnCookie appendString:@"; ds_user_id="];
    [returnCookie appendString:s_ds_user_id];
    [returnCookie appendString:@"; rur="];
    [returnCookie appendString:@"ASH"];
    [returnCookie appendString:@"; urlgen="];
    [returnCookie appendString:s_urlgen];
    [returnCookie appendString:@"; sessionid="];
    [returnCookie appendString:s_sessionid];
    [returnCookie appendString:@"; igfl="];
    [returnCookie appendString:s_igfl];
    [returnCookie appendString:@"; is_starred_enabled="];
    [returnCookie appendString:@"yes"];
    [returnCookie appendString:@"; ds_user="];
    [returnCookie appendString:s_ds_user];
    [returnCookie appendString:@"; mid="];
    [returnCookie appendString:s_mid];
    
    //[returnCookie appendString:@";"];
    
    return returnCookie;
}

-(NSString*) getFkCountryCode{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    return countryCode;
}

-(NSString*) getFkMd{
    NSMutableString* primaryCookie = [[NSUserDefaults standardUserDefaults] objectForKey:kConstant_MID];
    if (primaryCookie == nil) {
        primaryCookie = [NSMutableString stringWithFormat:@"VH1%@AAAAAG%i%@",[self generateCoookie:2],arc4random_uniform(8)+1,[self generateCoookie:16]];
        [[NSUserDefaults standardUserDefaults] setObject:primaryCookie forKey:kConstant_MID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return primaryCookie;
}

-(NSString*)generateCoookie:(int)lenght{
    NSString *alphabet  = @"ABCDEFGHIJKLMNOPQRSTUVWXZY0123456789abcdefghijklmnopqrstuvwxzy";
    NSMutableString *s = [NSMutableString stringWithCapacity:lenght];
    for (NSUInteger i = 0U; i < lenght; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
        
    }
    return s;
}


-(NSString*) getFkBoundary{
    NSMutableString* primaryCookie = [[NSUserDefaults standardUserDefaults] objectForKey:kConstant_Boundary];
    if (primaryCookie == nil) {
        primaryCookie = [NSMutableString stringWithString:[self random_dev]];
        [[NSUserDefaults standardUserDefaults] setObject:primaryCookie forKey:kConstant_Boundary];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return primaryCookie;
}

-(NSString*) random_dev{
    NSMutableString* ranDeviceString = [NSMutableString string];
    int fuckRan[8];
    fuckRan[0] = arc4random() % 65536;
    fuckRan[1] = arc4random() % 65536;
    fuckRan[2] = arc4random() % 65536;
    fuckRan[3] = arc4random() % 4096;
    fuckRan[4] = arc4random() % 16384;
    fuckRan[5] = arc4random() % 65536;
    fuckRan[6] = arc4random() % 65536;
    fuckRan[7] = arc4random() % 65536;
    
    fuckRan[3] += 16834;
    fuckRan[4] += 32768;
    
    
    NSString* fuckString[8];
    for(int i = 0 ; i < 8 ; i++){
        fuckString[i] = [self ran_hex:fuckRan[i]];
    }
    
    [ranDeviceString setString:@""];
    [ranDeviceString appendString:fuckString[0]];
    [ranDeviceString appendString:fuckString[1]];
    [ranDeviceString appendString:@"-"];
    [ranDeviceString appendString:fuckString[2]];
    [ranDeviceString appendString:@"-"];
    [ranDeviceString appendString:fuckString[3]];
    [ranDeviceString appendString:@"-"];
    [ranDeviceString appendString:fuckString[4]];
    [ranDeviceString appendString:@"-"];
    [ranDeviceString appendString:fuckString[5]];
    [ranDeviceString appendString:fuckString[6]];
    [ranDeviceString appendString:fuckString[7]];
    
    return ranDeviceString;
}

-(NSString*) ran_hex:(int)_number{
    NSString* dexString = [NSString stringWithFormat:@"%i", _number];
    NSMutableString* hexString = [NSMutableString string];
    
    if(_number < 16){
        [hexString setString:@"000"];
    }else if(_number < 256){
        [hexString setString:@"00"];
    }else if(_number < 4096){
        [hexString setString:@"0"];
    }else{
        [hexString setString:@""];
    }
    
    [hexString appendString:[NSString stringWithFormat:@"%lX",
                             (unsigned long)[dexString integerValue]]];
    
    return hexString;
}

+ (NSString *)escapeQueryString:(id)string {
    
    // convert to string if not.
    if (![string isKindOfClass:[NSString class]]) {
        string = [NSString stringWithFormat:@"%@", string];
    }
    
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    
    CFStringRef escaped =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)string,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
    return CFBridgingRelease(escaped);
}

+(NSString*) getFkKey:(NSString*)_fk{
    
    NSString* ss[3];
    NSRange rag = NSMakeRange(0,8);
    ss[0] = [_fk substringWithRange:rag];
    NSRange rag1 = NSMakeRange(8,8);
    ss[1] = [_fk substringWithRange:rag1];
    NSRange rag2 = NSMakeRange(16,16);
    ss[2] = [_fk substringWithRange:rag2];
    
    NSMutableString* keyGen = [NSMutableString string];
    [keyGen setString:@""];
    
    // [keyGen setString:@"41c23fee"];
    [keyGen setString:ss[0]];
    
    for(int i = 0 ; i < [keyGen length] ; i++){
        unichar c = [keyGen characterAtIndex:i];
        c--;
        [keyGen replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
    }
    
    NSMutableString *rr2 = [NSMutableString string];
    [rr2 setString:@""];
    NSInteger c = [keyGen length];
    while (c > 0) {
        c--;
        NSRange ssr = NSMakeRange(c, 1);
        [rr2 appendString:[keyGen substringWithRange:ssr]];
    }
    
    [keyGen setString:rr2];
    [keyGen appendString:ss[1]];
    
    for(int i = 0 ; i < [keyGen length] ; i++){
        unichar c = [keyGen characterAtIndex:i];
        c--;
        [keyGen replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
    }
    
    
    [keyGen appendString:ss[2]];
    
    
    return keyGen;
    
}

+(NSString*) getFkLongKey:(NSString*)_fk{
    
    NSString* ss[3];
    NSRange rag = NSMakeRange(0,16);
    ss[0] = [_fk substringWithRange:rag];
    NSRange rag1 = NSMakeRange(16,16);
    ss[1] = [_fk substringWithRange:rag1];
    NSRange rag2 = NSMakeRange(32,32);
    ss[2] = [_fk substringWithRange:rag2];
    
    
    NSMutableString* keyGen = [NSMutableString string];
    [keyGen setString:@""];
    
    // [keyGen setString:@"41c23fee"];
    [keyGen setString:ss[0]];
    
    for(int i = 0 ; i < [keyGen length] ; i++){
        unichar c = [keyGen characterAtIndex:i];
        c--;
        [keyGen replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
    }
    
    
    NSMutableString *rr2 = [NSMutableString string];
    [rr2 setString:@""];
    NSInteger c = [keyGen length];
    while (c > 0) {
        c--;
        NSRange ssr = NSMakeRange(c, 1);
        [rr2 appendString:[keyGen substringWithRange:ssr]];
    }
    
    
    [keyGen setString:rr2];
    [keyGen appendString:ss[1]];
    
    for(int i = 0 ; i < [keyGen length] ; i++){
        unichar c = [keyGen characterAtIndex:i];
        c--;
        [keyGen replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
    }
    
    [keyGen appendString:ss[2]];
    for(int i = 0 ; i < [keyGen length] ; i++){
        unichar c = [keyGen characterAtIndex:i];
        c--;
        [keyGen replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
    }
    
    return keyGen;
    
}

//new add 20170410
+(NSString*) forOwnUsage:(NSString*)_kkk{
    
    NSString* ss[3];
    NSRange rag = NSMakeRange(0,16);
    ss[0] = [_kkk substringWithRange:rag];
    NSRange rag1 = NSMakeRange(16,16);
    ss[1] = [_kkk substringWithRange:rag1];
    NSRange rag2 = NSMakeRange(32,32);
    ss[2] = [_kkk substringWithRange:rag2];
    
    NSMutableString* keyGen = [NSMutableString string];
    [keyGen setString:@""];
    
    // [keyGen setString:@"41c23fee"];
    [keyGen setString:ss[0]];
    
    for(int i = 0 ; i < [keyGen length] ; i++){
        unichar c = [keyGen characterAtIndex:i];
        c++;
        [keyGen replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
    }
    
    NSMutableString *rr2 = [NSMutableString string];
    [rr2 setString:@""];
    NSInteger c = [keyGen length];
    while (c > 0) {
        c--;
        NSRange ssr = NSMakeRange(c, 1);
        [rr2 appendString:[keyGen substringWithRange:ssr]];
    }
    
    [keyGen setString:rr2];
    [keyGen appendString:ss[1]];
    
    for(int i = 0 ; i < [keyGen length] ; i++){
        unichar c = [keyGen characterAtIndex:i];
        c++;
        [keyGen replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
    }

    [keyGen appendString:ss[2]];
    for(int i = 0 ; i < [keyGen length] ; i++){
        unichar c = [keyGen characterAtIndex:i];
        c++;
        [keyGen replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
    }
 
    return keyGen;
    
}


- (NSString *)escapeQueryString:(id)string {
    
    // convert to string if not.
    if (![string isKindOfClass:[NSString class]]) {
        string = [NSString stringWithFormat:@"%@", string];
    }
    
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    
    CFStringRef escaped =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)string,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
    return CFBridgingRelease(escaped);
}

-(NSString*) ss1616:(NSString *)clear{
    const char *s=[clear cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

NSData *mfkda(NSString *k, NSString *d)
{
    const char *cK  = [k cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cD = [d cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cK, strlen(cK), cD, strlen(cD), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

+(NSString*) getOnesCode:(NSString*)_k k:(NSString*)_kk{
    unsigned char *digest = (unsigned char *)[mfkda(_k, _kk) bytes];
    
    // Convert the bytes to their hex representation
    NSMutableString *mfkdaStr = [NSMutableString string];
    [mfkdaStr setString:@""];
    for(int i = 0 ; i < CC_SHA256_DIGEST_LENGTH ; i++){
        [mfkdaStr appendFormat:@"%02x", digest[i]];
    }
    
    return mfkdaStr;
    
}


+(NSString*) getFkCode:(NSString*)_fc{
    NSString* ss[3];
    NSRange rag = NSMakeRange(0,8);
    ss[0] = [_fc substringWithRange:rag];
    NSRange rag1 = NSMakeRange(8,8);
    ss[1] = [_fc substringWithRange:rag1];
    NSRange rag2 = NSMakeRange(16,16);
    ss[2] = [_fc substringWithRange:rag2];
    
    
    NSMutableString* g = [NSMutableString string];
    [g setString:ss[0]];
    
    NSMutableString *rr = [NSMutableString string];
    [rr setString:@""];
    NSInteger c = [g length];
    while (c > 0) {
        c--;
        NSRange ssr = NSMakeRange(c, 1);
        [rr appendString:[g substringWithRange:ssr]];
    }
    
    [g setString:rr];
    [g appendString:ss[1]];
    
    int t = 15;
    for(int i = 0 ; i < t ; i++){
        unichar c = [g characterAtIndex:i];
        c++;
        [g replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
    }
    
    NSMutableString *rr2 = [NSMutableString string];
    NSInteger cc = [g length];
    while (cc > 0) {
        cc--;
        NSRange ssr = NSMakeRange(cc, 1);
        [rr2 appendString:[g substringWithRange:ssr]];
    }
    
    [g setString:rr2];
    
    [g appendString:ss[2]];
    
    for(int i = 0 ; i < t ; i++){
        unichar c = [g characterAtIndex:i];
        c -= i%5;
        [g replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
    }
    
    
    return g;
    
}

+(NSString*) getOneCode:(NSString*)_pa{
    NSMutableString *rr = [NSMutableString string];
    NSMutableString *rt = [NSMutableString string];
    [rr setString:_pa];
    [rt setString:@""];
    
    for(int i = 0 ; i < [_pa length] ; i++){
        NSRange rag = NSMakeRange(i,1);
        NSString* c = [rr substringWithRange:rag];
        NSString* cc;
        
        if([c isEqualToString:@"A"]){
            cc = @"0";
        }
        if([c isEqualToString:@"B"]){
            cc = @"j";
        }
        if([c isEqualToString:@"C"]){
            cc = @"G";
        }
        if([c isEqualToString:@"D"]){
            cc = @"s";
        }
        if([c isEqualToString:@"E"]){
            cc = @"X";
        }
        if([c isEqualToString:@"F"]){
            cc = @"6";
        }
        if([c isEqualToString:@"G"]){
            cc = @"I";
        }
        if([c isEqualToString:@"H"]){
            cc = @"y";
        }
        if([c isEqualToString:@"I"]){
            cc = @"Y";
        }
        if([c isEqualToString:@"J"]){
            cc = @"B";
        }
        if([c isEqualToString:@"K"]){
            cc = @"1";
        }
        if([c isEqualToString:@"L"]){
            cc = @"R";
        }
        if([c isEqualToString:@"M"]){
            cc = @"p";
        }
        if([c isEqualToString:@"N"]){
            cc = @"g";
        }
        if([c isEqualToString:@"O"]){
            cc = @"w";
        }
        if([c isEqualToString:@"P"]){
            cc = @"N";
        }
        if([c isEqualToString:@"Q"]){
            cc = @"z";
        }
        if([c isEqualToString:@"R"]){
            cc = @"f";
        }
        if([c isEqualToString:@"S"]){
            cc = @"Z";
        }
        if([c isEqualToString:@"T"]){
            cc = @"7";
        }
        if([c isEqualToString:@"U"]){
            cc = @"9";
        }
        if([c isEqualToString:@"V"]){
            cc = @"l";
        }
        if([c isEqualToString:@"W"]){
            cc = @"H";
        }
        if([c isEqualToString:@"X"]){
            cc = @"Q";
        }
        if([c isEqualToString:@"Y"]){
            cc = @"b";
        }
        if([c isEqualToString:@"Z"]){
            cc = @"C";
        }
        
        
        if([c isEqualToString:@"a"]){
            cc = @"q";
        }
        if([c isEqualToString:@"b"]){
            cc = @"S";
        }
        if([c isEqualToString:@"c"]){
            cc = @"4";
        }
        if([c isEqualToString:@"d"]){
            cc = @"L";
        }
        if([c isEqualToString:@"e"]){
            cc = @"P";
        }
        if([c isEqualToString:@"f"]){
            cc = @"a";
        }
        if([c isEqualToString:@"g"]){
            cc = @"k";
        }
        if([c isEqualToString:@"h"]){
            cc = @"F";
        }
        if([c isEqualToString:@"i"]){
            cc = @"m";
        }
        if([c isEqualToString:@"j"]){
            cc = @"V";
        }
        if([c isEqualToString:@"k"]){
            cc = @"u";
        }
        if([c isEqualToString:@"l"]){
            cc = @"K";
        }
        if([c isEqualToString:@"m"]){
            cc = @"o";
        }
        if([c isEqualToString:@"n"]){
            cc = @"i";
        }
        if([c isEqualToString:@"o"]){
            cc = @"O";
        }
        if([c isEqualToString:@"p"]){
            cc = @"v";
        }
        if([c isEqualToString:@"q"]){
            cc = @"8";
        }
        if([c isEqualToString:@"r"]){
            cc = @"T";
        }
        if([c isEqualToString:@"s"]){
            cc = @"n";
        }
        if([c isEqualToString:@"t"]){
            cc = @"U";
        }
        if([c isEqualToString:@"u"]){
            cc = @"5";
        }
        if([c isEqualToString:@"v"]){
            cc = @"e";
        }
        if([c isEqualToString:@"w"]){
            cc = @"r";
        }
        if([c isEqualToString:@"x"]){
            cc = @"M";
        }
        if([c isEqualToString:@"y"]){
            cc = @"2";
        }
        if([c isEqualToString:@"z"]){
            cc = @"E";
        }
        
        
        if([c isEqualToString:@"0"]){
            cc = @"t";
        }
        if([c isEqualToString:@"1"]){
            cc = @"W";
        }
        if([c isEqualToString:@"2"]){
            cc = @"c";
        }
        if([c isEqualToString:@"3"]){
            cc = @"h";
        }
        if([c isEqualToString:@"4"]){
            cc = @"3";
        }
        if([c isEqualToString:@"5"]){
            cc = @"x";
        }
        if([c isEqualToString:@"6"]){
            cc = @"A";
        }
        if([c isEqualToString:@"7"]){
            cc = @"J";
        }
        if([c isEqualToString:@"8"]){
            cc = @"d";
        }
        if([c isEqualToString:@"9"]){
            cc = @"D";
        }
        
        if([c isEqualToString:@"-"]){
            cc = @"/";
        }
        if([c isEqualToString:@"?"]){
            cc = @":";
        }
        if([c isEqualToString:@"!"]){
            cc = @"?";
        }
        if([c isEqualToString:@"="]){
            cc = @"=";
        }
        if([c isEqualToString:@"&"]){
            cc = @"&";
        }
        
        if(cc == nil){
            cc = c;
        }
        
        [rt appendString:cc];
    }
    
    return rt;
}


@end
