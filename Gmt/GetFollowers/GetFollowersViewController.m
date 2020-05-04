//
//  GetFollowersViewController.m
//  FunnyBirthCard
//
//  Created by Ankit Garg on 5/4/20.
//  Copyright © 2020 Yusri. All rights reserved.
//

#import "GetFollowersViewController.h"
#import "GetLikesCell.h"
#import "UIImageView+WebCache.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Toast+UIView.h"

@interface GetFollowersViewController ()

@end

@implementation GetFollowersViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Get Followers";
    dataArray=@[@100, @200, @500, @1000, @2000];
    [self.tableView registerNib:[UINib nibWithNibName:@"GetLikesCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    NSString *profilePicURL=[[NSUserDefaults standardUserDefaults] stringForKey:@"profilePicURL"];
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:profilePicURL]];
    
    [self check_tag_history1];
}

-(void)check_tag_history1
{
    NSString *urlString=@"http://cutetstickers.co/temp_sticker_status_l.php";
    NSURL *baseURL=[NSURL URLWithString:urlString];
    
    AFHTTPClient *httpClient=[[AFHTTPClient alloc] initWithBaseURL:baseURL];
    NSMutableURLRequest *request=[httpClient requestWithMethod:@"GET" path:urlString parameters:nil];

    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc] initWithRequest:request];

    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *responseDic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        self.followersLbl.text=[NSString stringWithFormat:@"Followers delivered: %@/%@", responseDic[@"delivered"], responseDic[@"totalOrdered"]];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        
    }];
    [operation start];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GetLikesCell *cell=(GetLikesCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
    [cell.getLikesBtn setTitle:[NSString stringWithFormat:@"Get %@ Followers", [dataArray objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
    [cell.getLikesBtn addTarget:self action:@selector(openWebView:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)openWebView:(id)sender
{
    UIButton *button=(UIButton *)sender;
    [button setBackgroundColor:[UIColor colorWithRed:92.0/255.0 green:175.0/255.0 blue:164.0/255.0 alpha:1.0]];
    
    loadingWebview=true;
    webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:webView];
    webView.delegate=self;

    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://cutetstickers.co/get_sticker_f.php?userid=%@&img_url=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"], [[NSUserDefaults standardUserDefaults] valueForKey:@"username"]]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];

    [webView loadRequest:request];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [webView makeToastActivity];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView hideToastActivity];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [webView hideToastActivity];
}

@end
