//
//  CheckOutCell.m
//  Bevy
//
//  Created by CompanyName on 23/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "CheckOutCell.h"

@implementation CheckOutCell

- (void)awakeFromNib {
    
    CALayer *btnLayerDecr = [self.btndecreaseQty layer];
    [btnLayerDecr setMasksToBounds:YES];
    [btnLayerDecr setCornerRadius:3.0f];
    CALayer *btnLayerIncr = [self.btnincreaseQty layer];
    [btnLayerIncr setMasksToBounds:YES];
    [btnLayerIncr setCornerRadius:3.0f];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
