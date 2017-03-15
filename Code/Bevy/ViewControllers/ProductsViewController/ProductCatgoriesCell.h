//
//  ProductCatgoriesCell.h
//  Bevy
//
//  Created by CompanyName on 12/22/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NPRImageView.h"

/**
 * This class is used to create a cell for product categories list.
 */
@interface ProductCatgoriesCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIButton *btnAdd;
@property (nonatomic, strong) IBOutlet UILabel *lblProductTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblProductSubtitle;
@property (nonatomic, strong) IBOutlet UILabel *lblPrice;
@property (nonatomic, strong) IBOutlet UILabel *lblQuantity;
@property (nonatomic, strong) IBOutlet UIImageView *imgProduct;
@end
