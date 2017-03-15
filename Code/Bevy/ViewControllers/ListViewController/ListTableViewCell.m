
//  ListTableViewCell.m
//  TableCellAnimationDemo
//
//  Created by CompanyName on 12/23/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "ListTableViewCell.h"

@implementation ListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)layoutSubviews{
//    self.lblText.font = [UIFont fontWithName:@"Optima-Bold" size:30];
    self.lblText.font = [UIFont fontWithName:@"OpenSans-Semibold" size:23];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
