//
//  CheckOutCell.h
//  Bevy
//
//  Created by CompanyName on 23/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class is used to create cell for check out view.
 */
@interface CheckOutCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *lblProductTitle;
@property (nonatomic,strong) IBOutlet UILabel *lblProductSubTitle;
@property (nonatomic,strong) IBOutlet UILabel *lbltotalAmount;
@property (nonatomic,strong) IBOutlet UILabel *lblnumberOfQty;

@property (nonatomic,strong) IBOutlet UIButton *btnincreaseQty;
@property (nonatomic,strong) IBOutlet UIButton *btndecreaseQty;
@property (nonatomic,strong) IBOutlet UIButton *btndelete;

@property (nonatomic,strong) IBOutlet UIImageView *itemImage;
@end
