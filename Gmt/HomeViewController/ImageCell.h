//
//  ImageCell.h
//  FunnyBirthCard
//
//  Created by Ankit Garg on 5/3/20.
//  Copyright © 2020 Yusri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *likesLbl;

@end
