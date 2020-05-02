//
//  ContentDetailViewController.m
//
//  Created by ming on 11/2/2017.
//  Copyright © 2017 ILApps. All rights reserved.
//

#import "HomeVer.h"
#import "Global.h"
#import "AppDelegate.h"
#import "ViewController_Home.h"
#import "Toast+UIView.h"
#import "HomeVer_Final.h"

@interface HomeVer ()

@end

@implementation HomeVer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self load_background];
    [self load_buttons];
}

-(void) load_buttons{
    btn_tag = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_tag.adjustsImageWhenHighlighted = NO;
    btn_tag.backgroundColor = [UIColor colorWithRed:83.0/255.0 green:44.0/255.0 blue:195.0/255.0 alpha:1.0];
    btn_tag.layer.cornerRadius = 18;
    [btn_tag setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 150 * ipadRatio, 280 * ipadRatio, 300 * ipadRatio, 43 * ipadRatio)];
    [btn_tag setTitle:@"Get Likes for Instagram" forState:UIControlStateNormal];
    
    
    [btn_tag addTarget:self action:@selector(click_tag:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_tag];
    
    
    
    
}

-(void) click_tag_delay:(NSTimer*) timer{
    ViewController_Home* vc;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        vc = [[ViewController_Home alloc] initWithNibName:@"ViewController_Home_iPad" bundle:nil];
    }else{
        vc = [[ViewController_Home alloc] initWithNibName:@"ViewController_Home" bundle:nil];
    }
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [navigationController.navigationBar setTranslucent:NO];
    
    AppDelegate *newDelegate = [[UIApplication sharedApplication] delegate];
    
    newDelegate.window.rootViewController = navigationController;
    [newDelegate.window makeKeyAndVisible];
}

- (IBAction)click_tag:(id)sender{
    
    [self.view makeToastActivity];
     NSTimer* _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(click_tag_delay:) userInfo:nil repeats:NO];

}

- (IBAction)click_magic:(id)sender{
   /* 
    FirstViewController *view = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
    
    //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:view];
    
    AppDelegate *newDelegate = [[UIApplication sharedApplication] delegate];
    
    newDelegate.window.rootViewController = view;
    [newDelegate.window makeKeyAndVisible];*/

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

@end

