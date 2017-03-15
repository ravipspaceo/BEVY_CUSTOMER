//
//  AppDelegate.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "AppDelegate.h"
#import "LoadingViewController.h"
#import "OrderStatusViewController.h"
#import "MenuViewController.h"
#import "Crittercism.h"
#import "CheckOutViewController.h"
#import "ListViewController.h"
#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <objc/runtime.h>
#import "ACTReporter.h"
#import <AdSupport/ASIdentifierManager.h>
#import <Google/Analytics.h>
#import "Flurry.h"

static HomeViewController *homeViewController = nil;

@interface AppDelegate ()
{
    NSMutableArray *aryDrivers;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.isAppOpened = NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.objSidePanelviewController =[[JASidePanelController alloc] init];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:APPLICATION_FLURRY];

    /********** GOOGLE ANALYTICS **********/
    [self googleAnalytics];

    /********** GOOGLE TRACKING **********/
    [self performSelector:@selector(googleTracking) withObject:nil afterDelay:15.0];
    
    /********** CUSTOM FONT DETAILS **********/
    [self customFontDetails];
    
    [Crittercism enableWithAppID:@"54ca40eb51de5e9f042ed2fb"];
    [self setApperenceSetUp];

    /********** LOCATION MANAGER **********/
    
    [self locationManagerInitialisation];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"backGround"];
    
    [self callApplicationSettingsWS];
  
    NSLog( @"### running FB sdk version: %@", [FBSDKSettings sdkVersion] );

    
   if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    if (launchOptions != nil)
    {
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSLog(@"LAUNCH DETAILS: %@", dictionary);
        self.isAppOpened = YES;
        if (dictionary) {
            [self handleRemoteNotification:dictionary];
        }
//        [self handleRemoteNotification:dictionary];
    }
    
    LoadingViewController *objLoadingVC = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] length] && [[[NSUserDefaults standardUserDefaults] objectForKey:PRODUCT_COUNT] integerValue] > 0) {

        self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
        [self callMakeCartEmptyWS];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:PRODUCT_COUNT];
    }
    else
    {
        [self setApplicationSettings];
    }
    self.objNavController = [[UINavigationController alloc] initWithRootViewController:objLoadingVC];
    [self.objNavController.navigationBar setTranslucent:NO];
    [self.objNavController setNavigationBarHidden:YES];

    self.window.rootViewController = self.objNavController;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - GOOGLE ANALYTICS
-(void)googleAnalytics
{
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    //     Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
//    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
}

#pragma mark - FLURRY ANALYTICS
-(void)flurryAnalytics
{
    [Flurry startSession:@"TNY6N9VPCVYSGKNM3Q52"];
    [Flurry setShowErrorInLogEnabled:YES];
//    [Flurry setDebugLogEnabled:YES];
    [Flurry logPageView];
}

#pragma mark - GOOGLE TRACKING
-(void)googleTracking
{
    [ACTConversionReporter reportWithConversionID:@"894607512" label:@"k_qRCNeP_WEQmMHKqgM" value:@"0.00" isRepeatable:NO];
}

#pragma mark - CUSTOM FONT DETAILS
-(void)customFontDetails
{
//    for(NSString *fontfamilyname in [UIFont familyNames])
//    {
//        NSLog(@"Family:'%@'",fontfamilyname);
//        for(NSString *fontName in [UIFont fontNamesForFamilyName:fontfamilyname])
//        {
//            NSLog(@"\tfont:'%@'",fontName);
//        }
//        NSLog(@"~~~~~~~~");
//    }
}

#pragma mark - LOCATION MANAGER
-(void)locationManagerInitialisation
{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [self.locationManager setDistanceFilter:kCLLocationAccuracyBestForNavigation];
#ifdef __IPHONE_8_0
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self.locationManager requestWhenInUseAuthorization];
    }
#endif
    [self.locationManager startUpdatingLocation];
}
-(void)setApplicationSettings
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:AUTO_LOGIN] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AUTO_LOGIN];
    if([[NSUserDefaults standardUserDefaults] objectForKey:RUNNING_FIRST] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:RUNNING_FIRST];
    if([[NSUserDefaults standardUserDefaults] objectForKey:REMAINING_ORDERS] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"-99" forKey:REMAINING_ORDERS];
    if([[NSUserDefaults standardUserDefaults] objectForKey:PRODUCT_COUNT] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:PRODUCT_COUNT];
    if([[NSUserDefaults standardUserDefaults] objectForKey:CART_ID] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:CART_ID];
    if([[NSUserDefaults standardUserDefaults] objectForKey:DELIVERY_NOTE] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:DELIVERY_NOTE];
    if([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN] == nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"1111111111" forKey:DEVICE_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setApperenceSetUp
{
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)])
    {
        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:-2 forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundImage:[GlobalManager imageWithColor:[UIColor colorWithRed:29.0/255.0 green:29.0/255.0 blue:29.0/255.0 alpha:1.0]] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:29.0/255.0 green:29.0/255.0 blue:29.0/255.0 alpha:1.0]];
        [[UINavigationBar appearance] setShadowImage:[UIImage new]];
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
          NSForegroundColorAttributeName,
          [GlobalManager fontMuseoSans300:20.0],NSFontAttributeName,
          nil]];
    }
}

+(HomeViewController *)sharedHomeViewController
{
    if(homeViewController == nil)
    {
        homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    }
    return homeViewController;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

#pragma - mark UIApplicationDelegate methods

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.locationManager stopUpdatingLocation];
//    self.objRateView = [[RateViewController alloc]init];
//
//    [self.objRateView.view removeFromSuperview];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"backGround"];

    [self callApplicationSettingsWS];
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:STORE_DONT_SHOW_OUTSIDE_ZONE];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:STORE_DONT_SHOW_CLOSE];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"is_push_Notifcation"];



    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Push Notification Methods

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
    NSString *newDeviceToken = [[[[deviceToken description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"DEVICE TOKEN: %@",newDeviceToken);
    if ([newDeviceToken length]) {
        [[NSUserDefaults standardUserDefaults] setObject:newDeviceToken forKey:DEVICE_TOKEN];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1111111111" forKey:DEVICE_TOKEN];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
//    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
    [[NSUserDefaults standardUserDefaults] setObject:@"1111111111" forKey:DEVICE_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    self.isAppOpened = NO;
    NSLog(@"didReceiveRemoteNotification: %@", userInfo);
    [self handleRemoteNotification:userInfo];
}

-(void)handleRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"handleRemoteNotification: %@", userInfo);
   
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    [UIAlertView showWithTitle:APPNAME message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         
         if(self.isAppOpened || [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] == nil)
         {
             NSLog(@"Loading Page");
             LoadingViewController *objLoadingVC = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
             objLoadingVC.isNotificationFired = YES;
             [self.objNavController setViewControllers:@[objLoadingVC] animated:YES];
         }
         else
         {
             NSLog(@"Menu Page");
             MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
             
             NSString *stingNotificationType = @"";
             NSLog(@"Checking not null condition %@",[[userInfo objectForKey:@"aps"] objectForKey:@"otherparam"]);
             if ([[[userInfo objectForKey:@"aps"] objectForKey:@"otherparam"] isKindOfClass:[NSArray class]] || [[[userInfo objectForKey:@"aps"] objectForKey:@"otherparam"] isKindOfClass:[NSDictionary class]]) {
                 stingNotificationType = [[[userInfo objectForKey:@"aps"] objectForKey:@"otherparam"] objectForKey:@"notificationtype"];
             }
             else
             {
                 stingNotificationType = @"";
             }
             if ([stingNotificationType isEqualToString:@"CANCELLEDORDER"])
             {
                 [menuViewcontroller menuItemHomeClikced:nil];
             }
             else if ([stingNotificationType isEqualToString:@"DEMANDHIGH"]) {

                 [menuViewcontroller menuItemHomeClikced:nil];
             }
             else
             {
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"is_push_Notifcation"];
                 [menuViewcontroller menuItemStatusClicked:nil];
             }
         }
    }];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"])
    {   }
    else if ([identifier isEqualToString:@"answerAction"])
    {   }
}
#endif

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    [defaluts setObject:@"0.0" forKey:USER_LATITUDE];
    [defaluts setObject:@"0.0" forKey:USER_LONGITUDE];
    if([[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LATITUDE] == nil)
    {
        [defaluts setObject:@"0.0" forKey:REQUIRED_LATITUDE];
        [defaluts setObject:@"0.0" forKey:REQUIRED_LONGITUDE];
        self.recentStoreLocation = [[CLLocation alloc] initWithLatitude:55.860760 longitude:-4.258947];
    }
    [defaluts synchronize];
    self.currentLocation = [[CLLocation alloc] initWithLatitude:55.860760 longitude:-4.258947];
    NSLog(@"You have chosen not to share your current location.");
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
}

-(void)getCurrentLocation:(CLLocationManager*)locationManager
{
    CLLocation *location = [locationManager location];
    self.currentLocation = location;
    if([[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LATITUDE] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:REQUIRED_LATITUDE];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:REQUIRED_LONGITUDE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.recentStoreLocation = location;
    }
    else
    {
        if(self.recentStoreLocation == nil)
        {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LATITUDE] floatValue], [[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LONGITUDE] floatValue]);
            self.recentStoreLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(locations.count)
    {
        self.currentLocation =  [locations lastObject];
        if (self.currentLocation != nil)
        {
            [self getCurrentLocation:manager];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined)
    {
    }
    else if(status == kCLAuthorizationStatusRestricted)
    {
    }
    else if(status == kCLAuthorizationStatusDenied)
    {
        // Don't Allow
    }
    else if(status == kCLAuthorizationStatusAuthorized)
    {
        //Allow
    }
    else if(status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
    }
    else //kCLAuthorizationStatusAuthorizedAlways
    {
    }
}

#pragma mark - WS Calling Methods
-(void)callMakeCartEmptyWS
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    self.objWSHelper.serviceName = @"Make_Cart_Empty";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getMakeCartEmptyURL:params]];
}



-(void)callApplicationSettingsWS
{
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];

    [self.objWSHelper setServiceName:@"APPLICATION_SETTINGS"];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] length]) {
          [self.objWSHelper sendRequestWithURL:[WS_Urls getApplicationSettingsURL:@{@"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID]}]];
    }
    else
    {
          [self.objWSHelper sendRequestWithURL:[WS_Urls getApplicationSettingsURL:nil]];
        
    }
  
}

#pragma mark - WS Delegate methods
-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    NSLog(@"response --- %@", response);
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if(!response)
        return;
    NSDictionary *dictResults = (NSMutableDictionary *)response;
    
    
    LoadingViewController *objLoadingVC = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    
    if([helper.serviceName isEqualToString:@"APPLICATION_SETTINGS"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
             NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
            NSDictionary *dictSupport = [NSDictionary dictionaryWithDictionary:[[dictResults objectForKey:@"data"] objectForKey:@"app_settings"]];
            
            [[NSUserDefaults standardUserDefaults] setObject:[[dictSupport valueForKey:@"isflurryenable"] uppercaseString] forKey:APPLICATION_FLURRY];
            
            if ([[[dictSupport valueForKey:@"isflurryenable"] uppercaseString] isEqualToString:@"YES"]) {
                /********** FLURRY ANALYTICS **********/
                [self flurryAnalytics];
            }
            else{
                NSLog(@"Flurry disabled");
            }
            if ([version floatValue] < [[dictSupport valueForKey:@"applicatin_version"] floatValue]) {
                    [[GlobalUtilityClass sharedInstance] createUpgradePopUp];
            }
            else
            {
                [self.locationManager startUpdatingLocation];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:dictSupport forKey:APPLICATION_SETTINGS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (IS_IPHONE_4 || IS_IPHONE_5) {
                self.coverImage = [dictSupport valueForKey:@"user_application_cover_image640"];
            }
            else
            {
                self.coverImage = [dictSupport valueForKey:@"user_application_cover_image960"];
            }
            
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"backGround"];

            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"backGround"])
            {
                aryDrivers = [NSMutableArray arrayWithArray: [[dictResults objectForKey:@"data"] objectForKey:@"drivers"]];
                
                NSMutableArray *arrayDriverData = [NSMutableArray arrayWithArray:aryDrivers];
                
                
                for (NSMutableDictionary *dict in arrayDriverData) {
                    NSString *driverID = [dict objectForKey:@"driver_id"];
                    if([driverID length] == 0)
                    {
                        [aryDrivers removeObjectAtIndex:[aryDrivers indexOfObject:dict]];
                    }
                }
                if ([aryDrivers count])
                {
                    NSMutableDictionary *dictDriver = [aryDrivers objectAtIndex:0];
                    self.objRateView = [[RateViewController alloc]init];
                    self.objRateView.objDelegate = self;
                    self.objRateView.dictDriver = dictDriver;
                    if([self.objRateView.view isDescendantOfView:self.window]) {
                        [self.window  addSubview:self.objRateView.view];

                    }
                    
                    self.objRateView.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
                    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                        self.objRateView.view.transform = CGAffineTransformIdentity;
                        
                    } completion:^(BOOL finished) {
                        
                    }];
                }

            }
            
           
            
        }
        
    }
    else
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            [self setApplicationSettings];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:PRODUCT_COUNT];
        }
        else
        {
            self.objNavController = [[UINavigationController alloc] initWithRootViewController:objLoadingVC];
            [self.objNavController.navigationBar setTranslucent:NO];
            [self.objNavController setNavigationBarHidden:YES];
            [self setApplicationSettings];
            self.window.rootViewController = self.objNavController;
        }
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}


-(void)btnSubmitClikced
{
    NSLog(@"drivers :%@",aryDrivers);
    
    [aryDrivers removeObjectAtIndex:0];
    
    if ([aryDrivers count])
    {
        NSMutableDictionary *dictDriver = [aryDrivers objectAtIndex:0];
        self.objRateView.dictDriver = dictDriver;
        [self.window  addSubview:self.objRateView.view];
        self.objRateView.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.objRateView.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        
    }

    
}



@end
