//
//  ViewController_Home.m
//
//  Created by Ali Raza on 25/03/2014.
//  Copyright (c) 2014 ILApps. All rights reserved.
//
#import "ViewController_Home.h"
#import "Toast+UIView.h"
#import "UIImageView+WebCache.h"
#import "GenericFetcher.h"
#import "ViewController_Shop.h"
#import "Global.h"
#import "SBJsonParser.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "ViewController_LogTag.h"
#import "HMedia.h"
#import "ToIncreaseViewController.h"

//#import "SDImageCache.h"

#import "NSObject+SBJSON.h"


#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#include <sys/sysctl.h>

#import "ExtraTools.h"



//search engine

NSDictionary *dataDict;
NSMutableArray *feedsArry;
NSDictionary *currentImageData;
NSMutableData *_responseData;

//get likes code
const NSInteger kthumbnailWidth = 89;
const NSInteger kthumbnailHeight = 89;
const NSInteger kImagesPerRow = 3;
const NSInteger kcenterMenuHeight = 200;

NSInteger horizentalSpace = 10;
NSInteger kverticalSpace = 10;
NSInteger scrolerHeight = 0;

NSUserDefaults* user_defaults;

bool isADEnable;
int adInterval;

bool isAutomatic;
int automaticTimer;
int automacticInterval;
bool automacticNoFeed;

int seikeAvailable;
int seikeAvailableReturn;
int seikeAvailableTimer;
bool seikeAvailableHasInit;
int likeBlockTimer;

NSString* FishMsg;
NSString* FishTitle;

NSString* adMsg;
NSString* adTitle;
int ownAdVersion;
int ownAdLink;
int ownAdRatio;
bool hasShownOwnAdInThisSession;

int minimumVersion;

int canAskRate;



#define noDisableVerticalScrollTag 836913
#define noDisableHorizontalScrollTag 836914

@implementation UIImageView (ForScrollView)

- (void) setAlpha:(CGFloat)alpha {
    
    if (self.superview.tag == noDisableVerticalScrollTag) {
        if (alpha == 0 && self.autoresizingMask == UIViewAutoresizingFlexibleLeftMargin) {
            if (self.frame.size.width < 10 && self.frame.size.height > self.frame.size.width) {
                UIScrollView *sc = (UIScrollView*)self.superview;
                if (sc.frame.size.height < sc.contentSize.height) {
                    return;
                }
            }
        }
    }
    
    if (self.superview.tag == noDisableHorizontalScrollTag) {
        if (alpha == 0 && self.autoresizingMask == UIViewAutoresizingFlexibleTopMargin) {
            if (self.frame.size.height < 10 && self.frame.size.height < self.frame.size.width) {
                UIScrollView *sc = (UIScrollView*)self.superview;
                if (sc.frame.size.width < sc.contentSize.width) {
                    return;
                }
            }
        }
    }
    
    [super setAlpha:alpha];
}
@end

@interface ViewController_Home ()

@end

@implementation ViewController_Home
@synthesize accessToken = _accessToken;

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

-(NSString*) sha256:(NSString *)clear{
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

NSData *hmac_key_data(NSString *key, NSString *data)
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:)
                                                 name:kConstant_MenuChangedToTag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:)
                                                 name:kConstant_MenuCaangedToDiamond object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:)
                                                 name:kConstant_tagSuccess object:nil];
    return self;
}
- (void) receiveTestNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    
    if ([[notification name] isEqualToString:kConstant_MenuChangedToTag])
    {
        [self.tagDia_2_btn setSelected:YES];
        [self.tagDiamond_btn setSelected:NO];
        [self.increaseTagView setHidden:NO];
    }
    if ([[notification name] isEqualToString:kConstant_MenuCaangedToDiamond])
    {
        [self.tagDia_2_btn setSelected:NO];
        [self.tagDiamond_btn setSelected:YES];
        [self.increaseTagView setHidden:YES];
    }
    if ([[notification name] isEqualToString:kConstant_tagSuccess])
    {
        [self getVersion:true];
        [self registerAUser];
    }
}

-(void) getFirstVersion{
    [viewController_Shop loading_items];
    
    if(kVersion <= responseVersion){
        [self check_tag_status];
    }
    
    
    //add on 20190112
    /*if(hasIniit_tag_VC){
        [viewController_LogTag get_session_1sttime];
    }*/
    
    //recover
    get_session_1sttime_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(get_session_11sttime:) userInfo:nil repeats:YES];
    
}

//add on 20190112
int aaa = 0;
-(void) get_session_11sttime:(NSTimer*) timer{
    if(hasIniit_tag_VC || aaa == 20){
        [viewController_LogTag get_session_1sttime];
        [get_session_1sttime_timer invalidate];
    }
    aaa++;
}

bool hasCheckedVersionFirst = false;
-(void) getVersion:(bool)_newLogin{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    [params setValue:[NSString stringWithFormat:@"%i", 12]  forKey:@"p_Whatson"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@ver_ws6.php", @"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    if(!loopChecking){
        isLogged = false;
        [self.view makeToastActivity];
    }
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
       // responseStr = @"3500102";
        
        NSObject *result=nil;
        SBJsonParser *parser=[[SBJsonParser alloc]init];
        result =  [parser objectWithString:responseStr];
        
        FishLink = [[result valueForKey:@"l"] intValue];
        ownAdVersion = [[result valueForKey:@"adv"] intValue];
        ownAdLink = [[result valueForKey:@"adl"] intValue];
        ownAdRatio = [[result valueForKey:@"adr"] intValue];
        minimumVersion = [[result valueForKey:@"mv"] intValue];
        superAllow_server = [[result valueForKey:@"ssa"] intValue];
        cap = [result valueForKey:@"cap"];
        p_key_type = [[result valueForKey:@"key"] intValue];
        canAskRate = [[result valueForKey:@"r"] intValue];

        
        pp_and_pp = [[result valueForKey:@"pp"] intValue];
        [viewController_Shop loading_items];

        if(!seikeAvailableHasInit){
            seikeAvailable = [[result valueForKey:@"al"] intValue];
            seikeAvailableHasInit = true;
        }
        
        seikeAvailableReturn = [[result valueForKey:@"al"] intValue];
        likeBlockTimer = [[result valueForKey:@"bt"] intValue];
        
        int responseValue = [[result valueForKey:@"v"] intValue];
        
        int calValue = responseValue;
        int totalLength = 0;
        int firstLength = 1;
        int secondLength = 1;
        
        
        do{
            calValue /= 10;
            totalLength++;
        }while(calValue > 0);
        
        int calLength  = totalLength;
        int calDivide = 1;
        
        do{
            calLength--;
            
            if(calLength > 0){
                calDivide *= 10;
            }
        }while(calLength > 0);
        
        firstLength = responseValue/calDivide;
        secondLength = totalLength - firstLength - 1;
        
        int combineValue = responseValue - calDivide * firstLength;
        
        
        
        calLength = secondLength;
        calDivide = 1;
        
        do{
            calLength--;
            calDivide *= 10;
        }while(calLength > 0);
        
        int firstValue = combineValue / calDivide;
        int secondValue = combineValue - firstValue * calDivide;
        
        likeAwardToFish = firstValue;

        
        bool canGoNext = true;

        
        if(responseVersion < kVersion){
            adInterval = 0;
            isADEnable = true;
        }
        
        if(canGoNext){
            if(_newLogin){
                [self registerAUser];
            }else{
                if(!loopChecking){
                    [self load_all_feed];
                }
                
                [self getFreeDiamond];
            }
        }else{
            [self ask_update_version_to_new];
        }
        
        loopChecking = false;
        
        hasCheckedVersionFirst = true;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(!loopChecking){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"There is an error in version checking. Please check the network and make sure it is turning on." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            
            if(_newLogin){
                alert.tag = 11;
            }else{
                alert.tag = 12;
            }
        }
        
         loopChecking = false;
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 11){
        [self getVersion:true];
    }
    if(alertView.tag == 12){
        [self getVersion:false];
    }
    if(alertView.tag == 13){
        [self load_tagview];
    }
    if(alertView.tag == 103){
        [self gotoUpdateVersion];
    }
    if(alertView.tag == 104){
        [self gotoUpdateVersion];
    }
    
    if(responseVersion < kVersion){
        
    }else{
        if(alertView.tag == 1004 || alertView.tag == 1005){
            NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
            
            [self.view hideToastActivity];
            [self.itag hideToastActivity];
            
            if ([title isEqualToString:@"SURE"]) {
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                               @"FeedWarning", @"From",
                                               nil];
                
                //[ViewController_Shop.ssaPublisher showOfferWallWithApplicationKey:@"2f835d65" userId:[user_defaults valueForKey:kConstant_UID] delegate:self shouldGetLocation:NO extraParameters:nil parentViewController:self];
                
          
                IAPItemShowingOnly = false;
                [viewController_Shop load_before_appearing_view];
                [self.navigationController pushViewController:viewController_Shop animated:YES];
                [viewController_Shop delayToLoadFreeCoinsContent];
            }
            
        }
    }
   
    if(alertView.tag == 1006){
        [self tag_out];
    }
    
    if(alertView.tag == 1007){
        int totalCoinsFromRefund = [[user_defaults valueForKey:kConstant_Diamond] intValue] + refundAmt;
        
        self.diamond_lbl.text = [NSString stringWithFormat:@"%i", totalCoinsFromRefund];
        [user_defaults setValue:[NSString stringWithFormat:@"%i", totalCoinsFromRefund] forKey:kConstant_Diamond];
        [user_defaults synchronize];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        [params setValue:[user_defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
        [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
        [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_refundCoins.php",@"http://liker.j2sighte.com/api/"]]];
        //-- the content of the POST request is passed in as an NSDictionary
        //-- in this example, there are two keys with an object each
        
        
        [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if(isInSelectseikeView){
                [inIncreaseVC press_back_button];
            }
            
            refund_isGettingBack = false;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed to get the refund" message:@"Please try to logout then login again" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
            
            refund_isGettingBack = false;
        }];
    }
    
    if(alertView.tag == 1008){
        int totalCoinsFromReward = [[user_defaults valueForKey:kConstant_Diamond] intValue] + rewardAmt;
        
        self.diamond_lbl.text = [NSString stringWithFormat:@"%i", totalCoinsFromReward];
        [user_defaults setValue:[NSString stringWithFormat:@"%i", totalCoinsFromReward] forKey:kConstant_Diamond];
        [user_defaults synchronize];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        [params setValue:[user_defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
        [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
        [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_rewardCoins.php",@"http://liker.j2sighte.com/api/"]]];
        //-- the content of the POST request is passed in as an NSDictionary
        //-- in this example, there are two keys with an object each
        
        
        [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if(isInSelectseikeView){
                [inIncreaseVC press_back_button];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed to get the reward..." message:@"Please try to logout then login again" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
    
    if(alertView.tag == 1011){
        int totalCoinsFromReward = [[user_defaults valueForKey:kConstant_Diamond] intValue] + ownAmt;
        
        self.diamond_lbl.text = [NSString stringWithFormat:@"%i", totalCoinsFromReward];
        [user_defaults setValue:[NSString stringWithFormat:@"%i", totalCoinsFromReward] forKey:kConstant_Diamond];
        [user_defaults synchronize];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        [params setValue:[user_defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
        [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
        [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_ownAdCoins.php",@"http://liker.j2sighte.com/api/"]]];
        //-- the content of the POST request is passed in as an NSDictionary
        //-- in this example, there are two keys with an object each
        
        
        [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if(isInSelectseikeView){
                [inIncreaseVC press_back_button];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed to get coins...." message:@"Please try to logout then login again" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }];
    }

    if(alertView.tag == 1009){
 
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

        if ([title isEqualToString:@"SURE"]) {
            [self pressRate:nil];
            [self toIncrease_rate];
        }
        
        if ([title isEqualToString:@"Don't ask me again"]) {
            [user_defaults setValue:[NSString stringWithFormat:@"%i", kVersion] forKey:kConstant_VersionRate];
            [user_defaults synchronize];
        }
    }
    
    if(alertView.tag == 1010){
        
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if ([title isEqualToString:@"SURE"]) {
            [self pressedOwn];
            [self toIncreaseFromOwn];
        }
        
        if ([title isEqualToString:@"Don't ask me again"]) {
            [user_defaults setValue:[NSString stringWithFormat:@"%i", ownAdVersion] forKey:kConstant_VersionOwn];
            [user_defaults synchronize];
        }
    }
}

- (void)pressedOwn{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        NSString *str = @"itms-apps://itunes.apple.com/app/";
        
        // Here is the app id from itunesconnect
        str = [NSString stringWithFormat:@"%@id%@", str, [NSString stringWithFormat:@"%i",ownAdLink]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }else{
        NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
        str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str];
        str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
        
        // Here is the app id from itunesconnect
        str = [NSString stringWithFormat:@"%@%@", str, [NSString stringWithFormat:@"%i",ownAdLink]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

-(void) toIncreaseFromOwn{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_updateCoinsFromOwnAD.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
       // [user_defaults setValue:[NSString stringWithFormat:@"%i", ownAdVersion] forKey:kConstant_VersionOwn];
        [user_defaults setValue:[NSString stringWithFormat:@"%i",[[user_defaults valueForKey:kConstant_Diamond] intValue] + [responseStr integerValue]] forKey:kConstant_Diamond];
        [user_defaults synchronize];
        
        self.diamond_lbl.text = [NSString stringWithFormat:@"%i",[responseStr integerValue] + (int)[self.diamond_lbl.text integerValue]];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        static int toIncreaseFromOwnFailTime = 0;
        toIncreaseFromOwnFailTime++;
        if(toIncreaseFromOwnFailTime < 4){
            [self toIncreaseFromOwn];
        }
    }];
}

-(void) toIncrease_rate{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_updateCoinsFromRate.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        [user_defaults setValue:[NSString stringWithFormat:@"%i", kVersion] forKey:kConstant_VersionRate];
        [user_defaults setValue:[NSString stringWithFormat:@"%i",[[user_defaults valueForKey:kConstant_Diamond] intValue] + [responseStr integerValue]] forKey:kConstant_Diamond];
        [user_defaults synchronize];

        self.diamond_lbl.text = [NSString stringWithFormat:@"%i",[responseStr integerValue] + (int)[self.diamond_lbl.text integerValue]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        static int toIncrease_rateFailTime = 0;
        toIncrease_rateFailTime++;
        if(toIncrease_rateFailTime < 4){
            [self toIncrease_rate];
        }
    }];
}

//encrypt add new user p_registerAUser_cid.php in next update
-(void) registerAUser{
    if(kVersion > responseVersion){
       // [self presentEULA];
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i",cid_from] forKey:@"p_cid"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[defaults objectForKey:kConstant_AccessKey] forKey:@"p_token"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_addNewUser_cid.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (![responseStr isEqual:@"-1"]) {
            [self load_feed_history];
            [viewController_Shop loadSuperS];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:responseStr forKey:kConstant_Session];
            [userDefaults synchronize];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Please try to login again" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
            
            [self pressTagOut:nil];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Please try to login again" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
        
        [self pressTagOut:nil];
        
    }];
}

-(void) load_feed_history{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_readHistory.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSObject *result=nil;
        SBJsonParser *parser=[[SBJsonParser alloc]init];
        result =  [parser objectWithString:responseStr];
        
        NSArray *resultArray = (NSArray*)result;
        NSMutableArray* saveIdArray = [NSMutableArray array];
        NSMutableArray* unSaveIdArray = [NSMutableArray array];
        
        if (resultArray.count > 0) {
            for(int i = 0 ; i < resultArray.count ; i++){
                NSDictionary *dict = (NSDictionary*)[resultArray objectAtIndex:i];
                [saveIdArray addObject:[dict valueForKey:@"media_id"]];
            }
            
            [user_defaults setObject:saveIdArray forKey:kConstant_saveTagID];
            [user_defaults setObject:unSaveIdArray forKey:kConstant_unsaveTagID];
            [user_defaults synchronize];
            
            unsaveHistoryArray = [[NSMutableArray alloc] initWithArray:[user_defaults objectForKey:kConstant_unsaveTagID]];
            saveArray = [[NSMutableArray alloc] initWithArray:[user_defaults objectForKey:kConstant_saveTagID]];
            
            [self delete_print_history];
        }else{
            [user_defaults setObject:[NSArray array] forKey:kConstant_saveTagID];
            [user_defaults setObject:[NSArray array] forKey:kConstant_unsaveTagID];
            [user_defaults synchronize];
            
            unsaveHistoryArray = [[NSMutableArray alloc] initWithArray:[user_defaults objectForKey:kConstant_unsaveTagID]];
            saveArray = [[NSMutableArray alloc] initWithArray:[user_defaults objectForKey:kConstant_saveTagID]];
            
            [self delete_print_history];
        }
        
        [self load_all_feed];
        [self getFreeDiamond];
        [self pressDiamond:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Please try to login again" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
        
        [self pressTagOut:nil];
    }];
}


-(void) save_feed_history:(NSString*)_mediaId{
    
    [unsaveHistoryArray addObject:_mediaId];
    
    // for (int i = 0 ; i < [unsaveHistoryArray count]; i++) {
    // }
    
    [user_defaults setObject:unsaveHistoryArray forKey:kConstant_unsaveTagID];
    // [user_defaults setValue:@"AAAD" forKey:kTestingSave];
    [user_defaults synchronize];
    
    
    if([unsaveHistoryArray count] >= 5){
        
        NSString* jasonString = [unsaveHistoryArray JSONRepresentation];
        
         NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        [params setValue:jasonString forKey:@"jsonForUnsaveString"];
        [params setValue:[user_defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
        [params setValue:[NSString stringWithFormat:@"%i", kLV] forKey:@"p_LV"];
        [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_insertHistory.php",@"http://liker.j2sighte.com/api/"]]];
        //-- the content of the POST request is passed in as an NSDictionary
        //-- in this example, there are two keys with an object each
        
        
        [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            [saveArray addObjectsFromArray:unsaveHistoryArray];
            [unsaveHistoryArray removeAllObjects];
            
            [user_defaults setObject:saveArray forKey:kConstant_saveTagID];
            [user_defaults setObject:unsaveHistoryArray forKey:kConstant_unsaveTagID];
            [user_defaults synchronize];
            
            [self delete_print_history];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
        
    }
    
    [self delete_print_history];
}

-(void) delete_print_history{
    
    //if(responseVersion != 2){
        return;
   // }
    
    for(int i = 0 ; i < [unsaveHistoryArray count] ; i++){
    }
    
    for(int i = 0 ; i < [saveArray count] ; i++){
    }*/
    
}

-(void) viewDidAppear:(BOOL)animated{
    // self.Scrollview_2.tag = 836913;
    // [self.Scrollview_2 flashScrollIndicators];
    
}

-(void) remove_shop_view{
    [viewController_Shop press_back_button];
}

-(UIColor *)colorWithHex:(long)hexColor
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //delete
    
    //F44233
    [self.tagDia_2_btn setTitle:@"Get Likes" forState:UIControlStateNormal];
    [self.tagDia_2_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.tagDia_2_btn setTitleColor:[self colorWithHex:0x5c5c5c] forState:UIControlStateNormal];
    
    [self.tagDiamond_btn setTitle:@"Get Coins" forState:UIControlStateNormal];
    [self.tagDiamond_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.tagDiamond_btn setTitleColor:[self colorWithHex:0x5c5c5c] forState:UIControlStateNormal];
    
    [self.msg_btn setImage:[UIImage imageNamed:@"money.png"] forState:UIControlStateNormal];
    if(isIpad == true) {
        self.msg_btn.imageEdgeInsets = UIEdgeInsetsMake(0.0, self.msg_btn.titleLabel.frame.size.width + 190.0 - 44, 0.0, 0.0);
        [self.msg_btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -44, 0, 0)];
    } else {
        self.msg_btn.imageEdgeInsets = UIEdgeInsetsMake(0.0, self.msg_btn.titleLabel.frame.size.width + 90.0, 0.0, 0.0);
        self.msg_btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //[self.msg_btn setTitleEdgeInsets:UIEdgeInsetsMake(46, 44, 0, 0)];
    }
    
    [self.msg_btn setTitle:@"Like +1" forState:UIControlStateNormal];
    [self.msg_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.img_btn setTitle:@"Skip" forState:UIControlStateNormal];
    [self.img_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.msg_btn.adjustsImageWhenHighlighted = NO;
    self.img_btn.adjustsImageWhenHighlighted = YES;
    [self.msg_btn setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateHighlighted];
    
    [self.rateUs setTitle:@"Rate Us" forState:UIControlStateNormal];
    [self.emailUs setTitle:@"Email" forState:UIControlStateNormal];
    [self.loginOut setTitle:@"Log Out" forState:UIControlStateNormal];
    
    [self.tagDiamond_btn setSelected:true];
    
    user_defaults = [NSUserDefaults standardUserDefaults];
    
    viewController_Shop = [[ViewController_Shop alloc]initWithNibName:@"ViewController_Shop" bundle:nil];
   // [self.navigationController pushViewController:ViewController_Shop animated:YES];
    [viewController_Shop set_delegate:self];
    [viewController_Shop loadSuperS];
    
    
   // [user_defaults setValue:[NSString stringWithFormat:@"%i",0] forKey:kConstant_ownQidIDX];
    qidIdx_own = [[user_defaults valueForKey:kConstant_ownQidIDX] intValue];
    //qidIdx_own = 0;
    
    max_preload = 40;
    max_load = 10;
    inLoading_preload = 0;
    for(int i = 0 ; i < max_preload ; i++){
        loadtagImg_pre[i] = [[UIImageView alloc] init];
        loadtagImg_pre[i].frame = CGRectMake(2000, 2000, 1, 1);
    }
    
    currentThread = 0;
    page_which = 0;
    requestFail_time = 0;
    can_nextTag = false;
    likeAwardToFish = 0;
    tappingOut = false;
    prev_id_update = -1;
    timeAim_preload = 1;
    isInSelectseikeView = false;
    runningTime = 0;
    isBlocked = false;
    refundChecking_counter = 3;
    loopChecking = false;
    refund_isGettingBack = false;
    isLoadingTag = false;
    own_time_running = 0;
    isADEnable = false;
    isAutomatic = false;
    
    //delete
   // isAutomatic = true;
    
    automacticNoFeed = false;
    automaticTimer = 0;
    automacticInterval = 5;
    
    self.accuImages = [NSMutableArray array];
    
    seikeAvailable = 60;
    seikeAvailableReturn = 60;
    seikeAvailableTimer = 0;
    seikeAvailableHasInit = false;
    
    isFish = false;
    hasShownOwnAdInThisSession = false;
    
    /* NSArray* aa = [[NSArray alloc] initWithObjects:@"ABC", @"DEF", nil];
     for(int i = 0 ; i < [aa count] ; i++){
     }*/
    
    
    // [user_defaults setValue:aa forKeyPath:kConstant_saveTagID];
    
    
    maxID_thumbnail = [NSMutableString stringWithString:@""];
    minID_thumbnail = [NSMutableString stringWithString:@""];
    tagmedia_ID_updating = [NSMutableString stringWithString:@""];
    
    
    
    //self.lineImgv.frame = CGRectMake(160, 50, 281, 0.5);
    
    //user_defaults = [NSUserDefaults standardUserDefaults];
    
    unsaveHistoryArray = [[NSMutableArray alloc] initWithArray:[user_defaults objectForKey:kConstant_unsaveTagID]];
    saveArray = [[NSMutableArray alloc] initWithArray:[user_defaults objectForKey:kConstant_saveTagID]];
    [self delete_print_history];
    

    //set corner radious of image view
    //    [self.itag.layer setCornerRadius:15];
    //    self.itag.clipsToBounds = YES;
    //
    //get likes
    self.scrollview.contentSize = CGSizeMake(273, 350);
    [self.scrollview setDelegate:self];
    [self.Scrollview_2 setDelegate:self];
    // [self.scrollview showsVerticalScrollIndicator];
    self.scrollview.showsVerticalScrollIndicator = YES;
    [self.scrollview flashScrollIndicators];
    self.thumbnails = [[NSMutableArray alloc]init];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *accessToken = [defaults objectForKey:kConstant_AccessKey];
    if (accessToken) {
       
        //delete
        //p_key_type_forceToLogout = true;
        
        //[self getVersion:false];
        if(p_key_type_forceToLogout){
            [self load_tagview];
            p_key_type_forceToLogout = false;
        }else{
            [self getVersion:false];
        }
        
    }
    
    if ([self.focousView isEqualToString:kConstant_MenuChangedToTag])
    {
        [self.tagDia_2_btn setSelected:YES];
        [self.tagDiamond_btn setSelected:NO];
        [self.increaseTagView setHidden:NO];
    }
    if ([self.focousView isEqualToString:kConstant_MenuCaangedToDiamond])
    {
        [self.tagDia_2_btn setSelected:NO];
        [self.tagDiamond_btn setSelected:YES];
        [self.increaseTagView setHidden:YES];
    }
    
    self.Scrollview_2.contentSize=CGSizeMake(320, 10);
    
    if(isIphone6){
        self.itag.frame = CGRectMake(32 + 27, 40, 256, 256);
        self.itagThumnail.frame = CGRectMake(32 + 27, 40, 256, 256);
        
        self.msg_btn.frame = CGRectMake(self.msg_btn.frame.origin.x + 27,
                                        self.msg_btn.frame.origin.y - 34,
                                        self.msg_btn.frame.size.width,
                                        self.msg_btn.frame.size.height);
        
        self.img_btn.frame = CGRectMake(self.img_btn.frame.origin.x + 27,
                                        self.img_btn.frame.origin.y - 34 ,
                                        self.img_btn.frame.size.width,
                                        self.img_btn.frame.size.height);
        
    }else if(isIphone6P){
        self.itag.frame = CGRectMake(32 + 47, 40, 256, 256);
        self.itagThumnail.frame = CGRectMake(32 + 47, 40, 256, 256);
        
        self.msg_btn.frame = CGRectMake(self.msg_btn.frame.origin.x + 47,
                                        self.msg_btn.frame.origin.y - 104,
                                        self.msg_btn.frame.size.width,
                                        self.msg_btn.frame.size.height);
        
        self.img_btn.frame = CGRectMake(self.img_btn.frame.origin.x + 47,
                                        self.img_btn.frame.origin.y - 104,
                                        self.img_btn.frame.size.width,
                                        self.img_btn.frame.size.height);
    }else if(isOldIphone){
        self.itag.frame = CGRectMake(32, 6, 256, 256);
        self.itagThumnail.frame = CGRectMake(32, 6, 256, 256);
        
        
        self.msg_btn.frame = CGRectMake(self.msg_btn.frame.origin.x,
                                        self.msg_btn.frame.origin.y + 14,
                                        self.msg_btn.frame.size.width,
                                        self.msg_btn.frame.size.height);
        
        self.img_btn.frame = CGRectMake(self.img_btn.frame.origin.x,
                                        self.img_btn.frame.origin.y + 14,
                                        self.img_btn.frame.size.width,
                                        self.img_btn.frame.size.height);
    }
    
    if(isIphone6){
        self.tagDia_2_btn.frame = CGRectMake(196,
                                             self.tagDia_2_btn.frame.origin.y,
                                             self.tagDia_2_btn.frame.size.width + 0,
                                             self.tagDia_2_btn.frame.size.height);
        
        self.tagDiamond_btn.frame = CGRectMake(0,
                                               self.tagDiamond_btn.frame.origin.y,
                                               self.tagDiamond_btn.frame.size.width + 18,
                                               self.tagDiamond_btn.frame.size.height);
        
        self.centermenu_btn.frame = CGRectMake(154,
                                               self.centermenu_btn.frame.origin.y,
                                               self.centermenu_btn.frame.size.width,
                                               self.centermenu_btn.frame.size.height);
        
    }
    
    if(isIphone6P){
        self.tagDia_2_btn.frame = CGRectMake(220,
                                             self.tagDia_2_btn.frame.origin.y,
                                             self.tagDia_2_btn.frame.size.width + 10,
                                             self.tagDia_2_btn.frame.size.height);
        
        self.tagDiamond_btn.frame = CGRectMake(0,
                                               self.tagDiamond_btn.frame.origin.y,
                                               self.tagDiamond_btn.frame.size.width + 30,
                                               self.tagDiamond_btn.frame.size.height);
        
        self.centermenu_btn.frame = CGRectMake(175,
                                               self.centermenu_btn.frame.origin.y,
                                               self.centermenu_btn.frame.size.width,
                                               self.centermenu_btn.frame.size.height);
        
    }

    
    photoLoading_url_timer = -1;
    NSTimer* _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(LoopingTimer:) userInfo:nil repeats:YES];
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(pressedMenuButton)];
    
    
    //set center menu fram
    //    self.center_uiview.frame =CGRectMake(0, self.view.frame.size.height, 320, 130);
    
    [self setTopBar];
    
    //init
    //p_key = @"b4a23f5e39b5929e0666ac5de94c89d1618a2916";
    //p_key_type = 1;
    
    hasIniit_tag_VC = false;
    [self getFirstVersion];
    //[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(getFirstVersion) userInfo:nil repeats:NO];
    [self.view makeToastActivity];
}

-(void) setTopBar{
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text= @"Get Coins";
    label.textColor=[UIColor blackColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    if(isIpad){
        label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:29];
    }else{
        label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:16.5];
    }
    label.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView=label;
    
    user_defaults = [NSUserDefaults standardUserDefaults];
    NSString *coins = [user_defaults valueForKey:kConstant_Diamond];
    if (coins) {
        self.diamond_lbl.text = coins;
    }
    
    
    // [RageIAPHelper sharedInstance].delegate = self;
    
    [self setTitle:@"Get Coins"];
    
    
    //set right menu button
    button_store = [UIButton buttonWithType:UIButtonTypeCustom];
    button_store.frame = CGRectMake(0, 0, 19 * ipadRatio, 19 * ipadRatio);
    [button_store setImage:[UIImage imageNamed:@"icon_coin.png"] forState:UIControlStateNormal];
    [button_store addTarget:self action:@selector(goto_store:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barRightButton=[[UIBarButtonItem alloc] init];
    [barRightButton setCustomView:button_store];
    
    self.diamond_lbl.frame = CGRectMake(0, 0, 30 * ipadRatio, 20 * ipadRatio);
    
    UIBarButtonItem *barLbl=[[UIBarButtonItem alloc] init];
    [barLbl setCustomView:self.diamond_lbl];
    
    NSArray *barItems = [[NSArray alloc]initWithObjects:barRightButton,barLbl, nil];
    self.navigationItem.rightBarButtonItems=barItems;
    
    // [self.view makeToastActivity];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(press_back_button)];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
}

-(void) press_back_button{

}

-(void) pressedMenuButton{
    UIButton *btn = self.centermenu_btn;
    [btn setSelected:!btn.isSelected];
    
    if ([btn isSelected]) {
        [self showCenterMenu];
        
        [self.tagDiamond_btn setSelected:NO];
        [self.tagDia_2_btn setSelected:NO];
        
        [btn_donotandDonot setAlpha:0];
        
    }else
    {
        [self hideCenterMenu:1];
        
        if(page_which == 0){
            [self.tagDiamond_btn setSelected:YES];
        }
        if(page_which == 1){
            [self.tagDia_2_btn setSelected:YES];
        }
        
        [btn_donotandDonot setAlpha:1];
    }
}

-(void) LoopingTimer:(NSTimer*) timer{
    
    if(isAutomatic){
        if(can_nextTag){
            automaticTimer++;
            
            if(automaticTimer % automacticInterval == 0){
                [self TagImage:nil];
                automacticNoFeed = false;
            }else{
                
                if(automacticNoFeed){
                    automacticInterval = 60;
                }else{
                    automacticInterval = 5 + requestFail_time * 60;
                }
                
            }
        }
    }
    
    seikeAvailableTimer++;
    if(seikeAvailableTimer >= likeBlockTimer){
        seikeAvailable++;
        if(seikeAvailable >= seikeAvailableReturn){
            seikeAvailable = seikeAvailableReturn;
        }
        seikeAvailableTimer = 0;
    }
    
    if(!preloading){
        
        if(photoLoading_url_timer >= 0){
            photoLoading_url_timer++;
            
            if(photoLoading_url_timer == 3){
                [self.itag hideToastActivity];
                can_nextTag = true;
                photoLoading_url_timer = -1;
                
                loaded_pre[idx_preload] = true;
            }else{
                [self.itag makeToastActivity];
            }
            
            if(photoLoading_url_timer == 1){
                
                /*
                self.itagThumnail.frame = CGRectMake(32, 6, 256, 256);
                
                [self.itagThumnail setImageWithURL:[currentImageData valueForKey:@"photo_thumnailurl"] success:^(UIImage *image, BOOL cached) {
                } failure:^(NSError *error) {
                }];*/
            }
        }
    }else{
        timer_preload++;
        
        if(timer_preload >= timeAim_preload){
            
            self.itag.image = loadtagImg_pre[idx_preload].image;
            [self.itag hideToastActivity];
            photoLoading_url_timer = -1;
            loaded_pre[idx_preload] = true;
            can_nextTag = true;
            preloading = false;
        }
    }
    
    if(isBlocked){
        [self.reqFailCounter_lbl setAlpha:1];
        
        NSMutableString* requestFailedTimerString = [NSMutableString string];
        [requestFailedTimerString setString:@"00:"];
         if(blockedTimer >= 10){
         
         }else{
             [requestFailedTimerString appendString:@"0"];
         }
         
        [requestFailedTimerString appendFormat:@"%i", blockedTimer];
        blockedTimer--;
         
        self.reqFailCounter_lbl.text = requestFailedTimerString;
        
        if(blockedTimer == 0){
            isBlocked = false;
        }
    }else{
        [self.reqFailCounter_lbl setAlpha:0];
    }
    
    if(!refund_isGettingBack){
        refundChecking_counter--;
    }
    
    if(refundChecking_counter == 0){
        loopChecking = true;
        refundChecking_counter = 180;
        [self getVersion:false];
    }
}

-(void) thumbnail_load_for_mainimg{
    //[self.itagThumnail setImageWithURL:@"liker.j2sighte.com/api/IMG_SMALL.png" success:^(UIImage *image, BOOL cached) {
//    [self.itagThumnail sd_setImageWithURL:[currentImageData valueForKey:@"photo_url"] success:^(UIImage *image, BOOL cached) {
//    } failure:^(NSError *error) {
//    }];   old
    
    [self.itagThumnail sd_setImageWithURL:[currentImageData valueForKey:@"photo_url"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self check_tag_status];
    [self hideCenterMenu:0.1];
}

-(void)load_all_feed{
    if(isLoadingTag){
        return;
    }
    isLoadingTag = true;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    AFHTTPClient *httpClient;
    [params setValue:[NSString stringWithFormat:@"%i",qidIdx_own]  forKey:@"p_qidIdx"];
    httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_displayPhotos_ALL.php",@"http://liker.j2sighte.com/api/"]]];
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSObject *result=nil;
        SBJsonParser *parser=[[SBJsonParser alloc]init];
        result =  [parser objectWithString:responseStr];
        
        isLoadingTag = false;
        
        feedsArry = (NSMutableArray*)result;
        
        [self.view hideToastActivity];
        
        if (feedsArry.count <= 0)
        {
            [self.view hideToastActivity];
            [self.itag hideToastActivity];
            [self popup_nofeed_alert];
            
        }else{
            
            if([self checkCanLikeEitherPhotoInFeed]){
                noTagFeed = false;
                [self.itag makeToastActivity];
                [self checkAndLoadThisImg];
            }else{
                [self.view hideToastActivity];
                [self popup_nofeed_alert];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        isLoadingTag = false;
    }];
}

-(void)check_tag_status{
    if ([user_defaults objectForKey:kConstant_AccessKey] == nil || [user_defaults valueForKey:kConstant_UID] == nil || [user_defaults valueForKey:kConstant_Cookie] == nil || [user_defaults valueForKey:kConstant_DevID] == nil || [user_defaults valueForKey:kConstant_Session] == nil) {
        
        if ([user_defaults objectForKey:kConstant_AccessKey] == nil){
        }
        if ([user_defaults valueForKey:kConstant_UID] == nil){
        }
        if ([user_defaults valueForKey:kConstant_Cookie] == nil){
        }
        if ([user_defaults valueForKey:kConstant_DevID] == nil){
        }
        if ([user_defaults valueForKey:kConstant_Session] == nil){
        }
        
        [self load_tagview];
    }
}

-(void) load_tagview{
    //LoginViewController *vc;
    hasIniit_tag_VC = true;
    
    static bool hasInitLoginBefore = false;
    
    if(!hasInitLoginBefore){
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            viewController_LogTag = [[ViewController_LogTag alloc] init];
            [viewController_LogTag set_delegate:self];
            //[self.view addSubview:ViewController_LogTag.view];
            [self presentViewController:viewController_LogTag animated:YES completion:^{
            }];
        }else{
            viewController_LogTag = [[ViewController_LogTag alloc] init];
            [viewController_LogTag set_delegate:self];
            //[self.view addSubview:ViewController_LogTag.view];
            [self presentViewController:viewController_LogTag animated:YES completion:^{
            }];
        }
        
        hasInitLoginBefore = true;
    }else{
        [self presentViewController:viewController_LogTag animated:NO completion:^{
        }];
    }
}

- (IBAction)skipTag:(id)sender {
    if(isLogged){
        [self ask_update_version_to_new];
        return;
    }
    
    if(!can_nextTag){
        [self.itag makeToastActivity];
        return;
    }
    
    if(tappingOut){
        return;
    }
    
    if([self checkIfNullUser]){
        return;
    }
    
    if(isBlocked){
        return;
    }
    
    if(isInsertingTMD){
        return;
    }
    
    can_nextTag = false;
    
    [self load_next_tags];
    // [self updateSkipLike:0];
}

- (IBAction)TagImage:(id)sender {
    
    if(isLogged){
        [self ask_update_version_to_new];
        return;
    }
    
    if(!can_nextTag){
        [self.itag makeToastActivity];
        return;
    }
    
    if(tappingOut){
        return;
    }
    
    if([self checkIfNullUser]){
        return;
    }
    
    if(isInsertingTMD){
        return;
    }
    
    if(noTagFeed){
        [self load_all_feed];
        return;
    }
    
    if(isBlocked){
        return;
    }
    
    if(isADEnable){
        if(adInterval % 3 == 0){
            //can add revmomb ad here later

        }
        adInterval++;
    }
    
    can_nextTag = false;
    
    [self.itag makeToastActivity];
    
    int curntCoins = (int)[[self.diamond_lbl text] integerValue];
    self.diamond_lbl.text = [NSString stringWithFormat:@"%i",curntCoins + 1];
    [user_defaults setValue:[NSString stringWithFormat:@"%i",curntCoins+1] forKey:kConstant_Diamond];
    [user_defaults synchronize];
    
    
    qid_updateing = [[currentImageData valueForKey:@"qid"] intValue];
    orderedtag_updating = [[currentImageData valueForKey:@"ordered_like"] intValue];
    tagdelivered_updating = [[currentImageData valueForKey:@"delivered_like"] intValue];
    tagmedia_ID_updating = [currentImageData valueForKey:@"media_id"];
    totaltagordered_updating = [[currentImageData valueForKey:@"totalOrdered_like"] intValue];
    
    seikeAvailable--;
    if(seikeAvailable < 0){
        seikeAvailable = 0;
    }
    
    if(orderedtag_updating >= 9999999){
        
        if(prev_id_update != qid_updateing){
            
            failDiamond_fromserver = 0;
            [self updateCurrentLikes];
            //[self updateSkipLike:1];//1 mean user like image
            [self increase_diamond:1];
            
         //   [self saveHistory:tagmedia_ID_updating];
            
            [self requestSuccess];
            
            prev_id_update = qid_updateing;
            
            if(seikeAvailable <= 0){
                seikeAvailable = 1;
                own_time_running++;
                
                if(own_time_running >= 7){
                    own_time_running = 0;
                }
            }
            
            if(qidIdx_own < qid_updateing){
                qidIdx_own = qid_updateing + 1;
                [user_defaults setValue:[NSString stringWithFormat:@"%i",qidIdx_own] forKey:kConstant_ownQidIDX];
                [user_defaults synchronize];
            }
        }
        
        [self load_next_tags];
        
        return;
    }
    
    [self get_session_init];
    if(!isSessionExpired){
        [self cointue_tag_increase];
    }else{
        [self get_session_2ndtime];
    }
}

-(void) cointue_tag_increase{
    NSMutableString* likeString = [NSMutableString string];
    
    if(p_key_type == 0){
        [likeString setString:@"http://i.instagram.com/api/v1/media/"];
    }else{
        //android IG 5.2.1 also use this?
        [likeString setString:@"http://i.instagram.com/api/v1/media/"];
    }
    
    [likeString appendString:[currentImageData valueForKey:@"media_id"]];
    // [likeString appendString:@"724778629267393281_385764545"];
    [likeString appendString:@"/like/"];
    
    NSURL *aUrl = [NSURL URLWithString:likeString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl];
    
    [request setHTTPMethod:@"POST"];
    
    if ([user_defaults objectForKey:kConstant_AccessKey] == nil || [user_defaults valueForKey:kConstant_UID] == nil || [user_defaults valueForKey:kConstant_Cookie] == nil || [user_defaults valueForKey:kConstant_DevID] == nil) {
        [self popup_tag_out_warning];
        return;
    }
    
    NSString *unencodedCookie = [[user_defaults valueForKey:kConstant_Cookie] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setValue:unencodedCookie forHTTPHeaderField:@"Cookie"];
    
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
    
    
    NSMutableString *unencodedUrlStringEncode = [NSMutableString string];
    
    if(p_key_type == 0){
        //ios
        [unencodedUrlStringEncode setString:@"%7B%22media_id%22%3A%22"];
        [unencodedUrlStringEncode appendString:[currentImageData valueForKey:@"media_id"]];
        [unencodedUrlStringEncode appendString:@"%22%2C%22_csrftoken%22%3A%22"];
        [unencodedUrlStringEncode appendString:[user_defaults valueForKey:kConstant_Token]];
        [unencodedUrlStringEncode appendString:@"%22%7D"];
        
    }else{
        [unencodedUrlStringEncode setString:@"%7B%22_uid%22%3A%22"];
        [unencodedUrlStringEncode appendString:[user_defaults valueForKey:kConstant_UID]];
        [unencodedUrlStringEncode appendString:@"%22%2C%22_csrftoken%22%3A%22"];
        [unencodedUrlStringEncode appendString:[user_defaults valueForKey:kConstant_Token]];
        [unencodedUrlStringEncode appendString:@"%22%2C%22media_id%22%3A%22"];
        [unencodedUrlStringEncode appendString:[currentImageData valueForKey:@"media_id"]];
        [unencodedUrlStringEncode appendString:@"%22%7D"];
    }
    
    [s_postToLikePhoto setString:@"signed_body="];
    [s_postToLikePhoto appendString:[ExtraTools getOnesCode:[ExtraTools getFkKey:@"eeg43d25ddbd35a82a8b95780755bdc8"] k:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [s_postToLikePhoto appendString:@"."];
    [s_postToLikePhoto appendString:[unencodedUrlStringEncode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [s_postToLikePhoto appendString:@"&ig_sig_key_version=4&src=timeline&d=0"];
    
    //  NSString *postString = @"company=Locassa&quality=AWESOME!";
    [request setHTTPBody:[s_postToLikePhoto dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

//real for key == 2 - 6.4.1 (sig = 5 key)
-(void) get_session_2ndtime{
    
    NSURL *baseURL;
    baseURL = [NSURL URLWithString:[NSMutableString stringWithString:[ExtraTools getOneCode:@"300MD?--n.nsD0fNwfi.2mi"]]];
    
    NSMutableString* gotoPath = [NSMutableString string];
    [gotoPath setString:[ExtraTools getOneCode:@"-fMn-pK-iv8nf-"]];
    [gotoPath appendString:[currentImageData valueForKey:@"media_id"]];
    
    // -> /like/?d=0&src=timeline
    [gotoPath appendString:[ExtraTools getOneCode:@"-Vngv-!8=A"]];
    
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
    
    
    NSString *unencodedCookie;
    if(p_key_type == 27){
        unencodedCookie = [u getCk_27];
    }else{
        unencodedCookie = [u getCk];
    }
    [request addValue:unencodedCookie forHTTPHeaderField:@"Cookie"];
    
    
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
        [unencodedUrlStringEncode setString:@"%7B%22_csrftoken%22%3A%22"];
        [unencodedUrlStringEncode appendString:[user_defaults valueForKey:kConstant_Token]];
        [unencodedUrlStringEncode appendString:@"%22%2C%22module_name%22%3A%22"];
        [unencodedUrlStringEncode appendString:@"feed_timeline"];
        [unencodedUrlStringEncode appendString:@"%22%2C%22_uuid%22%3A%22"];
        [unencodedUrlStringEncode appendString:ranDevice];
        [unencodedUrlStringEncode appendString:@"%22%2C%22media_id%22%3A%22"];
        [unencodedUrlStringEncode appendString:[currentImageData valueForKey:@"media_id"]];
        [unencodedUrlStringEncode appendString:@"%22%2C%22_uid%22%3A%22"];
        [unencodedUrlStringEncode appendString:[defaults valueForKey:kConstant_UID]];
        [unencodedUrlStringEncode appendString:@"%22%7D"];
    }else{
        [unencodedUrlStringEncode setString:@"%7B%22_csrftoken%22%3A%22"];
        [unencodedUrlStringEncode appendString:[user_defaults valueForKey:kConstant_Token]];
        [unencodedUrlStringEncode appendString:@"%22%2C%22media_id%22%3A%22"];
        [unencodedUrlStringEncode appendString:[currentImageData valueForKey:@"media_id"]];
        [unencodedUrlStringEncode appendString:@"%22%2C%22_uuid%22%3A%22"];
        [unencodedUrlStringEncode appendString:ranDevice];
        [unencodedUrlStringEncode appendString:@"%22%2C%22module_name%22%3A%22"];
        [unencodedUrlStringEncode appendString:@"feed_timeline"];
        [unencodedUrlStringEncode appendString:@"%22%2C%22uid%22%3A%22"];
        [unencodedUrlStringEncode appendString:[defaults valueForKey:kConstant_UID]];
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
         
         [self check_tag_result:response];
         
         //[self saveUserDataAndContinue];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [self requestFail];
         [self save_feed_history:tagmedia_ID_updating];
         prev_id_update = qid_updateing;
         [self load_next_tags];
         // NSString *errorBodyMessage = [[error userInfo] objectForKey:@"NSLocalizedRecoverySuggestion"];
     }];
    [operation start];
}

-(void) tag_one{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [params setValue:tagmedia_ID_updating forKey:@"p_mediaID"];
    [params setValue:[NSString stringWithFormat:@"%i", orderedtag_updating] forKey:@"p_orderedLike"];
    [params setValue:[NSString stringWithFormat:@"%i", qid_updateing] forKey:@"p_qID"];
    [params setValue:[NSString stringWithFormat:@"%i", tagdelivered_updating] forKey:@"p_deliveredLike"];
    [params setValue:[NSString stringWithFormat:@"%i", totaltagordered_updating] forKey:@"p_totalOrderedLike"];
    [params setValue:[defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[user_defaults valueForKey:kConstant_Session]  forKey:@"p_sessionID"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    unsigned char *digest2 = (unsigned char *)[hmac_key_data(@"3c76a5cb90c5124d", [defaults valueForKey:kConstant_UID]) bytes];
    
    // Convert the bytes to their hex representation
    NSMutableString *hmacStr2 = [NSMutableString string];
    [hmacStr2 setString:@""];
    for(int i = 0 ; i < CC_SHA256_DIGEST_LENGTH ; i++){
        [hmacStr2 appendFormat:@"%02x", digest2[i]];
    }
    
    [params setValue:hmacStr2 forKey:@"coded"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_likeOnePhoto.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([responseStr integerValue] == -1) {
            //kConstant_Session
            [self expired_session];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

-(void) expired_session{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Session ID is expired" message:@"Please try to log out and then login again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)updateCurrentLikes{
    
    [self tag_one];
    return;
}

-(void)increase_diamond:(int)coins{
    
    [self get_session_init];
    if(!isSessionExpired){
        [self continueToincrease_diamond];
    }else{
        [self get_session_2ndtime_Inside];
    }
}

-(void) continueToincrease_diamond{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    unsigned char *digest2 = (unsigned char *)[hmac_key_data(@"8c77c5dc9165b34a", [defaults valueForKey:kConstant_UID]) bytes];
    
    // Convert the bytes to their hex representation
    NSMutableString *hmacStr2 = [NSMutableString string];
    [hmacStr2 setString:@""];
    for(int i = 0 ; i < CC_SHA256_DIGEST_LENGTH ; i++){
        [hmacStr2 appendFormat:@"%02x", digest2[i]];
    }
    
    [params setValue:hmacStr2 forKey:@"coded"];
    
    NSURL *baseURL;
    baseURL = [NSURL URLWithString:@"http://liker.j2sighte.com"];
    
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [httpClient defaultValueForHeader:@"Accept"];
    
    NSString* gotoPath;
    if(orderedtag_updating >= 9999999){
        gotoPath = @"/api/p_addOneFakeCoin_Expert.php";
    }else{
        gotoPath = @"/api/p_addOneCoin_Expert.php";
    }
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:gotoPath parameters:params];
    [request setValue:[NSString stringWithString:[defaults valueForKey:kConstant_UID]] forHTTPHeaderField:@"Set-Cookie"];
    
    //Add your request object to an AFHTTPRequestOperation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    
    
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation,
       id responseObject) {
         NSString *response = [operation responseString];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         failDiamond_fromserver++;
         if(failDiamond_fromserver < 2){
             [self increase_diamond:1];
         }
     }];
    
    //call start on your request operation
    [operation start];
}

//real to add coins to server
-(void) get_session_2ndtime_Inside{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    unsigned char *digest2 = (unsigned char *)[hmac_key_data(@"8c77a5dc9165b34a", [defaults valueForKey:kConstant_UID]) bytes];
    
    // Convert the bytes to their hex representation
    NSMutableString *hmacStr2 = [NSMutableString string];
    [hmacStr2 setString:@""];
    for(int i = 0 ; i < CC_SHA256_DIGEST_LENGTH ; i++){
        [hmacStr2 appendFormat:@"%02x", digest2[i]];
    }
    
    [params setValue:hmacStr2 forKey:@"coded"];
    
    
    NSURL *baseURL;
  //  baseURL = [NSURL URLWithString:@"http://liker.j2sighte.com"];
    baseURL = [NSURL URLWithString:[ExtraTools getOneCode:@"300M?--Vngvw.ByDnN30v.2mi"]];
    
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [httpClient defaultValueForHeader:@"Accept"];
    
    NSString* gotoPath;
    if(orderedtag_updating >= 9999999){
        //gotoPath = @"/api/p_addOneFakeCoin_Expert.php";
        gotoPath = [ExtraTools getOneCode:@"-fMn-M_f88osvhfgvZmns_z5Mvw0.M3M"];
    }else{
       // gotoPath = @"/api/p_addOneCoin_Expert.php";
        gotoPath = [ExtraTools getOneCode:@"-fMn-M_f88osvZmns_z5Mvw0.M3M"];
    }
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:gotoPath parameters:params];
    [request setValue:[NSString stringWithString:[defaults valueForKey:kConstant_UID]] forHTTPHeaderField:@"Set-Cookie"];
    
    //Add your request object to an AFHTTPRequestOperation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    
    
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation,
       id responseObject) {
         NSString *response = [operation responseString];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         failDiamond_fromserver++;
         if(failDiamond_fromserver < 2){
             [self increase_diamond:1];
         }
     }];
    
    //call start on your request operation
    [operation start];
}

-(void)getFreeDiamond{
    self.diamond_lbl.text = [user_defaults valueForKey:kConstant_Diamond];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_getCoinsFromUser_2.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSObject *result=nil;
        
        SBJsonParser *parser=[[SBJsonParser alloc]init];
        result =  [parser objectWithString:responseStr];
        
        
        NSArray *resultArray = (NSArray*)result;
        if (resultArray.count>0) {
            NSDictionary *dict = (NSDictionary*)[resultArray objectAtIndex:0];
            self.diamond_lbl.text = [dict valueForKey:@"coins"];
            [user_defaults setValue:[dict valueForKey:@"coins"] forKey:kConstant_Diamond];
            [user_defaults synchronize];
            
            if([[dict valueForKey:@"refundAmt"] intValue] > 0){
                refundAmt = [[dict valueForKey:@"refundAmt"] intValue];
                
                refund_isGettingBack = true;
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You are getting REFUND" message:@"Your photo(s) can't be liked by others. Please login to Instagram and turn off the 'Posts are Private'. Make sure it is set in 'Public'." delegate:self cancelButtonTitle:@"GET REFUND" otherButtonTitles:nil, nil];
                [alert show];
                alert.tag = 1007;
               
            }
            
            if([[dict valueForKey:@"rewardAmt"] intValue] > 0 && responseVersion == kVersion){
                rewardAmt = [[dict valueForKey:@"rewardAmt"] intValue];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You are getting coins" message:@"You'll get coins every time when you update the app to the latest version." delegate:self cancelButtonTitle:@"GET COINS" otherButtonTitles:nil, nil];
                [alert show];
                alert.tag = 1008;
                
            }
            
            if([[dict valueForKey:@"ownAdAmount"] intValue] > 0){
                ownAmt = [[dict valueForKey:@"ownAdAmount"] intValue];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You are getting coins" message:@"You should get coins for both apps. Restart the apps if you don't get the coins." delegate:self cancelButtonTitle:@"GET COINS" otherButtonTitles:nil, nil];
                [alert show];
                alert.tag = 1011;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (IBAction)load_next_tags:(id)sender {
    [self load_next_tags];
}

- (IBAction)pressDiamond:(id)sender {
    if(isLogged){
        [self ask_update_version_to_new];
        return;
    }
    
    if(!can_nextTag){
        [self.itag makeToastActivity];
        return;
    }
    
    if(tappingOut){
        return;
    }
    
    if([self checkIfNullUser]){
        return;
    }
    
    if(isInsertingTMD){
        return;
    }
    
    [self tryAskRate];
    
    [btn_donotandDonot setAlpha:1.0];
    
    UIButton *btn = sender;
    [btn setSelected:YES];

    [self.tagDiamond_btn setBackgroundColor:[UIColor colorWithRed:92.0/255.0 green:175.0/255.0 blue:164.0/255.0 alpha:1.0]];
    [self.tagDia_2_btn setBackgroundColor:[self colorWithHex:0xececec]];
    [self.tagDia_2_btn setSelected:NO];
    [self.centermenu_btn setSelected:NO];
    
    [self.increaseTagView setHidden:YES];
    [self hideCenterMenu:1];
    
    // if(thumbnail_isloading){
    //    thumbnail_isloading = false;
    [self.view hideToastActivity];
    // }
    
    page_which = 0;
    
}
- (IBAction)pressPageLeft:(id)sender {
    if(isLogged){
        [self ask_update_version_to_new];
        return;
    }
    
    if(!can_nextTag){
        [self.itag makeToastActivity];
        return;
    }
    
    if(tappingOut){
        return;
    }
    
    if([self checkIfNullUser]){
        return;
    }
    
    if(isInsertingTMD){
        return;
    }
    
    [self tryAskRate];
    
    [btn_donotandDonot setAlpha:0];
    
    UIButton *btn = sender;
    [btn setSelected:YES];
    [self.tagDiamond_btn setSelected:NO];
    [self.centermenu_btn setSelected:NO];
        
    [self.tagDia_2_btn setBackgroundColor:[UIColor colorWithRed:92.0/255.0 green:175.0/255.0 blue:164.0/255.0 alpha:1.0]];
    [self.tagDiamond_btn setBackgroundColor:[self colorWithHex:0xececec]];
    
    [self.increaseTagView setHidden:NO];
    [self hideCenterMenu:1];
    
    [self.thumbnails removeAllObjects];
    [self.accuImages removeAllObjects];
    [self requestImages];
    currentThread++;
    
    page_which = 1;
    
}
- (IBAction)pressCenter:(id)sender {
    if(isLogged){
        [self ask_update_version_to_new];
        return;
    }
    
    if(!can_nextTag){
        [self.itag makeToastActivity];
        return;
    }
    
    if(tappingOut){
        return;
    }
    
    if([self checkIfNullUser]){
        return;
    }
    
    if(isInsertingTMD){
        return;
    }
        
    UIButton *btn = sender;
    [btn setSelected:!btn.isSelected];
    
    if ([btn isSelected]) {
        [self showCenterMenu];
        
        [self.tagDiamond_btn setSelected:NO];
        [self.tagDia_2_btn setSelected:NO];
        
        [btn_donotandDonot setAlpha:0];
        
    }else
    {
        [self hideCenterMenu:1];
        
        if(page_which == 0){
            [self.tagDiamond_btn setSelected:YES];
        }
        if(page_which == 1){
            [self.tagDia_2_btn setSelected:YES];
        }
        
        [btn_donotandDonot setAlpha:1];
    }
}

-(void)showCenterMenu{
    [UIView animateWithDuration:1.0f animations:^{
        //        [optionView setFrame:CGRectMake(16, 200, 63, 35)];
        
        int menu_offsetX = 0;
        if(isIphone6){
            menu_offsetX = 27;
        }
        if(isIphone6P){
            menu_offsetX = 47;
        }
        
        if(isIpad){
             self.center_uiview.frame =CGRectMake(menu_offsetX, self.view.frame.size.height-kcenterMenuHeight * 2, 768, kcenterMenuHeight * 2);
        }else{
             self.center_uiview.frame =CGRectMake(menu_offsetX, self.view.frame.size.height-kcenterMenuHeight, 320, kcenterMenuHeight);
        }
    }];
}
-(void)hideCenterMenu:(float)time{
    
    [UIView animateWithDuration:time animations:^{
        //        [optionView setFrame:CGRectMake(16, 200, 63, 35)];
        
        int menu_offsetX = 0;
        if(isIphone6){
            menu_offsetX = 27;
        }
        if(isIphone6P){
            menu_offsetX = 47;
        }
        
        if(isIpad){
            self.center_uiview.frame =CGRectMake(menu_offsetX, self.view.frame.size.height * 2, 768, kcenterMenuHeight * 2);
        }else{
            self.center_uiview.frame =CGRectMake(menu_offsetX, self.view.frame.size.height + 30, 320, kcenterMenuHeight);
        }
    }];
}

- (IBAction)pressTagOut:(id)sender {
    if(isLogged){
        [self ask_update_version_to_new];
        return;
    }
    
    if(tappingOut){
        return;
    }
    
    
    if([unsaveHistoryArray count] > 0){
        
        tappingOut = true;
        
        
        NSString* jasonString = [unsaveHistoryArray JSONRepresentation];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        [params setValue:jasonString forKey:@"jsonForUnsaveString"];
        [params setValue:[user_defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
        [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
        [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_insertHistory.php",@"http://liker.j2sighte.com/api/"]]];
        
        
        [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            [saveArray addObjectsFromArray:unsaveHistoryArray];
            [unsaveHistoryArray removeAllObjects];
            
            [user_defaults setObject:saveArray forKey:kConstant_saveTagID];
            [user_defaults setObject:unsaveHistoryArray forKey:kConstant_unsaveTagID];
            [user_defaults synchronize];
            
            [self delete_print_history];
            [self tag_out];
            
            tappingOut = false;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Log out failed" message:@"Please try again" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
            
            tappingOut = false;
            
        }];
        
        return;
    }
    
    [self tag_out];
}

-(void) tag_out{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kConstant_AccessKey];
    //    [defaults removeObjectForKey:kConstant_Diamond];
    //    [defaults removeObjectForKey:kConstant_UID];
    [defaults synchronize];
    [self check_tag_status];
    [self hideCenterMenu:0.1];
    [self.centermenu_btn setSelected:NO];
    
    // tappingOut = false;
}

- (IBAction)pressStore:(id)sender {
    return;
}

- (IBAction)pressInstruction:(id)sender {
       
}

-(void) tryAskRate{
    //[user_defaults setValue:[NSString stringWithFormat:@"%i", 0] forKey:kConstant_VersionRate];
   // [user_defaults synchronize];
    
   // counterForRate++;
    
    if(canAskRate == 0){
        return;
    }
    
    static int prevRateCounter = 0;
    static int prevOwnADCounter = 0;
    bool canRate = false;
    
    int ranChose = arc4random() % 100;
    
    if(ranChose < ownAdRatio){
        //own ad
        if((counterForRate == 3 || counterForRate % 5 == 0) && counterForRate > 0){
            canRate = true;
        }
        
        if(counterForRate > 0 && prevOwnADCounter == 0){
            canRate = true;
        }
        
    }else{
        //rate
        if((counterForRate == 3 || counterForRate % 5 == 0) && counterForRate > 0){
            canRate = true;
        }
        
        if(counterForRate > 0 && prevRateCounter == 0){
            canRate = true;
        }
    }
    
    if(canRate){
        
        if(ranChose < ownAdRatio){
            //show own ad
            if([[user_defaults valueForKey:kConstant_VersionOwn] intValue] < ownAdVersion && !hasShownOwnAdInThisSession){
        
                if(responseVersion < kVersion){
                    
                }else{
                    prevOwnADCounter = counterForRate;
                    hasShownOwnAdInThisSession = true;
                    
                    [self getAdMsg];
                }
                
            }
            
        }else{
            //show rate
            if([[user_defaults valueForKey:kConstant_VersionRate] intValue] < kVersion && prevRateCounter != counterForRate){
                
                prevRateCounter = counterForRate;
                
                UIAlertView* alert;
                if(responseVersion < kVersion){
                    
                }else{
                    alert = [[UIAlertView alloc]initWithTitle:@"Rate us 5 stars to get FREE Coins? You'll be rewarded more for writting a meaningful review." message:@"" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"SURE",@"Don't ask me again", nil];
                }
                
                [alert show];
                alert.tag = 1009;
            }
        }
    }
}

- (IBAction)pressRate:(id)sender {
    if(tappingOut){
        return;
    }
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        NSString *str = @"itms-apps://itunes.apple.com/app/";
        
        // Here is the app id from itunesconnect
        str = [NSString stringWithFormat:@"%@id10000000", str];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }else{
        NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
        str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str];
        str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
        
        // Here is the app id from itunesconnect
        str = [NSString stringWithFormat:@"%@10000000", str];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

-(void) gotoUpdateVersion{
    if(isFish){
        [self gotoFishVersion];
    }else{
        [self pressRate:nil];
    }
}

-(void) gotoFishVersion{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        NSString *str = @"itms-apps://itunes.apple.com/app/";
        
        // Here is the app id from itunesconnect
        str = [NSString stringWithFormat:@"%@id%@", str, [NSString stringWithFormat:@"%i",FishLink]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }else{
        NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
        str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str];
        str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
        
        // Here is the app id from itunesconnect
        str = [NSString stringWithFormat:@"%@%@", str, [NSString stringWithFormat:@"%i",FishLink]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
    
    if(responseVersion == 98){
        exit(0);
    }
}

-(void) ask_update_version_to_new{
    if(responseVersion < 98){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"New version is available. Please go to app store to download it and you'll get FREE coins. Thanks." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        alert.tag = 103;
    }else{
        [self getFishMsg];
        isFish = true;
    }
    
    isLogged = true;

}

-(void) getFishMsg{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[NSString stringWithFormat:@"%i", kLV] forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    [params setValue:[NSString stringWithFormat:@"%i", likeAwardToFish] forKey:@"p_reward"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@getFishMsg.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSObject *result=nil;
        SBJsonParser *parser=[[SBJsonParser alloc]init];
        result =  [parser objectWithString:responseStr];
        
        FishMsg = [result valueForKey:@"m"];
        FishTitle = [result valueForKey:@"t"];
        [self showFishMsg];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        static int failFishTimer = 0;
        failFishTimer++;
        if(failFishTimer < 5){
            [self getFishMsg];
        }
        
    }];

}

-(void) showFishMsg{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:FishTitle message:FishMsg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    alert.tag = 104;
}

-(void) getAdMsg{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[NSString stringWithFormat:@"%i", kLV] forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@getOwnADMsg.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSObject *result=nil;
        SBJsonParser *parser=[[SBJsonParser alloc]init];
        result =  [parser objectWithString:responseStr];
        
        adMsg = [result valueForKey:@"m"];
        adTitle = [result valueForKey:@"t"];
        [self popup_msg_ad];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        static int failADMsgTimer = 0;
        failADMsgTimer++;
        if(failADMsgTimer < 5){
            [self getAdMsg];
        }
    }];
    
}

-(void) popup_msg_ad{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:adTitle message:adMsg delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"SURE",@"Don't ask me again", nil];
    [alert show];
    alert.tag = 1010;
}

-(void)load_next_tags{
    if (remain_preload_feed > 0) {
        [self checkAndLoadThisImg];
    }else{
        [self load_all_feed];
        
    }
}

- (IBAction)goto_store:(id)sender {
    if(!can_nextTag){
        [self.itag makeToastActivity];
        return;
    }
    
    if(tappingOut){
        return;
    }
    
    if([self checkIfNullUser]){
        return;
    }
    
    //deleted on 20160310
    //StoreViewController *vc = [[StoreViewController alloc]initWithNibName:@"StoreViewController" bundle:nil];
    //[vc set_delegate:self];
    //[self.navigationController pushViewController:vc animated:YES];
    
    IAPItemShowingOnly = true;
    [viewController_Shop load_before_appearing_view];
    [self.navigationController pushViewController:viewController_Shop animated:YES];
}


-(void) requestFail{
    //[self.reqFail_lbl setAlpha:1];
    requestFail_time++;
    if(requestFail_time % 3 == 0){
    }
    
    if(responseVersion == 2){
        [self.reqFail_lbl setAlpha:0];
        [UIView transitionWithView:self.reqFail_lbl duration:2.0
                           options:UIViewAnimationOptionCurveEaseOut
                        animations:^{
                            [self.reqFail_lbl setAlpha:1];
                        }
                        completion:^(BOOL finished){
                            if(finished){
                                [UIView transitionWithView:self.reqFail_lbl duration:1.0
                                                   options:UIViewAnimationOptionTransitionNone
                                                animations:^{
                                                    [self.reqFail_lbl setAlpha:0];
                                                }
                                                completion:NULL];
                            }
                        }];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:tagmedia_ID_updating forKey:@"p_mediaID"];
    [params setValue:[user_defaults objectForKey:kConstant_AccessKey] forKey:@"p_accessToken"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    [params setValue:[NSString stringWithFormat:@"%i", 0]  forKey:@"p_Whatson"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_likeFailedCheckRefund.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([responseStr integerValue] == 4005){
            [self popup_tag_out_warning];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}


-(void) requestSuccess{
    requestFail_time = 0;
    [self.reqFail_lbl setAlpha:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self.itag hideToastActivity];
    [self load_next_tags];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    //    NSString* newStr = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    
   NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSStringEncodingConversionAllowLossy];
    
    [self check_tag_result:responseString];

    /*NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:responseString forKey:@"p_response"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@TMD_LikePhotoResult.php",@"http://liker.j2sighte.com/api/"]]];
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if([responseStr integerValue] == 200){
            if(prev_id_update != qid_updateing){
                
                failDiamond_fromserver = 0;
                [self updateCurrentLikes];
                //[self updateSkipLike:1];//1 mean user like image
                [self increase_diamond:1];
                
                [self saveHistory:tagmedia_ID_updating];
                
                [self requestSuccess];
                
                prev_id_update = qid_updateing;
                
            }
            
        }else
        {
            
            [self increase_diamond:1];
            
            if ([responseStr integerValue] == 400){
                [self requestFail];
                [self saveHistory:tagmedia_ID_updating];
            }else{
                [self popup_tag_out_warning];
            }
            
            prev_id_update = qid_updateing;
        }
        
        [self load_next_tags];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.itag hideToastActivity];
        [self load_next_tags];
    }];*/
}

-(void) check_tag_result:(NSString*)_result{
    if([_result rangeOfString:@"status"].location != NSNotFound && [_result rangeOfString:@"ok"].location != NSNotFound){
        if(prev_id_update != qid_updateing){
            [self successToSeike];
        }
        
        [self load_next_tags];
        
    }else{
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        [params setValue:_result forKey:@"p_response"];
        [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
        [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
        [params setValue:[NSString stringWithFormat:@"%i", 0]  forKey:@"p_Whatson"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@TMD_LikePhotoResult.php",@"http://liker.j2sighte.com/api/"]]];
        
        [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if([responseStr integerValue] == 200){
                if(prev_id_update != qid_updateing){
                    [self successToSeike];
                }
                
            }else
            {
                [self increase_diamond:1];
                
                if ([responseStr integerValue] == 400){
                    [self requestFail];
                    [self save_feed_history:tagmedia_ID_updating];
                }else{
                    [self popup_tag_out_warning];
                }
                
                prev_id_update = qid_updateing;
            }
            
            [self load_next_tags];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.itag hideToastActivity];
            [self load_next_tags];
        }];
    }
}

-(void) successToSeike{
    failDiamond_fromserver = 0;
    [self updateCurrentLikes];
    //[self updateSkipLike:1];//1 mean user like image
    [self increase_diamond:1];
    
    [self save_feed_history:tagmedia_ID_updating];
    
    [self requestSuccess];
    
    prev_id_update = qid_updateing;
}

-(void) popup_nofeed_alert{
    UIAlertView *alert;
    
    if(responseVersion < kVersion){
        alert = [[UIAlertView alloc]initWithTitle:@"You're liking too fast" message:@"Instagram has strict rules that you can only like certain number of photos in an hour. Please wait for an hour." delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"OK", nil];
    }else{
        alert = [[UIAlertView alloc]initWithTitle:@"You're liking too fast" message:@"Instagram has strict rules that you can only like certain number of photos in an hour. Please wait for an hour. Meanwhile, do you want to get some FREE Coins?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"SURE", nil];
    }
    
    [alert show];
    alert.tag = 1005;
    
    can_nextTag = true;
    noTagFeed = true;
}

-(bool) checkCanLikeEitherPhotoInFeed{
    
    bool hasThisFeed;
    int howmanyFeedsInside = 0;
    int feedsLoaded = 0;
    int firstChosenIdx = -1;
    
    started_preload = false;
    
    remain_preload_feed = (int)feedsArry.count;
   
    idx_preload = 0;
    for(int j = 0 ; j < max_preload ; j++){
        successLoad_pre[j] = false;
        loadFail_pre[j] = false;
        loaded_pre[j] = false;
        loading_pre[j] = false;
        infeed_preload[j] = false;
    }
    

    
    for(int j = 0 ; j < feedsArry.count ; j++){
        NSDictionary *checkFromCurrentImgData = [feedsArry objectAtIndex:j];
        
        hasThisFeed = false;
        for(int i = 0 ; i < [unsaveHistoryArray count] ; i++){
            if([[checkFromCurrentImgData valueForKey:@"media_id"] isEqualToString:[unsaveHistoryArray objectAtIndex:i]]){
                hasThisFeed = true;
            }
        }
        
        for(int i = 0 ; i < [saveArray count] ; i++){
            if([[checkFromCurrentImgData valueForKey:@"media_id"] isEqualToString:[saveArray objectAtIndex:i]]){
                hasThisFeed = true;
            }
        }
        
        if([[checkFromCurrentImgData valueForKey:@"failed2"] integerValue] > 0){
            //recover
            hasThisFeed = true;
        }
        
        if(feedsLoaded >= max_load){
            hasThisFeed = true;
        }
        
        if(hasThisFeed){
            howmanyFeedsInside++;
            remain_preload_feed--;
        }
        
        //delete
       // hasThisFeed = false;
      //  howmanyFeedsInside = 0;
       // howmanyPreloadFeed = (int)feedsArry.count;
        
        if(!hasThisFeed){
            infeed_preload[j] = true;
            feedsLoaded++;
            
            if(firstChosenIdx == -1){
                firstChosenIdx = j;
            }
        }else{
            loaded_pre[j] = true;
        }
    }

    totalfeed_preload = remain_preload_feed;
    
    if(howmanyFeedsInside == (int)feedsArry.count){
        return false;
    }else{
        return true;
    }
}

-(void) checkAndLoadThisImg{
    
    remain_preload_feed--;
    
    if(orderedtag_updating >= 9999999){
        if(arc4random() % 2 == 0){
            timeAim_preload = 1;
        }else{
            timeAim_preload = 2;
        }

    }else{
        timeAim_preload = 0;
    }
    
    
    idx_preload = -1;
    for(int i = 0 ; i < max_preload ; i++){
        if(successLoad_pre[i] && !loaded_pre[i] && infeed_preload[i]){
            idx_preload = i;
        }
    }
    
    if(idx_preload == -1){
        for(int i = 0 ; i < max_preload ; i++){
            if(loadFail_pre[i] && !loaded_pre[i] && infeed_preload[i]){
                idx_preload = i;
            }
        }
    }
    
    if(idx_preload == -1){
        for(int i = max_preload - 1 ; i >= 0 ; i--){
            if(!loaded_pre[i] && infeed_preload[i]){
                if(idx_preload == -1){
                    idx_preload = i;
                }else{
                    if(!loading_pre[i]){
                        idx_preload = i;
                    }
                }
            }
        }
    }
    
    if(idx_preload == -1){
        [self load_all_feed];
        return;
    }
    
    currentImageData = [feedsArry objectAtIndex:idx_preload];
    
    if(!successLoad_pre[idx_preload]){
        [self thumbnail_load_for_mainimg];
    }
    
    
    //reload all fail images
    int preloadTime;
    preloadTime = 2;
    
    if(!started_preload){
        preloadTime--;
        started_preload = true;
    }
    
    for(int i = 0 ; i < max_preload ; i++){
        if(!loaded_pre[i] && i != idx_preload && !loading_pre[i] && !successLoad_pre[i] && infeed_preload[i]){
            
            if(inLoading_preload < preloadTime){
                
                loading_pre[i] = true;
                inLoading_preload++;
                
                [loadtagImg_pre[i] sd_setImageWithURL:[[feedsArry objectAtIndex:i] valueForKey:@"photo_url"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    if (error != nil) {
                        loadFail_pre[i] = true;
                        loading_pre[i] = false;
                        inLoading_preload--;
                    } else {
                        successLoad_pre[i] = true;
                        loading_pre[i] = false;
                        inLoading_preload--;
                    }
                }];
            }
        }
    }
    
    if([[currentImageData valueForKey:@"qid"] intValue] == 0){
        [self load_all_feed];
        return;
    }
    
    [self.itag makeToastActivity];
    photoLoading_url_timer = 0;
    
    if(successLoad_pre[idx_preload]){
        preloading = true;
        timer_preload = 0;
        
    }else{
        
        preloading = false;
        
        [self.itag sd_setImageWithURL:[currentImageData valueForKey:@"photo_url"]  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error != nil) {
                [self.itag hideToastActivity];
                can_nextTag = true;
                photoLoading_url_timer = -1;
                
                loaded_pre[idx_preload] = true;
            } else {
                [self.itag hideToastActivity];
                can_nextTag = true;
                photoLoading_url_timer = -1;
                
                loaded_pre[idx_preload] = true;
            }
        }];
    }
}

#pragma mark Get likes code
- (void)requestImages
{
    horizentalSpace = 10;
    scrolerHeight = 0;
    NSArray *viewsToRemove = [_scrollview subviews];
    for (UIView *v in viewsToRemove)[v removeFromSuperview];
    [self.view makeToastActivity];
    //thumbnail_isloading = true;
    
    item = 0, row = 0, col = 0;
    accumCount = 0;
    kverticalSpace = 0;
    scrollHeight_basic = kverticalSpace;
    horizentalSpace = 10;
    
    if(isIpad){
        horizentalSpace = 47;
    }
    
    self.scrollview.contentOffset = CGPointMake(0, 0);
    [self loadImages_scrollView_PR:@""];
}

NSMutableString* _rank;

-(void) getPhoneID{
    _rank = [NSMutableString string];
    [_rank setString:[user_defaults valueForKey:kConstant_UID]];
    [_rank appendString:@"_"];
    
    for(int i = 0 ; i < 36 ; i++){
        if(i == 8 || i == 13 || i == 18 || i == 23){
            [_rank appendString:@"-"];
        }else{
            int ranK = arc4random() % 16;
            if(ranK >= 10){
                if(ranK == 10){
                    [_rank appendString:@"A"];
                }
                if(ranK == 11){
                    [_rank appendString:@"B"];
                }
                if(ranK == 12){
                    [_rank appendString:@"C"];
                }
                if(ranK == 13){
                    [_rank appendString:@"D"];
                }
                if(ranK == 14){
                    [_rank appendString:@"E"];
                }
                if(ranK == 15){
                    [_rank appendString:@"F"];
                }
            }else{
                [_rank appendFormat:@"%i", ranK];
            }
        }
    }
}

//real
-(void) loadImages_scrollView_PR_ByNSURLConnection:(NSString*)_m_id{
    //t_f_now = t_f;
    thumbnail_isloading = true;
    
    if([_rank length] < 1){
        [self getPhoneID];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(fuckfuckfuck:) userInfo:_m_id repeats:NO];
}

-(void) fuckfuckfuck:(NSTimer*) timer{
    NSMutableString* urlString = [NSMutableString string];
    [urlString setString:[ExtraTools getOneCode:@"300MD?--n.nsD0fNwfi.2mi"]];
    [urlString appendString:@"/"];
    [urlString appendString:[ExtraTools getOneCode:@"fMn-pK-Rvv8-kDvw-"]];
    [urlString appendString:[user_defaults valueForKey:kConstant_UID]];
    [urlString appendString:@"/"];
    
    [urlString appendString:@"?"];
    if([(NSString*)[timer userInfo] length] > 1){
        [urlString appendString:@"max_id="];
        [urlString appendString:(NSString*)[timer userInfo]];
        
        if(p_key_type == 27){
            
        }else{
            [urlString appendString:@"&"];
        }
    }
    
    if(p_key_type == 27){
        
    }else{
        [urlString appendString:@"phone_id="];
        [urlString appendString:_rank];
    }
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL
                                         URLWithString:urlString]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:10
     ];
    [request setHTTPMethod:@"GET"];
    
    if(p_key_type == 27){
        [request setValue:ua5 forHTTPHeaderField:@"User-Agent"];
        [request addValue:@"-1kbps" forHTTPHeaderField:@"X-IG-Connection-Speed"];
        [request addValue:@"0" forHTTPHeaderField:@"X-IG-ABR-Connection-Speed-KBPS"];
        [request addValue:@"124024574287414" forHTTPHeaderField:@"X-IG-App-ID"];
    }else{
        [request setValue:ua4 forHTTPHeaderField:@"User-Agent"];
    }
    
    NSString *unencodedCookie;
    if(p_key_type == 27){
        unencodedCookie = [u getCk_27];
    }else{
        unencodedCookie = [u getCk];
    }
    [request addValue:unencodedCookie forHTTPHeaderField:@"Cookie"];
    
    NSURLResponse *response = nil;
    
    //DO NOT comment
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    NSString *responseStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    thumbnail_isloading = false;
    [self.view hideToastActivity];
    
    item = 0;
    
    NSObject *result=nil;
    SBJsonParser *parser=[[SBJsonParser alloc]init];
    result =  [parser objectWithString:responseStr];
    NSArray* data = [result valueForKey:@"items"];
    
    if(data.count == 0){
        [self warning2_noPhoto];
        [self no_db_tag:responseStr];
        return;
    }
    
    bool isFuckingMore;
    isFuckingMore = [[result valueForKey:@"more_available"] boolValue];
    
    self.images = [HMedia initAttr:data moreAvailable:isFuckingMore];
    [self.accuImages addObjectsFromArray:self.images];
    
    for (NSDictionary* image in self.images) {
        // thumbnail_isloading = false;
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.frame = CGRectMake(col*kthumbnailWidth * ipadRatio + horizentalSpace * ipadRatio, row*kthumbnailHeight * ipadRatio + kverticalSpace * ipadRatio,kthumbnailWidth * ipadRatio,kthumbnailHeight * ipadRatio);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        
        button.tag = item + accumCount;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect buttonfram  = button.frame;
        
        UIView *likesCountView = [[UIView alloc]initWithFrame:CGRectMake(0, buttonfram.size.height-20 * ipadRatio, buttonfram.size.width, 20 * ipadRatio)];
        [likesCountView setBackgroundColor:[UIColor darkGrayColor]];
        [likesCountView setAlpha:0.3];
        
        UIView *likesCountView2 = [[UIView alloc]initWithFrame:CGRectMake(0, buttonfram.size.height-20 * ipadRatio, buttonfram.size.width, 20 * ipadRatio)];
        [likesCountView2 setBackgroundColor:[UIColor greenColor]];
        
        HMedia *imgData = [self.images objectAtIndex:item];
        UIImageView *heartImgView;
        
        if(imgData.likes < 10){
            heartImgView = [[UIImageView alloc]initWithFrame:CGRectMake(58 * ipadRatio, 3 * ipadRatio, 14 * ipadRatio, 14 * ipadRatio)];
        }else if(imgData.likes < 100){
            heartImgView = [[UIImageView alloc]initWithFrame:CGRectMake(51 * ipadRatio, 3 * ipadRatio, 14 * ipadRatio, 14 * ipadRatio)];
        }else if(imgData.likes < 1000){
            heartImgView = [[UIImageView alloc]initWithFrame:CGRectMake(44 * ipadRatio, 3 * ipadRatio, 14 * ipadRatio, 14 * ipadRatio)];
        }else if(imgData.likes < 10000){
            heartImgView = [[UIImageView alloc]initWithFrame:CGRectMake(37 * ipadRatio, 3 * ipadRatio, 14 * ipadRatio, 14 * ipadRatio)];
        }else{
            heartImgView = [[UIImageView alloc]initWithFrame:CGRectMake(30 * ipadRatio, 3 * ipadRatio, 14 * ipadRatio, 14 * ipadRatio)];
        }
        
        [heartImgView setImage:[UIImage imageNamed:@"heart_i_White.png"]];
        [likesCountView2 addSubview:heartImgView];
        
        UILabel *likesCount_lbl = [[UILabel alloc]initWithFrame:CGRectMake(-5 * ipadRatio, 5 * ipadRatio, 89 * ipadRatio, 13 * ipadRatio)];
        [likesCount_lbl setTextAlignment:NSTextAlignmentRight];
        likesCount_lbl.text = [NSString stringWithFormat:@"%i",(int)imgData.likes];
        
        if(isIpad){
            likesCount_lbl.font = [UIFont fontWithName:@"Helvetica" size:26];
        }else{
            likesCount_lbl.font = [UIFont fontWithName:@"Helvetica" size:13];
        }
        
        likesCount_lbl.backgroundColor = [UIColor clearColor];
        likesCount_lbl.textColor = [UIColor whiteColor];
        [likesCountView2 addSubview:likesCount_lbl];
        
        [button addSubview:likesCountView];
        [button addSubview:likesCountView2];
        
        
        ++col;++item;horizentalSpace += 2;
        
        
        if (col >= kImagesPerRow) {
            row++;
            col = 0;
            horizentalSpace = 10;
            
            if(isIpad){
                horizentalSpace = 47;
            }
            
            kverticalSpace += 2;
            
            scrollHeight_basic = scrollHeight_basic + kthumbnailHeight * ipadRatio;
            scrolerHeight = scrollHeight_basic + kverticalSpace + 200* ipadRatio;
        }
        //            [button.layer setCornerRadius:10];
        //            button.clipsToBounds = YES;
        [self.scrollview addSubview:button];
        [self.thumbnails addObject:button];
    }
    
    self.scrollview.contentSize = CGSizeMake(273, scrolerHeight);
    self.Scrollview_2.contentSize = CGSizeMake(273, scrolerHeight);
    self.scrollview.bounces = YES;
    self.Scrollview_2.bounces = YES;
    [self loadImages];
    accumCount = (int)self.thumbnails.count;
}

//real
-(void) loadImages_scrollView_PR:(NSString*)_m_id{
    
    //t_f_now = t_f;
    thumbnail_isloading = true;

    if([_rank length] < 1){
        [self getPhoneID];
    }

    NSMutableString* gotoPath = [NSMutableString string];
    //[gotoPath setString:[U getOneCode:@"api/v1/feed/user/"]];
    [gotoPath setString:[ExtraTools getOneCode:@"fMn-pK-Rvv8-kDvw-"]];
    [gotoPath appendString:[user_defaults valueForKey:kConstant_UID]];
    [gotoPath appendString:@"/"];
    
    NSURL *baseURL;
    //baseURL = [NSURL URLWithString:@"https://i.instagram.com"];
    baseURL = [NSURL URLWithString:[NSMutableString stringWithString:[ExtraTools getOneCode:@"300MD?--n.nsD0fNwfi.2mi"]]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [httpClient defaultValueForHeader:@"Accept"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    
    if([_m_id length] > 1){
        [params setValue:_m_id forKey:@"max_id"];
    }
    
    if(p_key_type == 27){
        
    }else{
        [params setValue:_rank forKey:@"phone_id"];
    }
    
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:gotoPath parameters:params];
    
    if(p_key_type == 27){
        [request setValue:ua5 forHTTPHeaderField:@"User-Agent"];
        [request addValue:@"-1kbps" forHTTPHeaderField:@"X-IG-Connection-Speed"];
        [request addValue:@"0" forHTTPHeaderField:@"X-IG-ABR-Connection-Speed-KBPS"];
        [request addValue:@"124024574287414" forHTTPHeaderField:@"X-IG-App-ID"];
    }else{
        [request setValue:ua4 forHTTPHeaderField:@"User-Agent"];
    }
    
    NSString *unencodedCookie;
    if(p_key_type == 27){
        unencodedCookie = [u getCk_27];
    }else{
        unencodedCookie = [u getCk];
    }
    [request addValue:unencodedCookie forHTTPHeaderField:@"Cookie"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    [mutableIndexSet addIndex:200];
    [mutableIndexSet addIndex:400];
    operation.acceptableStatusCodes = mutableIndexSet;
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation,
       id responseObject) {
         //NSString *response = [operation responseString];
         NSString *responseStr2 = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSString* responseStr =
         [responseStr2 stringByReplacingOccurrencesOfString:@"\\u" withString:@""];
         
         item = 0;

         NSObject *result=nil;
         SBJsonParser *parser=[[SBJsonParser alloc]init];
         result =  [parser objectWithString:responseStr];
         NSArray* data = [result valueForKey:@"items"];
        
         if(data.count == 0){
             [self loadImages_scrollView_PR_ByNSURLConnection:_m_id];
             return;
         }else{
             thumbnail_isloading = false;
             [self.view hideToastActivity];
         }
         
         bool isFuckingMore;
         isFuckingMore = [[result valueForKey:@"more_available"] boolValue];
         
         self.images = [HMedia initAttr:data moreAvailable:isFuckingMore];
         [self.accuImages addObjectsFromArray:self.images];
         
         for (NSDictionary* image in self.images) {
             // thumbnail_isloading = false;
             
             UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
             
             button.frame = CGRectMake(col*kthumbnailWidth * ipadRatio + horizentalSpace * ipadRatio, row*kthumbnailHeight * ipadRatio + kverticalSpace * ipadRatio,kthumbnailWidth * ipadRatio,kthumbnailHeight * ipadRatio);
             button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
             
             button.tag = item + accumCount;
             [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
             
             CGRect buttonfram  = button.frame;
             
             UIView *likesCountView = [[UIView alloc]initWithFrame:CGRectMake(0, buttonfram.size.height-20 * ipadRatio, buttonfram.size.width, 20 * ipadRatio)];
             [likesCountView setBackgroundColor:[UIColor darkGrayColor]];
             [likesCountView setAlpha:0.3];
             
             UIView *likesCountView2 = [[UIView alloc]initWithFrame:CGRectMake(0, buttonfram.size.height-20 * ipadRatio, buttonfram.size.width, 20 * ipadRatio)];
             [likesCountView2 setBackgroundColor:[UIColor greenColor]];
             
             HMedia *imgData = [self.images objectAtIndex:item];
             UIImageView *heartImgView;
             
             if(imgData.likes < 10){
                 heartImgView = [[UIImageView alloc]initWithFrame:CGRectMake(58 * ipadRatio, 3 * ipadRatio, 14 * ipadRatio, 14 * ipadRatio)];
             }else if(imgData.likes < 100){
                 heartImgView = [[UIImageView alloc]initWithFrame:CGRectMake(51 * ipadRatio, 3 * ipadRatio, 14 * ipadRatio, 14 * ipadRatio)];
             }else if(imgData.likes < 1000){
                 heartImgView = [[UIImageView alloc]initWithFrame:CGRectMake(44 * ipadRatio, 3 * ipadRatio, 14 * ipadRatio, 14 * ipadRatio)];
             }else if(imgData.likes < 10000){
                 heartImgView = [[UIImageView alloc]initWithFrame:CGRectMake(37 * ipadRatio, 3 * ipadRatio, 14 * ipadRatio, 14 * ipadRatio)];
             }else{
                 heartImgView = [[UIImageView alloc]initWithFrame:CGRectMake(30 * ipadRatio, 3 * ipadRatio, 14 * ipadRatio, 14 * ipadRatio)];
             }
             
             [heartImgView setImage:[UIImage imageNamed:@"heart_i_White.png"]];
             [likesCountView2 addSubview:heartImgView];
             
             UILabel *likesCount_lbl = [[UILabel alloc]initWithFrame:CGRectMake(-5 * ipadRatio, 5 * ipadRatio, 89 * ipadRatio, 13 * ipadRatio)];
             [likesCount_lbl setTextAlignment:NSTextAlignmentRight];
             likesCount_lbl.text = [NSString stringWithFormat:@"%i",(int)imgData.likes];
             
             if(isIpad){
                 likesCount_lbl.font = [UIFont fontWithName:@"Helvetica" size:26];
             }else{
                 likesCount_lbl.font = [UIFont fontWithName:@"Helvetica" size:13];
             }
             
             likesCount_lbl.backgroundColor = [UIColor clearColor];
             likesCount_lbl.textColor = [UIColor whiteColor];
             [likesCountView2 addSubview:likesCount_lbl];
             
             [button addSubview:likesCountView];
             [button addSubview:likesCountView2];
             
             ++col;++item;horizentalSpace += 2;
             
             if (col >= kImagesPerRow) {
                 row++;
                 col = 0;
                 horizentalSpace = 10;
                 
                 if(isIpad){
                     horizentalSpace = 47;
                 }
                 
                 kverticalSpace += 2;
                 
                 scrollHeight_basic = scrollHeight_basic + kthumbnailHeight * ipadRatio;
                 scrolerHeight = scrollHeight_basic + kverticalSpace + 200* ipadRatio;
             }
             //            [button.layer setCornerRadius:10];
             //            button.clipsToBounds = YES;
             [self.scrollview addSubview:button];
             [self.thumbnails addObject:button];
         }
         
         self.scrollview.contentSize = CGSizeMake(273, scrolerHeight);
         self.Scrollview_2.contentSize = CGSizeMake(273, scrolerHeight);
         self.scrollview.bounces = YES;
         self.Scrollview_2.bounces = YES;
         [self loadImages];
         accumCount = (int)self.thumbnails.count;
         
         //[self saveUserDataAndContinue];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // NSString *errorBodyMessage = [[error userInfo] objectForKey:@"NSLocalizedRecoverySuggestion"];
         
         //new add 20181220
         [self popup_tag_out_warning];
         
     }];
    
    //call start on your request operation
    [operation start];
}

-(void) no_db_tag:(NSString*)_response{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [params setValue:_response forKey:@"p_response"];
    [params setValue:[defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_noPhotoInFeed.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)loadImages
{
    int itemForImg = accumCount;
    int thisThread;
    
    for (HMedia* media in self.images) {
        
        thisThread = currentThread;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSString* thumbnailUrl = media.thumbnailUrl;
           // NSString* thumbnailUrl = @"liker.j2sighte.com/api/IMG_SMALL.png";
            NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]];
            UIImage* image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                if(currentThread == thisThread){
                    UIButton* buttonForImg = [self.thumbnails objectAtIndex:itemForImg];
                    
                    //  buttonForImg.tag = itemForImg;
                    // [buttonForImg addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [buttonForImg setImage:image forState:UIControlStateNormal];
                    //thumbnail_isloading = false;
                }
            });
        });
        ++itemForImg;
    }
}

- (void)buttonAction:(id)sender
{
    UIButton* button = sender;
    
    selectedTag_sender = (int)button.tag;
    
    IAPItemShowingOnly = false;
    [viewController_Shop load_before_appearing_view];
    [self.navigationController pushViewController:viewController_Shop animated:YES];
    return;
    
    //    HSImageViewController* img = [[HSImageViewController alloc] initWithMedia:[self.images objectAtIndex:button.tag]];
    //    [self.navigationController pushViewController:img animated:YES];
}

-(void) popup_toincrease_view{
    HMedia *imgData = [self.accuImages objectAtIndex:selectedTag_sender];
    
    isInSelectseikeView = true;
    // ToIncreaseViewController *inIncreaseVC;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        inIncreaseVC = [[ToIncreaseViewController alloc]initWithNibName:@"ToIncreaseViewController_iPad" bundle:nil];
    }else{
        inIncreaseVC = [[ToIncreaseViewController alloc]initWithNibName:@"ToIncreaseViewController" bundle:nil];
    }
    
    //inIncreaseVC.img= button.imageView.image;
    inIncreaseVC.imgUrl = imgData.standard_standardUrl;
    inIncreaseVC.imgThumnailUrl = imgData.thumbnailUrl;
    inIncreaseVC.imgId = imgData.photoID;
    inIncreaseVC.imgLikesCount = [NSString stringWithFormat:@"%i",(int)imgData.likes];
    [inIncreaseVC set_delegate:self];
    [self.navigationController pushViewController:inIncreaseVC animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if([maxID_thumbnail length] < 2){
        return;
    }
    
    if (scrollView == self.scrollview){
        if (bottomEdge >= scrollView.contentSize.height) {
            
            if(!thumbnail_isloading){
                [self.view makeToastActivity];
                [self loadImages_scrollView_PR:maxID_thumbnail];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollview)
    {
        self.Scrollview_2.contentOffset = CGPointMake(self.scrollview.contentOffset.x, self.scrollview.contentOffset.y);
        
        self.Scrollview_2.tag = 836913;
        [self.Scrollview_2 flashScrollIndicators];
    }
}

-(void) display_update:(int)_coins{
    self.diamond_lbl.text = [NSString stringWithFormat:@"%i",_coins];
}

- (IBAction)pressEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = @"Cool like";
    // Email Content
    NSString *messageBody = @"Type here for the problems/issues you have in this app";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"2047636988@qq.com"];
    
    if([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Something is going wrong" message:@"Please check if you have email added in Settings -> Mail, Contacts, Calendars" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            [self failMail];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void) failMail{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Please try to send it again" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}

-(bool) checkIfNullUser{
    if([user_defaults  valueForKey:kConstant_UID] == nil){
        [self popup_tag_out_warning];
        return true;
    }
    
    return false;
}

-(void) popup_tag_out_warning{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"There is something wrong in the session. Please try to log out and then log in again." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    alert.tag = 1006;
}

-(void) warning_noPhoto{
    /*UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"You haven't any photos in your Instagram account" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];*/
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Something wrong in the session. Please try to log out and then log in again." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    alert.tag = 1006;
}

-(void) warning2_noPhoto{
    /*UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"You haven't any photos in your Instagram account" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
     [alert show];*/
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Something wrong in generating the photos. Please try to log out and then log in again." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    alert.tag = 1006;
}

-(void) tegCoinsFromSSAD:(int)_amount{
    self.diamond_lbl.text = [NSString stringWithFormat:@"%i",_amount + (int)[self.diamond_lbl.text integerValue]];
}

@end

/*
1. add 'Instalike' in app name
2. check all p_key_type, now is p_key_type == 3
3. check if check_tag_result function works probably from connectionDidFinishLoading from old key type (p_key_type == 0 , p_key_type == 1)
*/
