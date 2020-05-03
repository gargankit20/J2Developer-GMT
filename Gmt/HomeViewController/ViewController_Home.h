//
//  ViewController_Home.h
//
//  Created by Ali Raza on 25/03/2014.
//  Copyright (c) 2014 ILApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class ToIncreaseViewController, ViewController_Shop,ViewController_LogTag;

@interface ViewController_Home : UIViewController<NSURLConnectionDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    NSTimer* get_session_1sttime_timer;

    ViewController_LogTag *viewController_LogTag;
    bool hasIniit_tag_VC;
    ViewController_Shop* viewController_Shop;
    UIButton *button_store;
    
    int currentThread;
    bool thumbnail_isloading;
    int page_which;
    float scrollHeight_basic;
    bool isLogged;
    bool tappingOut;
    
    int item;
    int row;
    int col;
    int accumCount;
    bool can_nextTag;
    bool noTagFeed;
    bool isLoadingTag;
    
    int requestFail_time;
    int qid_updateing;
    int orderedtag_updating;
    int tagdelivered_updating;
    int totaltagordered_updating;
    int prev_id_update;
    NSMutableString* tagmedia_ID_updating;
    
    NSMutableArray* unsaveHistoryArray;
    NSMutableArray* saveArray;
    
    int failDiamond_fromserver;
    
    int likeAwardToFish;
    int FishLink;
    bool isFish;
    
    int photoLoading_url_timer;
    
    int max_preload;
    int max_load;
    UIImageView* loadtagImg_pre[40];
    bool successLoad_pre[40];
    bool loadFail_pre[40];
    bool loaded_pre[40];
    bool loading_pre[40];
    bool infeed_preload[40];
    bool started_preload;
    int idx_preload;
    int remain_preload_feed;
    int totalfeed_preload;
    int timer_preload;
    int timeAim_preload;
    bool preloading;
    int inLoading_preload;

    int refundAmt;
    int rewardAmt;
    int ownAmt;
    
   // int responseVersion;
    
    ToIncreaseViewController *inIncreaseVC;
    
    int runningTime;
    
    bool isBlocked;
    int blockedTimer;
    
    int qidIdx_own;
    
    int refundChecking_counter;
    bool loopChecking;
    bool refund_isGettingBack;
    
    int cid_from;
    
    int selectedTag_sender;
    
    int own_time_running;
    
    UIButton* btn_donotandDonot;
}

@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSString* focousView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImgv;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *reqFail_lbl;
@property (strong, nonatomic) IBOutlet UILabel *null_lbl;
@property (strong, nonatomic) IBOutlet UILabel *reqFailCounter_lbl;
@property (weak, nonatomic) IBOutlet UIView *increaseTagView;
@property (weak, nonatomic) IBOutlet UIButton *tagDiamond_btn;
@property (weak, nonatomic) IBOutlet UIButton *tagDia_2_btn;
@property (weak, nonatomic) IBOutlet UIView *center_uiview;
@property (weak, nonatomic) IBOutlet UIButton *centermenu_btn;
@property (weak, nonatomic) IBOutlet UIButton *rateUs;
@property (weak, nonatomic) IBOutlet UIButton *emailUs;
@property (weak, nonatomic) IBOutlet UIButton *loginOut;
@property (nonatomic, strong) NSArray* images;
@property (nonatomic, strong) NSMutableArray* accuImages;
@property (nonatomic, strong) NSMutableArray* thumbnails;

- (IBAction)load_next_tags:(id)sender;

- (IBAction)pressDiamond:(id)sender;
- (IBAction)pressCenter:(id)sender;
- (IBAction)pressTagOut:(id)sender;
- (IBAction)pressStore:(id)sender;
- (IBAction)pressRate:(id)sender;
- (IBAction)pressInstruction:(id)sender;
- (IBAction)pressEmail:(id)sender;

-(void) getFreeDiamond; //getUserCoins

-(void) loadImages_scrollView:(NSString*)_min_id maxID:(NSString*)_max_id;

-(void) display_update:(int)_coins;
-(void) save_feed_history:(NSString*)_mediaId;

-(void) requestFail;
-(void) requestSuccess;

-(void) popup_toincrease_view;
-(void) remove_shop_view;

-(void) tegCoinsFromSSAD:(int)_amount;

@end
