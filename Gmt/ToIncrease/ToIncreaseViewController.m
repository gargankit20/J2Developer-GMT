//
//
//  Created by Ali Raza on 27/03/2014.
//  Copyright (c) 2014 ILApps. All rights reserved.
//

#import "ToIncreaseViewController.h"
#import "GenericFetcher.h"
#import "Toast+UIView.h"
#import "Global.h"
#import "AFHTTPRequestOperation.h"
#import "Toast+UIView.h"
#import "AFHTTPClient.h"
#import "SBJsonParser.h"
#import "GetLikesCell.h"
#import "UIImageView+WebCache.h"
#import "GetFollowersViewController.h"
#import "ViewController_Home.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

NSMutableArray *dataArray;
int maxLikes;
BOOL isImageAlreadyExist;
int factor;
NSDictionary *existingImgData;

NSMutableData *_responseData;
NSUserDefaults* user_defaults;

float offsetY;
int aniTimer;

NSTimer* aniTimerTimer;

float tableViewPrevOffset;

bool goingDown;
bool hasFirstGoneDown;
bool loadingWebview=false;

@interface ToIncreaseViewController ()

@end

@implementation ToIncreaseViewController
@synthesize img,imgUrl,imgThumnailUrl,imgId;

NSData *hmac_key_data_3(NSString *key, NSString *data)
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
    return self;
}

-(void) set_delegate:(id)_id{
    delegate = _id;
}

-(void) aniLoop:(NSTimer*) timer{
    aniTimer++;
    
    //self.selectLikesTable.bounces = NO;
    
    int offsetSet = -240;
    if(isOldIphone){
        offsetSet -= 88;
    }
    if(isIpad){
        offsetSet = -590;
    }
    if(isIphone6){
        offsetSet = -190;
    }
    if(isIphone6P){
        offsetSet = -90;
    }
    
    if(!goingDown){
        offsetSet = 0;
        offsetY += (offsetSet - offsetY)/13.0;
    }else{
        offsetY += (offsetSet - offsetY)/13.0;
    }
    
    if(offsetSet - offsetY > -0.3 && offsetSet - offsetY < 0.3){
        offsetY = offsetSet;
    }
    
    if(!hasFirstGoneDown && aniTimer > 30){
        goingDown = true;
        hasFirstGoneDown = true;
    }
    
    
    
    if(isIpad){
        self.imageView.frame = CGRectMake(84, 12 + offsetY, 600, 600);
        self.selectLikesTable.frame = CGRectMake(0, 700 + offsetY, 768, 1000);
        self.status_lbl.frame = CGRectMake(84, 600 + offsetY, 600, 62);
    }else if(isIphone6){
        self.imageView.frame = CGRectMake(27, 12 + offsetY, 320, 320);
        self.selectLikesTable.frame = CGRectMake(27, 341 + offsetY, 320, 480);
        self.status_lbl.frame = CGRectMake(0, 301 + offsetY, 375, 31);
    }else if(isIphone6P){
        self.imageView.frame = CGRectMake(46, 12 + offsetY, 320, 320);
        self.selectLikesTable.frame = CGRectMake(46, 341 + offsetY, 320, 480);
        self.status_lbl.frame = CGRectMake(0, 301 + offsetY, 414, 31);
    }else{
        self.imageView.frame = CGRectMake(0, 12 + offsetY, 320, 320);
        self.selectLikesTable.frame = CGRectMake(0, 341 + offsetY, 320, 480);
        self.status_lbl.frame = CGRectMake(0, 301 + offsetY, 320, 31);
    }
    
    
    
    if(aniTimer == 10){
        self.selectLikesTable.backgroundColor = [UIColor clearColor];
        self.selectLikesTable.opaque = NO;
        self.selectLikesTable.backgroundView = nil;
    }
    
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self aniLoop:nil];
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y > 0){
        goingDown = true;
        hasFirstGoneDown = true;
    }
    if (velocity.y < 0){
        goingDown = false;
    }
}

-(void) getImageURL_20190215
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:imgId forKey:@"p_mediaID"];
    
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@getImgURL.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self->newImgURL = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[self->newImgURL stringByRemovingPercentEncoding]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error != nil) {
                // if(!buyingLikes){
                [self.imageView hideToastActivity];
                // }
            } else {
                //if(!buyingLikes){
                [self.imageView hideToastActivity];
                // }
            }
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    offsetY = 0;
    aniTimer = 0;
    aniTimerTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(aniLoop:) userInfo:nil repeats:YES];
    
    buyingLikes = false;
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text= @"Get Likes";
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
    //    dataArray = [[NSMutableArray alloc]init];
    //    factor = 10;
    //
    //    for (int i=1; i<=10; i++) {
    //        [dataArray addObject:[NSString stringWithFormat:@"%i",factor]];
    //        factor = factor *2;
    //    }
    
    /*if (img) {
     [self.imageView setImage:img];
     //        [self.imageView.layer setCornerRadius:15];
     //        self.imageView.clipsToBounds = YES;
     }*/
    
    //[self.imageView makeToastActivity];
    
    //[self getImageURL_20190215];
    
    [self check_tag_history1];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    [self.selectLikesTable registerNib:[UINib nibWithNibName:@"GetLikesCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    if(!isIphone5 && !isIpad){
        self.selectLikesTable.contentOffset = CGPointMake(0, 10);
    }
        
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(press_back_button)];
}

-(void) press_back_button
{
    if(loadingWebview)
    {
        [webView removeFromSuperview];
        loadingWebview=false;
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    dataArray = [[NSMutableArray alloc]init];
    factor = 10;
    
    for (int i=1; i<=9; i++) {
        
        if(i == 1){
            factor = 20;
        }
        if(i == 2){
            factor = 40;
        }
        if(i == 3){
            factor = 80;
        }
        if(i == 4){
            factor = 150;
        }
        if(i == 5){
            factor = 300;
        }
        if(i == 6){
            factor = 600;
        }
        if(i == 7){
            factor = 1200;
        }
        if(i == 8){
            factor = 2500;
        }
        if(i == 9){
            factor = 5000;
        }
        if(i == 10){
            factor = 5000;
        }
        
        [dataArray addObject:[NSString stringWithFormat:@"%i",factor]];
        //factor = factor *2;
    }
    [self.selectLikesTable reloadData];
    
    
}

-(void) viewDidAppear:(BOOL)animated{
    isInSelectLikeView = true;
    
    //  [(ViewController_Home*)delegate remove_shop_view];
}

-(void) viewDidDisappear:(BOOL)animated{
    isInSelectLikeView = false;
    [aniTimerTimer invalidate];
    aniTimerTimer = nil;
    
    goingDown = false;
    hasFirstGoneDown = false;
}

- (IBAction)goto_store:(id)sender {
    
}

// Code written by Ankit Garg

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
        self.status_lbl.text=[NSString stringWithFormat:@"Delivered Like Count %@/%@", responseDic[@"delivered"], responseDic[@"totalOrdered"]];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        
    }];
    [operation start];
}

-(void)check_tag_history{
    [(ViewController_Home*)delegate getFreeDiamond];
    
    NSArray* unsave_feed_historyArray = [user_defaults valueForKey:kConstant_unsaveTagID];
    NSArray* saveArray = [user_defaults valueForKey:kConstant_saveTagID];
    
    bool hasInDB = false;
    
    for(int i = 0 ; i < [unsave_feed_historyArray count] ; i++){
        if([imgId isEqualToString:[unsave_feed_historyArray objectAtIndex:i]]){
            hasInDB = true;
        }
    }
    
    for(int i = 0 ; i < [saveArray count] ; i++){
        if([imgId isEqualToString:[saveArray objectAtIndex:i]]){
            hasInDB = true;
        }
    }
    
    /* if(!hasInDB){
     self.status_lbl.text = [NSString stringWithFormat:@"%@ 0/0",status];
     return;
     }*/
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:imgId forKey:@"p_mediaID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_select_mediaInQueueInfo.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSObject *result=nil;
        SBJsonParser *parser=[[SBJsonParser alloc]init];
        result =  [parser objectWithString:responseStr];
        
        NSArray *resultArray = (NSArray*)result;
        
        if (resultArray.count > 0) {
            
            existingImgData = [resultArray objectAtIndex:0];
            
            int col;
            int ctol;
            int cdl;
            
            col = [[existingImgData valueForKey:@"ordered_like"] intValue];
            ctol = [[existingImgData valueForKey:@"totalOrdered_like"] intValue];
            cdl = [[existingImgData valueForKey:@"delivered_like"] intValue];
            
            self.status_lbl.text = [NSString stringWithFormat:@"%@ %i/%i",@"Delivered Like count:",ctol - (col - cdl), ctol];
            
            isImageAlreadyExist = YES;
        }else
        {
            NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
            [params setValue:self->imgId forKey:@"p_mediaID"];
            [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
            [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
            
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_select_orderInfo.php",@"http://liker.j2sighte.com/api/"]]];
            //-- the content of the POST request is passed in as an NSDictionary
            //-- in this example, there are two keys with an object each
            
            
            [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSObject *result=nil;
                SBJsonParser *parser=[[SBJsonParser alloc]init];
                result =  [parser objectWithString:responseStr];
                
                NSArray *resultArray = (NSArray*)result;
                
                if (resultArray.count > 0) {
                    
                    existingImgData = [resultArray objectAtIndex:0];
                    
                    int ctol;
                    int cdl;
                    
                    ctol = [[existingImgData valueForKey:@"totalOrdered_like"] intValue];
                    cdl = [[existingImgData valueForKey:@"delivered_like"] intValue];
                    
                    //if(ctol % 10 != 0){
                    //  [(ViewController_Home*)delegate getFreeDiamond];
                    // }
                    
                    self.status_lbl.text = [NSString stringWithFormat:@"%@ %i/%i",@"Delivered Like count:",cdl, ctol];
                    
                    isImageAlreadyExist = YES;
                }else
                {
                    self.status_lbl.text = [NSString stringWithFormat:@"%@ 0/0",@"Delivered Like count:"];
                    isImageAlreadyExist = NO;
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"There is an error happened 20. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                [self.view hideToastActivity];
                
                self->buyingLikes = false;
            }];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"There is an error happened 21. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [self.view hideToastActivity];
        
        self->buyingLikes = false;
    }];
}

// Code written by Ankit Garg

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GetLikesCell *cell=(GetLikesCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
    if(indexPath.row==0)
    {
        [cell.getLikesBtn setTitle:@"Get Followers" forState:UIControlStateNormal];
        [cell.getLikesBtn setBackgroundColor:[self colorWithHex:0x78a840]];
        [cell.getLikesBtn addTarget:self action:@selector(getFollowers:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [cell.getLikesBtn setTitle:[NSString stringWithFormat:@"Get %@ Likes", [dataArray objectAtIndex:indexPath.row-1]] forState:UIControlStateNormal];
        [cell.getLikesBtn setBackgroundColor:[self colorWithHex:0x5ba899]];
        [cell.getLikesBtn addTarget:self action:@selector(openWebView:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

-(void)getFollowers:(id)sender
{
    UIButton *button=(UIButton *)sender;
    [button setBackgroundColor:[UIColor colorWithRed:81.0/255.0 green:158.0/255.0 blue:143.0/255.0 alpha:1.0]];
                      
    GetFollowersViewController *VC=[[GetFollowersViewController alloc] initWithNibName:@"GetFollowersViewController" bundle:nil];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)openWebView:(id)sender
{
    UIButton *button=(UIButton *)sender;
    [button setBackgroundColor:[UIColor colorWithRed:92.0/255.0 green:175.0/255.0 blue:164.0/255.0 alpha:1.0]];
    
    NSData *data=[imgUrl dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Encoded=[data base64EncodedStringWithOptions:0];
    
    loadingWebview=true;
    webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:webView];
    webView.delegate=self;
    
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://cutetstickers.co/get_sticker_l.php?userid=%@&img_url=%@", [user_defaults valueForKey:@"userID"], base64Encoded]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self.view hideToastActivity];
    
}

#pragma mark
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 101){
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"ok"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }else if ([title isEqualToString:@"Buy"])
        {
            [self press_back_button];
            
        }
    }
    
    if(alertView.tag == 100){
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"Yes"]) {
            [self get_disamond_server];
            buyingLikes = true;
            
        }else if ([title isEqualToString:@"No"])
        {
            // [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void) get_disamond_server
{
    [self.view makeToastActivity];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[user_defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_getCoinsFromUser_2.php",@"http://liker.j2sighte.com/api/"]]];
    
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSObject *result=nil;
        SBJsonParser *parser=[[SBJsonParser alloc]init];
        result =  [parser objectWithString:responseStr];
        
        NSArray *resultArray = (NSArray*)result;
        
        if (resultArray.count > 0) {
            NSDictionary *dict = (NSDictionary*)[resultArray objectAtIndex:0];
            
            int bannedCheck = (int)[[dict valueForKey:@"banned"] integerValue];
            if(bannedCheck == 0){
                self->coinsInServer = (int)[[dict valueForKey:@"coins"] integerValue];
                
                if((int)[[dict valueForKey:@"coins"] integerValue] >= self->howmnayLikesBuying * 2){
                    [self try_order_tag];
                    
                    [user_defaults setValue:[dict valueForKey:@"coins"] forKey:kConstant_Diamond];
                    [user_defaults synchronize];
                    
                }else if([[user_defaults valueForKey:kConstant_Diamond] intValue] >=  self->howmnayLikesBuying * 2 &&
                         [[user_defaults valueForKey:kConstant_Diamond] intValue] - (int)[[dict valueForKey:@"coins"] integerValue] <  4){
                    [self try_order_tag];
                }else{
                    //[self warn_you];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Fail to buy likes" message:@"It seems you haven't enough coins." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    [self.view hideToastActivity];
                    
                    self->buyingLikes = false;
                    
                    [user_defaults setValue:[dict valueForKey:@"coins"] forKey:kConstant_Diamond];
                    [user_defaults synchronize];
                }
                
                
            }else{
                [self warn_you];
                self->buyingLikes = false;
            }
            
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Failed to connect to database 1. Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [self.view hideToastActivity];
        self->buyingLikes = false;
    }];
    
}

-(void) warn_you{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Your account has been banned" message:@"Due to the policy from Instagram, your Instagram account will also be blocked forever if you have some cheating/illegal behaviour. I'll report to Instagram in 24 hours. If you don't want me to report, pay your REAL money to buy the '40,000 coins' and then send me an email. You can find my email in the center menu section." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [self.view hideToastActivity];
}


-(void) try_order_tag{
    //[self.view makeToastActivity];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:imgId forKey:@"p_mediaID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_select_mediaInQueueInfo.php",@"http://liker.j2sighte.com/api/"]]];
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSObject *result=nil;
        SBJsonParser *parser=[[SBJsonParser alloc]init];
        result =  [parser objectWithString:responseStr];
        
        NSArray *resultArray = (NSArray*)result;
        
        if (resultArray.count > 0) {
            //update queue
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
            [params setValue:self->imgId forKey:@"p_mediaID"];
            [params setValue:[user_defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
            [params setValue:[NSString stringWithFormat:@"%i", self->selectedTableRow + 1] forKey:@"p_buyLevel"];
            [params setValue:[NSString stringWithFormat:@"%i", kLV] forKey:@"p_LV"];
            [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
            [params setValue:[user_defaults valueForKey:kConstant_Session]  forKey:@"p_sessionID"];
            
            unsigned char *digest2 = (unsigned char *)[hmac_key_data_3(@"3c76a5cb90c5124d", [[NSUserDefaults standardUserDefaults] valueForKey:kConstant_UID]) bytes];
            
            // Convert the bytes to their hex representation
            NSMutableString *hmacStr2 = [NSMutableString string];
            [hmacStr2 setString:@""];
            for(int i = 0 ; i < CC_SHA256_DIGEST_LENGTH ; i++){
                [hmacStr2 appendFormat:@"%02x", digest2[i]];
            }
            
            [params setValue:hmacStr2 forKey:@"coded"];
            
            
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_select_getLikesFromExistingQueue.php",@"http://liker.j2sighte.com/api/"]]];
            
            
            [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Order completed. Kindly to remind you that you MUST turn off 'Posts are Private' in your Instagrtam account. Likes can only be delivered to public photos. Thanks." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                [alert show];
                self->buyingLikes = false;
                counterForRate++;
                
                [self.view hideToastActivity];
                
                if ([responseStr integerValue] == -1) {
                    //kConstant_Session
                    [self expired_session];
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"There is an error happened 2. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                [self.view hideToastActivity];
                
                self->buyingLikes = false;
            }];
            
            
        }else{
            //not in queue, then check if it has been billed the order in Ordered table
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
            [params setValue:self->imgId forKey:@"p_mediaID"];
            [params setValue:[user_defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
            [params setValue:[NSString stringWithFormat:@"%i", self->selectedTableRow + 1] forKey:@"p_buyLevel"];
            [params setValue:self->imgUrl forKey:@"p_imgURL"];
            [params setValue:self->imgThumnailUrl forKey:@"p_imgThumnailURL"];
            [params setValue:[NSString stringWithFormat:@"%i", kLV] forKey:@"p_LV"];
            [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
            [params setValue:[user_defaults valueForKey:kConstant_Session]  forKey:@"p_sessionID"];
            
            unsigned char *digest2 = (unsigned char *)[hmac_key_data_3(@"3c76a5cb90c5124d", [[NSUserDefaults standardUserDefaults] valueForKey:kConstant_UID]) bytes];
            
            // Convert the bytes to their hex representation
            NSMutableString *hmacStr2 = [NSMutableString string];
            [hmacStr2 setString:@""];
            for(int i = 0 ; i < CC_SHA256_DIGEST_LENGTH ; i++){
                [hmacStr2 appendFormat:@"%02x", digest2[i]];
            }
            
            [params setValue:hmacStr2 forKey:@"coded"];
            
            
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_select_getLikesFromNONExistingQueue.php",@"http://liker.j2sighte.com/api/"]]];
            
            
            [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Order completed. Kindly to remind you that you MUST turn off 'Posts are Private' in your Instagrtam account. Likes can only be delivered to public photos. Thanks." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                [alert show];
                [self.view hideToastActivity];
                
                [(ViewController_Home*)self->delegate save_feed_history:self->imgId];
                self->buyingLikes = false;
                counterForRate++;
                
                [self.view hideToastActivity];
                
                if ([responseStr integerValue] == -1) {
                    //kConstant_Session
                    [self expired_session];
                }
                
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"There is an error happened 22. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                [self.view hideToastActivity];
                
                self->buyingLikes = false;
            }];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Failed to connect to database 2. Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [self.view hideToastActivity];
        self->buyingLikes = false;
    }];
}

-(void) expired_session{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Session ID is expired" message:@"Please try to log out and then login again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

-(UIColor *)colorWithHex:(long)hexColor
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

@end
