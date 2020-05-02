#include <UIKit/UIDevice.h>


#import <QuartzCore/QuartzCore.h>
#import "AVFoundation/AVFoundation.h"

NSString* r1;
NSString* r2;
NSString* r3;
NSString* r4;
int r1r_begin;
int r2r_begin;
int r3r_begin;
int r4r_begin;
int r1r_end;
int r2r_end;
int r3r_end;
int r4r_end;


#define kVersion 36
#define kLV 1

#define kConstant_MID @"mid"
#define kConstant_Boundary @"boundary"
#define kConstantToken      @"UToken"
#define kConstant_AccountsKey @"userAccount"

#define kConstant_DevID    @"ranDeviceid"
#define kConstant_UID    @"userid"
#define kConstant_MenuChangedToTag @"likesMenu"
#define kConstant_MenuCaangedToDiamond @"creditsMenu"
#define kConstant_tagSuccess       @"loginSuccess"
#define kConstant_Diamond @"userCoins"
#define kConstant_saveTagID @"saveLikeId"
#define kConstant_unsaveTagID @"unsaveLikeId"
#define kConstant_ownQidIDX @"qidIdx_own"
//#define kCid @"cid"
#define kConstant_Cookie @"cookie"
#define kConstant_Token @"csrftoken"
#define kConstant_Code @"ccode"
#define kConstant_VersionRate @"rateVersion"
#define kConstant_VersionOwn @"ownAdVersion"

#define kConstant_Session @"sessionID"


//http://testingmywebsites.com/voice/sign_in.php?email=ali%40gmail.com&password=password

#define IS_IPHONE (!IS_IPAD)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)




float ipadRatio;
bool isIphone5;
bool isIpad;
bool isIphone6;
bool isIphone6P;
bool isOldIphone;
bool isIphoneX;

NSMutableString* maxID_thumbnail;
NSMutableString* minID_thumbnail;
NSString *transition_buying_ID;
bool isInSelectseikeView;
int responseVersion;
bool isInsertingTMD;
int counterForRate;
int superAllow_server;

NSString* f_name;
NSString* f_password;

NSString* ua4;
NSString* ua5;

NSString* p_key;
int p_key_type; //0 for ios, 1 for android
#define p_key_type_version @"key_type_version"
bool p_key_type_forceToLogout;

int p_private; //is public api
NSString* cap;

bool isSessionExpired;

int pp_and_pp;
bool IAPItemShowingOnly;

//NSString* s_cookie;
//NSString* s_csrftoken;

#import "ExtraTools.h"
ExtraTools* u;

#if DEVELOPER
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...) /* */
#endif

#define kConstant_AccessKey @"kUserAccessTokenKey"


int nav_bar_height;
int page_content_height;
NSDictionary* TAGINFO;
NSString *searchcontent;
#define DeviceWidth [UIScreen mainScreen].bounds.size.width
#define DeviceHeight [UIScreen mainScreen].bounds.size.height
#define UIColorFromHex(s) [UIColor colorWithRed:((s & 0xFF0000) >> 16)/255.0 green:(((s &0xFF00) >>8))/255.0 blue((s &0xFF))/255.0 alpha:1.0]
NSString *page6_imageurl;
NSString *page6_textcontent;
NSString *page6_videourl;
NSInteger page2_selected;

bool canShowTagPage;
bool showGet;
