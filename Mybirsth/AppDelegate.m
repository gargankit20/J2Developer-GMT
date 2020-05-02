//
//  AppDelegate.m
//  Mybirsth
//
//  Created by slow on 2018/12/12.
//  Copyright © 2018年 slow Yusri. All rights reserved.
//

#import "AppDelegate.h"
#import "Global.h"
#include <sys/sysctl.h>
#include <sys/utsname.h>
#import "HomeVer_PRE.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(void) checkForIphone5{
    isIphone5 = false;
    isIpad = false;
    isIphone6 = false;
    isIphone6P = false;
    isOldIphone = false;
    isIphoneX = false;
    isSessionExpired = true;
    ipadRatio = 1.0;
    
    
    printf("checkForIphone5 screenwidth:%4.8f height:%4.8f\n", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    if([UIScreen mainScreen].bounds.size.height >= 1024.0)
    {
        printf("is Ipad\n");
        isIpad = true;
        ipadRatio = 2.0;
        
    }else if([UIScreen mainScreen].bounds.size.height >= 812.0)
    {
        printf("is iPhone X\n");
        isIphone6 = true;
        isIphoneX = true;
    }else if([UIScreen mainScreen].bounds.size.height >= 736.0)
    {
        printf("is iPhone 6 Plus\n");
        isIphone6P = true;
    }else if([UIScreen mainScreen].bounds.size.height >= 667.0)
    {
        printf("is iPhone 6\n");
        isIphone6 = true;
    }else if([UIScreen mainScreen].bounds.size.height >= 568.0)
    {
        printf("is iPhone 5\n");
        isIphone5 = true;
    }else{
        printf("is old iPHone\n");
        isOldIphone = true;
    }
    
    //get UA
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    [webView removeFromSuperview];
    NSArray *agent = [secretAgent componentsSeparatedByString:@")"];
    agent = [agent[1] componentsSeparatedByString:@"("];
    secretAgent = [agent[0] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    /*ua = [NSString stringWithFormat:@"Instagram 6.1.4 (%@; %@ OS %@; %@; %@) %@",[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding], [UIDevice currentDevice].model,[[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"],[[NSLocale currentLocale] localeIdentifier],[[NSLocale preferredLanguages] objectAtIndex:0],secretAgent];
     
     ua2 = [NSString stringWithFormat:@"Instagram 6.4.1 (%@; %@ OS %@; %@; %@) %@",[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding], [UIDevice currentDevice].model,[[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"],[[NSLocale currentLocale] localeIdentifier],[[NSLocale preferredLanguages] objectAtIndex:0],secretAgent];
     
     ua3 = [NSString stringWithFormat:@"Instagram 6.4.0 (%@; %@ OS %@; %@; %@) %@",[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding], [UIDevice currentDevice].model,[[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"],[[NSLocale currentLocale] localeIdentifier],[[NSLocale preferredLanguages] objectAtIndex:0],secretAgent];*/
    
    ua4 = [NSString stringWithFormat:@"Instagram 10.15.0 (%@; %@ OS %@; %@; %@) %@",[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding], [UIDevice currentDevice].model,[[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"],[[NSLocale currentLocale] localeIdentifier],[[NSLocale preferredLanguages] objectAtIndex:0],secretAgent];
    
    ua5 = [NSString stringWithFormat:@"Instagram 27.0.0.13.98 (%@; %@ OS %@; %@; %@; scale=2.00; gamut=normal; 750x1334) %@",[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding], [UIDevice currentDevice].model,[[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"],[[NSLocale currentLocale] localeIdentifier],[[NSLocale preferredLanguages] objectAtIndex:0],secretAgent];
    
    
}

-(void) registerNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    int days[50];
    UILocalNotification* localNotification[50];
    
    days[0] = 1;
    days[1] = 3;
    for(int i = 2 ; i < 50 ; i++){
        days[i] = 3 * i;
    }
    
    for(int i = 0 ; i < 50 ; i++){
        
        NSMutableString* alertString = [NSMutableString string];
        [alertString setString:@"Come back to get Likes and may have a chance to get REAL gift cards"];
        
        localNotification[i] = [[UILocalNotification alloc] init];
        localNotification[i].fireDate = [NSDate dateWithTimeIntervalSinceNow:days[i] * 24 * 60 * 60];
        localNotification[i].alertBody = alertString;
        localNotification[i].timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification[i]];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//
//    FirstViewController *sv = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
//
//    self.window.rootViewController = sv;
//    [self.window makeKeyAndVisible];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    u = [[ExtraTools alloc] init];
    
    [self registerNotification];
    
    [self checkForIphone5];
    
    self.window= [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor=[UIColor grayColor];
    
    HomeVer_PRE* homeVer_PRE = [[HomeVer_PRE alloc] init];
    self.window.rootViewController=homeVer_PRE;
    
    [self.window makeKeyAndVisible];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
