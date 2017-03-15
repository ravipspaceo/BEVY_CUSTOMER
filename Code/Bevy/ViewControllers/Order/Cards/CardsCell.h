//
//  CardsCell.h
//  Bevy
//
//  Created by CompanyName on 12/24/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class is used to create cell for cards view list.
 */
@interface CardsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *lblCardsEnd;
@property (nonatomic, strong) IBOutlet UILabel *lblEndingNumber;
@property(nonatomic, retain) IBOutlet UIButton *btnCheckMark;

@end
