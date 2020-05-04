//
//  GetFollowersViewController.h
//  FunnyBirthCard
//
//  Created by Ankit Garg on 5/4/20.
//  Copyright © 2020 Yusri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetFollowersViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>
{
    NSArray *dataArray;
    UIWebView *webView;
    bool loadingWebview;
}

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *followersLbl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
