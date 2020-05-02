//
//
//  Created by Ali Raza on 27/03/2014.
//  Copyright (c) 2014 ILApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToIncreaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSURLConnectionDelegate,UIAlertViewDelegate>
{
    UIButton *button_store;
    
    int howmnayLikesBuying;
    int selectedTableRow;
    bool buyingLikes;
    bool allowBuy;
    
    int tol;
    int dl;
    int maxQueuePos;
    
    id delegate;
    
    bool isInSelectLikeView;
    
    int coinsInServer;
    
    int failToUpdateCoins;
    
    NSString* newImgURL;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIImage *img;
@property (weak, nonatomic) NSString *imgUrl;
@property (weak, nonatomic) NSString *imgThumnailUrl;
@property (weak, nonatomic) NSString *imgId;
@property (nonatomic, strong) NSString *imgLikesCount;
@property (weak, nonatomic) IBOutlet UITableView *selectLikesTable;
@property (weak, nonatomic) IBOutlet UILabel *status_lbl;
@property (strong, nonatomic) IBOutlet UILabel *diamond_lbl;

-(void) set_delegate:(id)_id;

-(void) display_update:(int)_coins;

-(void) press_back_button;

@end
