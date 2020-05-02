//
//  ContentDetailViewController.m
//
//  Created by ming on 11/2/2017.
//  Copyright © 2017 ILApps. All rights reserved.
//

#import "HomeVer_PRE.h"
#import "HomeVer.h"
#import "Global.h"
#import "AppDelegate.h"
#import "ViewController_Home.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "SBJsonParser.h"
#import "Toast+UIView.h"
 #import <Photos/Photos.h>

@interface HomeVer_PRE ()

@end

@implementation HomeVer_PRE

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self load_background];
    [self startApp];
    
    loaded_howmany = 0;
    load_timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(startApp) userInfo:nil repeats:YES];
}


-(void) startApp
{
    loaded_howmany++;
    if(loaded_howmany == 5){
        [load_timer invalidate];
    }
    
     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    [params setValue:[NSString stringWithFormat:@"%i", 12]  forKey:@"p_Whatson"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@ver_ws6.php", @"http://liker.j2sighte.com/api/"]]];
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if(self->loaded_howmany >= 999){
            return;
        }
        
        // responseStr = @"3500102";
        NSObject *result=nil;
        SBJsonParser *parser=[[SBJsonParser alloc]init];
        result =  [parser objectWithString:responseStr];
        
        p_key_type = [[result valueForKey:@"key"] intValue];
        p_private = [[result valueForKey:@"pr"] intValue];
        
        if([[defaults valueForKey:p_key_type_version] intValue] != p_key_type){
            if(p_key_type >= 27){
                p_key_type_forceToLogout = true;
            }
        }
        [defaults setValue:[result valueForKey:@"key"] forKey:p_key_type_version];
        [defaults synchronize];
        
        
        pp_and_pp = [[result valueForKey:@"pp"] intValue];
        //isHTTPS = [[result valueForKey:@"hh"] intValue];
        
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
        
        
        responseVersion = secondValue;
        
        [self->load_timer invalidate];
        self->loaded_howmany = 999;
        
        //delete
        //responseVersion = 36;
        
        //recover
        if(kVersion > responseVersion){
            /*FirstViewController *view = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
            //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:view];
            AppDelegate *newDelegate = [[UIApplication sharedApplication] delegate];
            newDelegate.window.rootViewController = view;
            [newDelegate.window makeKeyAndVisible];*/
            
            showGet = false;
            
        }else{
            
           
            HomeVer* vc = [[HomeVer alloc] init];;
            UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
            [navigationController.navigationBar setTranslucent:NO];
            
            AppDelegate *newDelegate = [[UIApplication sharedApplication] delegate];
            newDelegate.window.rootViewController = navigationController;
            [newDelegate.window makeKeyAndVisible];
            
            showGet = true;
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        static int startAppFirstFAIL = 0;
        startAppFirstFAIL++;
        if(startAppFirstFAIL < 3){
            [self startApp];
        }
        
    }];
    
}

-(void) load_background{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [view setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1]];
    self.view = view;
    
    CGSize viewSize = self.view.bounds.size;
    NSString *viewOrientation = @"Portrait";
    NSString *launchImage = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:launchImage]];
    
    
//    UIImageView* bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading.png"]];
//    bg.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2.0 - bg.frame.size.width/2.0, [UIScreen mainScreen].bounds.size.height/2.0 - bg.frame.size.height/2.0, bg.frame.size.width, bg.frame.size.height);
    
    /*if(isIpad){
        CGRect fuckIpadBGRect = bg.frame;
        fuckIpadBGRect.size.width *= 2;
        fuckIpadBGRect.size.height *= 2;
        bg.frame = fuckIpadBGRect;
    }*/
    
    [self.view addSubview:bg];
}

@end

