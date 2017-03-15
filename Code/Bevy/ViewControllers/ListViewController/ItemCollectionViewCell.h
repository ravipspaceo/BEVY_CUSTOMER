//
//  ItemCollectionViewCell.h
//  TableCellAnimationDemo
//
//  Created by CompanyName on 12/23/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NPRImageView.h"

/**
 * This class is used to create a cell for item collection view.
 */
@interface ItemCollectionViewCell : UICollectionViewCell
@property (nonatomic , strong) IBOutlet UILabel *lblItemName;
@property (nonatomic , strong) IBOutlet UIImageView *imgItem;

@end
