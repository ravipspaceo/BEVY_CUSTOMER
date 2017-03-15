//
//  LoadingViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "RateViewController.h"



@interface LoadingViewController : GAITrackedViewController<RateViewControllerDelegate>
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *actIndicator;
@property (nonatomic , strong) RateViewController *objRateView;

@property (nonatomic, strong) IBOutlet UIImageView *imageBg;
@property (nonatomic, strong) JASidePanelController *objSidePanelviewController;
@property (nonatomic, retain) WS_Helper *objWSHelper;
@property (nonatomic, retain) NSDictionary *dictCategory;
@property (nonatomic, retain) NSMutableArray *arraySubCategories;
@property (nonatomic, assign) BOOL isNotificationFired;

@end
