//
//  HSNstgamUserMedia.m
//  HSNstgamSample
//
//  Created by Harminder Sandhu on 12-05-01.
//  Copyright (c) 2012 Pushbits. All rights reserved.
//

#import "HMedia.h"
#import "Global.h"
@implementation HMedia

@synthesize thumbnailUrl = _thumbnailUrl;
@synthesize standardUrl = _standardUrl;
@synthesize standard_standardUrl = standard_standardUrl;
@synthesize likes = _likes;

+(NSArray*) initAttr:(NSArray*) attributesArray moreAvailable:(bool)_moreAvailable{
    //NSLog(@"init fuck attributes:%lu", (unsigned long)attributesArray.count);
    NSMutableArray *mutableRecords = [NSMutableArray array];
    
    [maxID_thumbnail setString:@""];

    for(int i = 0 ; i < attributesArray.count ; i++){
        //NSLog(@"init fuck iiii:%i", i);
        [mutableRecords addObject:[[HMedia alloc] initOneAttr:[attributesArray objectAtIndex:i] moreAvailable:_moreAvailable]];
    }
    
    return mutableRecords;
}

-(id) initOneAttr: (NSDictionary *)attributesDic moreAvailable:(bool)_moreAvailable{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSArray* checkImgSize_Array;
    NSArray* multi_post_array = [attributesDic objectForKey:@"carousel_media"];
    NSArray* video_array = [attributesDic objectForKey:@"video_versions"];
    
    if(multi_post_array.count == 0){
        checkImgSize_Array = [[attributesDic objectForKey:@"image_versions2"] objectForKey:@"candidates"];
    }else{
        checkImgSize_Array = [[multi_post_array[0] objectForKey:@"image_versions2"] objectForKey:@"candidates"];
    }
    
    int minIdx = 99999;
    int minSize = 99999;
    for(int i = 0 ; i < checkImgSize_Array.count ; i++){
        int checkSize = [[[checkImgSize_Array objectAtIndex:i] valueForKey:@"width"] intValue];
        if(checkSize < minSize){
            minSize = checkSize;
            minIdx = i;
        }
    }
    
    //NSLog(@"FKUCFUCKFUCK:%@", [[checkImgSize_Array objectAtIndex:minIdx] valueForKey:@"url"]);
    
    self.thumbnailUrl = [[checkImgSize_Array objectAtIndex:minIdx] valueForKey:@"url"];
    self.standardUrl = [[checkImgSize_Array objectAtIndex:minIdx] valueForKey:@"url"];
    
    if(video_array.count == 0){
        
        if(p_key_type == 27){
            self.standard_standardUrl = [[checkImgSize_Array objectAtIndex:1] valueForKey:@"url"];
        }else{
            //self.standard_standardUrl = [[checkImgSize_Array objectAtIndex:2] valueForKey:@"url"];
            self.standard_standardUrl = [[checkImgSize_Array objectAtIndex:1] valueForKey:@"url"];
        }
        
    }else{
        self.standard_standardUrl = [[checkImgSize_Array objectAtIndex:1] valueForKey:@"url"];
    }
    
    self.likes = [[attributesDic valueForKey:@"like_count"] integerValue];
    
    self.photoID = [attributesDic valueForKey:@"id"];
    
    
    if(_moreAvailable){
        [maxID_thumbnail setString:[attributesDic valueForKey:@"id"]];
    }
    
    
    return self;
    
}

- (id)initAttr:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.thumbnailUrl = [[[attributes valueForKeyPath:@"images"] valueForKeyPath:@"thumbnail"] valueForKeyPath:@"url"];
    self.standardUrl = [[[attributes valueForKeyPath:@"images"] valueForKeyPath:@"thumbnail"] valueForKeyPath:@"url"];
    self.standard_standardUrl = [[[attributes valueForKeyPath:@"images"] valueForKeyPath:@"low_resolution"] valueForKeyPath:@"url`"];
    self.likes = [[[attributes objectForKey:@"likes"] valueForKey:@"count"] integerValue];
    self.photoID = [attributes valueForKey:@"id"];
    
    return self;
}



@end
