//
//  ListTableViewCell.h
//  TableCellAnimationDemo
//
//  Created by CompanyName on 12/23/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NPRImageView.h"

/**
 * This class is used to create a cell for List table view.
 */
@interface ListTableViewCell : UITableViewCell

@property(nonatomic, retain) IBOutlet UILabel *lblText,*lblLine;
@property(nonatomic, strong) IBOutlet UIImageView *imageCategory;

@end
