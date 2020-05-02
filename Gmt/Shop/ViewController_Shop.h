//
//  ViewController_Shop.h
//  5000Likes
//
//  Created by apple on 14/6/3.
//  Copyright (c) 2014年 ILApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "Toast+UIView.h"

#import <IronSource/IronSource.h>


@interface ViewController_Shop : UIViewController<ISOfferwallDelegate, NSURLConnectionDelegate>

{
    
    UIButton *button_item[6];
    UILabel *diamond_lbl_2[6];
    
    UIButton *button_diamond;
    UIButton *button_diamond2;
    UIButton *button_next;
    UILabel *title_more;
    UILabel *title_tocoins;
    
     UIButton *button_store;
    

    id delegate;
    
    bool success_loadedItem;

    int item_buy_Idx;
    int coinsFrom_A[6];
    
    bool isLoadSuperS;
    bool hasSuperS;
    bool allowSuperS;
    
    int buttonStartX;
    
    UILabel *headingLabel;
    
    int offset_OW_onemore;
    
    UIWebView* webview;
}

@property (strong, nonatomic) IBOutlet UILabel *diamond_lbl;

-(void) set_delegate:(id)_id;
-(void) loadSuperS;

-(void) press_back_button;


//- (IBAction)freeCoins:(id)sender;
//- (IBAction)freeCoins2:(id)sender;
-(void) delayToLoadFreeCoinsContent;

-(void) loading_items;

-(void) load_before_appearing_view;

@end
