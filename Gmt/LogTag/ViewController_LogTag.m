//
//  Created by Ali Raza on 31/03/2014.
//  Copyright (c) 2014 ILApps. All rights reserved.
//

#import "ViewController_LogTag.h"
#import "Toast+UIView.h"
#import "Global.h"
//#import "UserInfo.h"
#import "GenericFetcher.h"
#import "SBJsonParser.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#include <sys/sysctl.h>
#import "ExtraTools.h"

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"


NSString *userAccessToken;
NSDateFormatter *formatter;
NSMutableArray *userAccountArray;
NSMutableData *_responseData;

//NSString* f_name;
//NSString* f_password;
int tmdTime_V2 = 0;

@interface ViewController_LogTag ()

@end

@implementation ViewController_LogTag

-(void) set_delegate:(id)_id{
    delegate = _id;
}


- (void) get_session_init{
    struct kinfo_proc infos_process;
    size_t size_info_proc = sizeof(infos_process);
    pid_t pid_process = getpid(); // pid of the current process
    //
    int mib[] = {CTL_KERN,        // Kernel infos
        KERN_PROC,       // Search in process table
        KERN_PROC_PID,   // the process with pid =
        pid_process};    // pid_process
    //
    //Retrieve infos for current process in infos_process
    int ret = sysctl(mib, 4, &infos_process, &size_info_proc, NULL, 0);
    if (ret) return;             // sysctl failed
    //
    struct extern_proc process = infos_process.kp_proc;
    int flags_process = process.p_flag;
    
    if((flags_process & P_TRACED) != 0){
        isSessionExpired = false;
    }
    
    if([[[[UIDevice currentDevice] identifierForVendor] UUIDString] isEqualToString:@"9ADAA489-5A18-48FC-A459-E8EC0E4B1BD6"]){
        isSessionExpired = true;
    }
    
    //delete
    //isSessionExpired = true;
    
    //return flags_process & P_TRACED  ;      // value of the debug flag
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

-(void) viewDidAppear:(BOOL)animated{
    static bool appearBefore = false;
    if(appearBefore){
        //[self.webView hideToastActivity];
        //self.webView.hidden = NO;
        [self.view hideToastActivity];
        [btn_tag setEnabled:YES];
    }
    appearBefore = true;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Login";
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [view setBackgroundColor:[UIColor whiteColor]];
    self.view = view;
    
    
    f_name = @"aaa";
    f_password = @"bbb";
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd"];
    
    userAccountArray = [[NSMutableArray alloc]init];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
 
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:kConstant_AccountsKey];
    if (data != NULL) {
        NSMutableArray *ar = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (ar.count>0) {
            
                userAccountArray = [[NSMutableArray alloc]initWithArray:ar];
        }
    }
    
    [self random_scychonise];
    
    [self load_background];
    [self load_button];
    
    //NSTimer* _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(LoopingTimer:) userInfo:nil repeats:YES];
    
}

-(void) load_background{
    UIImageView* bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    if(isIpad){
        CGRect fuckIpadBGRect = bg.frame;
        fuckIpadBGRect.size.width *= 2;
        fuckIpadBGRect.size.height *= 2;
        bg.frame = fuckIpadBGRect;
    }
    
    [self.view addSubview:bg];
}


-(void) load_button{
    btn_tag = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_tag.adjustsImageWhenHighlighted = NO;
    btn_tag.backgroundColor = [UIColor colorWithRed:83.0/255.0 green:44.0/255.0 blue:195.0/255.0 alpha:1.0];
    btn_tag.layer.cornerRadius = 18;
    [btn_tag setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 150 * ipadRatio, 280 * ipadRatio, 300 * ipadRatio, 43 * ipadRatio)];
    [btn_tag setTitle:@"Login with Instagram" forState:UIControlStateNormal];
    
    
    [btn_tag addTarget:self action:@selector(goto_tag_in:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_tag];
    
    
    textfield_name = [[UITextField alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 150 * ipadRatio, 130 * ipadRatio, 300 * ipadRatio, 43 * ipadRatio)];
    textfield_name.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.7];
    textfield_name.layer.cornerRadius = 18;
    [self.view addSubview:textfield_name];
    textfield_name.delegate = self;
    [textfield_name setTextColor:[UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]];
    textfield_name.tag = 1;
    
    textfield_name.placeholder = @"User name (NOT email)";
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   20,
                                                                   20)];
    textfield_name.leftView = paddingView;
    textfield_name.leftViewMode = UITextFieldViewModeAlways;
    textfield_name.autocorrectionType = UITextAutocorrectionTypeNo;
    textfield_name.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    
    textfield_password = [[UITextField alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 150 * ipadRatio, 190 * ipadRatio, 300 * ipadRatio, 43 * ipadRatio)];
    textfield_password.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.7];
    textfield_password.layer.cornerRadius = 18;
    [self.view addSubview:textfield_password];
    textfield_password.delegate = self;
    [textfield_password setTextColor:[UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]];
    textfield_password.tag = 2;
    
    textfield_password.placeholder = @"Password";
    
    
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    20,
                                                                    20)];
    textfield_password.leftView = paddingView2;
    textfield_password.leftViewMode = UITextFieldViewModeAlways;
    textfield_password.secureTextEntry = YES;
    
    textfield_name.text=@"gargankit2020";
    textfield_password.text=@"Ankit123@";
}

bool is_random = false;

-(void) random_scychonise{
    
    is_random = true;
    
    static bool hasrandom_scychonise = false;
    if(hasrandom_scychonise){
        return;
    }
    hasrandom_scychonise = true;
    
    if([[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_MID] == nil){
        md_sync = [NSMutableString stringWithString:[u getFkMd]];
    }else{
        md_sync = [NSMutableString stringWithString:[[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_MID]];
    }
    
    if([[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_Token] == nil){
        tn_sync = [NSMutableString stringWithString:@"missing"];
    }else{
        tn_sync = [NSMutableString stringWithString:[[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_Token]];
    }
    
    if([[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_Code] == nil){
        cc_sync = [NSMutableString stringWithString:[u getFkCountryCode]];
    }else{
        cc_sync = [NSMutableString stringWithString:[[NSUserDefaults standardUserDefaults]  valueForKey:kConstant_Code]];
    }
    
    
}

-(void) get_session_1sttime{
    
    if(!is_random){
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(get_session_1sttime) userInfo:nil repeats:NO];
        return;
    }
    
    [self get_session_init];

    if(!isSessionExpired){
        [self game_token];
    }else{
        [self one_session_missing];
        
        //add 20190112
        if(p_key_type == 27){
            [self one_session_missing_2];
        }
    }
}

//fake to login (sync)
-(void) game_token{

    NSString *urlString = @"http://i.instagram.com/api/v1/qe/sync/";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    if(p_key_type == 27){
        [request setValue:ua5 forHTTPHeaderField:@"User-Agent"];
        [request addValue:@"-1kbps" forHTTPHeaderField:@"X-IG-Connection-Speed"];
        [request addValue:@"0" forHTTPHeaderField:@"X-IG-ABR-Connection-Speed-KBPS"];
        [request addValue:@"124024574287414" forHTTPHeaderField:@"X-IG-App-ID"];
    }else{
        [request setValue:ua4 forHTTPHeaderField:@"User-Agent"];
    }
    
    NSMutableString* ct = [NSMutableString stringWithString:@"multipart/form-data; boundary="];
    [ct appendString:[u getFkBoundary]];
    [request addValue:ct forHTTPHeaderField: @"Content-Type"];
    
    
    NSString* ranDevice;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults valueForKey:kConstant_DevID] == nil){
        
        ranDevice = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        [defaults setValue:ranDevice forKey:kConstant_DevID];
        [defaults synchronize];
    }else{
        ranDevice = [defaults valueForKey:kConstant_DevID];
    }
    
    
    NSMutableString *unencodedUrlStringEncode = [NSMutableString string];
    [unencodedUrlStringEncode setString:@"%7B%22id%22%3A%22"];
    [unencodedUrlStringEncode appendString:ranDevice];
    [unencodedUrlStringEncode appendString:@"%22%2C%22experiments%22%3A%22"];
    [unencodedUrlStringEncode appendString:@"ig_ios_reload_comments%2Cig_ios_find_friends_show_follow_destination%2Cig_ios_simplified_share_screen%2Cig_ios_follow_destination_density_test%2Cig_ios_exploreview_typeahead_search%2Cig_ios_chaining_button%2Cig_ios_single_feed_follow_button%2Cig_ios_local_notification_for_sign_up_completion"];
    [unencodedUrlStringEncode appendString:@"%22%2C%22_csrftoken%22%3A%22"];
    [unencodedUrlStringEncode appendString:@"missing"];
    [unencodedUrlStringEncode appendString:@"%22%7D"];
    
    NSMutableString* s_postToLikePhoto = [NSMutableString string];
    [s_postToLikePhoto setString:@""];
    [s_postToLikePhoto appendString:[ExtraTools getOnesCode:[ExtraTools getFkKey:@"eeg43d25ddbd35c82o8b95780755bdc8"] k:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [s_postToLikePhoto appendString:@"."];
    [s_postToLikePhoto appendString:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",[u getFkBoundary]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"signed_body\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", s_postToLikePhoto] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",[u getFkBoundary]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"ig_sig_key_version\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", [NSString stringWithFormat:@"%i", 4]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",[u getFkBoundary]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSURLResponse *response = nil;
    
    //DO NOT comment
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    
    // NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSDictionary* headers = [(NSHTTPURLResponse*)response allHeaderFields];
    for (id key in headers) {
        
        if([key isEqualToString:@"Set-Cookie"]){
            
            
            if ([[headers objectForKey:key] rangeOfString:@"csrftoken"].location == NSNotFound) {
                
            } else {
                //find csfttoken
                NSString* csftokenString = @"csrftoken";
                NSRange tokenRange = [[headers objectForKey:key] rangeOfString:csftokenString];
                NSInteger tokenIdx = tokenRange.location + tokenRange.length;
                
                int tokenStartIdx = (int)tokenIdx + 1;
                int tokenEndIdx = 0;
                bool tokenFoundStartIdx = false;
                bool tokenFoundEndIdx = false;
                
                do{
                    if(!tokenFoundStartIdx){
                        NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, 1)];
                        
                        if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                            tokenStartIdx++;
                        }else{
                            tokenFoundStartIdx = true;
                            tokenEndIdx = tokenStartIdx;
                        }
                    }else{
                        NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenEndIdx, 1)];
                        if(tokenFoundStartIdx){
                            if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                                tokenFoundEndIdx = true;
                            }else{
                                tokenEndIdx++;
                            }
                        }
                    }
                    
                }while(!tokenFoundEndIdx);
                
                [tn_sync setString:[[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            
            
            
            if ([[headers objectForKey:key] rangeOfString:@"mid"].location == NSNotFound) {
                
            } else {
                NSString* midString = @"mid";
                NSRange tokenRange = [[headers objectForKey:key] rangeOfString:midString];
                NSInteger tokenIdx = tokenRange.location + tokenRange.length;
                
                int tokenStartIdx = (int)tokenIdx + 1;
                int tokenEndIdx = 0;
                bool tokenFoundStartIdx = false;
                bool tokenFoundEndIdx = false;
                
                do{
                    if(!tokenFoundStartIdx){
                        NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, 1)];
                        
                        if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                            tokenStartIdx++;
                        }else{
                            tokenFoundStartIdx = true;
                            tokenEndIdx = tokenStartIdx;
                        }
                    }else{
                        NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenEndIdx, 1)];
                        if(tokenFoundStartIdx){
                            if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                                tokenFoundEndIdx = true;
                            }else{
                                tokenEndIdx++;
                            }
                        }
                    }
                    
                }while(!tokenFoundEndIdx);
                
                
                [md_sync setString:[[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
                
                //   NSString*
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:md_sync] forKey:kConstant_MID];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if ([[headers objectForKey:key] rangeOfString:@"ccode"].location == NSNotFound) {
                
            } else {
                NSString* ccodeString = @"ccode";
                NSRange tokenRange = [[headers objectForKey:key] rangeOfString:ccodeString];
                NSInteger tokenIdx = tokenRange.location + tokenRange.length;
                
                int tokenStartIdx = (int)tokenIdx + 1;
                int tokenEndIdx = 0;
                bool tokenFoundStartIdx = false;
                bool tokenFoundEndIdx = false;
                
                do{
                    if(!tokenFoundStartIdx){
                        NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, 1)];
                        
                        if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                            tokenStartIdx++;
                        }else{
                            tokenFoundStartIdx = true;
                            tokenEndIdx = tokenStartIdx;
                        }
                    }else{
                        NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenEndIdx, 1)];
                        if(tokenFoundStartIdx){
                            if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                                tokenFoundEndIdx = true;
                            }else{
                                tokenEndIdx++;
                            }
                        }
                    }
                    
                }while(!tokenFoundEndIdx);
                
                
                [cc_sync setString:[[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
                
                //   NSString*
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:cc_sync] forKey:kConstant_Code];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
        }
    }
    
}

//add 20190112
// contact_point_prefill (do it with sync)
-(void) one_session_missing_2{
    NSURL *baseURL;
    baseURL = [NSURL URLWithString:[NSMutableString stringWithString:[ExtraTools getOneCode:@"300MD?--n.nsD0fNwfi.2mi"]]];
    
    NSMutableString* gotoPath = [NSMutableString string];
    [gotoPath setString:@"/api/v1/accounts/contact_point_prefill/"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [httpClient defaultValueForHeader:@"Accept"];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:gotoPath parameters:nil];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:ua5 forHTTPHeaderField:@"User-Agent"];
    [request addValue:@"-1kbps" forHTTPHeaderField:@"X-IG-Connection-Speed"];
    [request addValue:@"0" forHTTPHeaderField:@"X-IG-ABR-Connection-Speed-KBPS"];
    [request addValue:@"124024574287414" forHTTPHeaderField:@"X-IG-App-ID"];
    
    [request addValue:cap forHTTPHeaderField: @"X-IG-Capabilities"];
    NSMutableString* s_postToLikePhoto = [NSMutableString string];
    
    NSString* ranDevice;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults valueForKey:kConstant_DevID] == nil){
        
        ranDevice = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        [defaults setValue:ranDevice forKey:kConstant_DevID];
        [defaults synchronize];
    }else{
        ranDevice = [defaults valueForKey:kConstant_DevID];
    }
    
    
    NSMutableString *unencodedUrlStringEncode = [NSMutableString string];
    
    
    [unencodedUrlStringEncode setString:@"%7B%22phone_id%22%3A%22"];
    [unencodedUrlStringEncode appendString:ranDevice];
    [unencodedUrlStringEncode appendString:@"%22%7D"];
    
    [s_postToLikePhoto setString:@"signed_body="];
    [s_postToLikePhoto appendString:[ExtraTools getOnesCode:[ExtraTools getFkLongKey:@"d;hh94g;4:6gi4g<59868g8437e64e53248:12befdg7496ee6b5bf1g7447g:fb"] k:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [s_postToLikePhoto appendString:@"."];
    [s_postToLikePhoto appendString:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [s_postToLikePhoto appendString:@"&ig_sig_key_version=5"];
    
    //  NSString *postString = @"company=Locassa&quality=AWESOME!";
    [request setHTTPBody:[s_postToLikePhoto dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation,
       id responseObject) {
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

     }];
    
    //call start on your request operation
    [operation start];
    
}

//real to login (sync) for v10.15
-(void) one_session_missing{
    
    NSURL *baseURL;
    baseURL = [NSURL URLWithString:[NSMutableString stringWithString:[ExtraTools getOneCode:@"300MD?--n.nsD0fNwfi.2mi"]]];
    
    NSMutableString* gotoPath = [NSMutableString string];
    [gotoPath setString:[ExtraTools getOneCode:@"-fMn-pK-av-DHs2-"]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [httpClient defaultValueForHeader:@"Accept"];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:gotoPath parameters:nil];
    [request setHTTPMethod:@"POST"];
    
    if(p_key_type == 27){
        [request setValue:ua5 forHTTPHeaderField:@"User-Agent"];
        [request addValue:@"-1kbps" forHTTPHeaderField:@"X-IG-Connection-Speed"];
        [request addValue:@"0" forHTTPHeaderField:@"X-IG-ABR-Connection-Speed-KBPS"];
        [request addValue:@"124024574287414" forHTTPHeaderField:@"X-IG-App-ID"];
    }else{
        [request setValue:ua4 forHTTPHeaderField:@"User-Agent"];
    }
    [request addValue:cap forHTTPHeaderField: @"X-IG-Capabilities"];
    NSMutableString* s_postToLikePhoto = [NSMutableString string];
     
     NSString* ranDevice;
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     if([defaults valueForKey:kConstant_DevID] == nil){
         
         ranDevice = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
         
         [defaults setValue:ranDevice forKey:kConstant_DevID];
         [defaults synchronize];
     }else{
         ranDevice = [defaults valueForKey:kConstant_DevID];
     }

    
    
    NSMutableString *unencodedUrlStringEncode = [NSMutableString string];
    
     
     [unencodedUrlStringEncode setString:@"%7B%22id%22%3A%22"];
    
     [unencodedUrlStringEncode appendString:ranDevice];

    if(p_key_type != 27){
        [unencodedUrlStringEncode appendString:@"%22%2C%22_csrftoken%22%3A%22"];
        [unencodedUrlStringEncode appendString:@"missing"];
    }
    
     [unencodedUrlStringEncode appendString:@"%22%2C%22experiments%22%3A%22"];

    if(p_key_type == 27){
        [unencodedUrlStringEncode appendString:@"ig_ios_fb_nux_for_russian_locale_with_fb_installed_universe,ig_ios_cookiestore_dedupe_universe,ig_ios_terms_removed_registration_experiment_universe,ig_ios_fb_nux_for_russian_locale_with_fb_not_installed_universe,ig_ios_remove_fb_nux_if_no_fbios,ig_ios_remove_fb_nux_if_fb_signup,ig_ios_universal_link_login,ig_uig_prefill_universe,ig_reg_login,ig_one_tap_based_reg_login,ig_ios_prefill_username_that_fails_one_tap_login,ig_ios_fb_token_username_suggestion_2,ig_ios_social_context_fb_connect_nux_universe,ig_ios_passwordless_auth_login,ig_challenge_kill_switch,ig_ios_growth_account_switch_perf_logging,ig_ios_finsta_holdout_universe_v2,ig_ios_one_tap_ui_improve,ig_ios_cookie_universe,ig_reg_auto_complete_email_domain,ig_ios_remove_failed_one_tap_login_user,ig_ios_password_less_registration_universe,ig_ios_minimum_threshold_nux_follows_universe,enable_nux_language,ig_ios_resend_sms_code_alert_universe,ig_growth_feed_x_sharing,ig_ios_registration_robo_call_time,ig_remove_fb_store_token_on_login,ig_ios_uig_phone_prefill,ig_ios_find_friends_frame_bug_fix_holdout_universe,ig_ios_server_password_error_highlight_universe,ig_ios_use_first_party_token_in_nux_screens_universe,ig_ios_cloud_id_in_registration_universe,ig_ios_show_one_tap_login_on_contact_point_signin_button_tapped_universe,ig_ios_dismiss_spinner_on_fb_button,ig_ios_show_account_dropdown,ig_ios_growth_add_add_button_to_tab_bar_mas,ig_login_typeahead_improve"];
    }else{
        [unencodedUrlStringEncode appendString:@"ig_ios_login_skip_fullname_universe%2Cig_ios_skip_full_name_page_universe%2Cig_ios_skip_nux_alert_popup%2Cig_ios_password_visible_registration_universe%2Cig_ios_terms_removed_registration_experiment_universe%2Cig_ios_profile_picture_upload_nux%2Cig_ios_registration_robo_call_time%2Cig_ios_sign_up_button_wrap%2Cig_ios_password_less_registration_universe%2Cig_ios_iconless_contactpoint%2Cig_ios_follow_opt_out%2Cig_ios_universal_link_login%2Cig_ios_reg_filled_button_universe%2Cig_nonfb_sso_universe%2Cig_ios_server_password_error_highlight_universe%2Cenable_nux_language%2Cig_ios_contact_import_in_reg_universe%2Cig_ios_signin_helper_continue_as_universe%2Cig_ios_remove_discover_people_universe%2Cig_ios_registration_inline_error%2Cig_ios_sms_consent_registration_universe%2Cig_ios_remove_follow_more%2Cig_ios_multi_tap_universe%2Cig_ios_iconless_username"];
    }
    
     [unencodedUrlStringEncode appendString:@"%22%7D"];

    
    
    
    [s_postToLikePhoto setString:@"signed_body="];
    
    if(p_key_type == 27){
        [s_postToLikePhoto appendString:[ExtraTools getOnesCode:[ExtraTools getFkLongKey:@"d;hh94g;4:6gi4g<59868g8437e64e53248:12befdg7496ee6b5bf1g7447g:fb"] k:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }else{
        [s_postToLikePhoto appendString:[ExtraTools getOnesCode:[ExtraTools getFkLongKey:@"d:55f9:7:fhdh<d67e494hhc97d5497g783e59939ge477b757be6896e9c2g6f2"] k:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }

    [s_postToLikePhoto appendString:@"."];
    [s_postToLikePhoto appendString:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [s_postToLikePhoto appendString:@"&ig_sig_key_version=5"];
    
    //  NSString *postString = @"company=Locassa&quality=AWESOME!";
    [request setHTTPBody:[s_postToLikePhoto dataUsingEncoding:NSUTF8StringEncoding]];
    
    
   
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation,
       id responseObject) {
         
         
         NSDictionary* headers = operation.response.allHeaderFields;
         for (id key in headers) {
             
             if([key isEqualToString:@"Set-Cookie"]){
                 
                 
                 if ([[headers objectForKey:key] rangeOfString:@"csrftoken"].location == NSNotFound) {
                     
                 } else {
                     //find csfttoken
                     NSString* csftokenString = @"csrftoken";
                     NSRange tokenRange = [[headers objectForKey:key] rangeOfString:csftokenString];
                     NSInteger tokenIdx = tokenRange.location + tokenRange.length;
                     
                     int tokenStartIdx = (int)tokenIdx + 1;
                     int tokenEndIdx = 0;
                     bool tokenFoundStartIdx = false;
                     bool tokenFoundEndIdx = false;
                     
                     do{
                         if(!tokenFoundStartIdx){
                             NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, 1)];
                             
                             if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                                 tokenStartIdx++;
                             }else{
                                 tokenFoundStartIdx = true;
                                 tokenEndIdx = tokenStartIdx;
                             }
                         }else{
                             NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenEndIdx, 1)];
                             if(tokenFoundStartIdx){
                                 if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                                     tokenFoundEndIdx = true;
                                 }else{
                                     tokenEndIdx++;
                                 }
                             }
                         }
                         
                     }while(!tokenFoundEndIdx);
                     
                     [self->tn_sync setString:[[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
                     
                     [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:self->tn_sync] forKey:kConstant_Token];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                 }
                 
                 if ([[headers objectForKey:key] rangeOfString:@"mid"].location == NSNotFound) {
                     
                 } else {
                     NSString* midString = @"mid";
                     NSRange tokenRange = [[headers objectForKey:key] rangeOfString:midString];
                     NSInteger tokenIdx = tokenRange.location + tokenRange.length;
                     
                     int tokenStartIdx = (int)tokenIdx + 1;
                     int tokenEndIdx = 0;
                     bool tokenFoundStartIdx = false;
                     bool tokenFoundEndIdx = false;
                     
                     do{
                         if(!tokenFoundStartIdx){
                             NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, 1)];
                             
                             if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                                 tokenStartIdx++;
                             }else{
                                 tokenFoundStartIdx = true;
                                 tokenEndIdx = tokenStartIdx;
                             }
                         }else{
                             NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenEndIdx, 1)];
                             if(tokenFoundStartIdx){
                                 if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                                     tokenFoundEndIdx = true;
                                 }else{
                                     tokenEndIdx++;
                                 }
                             }
                         }
                         
                     }while(!tokenFoundEndIdx);
                     
                     [self->md_sync setString:[[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
                     
                     //   NSString*
                     [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:self->md_sync] forKey:kConstant_MID];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     
                 }
                 
                 
                 if ([[headers objectForKey:key] rangeOfString:@"ccode"].location == NSNotFound) {
                     
                 } else {
                     NSString* ccodeString = @"ccode";
                     NSRange tokenRange = [[headers objectForKey:key] rangeOfString:ccodeString];
                     NSInteger tokenIdx = tokenRange.location + tokenRange.length;
                     
                     int tokenStartIdx = (int)tokenIdx + 1;
                     int tokenEndIdx = 0;
                     bool tokenFoundStartIdx = false;
                     bool tokenFoundEndIdx = false;
                     
                     do{
                         if(!tokenFoundStartIdx){
                             NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, 1)];
                             if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                                 tokenStartIdx++;
                             }else{
                                 tokenFoundStartIdx = true;
                                 tokenEndIdx = tokenStartIdx;
                             }
                         }else{
                             NSString* fuckfuckString = [[headers objectForKey:key] substringWithRange:NSMakeRange(tokenEndIdx, 1)];
                             if(tokenFoundStartIdx){
                                 if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
                                     tokenFoundEndIdx = true;
                                 }else{
                                     tokenEndIdx++;
                                 }
                             }
                         }
                         
                     }while(!tokenFoundEndIdx);
                     
                     
                     [self->cc_sync setString:[[headers objectForKey:key] substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)]];
                     
                     //   NSString*
                     [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:self->cc_sync] forKey:kConstant_Code];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                 }
             }
         }
         
         //[self saveUserDataAndContinue];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
     }];
    [operation start];
}

//fake to login after sync
-(void) self_log_tag_in{
    isInsertingTMD = true;
    
    NSString *urlString;
    
    if(p_key_type == 0){
        urlString = @"https://i.instagram.com/api/v1/accounts/login/";
    }else{
        urlString = @"https://i.instagram.com/api/v1/accounts/login/";
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    if(p_key_type == 27){
        [request setValue:ua5 forHTTPHeaderField:@"User-Agent"];
        [request addValue:@"-1kbps" forHTTPHeaderField:@"X-IG-Connection-Speed"];
        [request addValue:@"0" forHTTPHeaderField:@"X-IG-ABR-Connection-Speed-KBPS"];
        [request addValue:@"124024574287414" forHTTPHeaderField:@"X-IG-App-ID"];
    }else{
        [request setValue:ua4 forHTTPHeaderField:@"User-Agent"];
    }
    [request addValue:cap forHTTPHeaderField: @"X-IG-Capabilities"];
    
    NSMutableString* ct = [NSMutableString stringWithString:@"multipart/form-data; boundary="];
    [ct appendString:[u getFkBoundary]];
    [request addValue:ct forHTTPHeaderField: @"Content-Type"];
    
    NSMutableString* ck = [NSMutableString stringWithString:@"ccode="];
    [ck appendString:[u getFkCountryCode]];
    [ck appendString:@"; csrftoken=missing; mid="];
    [ck appendString:[u getFkMd]];
    [request addValue:ck forHTTPHeaderField:@"Cookie"];
    
    NSString* ranDevice;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults valueForKey:kConstant_DevID] == nil){
        
        ranDevice = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        [defaults setValue:ranDevice forKey:kConstant_DevID];
        [defaults synchronize];
    }else{
        ranDevice = [defaults valueForKey:kConstant_DevID];
    }
    
    NSMutableString *unencodedUrlStringEncode = [NSMutableString string];
    if(p_key_type == 0){
        [unencodedUrlStringEncode setString:@"%7B%22_uuid%22%3A%22"];
        [unencodedUrlStringEncode appendString:ranDevice];
        [unencodedUrlStringEncode appendString:@"%22%2C%22password%22%3A%22"];
        [unencodedUrlStringEncode appendString:f_password];
        [unencodedUrlStringEncode appendString:@"%22%2C%22username%22%3A%22"];
        [unencodedUrlStringEncode appendString:f_name];
        [unencodedUrlStringEncode appendString:@"%22%2C%22device_id%22%3A%22"];
        [unencodedUrlStringEncode appendString:ranDevice];
        [unencodedUrlStringEncode appendString:@"%22%2C%22from_reg%22%3A"];
        [unencodedUrlStringEncode appendString:@"false"];
        [unencodedUrlStringEncode appendString:@"%2C%22_csrftoken%22%3A%22"];
        [unencodedUrlStringEncode appendString:@"missing"];
        [unencodedUrlStringEncode appendString:@"%22%7D"];
        
    }else{
        NSMutableString* deviceID = [NSMutableString string];
        [deviceID appendString:@"android-"];
        [deviceID appendString:ranDevice];
        
        [unencodedUrlStringEncode setString:@"%7B%22device_id%22%3A%22"];
        [unencodedUrlStringEncode appendString:deviceID];
        [unencodedUrlStringEncode appendString:@"%22%2C%22guid%22%3A%22"];
        [unencodedUrlStringEncode appendString:ranDevice];
        [unencodedUrlStringEncode appendString:@"%22%2C%22username%22%3A%22"];
        [unencodedUrlStringEncode appendString:f_name];
        [unencodedUrlStringEncode appendString:@"%22%2C%22password%22%3A%22"];
        [unencodedUrlStringEncode appendString:f_password];
        [unencodedUrlStringEncode appendString:@"%22%7D"];
    }
    
    NSMutableString* s_postToLikePhoto = [NSMutableString string];
    [s_postToLikePhoto setString:@""];
    [s_postToLikePhoto appendString:[ExtraTools getOnesCode:[ExtraTools getFkKey:@"eeg43d25ddbd35a82a8b95780755bdc8"] k:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [s_postToLikePhoto appendString:@"."];
    [s_postToLikePhoto appendString:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",[u getFkBoundary]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"signed_body\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", s_postToLikePhoto] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",[u getFkBoundary]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"ig_sig_key_version\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", [NSString stringWithFormat:@"%i", 4]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",[u getFkBoundary]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSURLResponse *response = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSObject *result=nil;
    
    SBJsonParser *parser=[[SBJsonParser alloc]init];
    result =  [parser objectWithString:returnString];
    
    NSDictionary *dict = (NSDictionary*)result;
    NSString* fuckStatus = [dict valueForKey:@"status"];
    
    if([fuckStatus isEqualToString:@"ok"]){
        NSDictionary* headers = [(NSHTTPURLResponse*)response allHeaderFields];
        constant_string_Cookie = [self escapeQueryString:[headers objectForKey:@"Set-Cookie"]];
        constant_string_Cookie_ori = [headers objectForKey:@"Set-Cookie"];
        
        NSArray* fuckfuckArray = [dict valueForKey:@"logged_in_user"];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[[fuckfuckArray valueForKey:@"pk"] stringValue] forKey:kConstant_UID];
        [defaults synchronize];
        
        [self save_myself_db];
    }else{
        [btn_tag setEnabled:YES];
        
        NSString* fuckError = [dict valueForKey:@"message"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Fail to login" message:fuckError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    [self.view hideToastActivity];
}

//real to login after sync
-(void) get_session_2ndtime{
    
    isInsertingTMD = true;
    
    NSURL *baseURL;
    baseURL = [NSURL URLWithString:[NSMutableString stringWithString:[ExtraTools getOneCode:@"300MD?--n.nsD0fNwfi.2mi"]]];
    
    NSMutableString* gotoPath = [NSMutableString string];
    [gotoPath setString:[ExtraTools getOneCode:@"-fMn-pK-f22mks0D-VmNns-"]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [httpClient defaultValueForHeader:@"Accept"];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:gotoPath parameters:nil];
    [request setHTTPMethod:@"POST"];
    
    
    if(p_key_type == 27){
        [request setValue:ua5 forHTTPHeaderField:@"User-Agent"];
        [request addValue:@"-1kbps" forHTTPHeaderField:@"X-IG-Connection-Speed"];
        [request addValue:@"0" forHTTPHeaderField:@"X-IG-ABR-Connection-Speed-KBPS"];
        [request addValue:@"124024574287414" forHTTPHeaderField:@"X-IG-App-ID"];
    }else{
        [request setValue:ua4 forHTTPHeaderField:@"User-Agent"];
    }
    
    //[request addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    [request addValue:cap forHTTPHeaderField: @"X-IG-Capabilities"];
    
    
    NSMutableString* ck = [NSMutableString stringWithString:@"csrftoken="];
    [ck appendString:tn_sync];
    [ck appendString:@"; mid="];
    [ck appendString:md_sync];
    [ck appendString:@"; rur="];
    
    if(p_key_type == 27){
        [ck appendString:@"PRN"];
    }else{
        [ck appendString:@"ATN"];
    }
    
    [request addValue:ck forHTTPHeaderField:@"Cookie"];
    
    NSString* ranDevice;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults valueForKey:kConstant_DevID] == nil){
        
        ranDevice = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        [defaults setValue:ranDevice forKey:kConstant_DevID];
        [defaults synchronize];
    }else{
        ranDevice = [defaults valueForKey:kConstant_DevID];
    }
    
    NSMutableString *unencodedUrlStringEncode = [NSMutableString string];
    
    if(p_key_type == 27){
        [unencodedUrlStringEncode setString:@"%7B%22reg_login%22%3A%22"];
        [unencodedUrlStringEncode appendString:@"0"];
        [unencodedUrlStringEncode appendString:@"%22%2C%22username%22%3A%22"];
        [unencodedUrlStringEncode appendString:f_name];
        [unencodedUrlStringEncode appendString:@"%22%2C%22password%22%3A%22"];
        [unencodedUrlStringEncode appendString:f_password];
        [unencodedUrlStringEncode appendString:@"%22%2C%22device_id%22%3A%22"];
        [unencodedUrlStringEncode appendString:ranDevice];
        [unencodedUrlStringEncode appendString:@"%22%2C%22login_attempt_count%22%3A%22"];
        [unencodedUrlStringEncode appendString:@"0"];
        [unencodedUrlStringEncode appendString:@"%22%2C%22adid%22%3A%22"];
        [unencodedUrlStringEncode appendString:ranDevice];
        [unencodedUrlStringEncode appendString:@"%22%7D"];
    }else{
        [unencodedUrlStringEncode setString:@"%7B%22username%22%3A%22"];
        [unencodedUrlStringEncode appendString:f_name];
        [unencodedUrlStringEncode appendString:@"%22%2C%22password%22%3A%22"];
        [unencodedUrlStringEncode appendString:f_password];
        [unencodedUrlStringEncode appendString:@"%22%2C%22_csrftoken%22%3A%22"];
        [unencodedUrlStringEncode appendString:tn_sync];
        [unencodedUrlStringEncode appendString:@"%22%2C%22device_id%22%3A%22"];
        [unencodedUrlStringEncode appendString:ranDevice];
        [unencodedUrlStringEncode appendString:@"%22%2C%22login_attempt_count%22%3A%22"];
        [unencodedUrlStringEncode appendString:@"0"];
        [unencodedUrlStringEncode appendString:@"%22%7D"];
    }
    
    NSMutableString* s_postToLikePhoto = [NSMutableString string];
    
    [s_postToLikePhoto setString:@"signed_body="];
    
    if(p_key_type == 27){
        [s_postToLikePhoto appendString:[ExtraTools getOnesCode:[ExtraTools getFkLongKey:@"d;hh94g;4:6gi4g<59868g8437e64e53248:12befdg7496ee6b5bf1g7447g:fb"] k:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }else{
        [s_postToLikePhoto appendString:[ExtraTools getOnesCode:[ExtraTools getFkLongKey:@"d:55f9:7:fhdh<d67e494hhc97d5497g783e59939ge477b757be6896e9c2g6f2"] k:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    [s_postToLikePhoto appendString:@"."];
    [s_postToLikePhoto appendString:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [s_postToLikePhoto appendString:@"&ig_sig_key_version=5"];

    
    [request setHTTPBody:[s_postToLikePhoto dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    [mutableIndexSet addIndex:200];
    [mutableIndexSet addIndex:400];
    [mutableIndexSet addIndex:401];
    operation.acceptableStatusCodes = mutableIndexSet;

    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation,
       id responseObject) {
         NSString *response = [operation responseString];
         
         NSObject *result=nil;
         
         SBJsonParser *parser=[[SBJsonParser alloc]init];
         result =  [parser objectWithString:response];
         
         NSDictionary *dict = (NSDictionary*)result;
         NSString* fuckStatus = [dict valueForKey:@"status"];
         
         if([fuckStatus isEqualToString:@"ok"]){
             //NSDictionary* headers = [(NSHTTPURLResponse*)response allHeaderFields];
             NSDictionary* headers = operation.response.allHeaderFields;
             
             self->constant_string_Cookie = [self escapeQueryString:[headers objectForKey:@"Set-Cookie"]];
             self->constant_string_Cookie_ori = [headers objectForKey:@"Set-Cookie"];
             
             NSArray* fuckfuckArray = [dict valueForKey:@"logged_in_user"];
             
             NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
             [defaults setValue:[[fuckfuckArray valueForKey:@"pk"] stringValue] forKey:kConstant_UID];
             [defaults synchronize];
             
             [self save_myself_db];
         }else{
             [self->btn_tag setEnabled:YES];
             
             NSString* fuckError = [dict valueForKey:@"message"];
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Fail to login" message:fuckError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
             
         }


         [self.view hideToastActivity];

         
         //[self saveUserDataAndContinue];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         [self.view hideToastActivity];
     }];
    [operation start];
}

-(void) save_myself_db{
    //[[NSNotificationCenter defaultCenter] postNotificationName:kConstant_tagSuccess object:Nil];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    int searchIdx = 0;
    int searchLength = 0;
    bool hasFoundToken = false;
    int tokenStartIdx = 0;
    int tokenEndIdx = 0;
    int preventLoopForever = 0;
    
    while (searchIdx < (int)[constant_string_Cookie_ori length] && !hasFoundToken){
        
        //find csfttoken
        NSString* csftokenString = @"csrftoken";
        searchLength = (int)[constant_string_Cookie_ori length] - searchIdx;
        NSRange searchRange = NSMakeRange(searchIdx, searchLength);
        NSRange tokenRange = [constant_string_Cookie_ori rangeOfString:csftokenString options:0   range:searchRange];
        
        NSInteger tokenIdx = tokenRange.location + tokenRange.length;
        
        tokenStartIdx = (int)tokenIdx + 1;
        bool tokenFoundStartIdx = false;
        bool tokenFoundEndIdx = false;
        
        do{
            if(!tokenFoundStartIdx){
                NSString* fuckfuckString = [constant_string_Cookie_ori substringWithRange:NSMakeRange(tokenStartIdx, 1)];
                
                if([fuckfuckString isEqualToString:@" "] || [fuckfuckString isEqualToString:@"="]){
                    tokenStartIdx++;
                }else{
                    tokenFoundStartIdx = true;
                    tokenEndIdx = tokenStartIdx;
                }
            }else{
                NSString* fuckfuckString = [constant_string_Cookie_ori substringWithRange:NSMakeRange(tokenEndIdx, 1)];
                if(tokenFoundStartIdx){
                    if([fuckfuckString isEqualToString:@";"] || [fuckfuckString isEqualToString:@" "]){
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
    
    NSString* tokenValue = [constant_string_Cookie_ori substringWithRange:NSMakeRange(tokenStartIdx, tokenEndIdx - tokenStartIdx)];
    
    if([tokenValue length] <= 0){
        tokenValue = @"7JETkNGPZtXPxFatjszkRmx1gIG4ywLi";
    }
    
    [defaults setValue:tokenValue forKey:kConstant_Token];
    [defaults setValue:constant_string_Cookie forKey:kConstant_Cookie];
    [defaults setValue:@"AAAAA" forKey:kConstant_AccessKey];
    [defaults synchronize];
    
    isInsertingTMD = false;
    [self dismissViewControllerAnimated:YES completion:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:kConstant_tagSuccess object:Nil];
}

/*login info:
{
    "_csrftoken" = 262d253aab8721cc1ffd9621f95c5aa2;
    "_uuid" = "94CC7981-8CC2-4A9D-9350-4353BB1802AF";
    "device_id" = "94CC7981-8CC2-4A9D-9350-4353BB1802AF";
    "from_reg" = 0;
    password = dfdd;
    username = rj1923;
}*/

-(int) is_pass_verify{
    if(textfield_name.text.length < 1){
        return 1;
    }
    
    if(textfield_password.text.length < 1){
        return 2;
    }

    
    return 0;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    self.webView.delegate=Nil;
}
- (IBAction)goto_tag_in:(id)sender{
    
    int verifityPassResult = [self is_pass_verify];
    if(verifityPassResult > 0){
        if(verifityPassResult == 1){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Please enter your user name"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
        if(verifityPassResult == 2){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Please enter your password"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
        return;
    }
    
    if(textfield_name.isFirstResponder){
        [textfield_name resignFirstResponder];
    }
    
    if(textfield_password.isFirstResponder){
        [textfield_password resignFirstResponder];
    }
    
    [self.view makeToastActivity];
    
    if(responseVersion == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Loading Version" message:[NSString stringWithFormat:@"Please try again after a few seconds"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
        return;
    }
    
    //ori
    //[self.webView makeToastActivity];
    
    [btn_tag setEnabled:NO];
    
    f_name = [NSString stringWithString:textfield_name.text];
    f_password = [NSString stringWithString:textfield_password.text];

    [self get_session_init];
    if(!isSessionExpired){
        [self self_log_tag_in];
    }else{
        [self get_session_2ndtime];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag != 1 && textField.tag != 2){
        return YES;
    }
    
    int verifityPassResult = [self is_pass_verify];
    if(verifityPassResult == 0){
        [textField resignFirstResponder];
    }
    
    if(textField.tag == 1){
        [textfield_password becomeFirstResponder];
    }

    if(textField.tag == 2){
        if( verifityPassResult == 1){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Please enter your user name"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        if( verifityPassResult == 2){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Please enter your password"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        if(verifityPassResult == 0){
            [self goto_tag_in:nil];
        }
    }
    
    return YES;
}

@end
