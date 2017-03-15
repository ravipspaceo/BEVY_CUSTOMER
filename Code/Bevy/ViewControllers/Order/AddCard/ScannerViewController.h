//
//  ScannerViewController.h
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardIO.h"

/**
 * This class is used to scan payment card.
 */

@interface ScannerViewController : UIViewController<CardIOPaymentViewControllerDelegate>

@end
