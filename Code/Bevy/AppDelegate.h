//
//  AppDelegate.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "HomeViewController.h"

#import "RateViewController.h"


//#import <Google/Analytics.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,ParseWSDelegate,RateViewControllerDelegate>

@property (nonatomic , strong) RateViewController *objRateView;


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *objNavController;
@property (strong, nonatomic) JASidePanelController *objSidePanelviewController;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocation *recentStoreLocation;

@property (nonatomic, assign) BOOL isRunningFirstTime;
@property (nonatomic, assign) BOOL isFromHomeTab;
@property (nonatomic, assign) BOOL isFromOrderSummery,isfromFB;
@property (nonatomic, assign) BOOL isAppOpened;

@property (nonatomic, strong) NSMutableDictionary *dictAddress;

@property (nonatomic, strong) NSString *strContactNumber,*cardHolderName;

@property (nonatomic, strong) WS_Helper *objWSHelper;

@property (nonatomic, strong) NSString *coverImage;

@property (nonatomic, assign) BOOL isNumber_Changed;
/**
 *  This method is used to create instance of HomeViewController.
 */
+(HomeViewController *)sharedHomeViewController;

-(void)callApplicationSettingsWS;


-(void)flurryAnalytics;

@end
