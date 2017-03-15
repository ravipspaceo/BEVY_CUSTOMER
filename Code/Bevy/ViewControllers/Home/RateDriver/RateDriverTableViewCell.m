//
//  RateDriverTableViewCell.m
//  Bevy
//
//  Created by CompanyName on 12/24/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "RateDriverTableViewCell.h"

@implementation RateDriverTableViewCell

- (void)awakeFromNib {
    [self.rateDriver setStarBorderColor:[UIColor grayColor]];
    [self.rateDriver setStarSize:25.0];
    
    self.imgDriver.layer.cornerRadius = self.imgDriver.frame.size.height/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
