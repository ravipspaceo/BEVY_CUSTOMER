//
//  LocationTableViewCell.h
//  Bevy
//
//  Created by CompanyName on 12/22/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class is used to create a cell for lacation table view.
 */
@interface LocationTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *lblLocationName,*lblLocationAddress;

@end
