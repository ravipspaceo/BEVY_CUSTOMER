//
//  RateDriverTableViewCell.h
//  Bevy
//
//  Created by CompanyName on 12/24/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class is used to create a custom cell for driver rate .
 */
@interface RateDriverTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *lblDriverName;
@property (nonatomic, strong) IBOutlet RateView *rateDriver;
@property (nonatomic, strong) IBOutlet UIImageView *imgDriver;

@end
