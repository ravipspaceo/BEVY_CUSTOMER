//
//  OrderCell.h
//  Bevy
//
//  Created by CompanyName on 12/25/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class is used to create cell for Order Summary.
 */
@interface OrderCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *lblProductTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblProductSubTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblPrice;
@property (nonatomic, strong) IBOutlet UILabel *lblQuantity;
@property (nonatomic, strong) IBOutlet UIImageView *imgProduct;

@end
