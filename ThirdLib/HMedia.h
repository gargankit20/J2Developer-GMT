//
//  HSNstgamUserMedia.h
//  HSNstgamSample
//
//  Created by Harminder Sandhu on 12-05-01.
//  Copyright (c) 2012 Pushbits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMedia : NSObject

@property (nonatomic, strong) NSString* thumbnailUrl;
@property (nonatomic, strong) NSString* standardUrl;
@property (nonatomic, strong) NSString* standard_standardUrl;
@property (nonatomic, strong) NSString* photoID;

@property (nonatomic, assign) NSUInteger likes;


+(NSArray*) initAttr:(NSArray*) attributesArray moreAvailable:(bool)_moreAvailable;

@end
