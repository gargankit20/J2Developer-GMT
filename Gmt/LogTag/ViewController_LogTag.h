//
//
//  Created by Ali Raza on 31/03/2014.
//  Copyright (c) 2014 ILApps. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NstgamthController.h"

@interface ViewController_LogTag : UIViewController<NSURLConnectionDelegate, UITextFieldDelegate>{
    id delegate;
    
    NSString* constant_string_Cookie;
    NSString* constant_string_Cookie_ori;
    
    NSMutableString* md_sync;  //mid
    NSMutableString* tn_sync; //token
    NSMutableString* cc_sync; //ccode
    
    UIButton* btn_tag;
    
    UITextField* textfield_name;
}

-(void) set_delegate:(id)_id;
-(void) get_session_1sttime;

@end
