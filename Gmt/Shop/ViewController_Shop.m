//
//  ViewController_Shop.m
//  5000Likes
//
//  Created by apple on 14/6/3.
//  Copyright (c) 2014年 ILApps. All rights reserved.
//

#import "ViewController_Shop.h"

//#import "StoreCell.h"
#import "AFHTTPClient.h"
#import "Global.h"

#import "ViewController_Home.h"
#import "ToIncreaseViewController.h"

#import "Global.h"

#import "SBJsonParser.h"

NSUserDefaults* user_defaults;


@interface ViewController_Shop ()
{
    NSArray *_products;
}

@end


@implementation ViewController_Shop

-(void) set_delegate:(id)_id{
    delegate = _id;
}

-(void)viewWillAppear:(BOOL)animated{
    
    offset_OW_onemore = 0;
    if(superAllow_server == 2){
        offset_OW_onemore = 56;
        
        if(isOldIphone){
            offset_OW_onemore = 46;
        }
    }
    
    if(responseVersion < kVersion){
        allowSuperS = false;
    }else{
        allowSuperS = true;
    }
    
    if(!allowSuperS){
        button_diamond.frame = CGRectMake(9999, 9999, 293 * ipadRatio, 33 * ipadRatio);
    }
    
    NSString *coins = [user_defaults valueForKey:kConstant_Diamond];
    if (coins) {
        self.diamond_lbl.text = coins;
    }
    
    //headingLabel.text = [NSString stringWithFormat:@"%4.1f", 2.0];
    
    if(allowSuperS && superAllow_server == 2){
        button_diamond2.frame = CGRectMake(buttonStartX, 283 * ipadRatio, 293 * ipadRatio, 33 * ipadRatio);
    }else{
        button_diamond2.frame = CGRectMake(9999, 9999, 283 * ipadRatio, 33 * ipadRatio);
    }
    
    button_next.frame = CGRectMake(buttonStartX, 323 * ipadRatio + offset_OW_onemore * ipadRatio, 293 * ipadRatio, 33 * ipadRatio);
    
    CGRect twoCoinsFrame = title_tocoins.frame;
    twoCoinsFrame.origin.y = 285 * ipadRatio + offset_OW_onemore * ipadRatio;
    title_tocoins.frame = twoCoinsFrame;
    
    if(isIpad){
        headingLabel.frame = CGRectMake(266, 588 + offset_OW_onemore * ipadRatio, 100, 21);
    }else if(isIphone6){
        headingLabel.frame = CGRectMake(106 + 27, 288 + offset_OW_onemore, 100, 21);
    }else if(isIphone6P){
        headingLabel.frame = CGRectMake(106 + 20, 288 + 5 + offset_OW_onemore, 100, 21);
    }else{
        headingLabel.frame = CGRectMake(106, 288 + offset_OW_onemore, 100, 21);
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        buttonStartX = 13;
        if(isIpad){
            buttonStartX = 105;
        }
        if(isIphone6){
            buttonStartX = 42;
        }
        if(isIphone6P){
            buttonStartX = 60;
        }
        
        success_loadedItem = false;
        
        //deleted on 20160310
        //[self loading_items];
        
        allowSuperS = false;
        hasSuperS = true ;
        isLoadSuperS = false;
        [self loadSuperS];
        
        

    }
    return self;
}

-(void) loadSuperS
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userId = [defaults objectForKey:kConstant_UID];
    
    if (!userId) {
        //[self load_tagview];
        return;
    }
    
    if(isLoadSuperS){
        return;
    }
    
    if(responseVersion < kVersion){
        allowSuperS = false;
    }else{
        allowSuperS = true;
    }
    
    if(hasSuperS){
        button_diamond.frame = CGRectMake(buttonStartX, 242 * ipadRatio, 293 * ipadRatio, 33 * ipadRatio);
    }else{
        button_diamond.frame = CGRectMake(9999, 9999, 293 * ipadRatio, 33 * ipadRatio);
    }
    
    if(!allowSuperS){
        button_diamond.frame = CGRectMake(9999, 9999, 293 * ipadRatio, 33 * ipadRatio);
    }
    
    isLoadSuperS = true;
    
    [ISIntegrationHelper validateIntegration];
    
    [ISSupersonicAdsConfiguration configurations].useClientSideCallbacks = @(YES);
    
    //Supersonic tracking SDK
    [ISEventsReporting reportAppStarted];
    
    // Before initializing any of our products (Rewarded video, Offerwall or Interstitial) you must set
    // their delegates. Take a look at these classes and you will see that they each implement a product
    // protocol. This is our way of letting you know what's going on, and if you don't set the delegates
    // we will not be able to communicate with you.
    // We're passing 'self' to our delegates because we want
    // to be able to enable/disable buttons to match ad availability.
    [IronSource setOfferwallDelegate:self];
    
    // After setting the delegates you can go ahead and initialize the SDK.
    [IronSource setUserId:[user_defaults valueForKey:kConstant_UID]];
    [IronSource initWithAppKey:@"2f835d65"];
    
    [ISIntegrationHelper validateIntegration];

}

-(void) viewDidAppear:(BOOL)animated{
    [self loadSuperS];
    [self loading_items];
}

-(void) load_before_appearing_view{
    if(IAPItemShowingOnly){
        title_tocoins.alpha = 0;
        button_next.alpha = 0;
        headingLabel.alpha = 0;
    }else{
        title_tocoins.alpha = 255;
        button_next.alpha = 255;
        headingLabel.alpha = 255;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text= @"Store";
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
    
    [self setTitle:@"Store"];
    
    
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
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(press_back_button)];
    
    [self load_buttons];
    
    //deleted on 20160310
    //[self loading_items];
    
    [self load_conversation];
}

-(void) load_conversation{
    headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    //headingLabel.text = [NSString stringWithFormat:@"%4.1f", 2.0];
    headingLabel.textColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1];
    
    // headingLabel.textAlignment = NSTextAlignmentRight;
    headingLabel.tag = 10;
    headingLabel.backgroundColor = [UIColor clearColor];
    
    if(isIpad){
        headingLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0];
    }else if(isIphone6P){
        headingLabel.font = [UIFont fontWithName:@"Helvetica" size:20.0];
    }else{
        headingLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    }
    
    [self.view addSubview:headingLabel];

    
    /*headingLabel.hidden = NO;
     headingLabel.highlighted = YES;
     headingLabel.highlightedTextColor = [UIColor blueColor];
     headingLabel.lineBreakMode = YES;
     headingLabel.numberOfLines = 0;*/
    
    
    /*self.coinsConversion_lbl.text = [NSString stringWithFormat:@"%4.1f", payCoinConversion];
     
     if(isIpad){
     self.coinsConversion_lbl.font = [UIFont fontWithName:@"Helvetica" size:28.0];
     }else{
     self.coinsConversion_lbl.font = [UIFont fontWithName:@"Helvetica" size:14.0];
     }*/
}

-(void) loading_items{
    if(success_loadedItem){
        return;
    }
    
    if(pp_and_pp == 1){
        [self show_PP_items];
        success_loadedItem = true;
        return;
    }
    
    
    success_loadedItem = true;
    
}

-(UIColor *)colorWithHex:(long)hexColor
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

-(void) load_buttons{
    
    if(isIphone6){
        //title_more = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"getmore_i_i6.png"]];
        //title_tocoins = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"two_i_coin_i6.png"]];
        title_tocoins = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, 30)];
        title_tocoins.text = @"2.0 coins per like";
        title_tocoins.font = [UIFont systemFontOfSize:12];
        title_tocoins.textAlignment = NSTextAlignmentCenter;
        title_tocoins.backgroundColor = [self colorWithHex:0xEFEEEF];
        
        
        title_more = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, 30)];
        title_more.text = @"Get More Coins?";
        title_more.font = [UIFont systemFontOfSize:12];
        title_more.textAlignment = NSTextAlignmentCenter;
        title_more.backgroundColor = [self colorWithHex:0xEFEEEF];
    }else{
        //title_more = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"getmore_i.png"]];
        //title_tocoins = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"two_i_coin.png"]];
        title_tocoins = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, 40)];
        title_tocoins.text = @"2.0 coins per like";
        title_tocoins.font = [UIFont systemFontOfSize:14];
        title_tocoins.textAlignment = NSTextAlignmentCenter;
        title_tocoins.backgroundColor = [self colorWithHex:0xEFEEEF];
        
        title_more = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, 40)];
        title_more.text = @"Get More Coins?";
        title_more.font = [UIFont systemFontOfSize:14];
        title_more.textAlignment = NSTextAlignmentCenter;
        title_more.backgroundColor = [self colorWithHex:0xEFEEEF];
    }

    
    [self.view addSubview:title_more];
    
    CGRect twoCoinsFrame = title_tocoins.frame;
    twoCoinsFrame.origin.y = 285 * ipadRatio + offset_OW_onemore * ipadRatio;

    
    title_tocoins.frame = twoCoinsFrame;
    
    button_next = [UIButton buttonWithType:UIButtonTypeCustom];
    button_next.frame = CGRectMake(buttonStartX, 323 * ipadRatio + offset_OW_onemore * ipadRatio, 293 * ipadRatio, 33 * ipadRatio);
    [button_next setTitle:@"Next" forState:UIControlStateNormal];
    [button_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button_next setBackgroundColor:[self colorWithHex:0x0CA5E5]];
    [button_next addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:title_tocoins];
    [self.view addSubview:button_next];
    
    
    
    button_diamond = [UIButton buttonWithType:UIButtonTypeCustom];
    //[button_diamond setImage:[UIImage imageNamed:@"iap_btn_freeCoins.png"] forState:UIControlStateNormal];
    [button_diamond setBackgroundColor:[self colorWithHex:0x957FE8]];
    [button_diamond setTitle:@"Free Coins" forState:UIControlStateNormal];
    
    if(!isIpad){
        button_diamond.titleLabel.font = [UIFont systemFontOfSize:15];
    }

    
    [button_diamond addTarget:self action:@selector(freeCoins:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_diamond];
    
    if(hasSuperS){
        button_diamond.frame = CGRectMake(buttonStartX, 242 * ipadRatio, 293 * ipadRatio, 33 * ipadRatio);
    }else{
        button_diamond.frame = CGRectMake(9999, 9999, 293 * ipadRatio, 33 * ipadRatio);
    }

    button_diamond2 = [UIButton buttonWithType:UIButtonTypeCustom];
    //[button_diamond2 setImage:[UIImage imageNamed:@"iap_btn_freecoins_2.png"] forState:UIControlStateNormal];
    [button_diamond2 setBackgroundColor:[self colorWithHex:0x957FE8]];
    [button_diamond2 setTitle:@"Free Coins 2" forState:UIControlStateNormal];
    [button_diamond2 addTarget:self action:@selector(freeCoins2:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button_diamond2];
    
    if(!isIpad){
        button_diamond2.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    
}




- (IBAction)freeCoins:(id)sender {
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"SetLiking", @"From",
                                   nil];

    [self showSuper];
    
}

- (IBAction)freeCoins2:(id)sender {
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"SetLiking", @"From",
                                   nil];

   [self showSuper];
    
}

-(void) showSuper{
    [self.view makeToastActivity];
    [IronSource showOfferwallWithViewController:self placement:@"DefaultOfferWall"];
}

-(void) delayToLoadFreeCoinsContent{
   [self showSuper];
}

-(void) press_back_button{

    if(isLoadingWebview){
        [webview removeFromSuperview];
        isLoadingWebview = false;
        return;
    }

    [self.navigationController popViewControllerAnimated:YES];
}



- (IBAction)next:(id)sender {
    
   // [self press_back_button];
    [(ViewController_Home*) delegate popup_toincrease_view];
}

-(void)increase_diamondFromII{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:transition_buying_ID forKey:@"p_transactionID"];
    [params setValue:[user_defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", coinsFrom_A[item_buy_Idx]] forKey:@"p_coinsToAdd"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@p_addCoinsFromIAP.php",@"http://liker.j2sighte.com/api/"]]];
    //-- the content of the POST request is passed in as an NSDictionary
    //-- in this example, there are two keys with an object each
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([responseStr integerValue] == 999) {
            
            int curntCoins = (int)[[self.diamond_lbl text] integerValue];
            self.diamond_lbl.text = [NSString stringWithFormat:@"%i",curntCoins + coinsFrom_A[item_buy_Idx]];
            
            [user_defaults setValue:[NSString stringWithFormat:@"%i",curntCoins + coinsFrom_A[item_buy_Idx]] forKey:kConstant_Diamond];
            [user_defaults synchronize];
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Success" message:@"In-App Purchase done successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            
            [delegate display_update:curntCoins + coinsFrom_A[item_buy_Idx]];
            
            [self.view hideToastActivity];
            
        }else{
            // [self increase_diamondFromII];
            
            [self.view hideToastActivity];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self increase_diamondFromII];
    }];
}

#pragma mark -
#pragma mark Offerwall Delegate Functions

// This method gets invoked after the availability of the Offerwall changes.
- (void)offerwallHasChangedAvailability:(BOOL)available {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self.viewController.showOWButton setEnabled:available];
    //    });
}

// This method gets invoked each time the Offerwall loaded successfully.
- (void)offerwallDidShow {
    [self.view hideToastActivity];
}

// This method gets invoked after a failed attempt to load the Offerwall.
// If it does happen, check out 'error' for more information and consult our
// Knowledge center.
- (void)offerwallDidFailToShowWithError:(NSError *)error {
    [self.view hideToastActivity];
}

// This method gets invoked after the user had clicked the little
// 'x' button at the top-right corner of the screen.
- (void)offerwallDidClose {
    [self.view hideToastActivity];
}

// This method will be called each time the user has completed an offer.
// All relative information is stored in 'creditInfo' and it is
// specified in more detail in 'SupersonicOWDelegate.h'.
// If you return NO the credit for the last offer will be added to
// Everytime you return 'NO' we aggragate the credit and return it all
// at one time when you return 'YES'.
- (BOOL)didReceiveOfferwallCredits:(NSDictionary *)creditInfo {
    
    if((int)[[creditInfo objectForKey:@"credits"] integerValue] == 0){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Get Free Coins now" message:@"Complete the missions to get free coins. For app-install offers, you must open the app which you've downloaded for a few seconds. If you still don't get coins, please close and restart this app." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    
    NSMutableString* wallRewardString = [NSMutableString stringWithString:@"You are getting "];
    [wallRewardString appendFormat:@"%i", (int)[[creditInfo objectForKey:@"credits"] integerValue]];
    [wallRewardString appendString:@" Coins from completing the tasks in the offer wall. You can always get More Free Coins by completing more tasks."];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Congradualations" message:wallRewardString delegate:self cancelButtonTitle:@"GET COINS" otherButtonTitles:nil, nil];
    [alertView show];
    
    int curntCoins = (int)[[self.diamond_lbl text] integerValue];
    self.diamond_lbl.text = [NSString stringWithFormat:@"%i",curntCoins + (int)[[creditInfo objectForKey:@"credits"] integerValue]];
    [user_defaults setValue:[NSString stringWithFormat:@"%i",curntCoins + (int)[[creditInfo objectForKey:@"credits"] integerValue]] forKey:kConstant_Diamond];
    [user_defaults synchronize];
    
    [(ViewController_Home*) delegate tegCoinsFromSSAD:(int)[[creditInfo objectForKey:@"credits"] integerValue]];
    
    return YES;
}

// This method get invoked when the ‘-getOWCredits’ fails to retrieve
// the user's credit balance info.
- (void)didFailToReceiveOfferwallCreditsWithError:(NSError *)error {
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//PP
-(void) show_PP_items{
    for(int i = 0 ; i < 5 ; i++){
        
        button_item[i] = [UIButton buttonWithType:UIButtonTypeCustom];
        button_item[i].frame = CGRectMake(buttonStartX, 38 * ipadRatio + 41 * i * ipadRatio, 293 * ipadRatio, 33 * ipadRatio);
        [button_item[i] setImage:[UIImage imageNamed:@"red_btn.png"] forState:UIControlStateNormal];
        
        
        [button_item[i] addTarget:self action:@selector(iapPPPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button_item[i]];
        
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        [numberFormatter setLocale:[NSLocale currentLocale]];
        

        
        NSMutableString* stringFromIAPTitle;
        
        if(i == 0){
            stringFromIAPTitle = [NSMutableString stringWithFormat:@" %@", @"$1.99"];
        }
        if(i == 1){
            stringFromIAPTitle = [NSMutableString stringWithFormat:@" %@", @"$4.99"];
        }
        if(i == 2){
            stringFromIAPTitle = [NSMutableString stringWithFormat:@" %@", @"$9.99"];
        }
        if(i == 3){
            stringFromIAPTitle = [NSMutableString stringWithFormat:@" %@", @"$19.99"];
        }
        if(i == 4){
            stringFromIAPTitle = [NSMutableString stringWithFormat:@" %@", @"$49.99"];
        }
        
        
        
        diamond_lbl_2[i] = [[UILabel alloc] initWithFrame:CGRectMake(0, -2 * ipadRatio, 300 * ipadRatio, 40 * ipadRatio)];
        diamond_lbl_2[i].text= @"a";
        diamond_lbl_2[i].textColor=[UIColor whiteColor];
        diamond_lbl_2[i].backgroundColor =[UIColor clearColor];
        //label.adjustsFontSizeToFitWidth=YES;
        if(isIpad){
            diamond_lbl_2[i].font = [UIFont fontWithName:@"Helvetica" size:29];
        }else{
            diamond_lbl_2[i].font = [UIFont fontWithName:@"Helvetica" size:15.5];
        }
        diamond_lbl_2[i].textAlignment = NSTextAlignmentCenter;
        
        [button_item[i] addSubview:diamond_lbl_2[i]];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.maximumIntegerDigits = 100;
        formatter.usesSignificantDigits = NO;
        formatter.usesGroupingSeparator = NO;
        // formatter.groupingSeparator = @",";
        formatter.decimalSeparator = @".";
        
        NSMutableString * s_displayTitle = [NSMutableString string];
        
        if(i == 0){
            coinsFrom_A[i] = 500;
        }
        if(i == 1){
            coinsFrom_A[i] = 1500;
        }
        if(i == 2){
            coinsFrom_A[i] = 4000;
        }
        if(i == 3){
            coinsFrom_A[i] = 12000;
        }
        if(i == 4){
            coinsFrom_A[i] = 55000;
        }
        [s_displayTitle setString:[formatter stringFromNumber:[NSNumber numberWithInt:coinsFrom_A[i]]]];
        
        [s_displayTitle appendString:@" Coins"];
        
        [s_displayTitle appendString:@" ("];
        [s_displayTitle appendString:stringFromIAPTitle];
        [s_displayTitle appendString:@")"];
        
        diamond_lbl_2[i].text = s_displayTitle;
    }
}

bool isLoadingWebview = false;
- (IBAction)iapPPPress:(id)sender {
    isLoadingWebview = true;
    webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:webview];
    webview.delegate = self;
    
    NSURLRequest* request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:
                                  [NSString stringWithFormat:@"%@buy.php?userid=%@",@"http://liker.j2sighte.com/instaapi/checkout_premium_1/", [user_defaults valueForKey:kConstant_UID]  ]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [webview loadRequest:request];
    
    [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:90.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:120.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:150.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:180.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:210.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:240.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:270.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:360.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:420.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:480.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:540.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:600.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:660.0 target:self selector:@selector(reload_tag:) userInfo:nil repeats:NO];
}

-(void) reload_tag:(NSTimer*) timer{
    self.diamond_lbl.text = [user_defaults valueForKey:kConstant_Diamond];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[defaults valueForKey:kConstant_UID]  forKey:@"p_userID"];
    [params setValue:[NSString stringWithFormat:@"%i", kLV]  forKey:@"p_LV"];
    [params setValue:[NSString stringWithFormat:@"%i", kVersion]  forKey:@"p_Version"];
    
     int currentCoins = [[defaults valueForKey:kConstant_Diamond] intValue];
    
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
            
            int updatedCoins = [[dict valueForKey:@"coins"] intValue];
            
            [user_defaults setValue:[dict valueForKey:@"coins"] forKey:kConstant_Diamond];
            [user_defaults synchronize];

            
            if(updatedCoins > currentCoins){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Purchase done successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
            [delegate display_update:[[user_defaults valueForKey:kConstant_Diamond] intValue]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [webView makeToastActivity];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [webView hideToastActivity];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [webView hideToastActivity];
}

@end
