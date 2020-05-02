//
//  ContentDetailViewController.m
//
//  Created by ming on 11/2/2017.
//  Copyright © 2017 ILApps. All rights reserved.
//

#import "HomeVer_Final.h"
#import "Global.h"
#import "AppDelegate.h"
#import "ViewController_Home.h"

@interface HomeVer_Final ()

@end

@implementation HomeVer_Final

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

