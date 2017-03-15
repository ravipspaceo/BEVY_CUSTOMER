//
//  LoadingViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "LoadingViewController.h"
#import "LoginViewController.h"
#import "ListViewController.h"
#import "MenuViewController.h"
#import "ProductsViewController.h"
#import "MNPageViewController.h"
#import "HomeViewController.h"
#import "CheckOutViewController.h"
#import "OrderStatusViewController.h"
#import "VerifivationViewController.h"
#import "RateViewController.h"

@interface LoadingViewController ()<MNPageViewControllerDataSource, MNPageViewControllerDelegate>
{
    NSMutableArray *aryDrivers;

}

@end

@implementation LoadingViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    
//    [[GlobalUtilityClass sharedInstance] createRatingPopUp];
//    VerifivationViewController *objVerify = [[VerifivationViewController alloc]init];
//    [self.navigationController pushViewController:objVerify animated:YES];
//    return;
    
    
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    NSString *strImageName = @"Default";
    if (iPhoneType>480)
    {
        strImageName = [strImageName stringByAppendingFormat:@"-%.fh.png",iPhoneType];
    }
    else
    {
        strImageName = [strImageName stringByAppendingFormat:@".png"];
    }
    [self.imageBg setImage:[UIImage imageNamed:strImageName]];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [self.actIndicator startAnimating];
    
}



-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Loading Screen"];
    [self appCurrentVersion];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Verification_Incomplete"])
    {
        VerifivationViewController *objVerify = [[VerifivationViewController alloc]initWithNibName:@"VerifivationViewController" bundle:nil];
        self.objSidePanelviewController =[GlobalManager getAppDelegateInstance].objSidePanelviewController;
        self.objSidePanelviewController.shouldDelegateAutorotateToVisiblePanel = NO;
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        self.objSidePanelviewController.rightPanel = objVerify;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:objVerify];
        navController.navigationBar.translucent = NO;
        self.objSidePanelviewController.centerPanel =navController;
        [self.navigationController setViewControllers:@[loginVC, self.objSidePanelviewController] animated:YES];
        
    }
    else if(self.isNotificationFired && [[NSUserDefaults standardUserDefaults] boolForKey:AUTO_LOGIN])
    {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
        self.objSidePanelviewController =[GlobalManager getAppDelegateInstance].objSidePanelviewController;
        self.objSidePanelviewController.shouldDelegateAutorotateToVisiblePanel = NO;
        
        MenuViewController *objMenuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        OrderStatusViewController *orderstatusViewController = [[OrderStatusViewController alloc] initWithNibName:@"OrderStatusViewController" bundle:nil];
        
        self.objSidePanelviewController.rightPanel = objMenuVC;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:orderstatusViewController];
        navController.navigationBar.translucent = NO;
        self.objSidePanelviewController.centerPanel =navController;
        [self.navigationController setViewControllers:@[loginVC, self.objSidePanelviewController] animated:YES];
        
        return;
    }
    else
        [self callApplicationSettingsWS];
}

#pragma mark - Current Version checking
-(void)appCurrentVersion
{
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    NSLog(@"Version -> %@ Build -> %@",version,build);
}


#pragma mark - Instance Methods

-(void)launchViewController
{
    [self.actIndicator stopAnimating];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:AUTO_LOGIN])
    {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
        self.objSidePanelviewController =[GlobalManager getAppDelegateInstance].objSidePanelviewController;
        self.objSidePanelviewController.shouldDelegateAutorotateToVisiblePanel = NO;
        MenuViewController *objMenuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        self.objSidePanelviewController.rightPanel = objMenuVC;
        [objMenuVC chooseRightPanelIndex:1];
        
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        HomeViewController *objList = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:objList];
        
        self.objSidePanelviewController.centerPanel =navController;
        [self.navigationController setViewControllers:@[loginVC, self.objSidePanelviewController] animated:YES];
    }
    else
    {
        LoginViewController *objLoginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:objLoginVC animated:YES];
    }
}

#pragma mark - MNPageViewControllerDataSource

- (UIViewController *)mn_pageViewController:(MNPageViewController *)pageViewController viewControllerBeforeViewController:(ProductsViewController *)viewController
{
    NSUInteger index = [self.arraySubCategories indexOfObject:viewController.dictSubCategory];
    if (index == NSNotFound || index == 0)
    {
        return nil;
    }
    return [[ProductsViewController alloc] initWithMNPageViewController:pageViewController withCategory:self.dictCategory andSubCategoryIndex:(index-1)];
}

- (UIViewController *)mn_pageViewController:(MNPageViewController *)pageViewController viewControllerAfterViewController:(ProductsViewController *)viewController
{
    NSUInteger index = [self.arraySubCategories indexOfObject:viewController.dictSubCategory];
    if (index == NSNotFound || index == (self.arraySubCategories.count - 1))
    {
        return nil;
    }
    return [[ProductsViewController alloc] initWithMNPageViewController:pageViewController withCategory:self.dictCategory andSubCategoryIndex:(index + 1)];
}

#pragma mark - MNPageViewControllerDelegate methods

- (void)mn_pageViewController:(MNPageViewController *)pageViewController willBeginPageToViewController:(UIViewController *)viewController
{
    NSLog(@"willBeginPageToViewController");
    ProductsViewController *productVC = (ProductsViewController *)viewController;
    productVC.txtSearchFiled.text = @"";
    productVC.txtSearchFiled.hidden = YES;
    [productVC btnCancelEditing:nil];
}

- (void)mn_pageViewController:(MNPageViewController *)pageViewController didPageToViewController:(UIViewController *)viewController
{
    [pageViewController.viewController viewWillAppear:YES];
}

#pragma mark - Webservice Methods

-(void)callApplicationSettingsWS
{
    [self.objWSHelper setServiceName:@"APPLICATION_SETTINGS"];

    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] length]) {
        [self.objWSHelper sendRequestWithURL:[WS_Urls getApplicationSettingsURL:@{@"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID]}]];
    }
    else
    {
        [self.objWSHelper sendRequestWithURL:[WS_Urls getApplicationSettingsURL:nil]];
        
    }

    }

-(void)callCategoryList
{
    [self.objWSHelper setServiceName:@"CATEGORY_LIST"];
    NSDictionary *params = @{@"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID], @"store_id" :[[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID]};
    [self.objWSHelper sendRequestWithURL:[WS_Urls getCategoryListURL:params]];
}

#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    if(!response)
        return;
    NSDictionary *responseDictionary = [NSDictionary dictionaryWithDictionary:response];
    if([helper.serviceName isEqualToString:@"APPLICATION_SETTINGS"])
    {
        if([[[responseDictionary objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            NSDictionary *dictSupport = [NSDictionary dictionaryWithDictionary:[[responseDictionary objectForKey:@"data"] objectForKey:@"app_settings"]];
            [[NSUserDefaults standardUserDefaults] setObject:dictSupport forKey:APPLICATION_SETTINGS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
            
            if ([[[dictSupport valueForKey:@"isflurryenable"] uppercaseString] isEqualToString:@"YES"]) {
                /********** FLURRY ANALYTICS **********/
                [[GlobalManager getAppDelegateInstance] flurryAnalytics];
            }
            else{
                NSLog(@"Flurry disabled");
            }
            if ([version floatValue] < [[dictSupport valueForKey:@"applicatin_version"] floatValue]) {
                [[GlobalUtilityClass sharedInstance] createUpgradePopUp];
                return;
            }
            
            aryDrivers = [NSMutableArray arrayWithArray: [[responseDictionary objectForKey:@"data"] objectForKey:@"drivers"]];
            
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
                [[GlobalManager getAppDelegateInstance].window  addSubview:self.objRateView.view];
                self.objRateView.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
                [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.objRateView.view.transform = CGAffineTransformIdentity;
                    
                } completion:^(BOOL finished) {
                    
                }];
                return;
            }
            
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:APPLICATION_SETTINGS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSInteger productCount = [[[NSUserDefaults standardUserDefaults] objectForKey:PRODUCT_COUNT] integerValue];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:AUTO_LOGIN])
        {
            [self performSelector:@selector(launchViewController) withObject:nil afterDelay:0.1];
        }
        else if(productCount > 0)//Open checkout screen;
        {
//            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
            self.objSidePanelviewController =[GlobalManager getAppDelegateInstance].objSidePanelviewController;
            self.objSidePanelviewController.shouldDelegateAutorotateToVisiblePanel = NO;
            
            MenuViewController *objMenuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
            LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            ListViewController *objList = [[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil];
            CheckOutViewController *objChkoutVC = [[CheckOutViewController alloc] initWithNibName:@"CheckOutViewController" bundle:nil];
             objChkoutVC.isProductAvailble = YES;
            self.objSidePanelviewController.rightPanel = objMenuVC;

            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:objList];
            navController.navigationBar.translucent = NO;
            
            NSArray *viewControllers = [NSArray arrayWithObjects:objList, objChkoutVC, nil];
            [navController setViewControllers:viewControllers animated:NO];
            self.objSidePanelviewController.centerPanel =navController;
            [self.navigationController setViewControllers:@[loginVC, self.objSidePanelviewController] animated:YES];
            
            return;
        }
        else if([[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID] == nil)
        {
//            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
            self.objSidePanelviewController =[GlobalManager getAppDelegateInstance].objSidePanelviewController;
            self.objSidePanelviewController.shouldDelegateAutorotateToVisiblePanel = NO;
            
            LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            MenuViewController *objMenuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
            HomeViewController *objHomeVC = [AppDelegate sharedHomeViewController];
            [objHomeVC setIsChangingLocation:NO];

            self.objSidePanelviewController.rightPanel = objMenuVC;
            [objMenuVC chooseRightPanelIndex:1];
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:objHomeVC];
            navController.navigationBar.translucent = NO;
            
            self.objSidePanelviewController.centerPanel =navController;
            [self.navigationController setViewControllers:@[loginVC, self.objSidePanelviewController] animated:YES];
            
            return;
        }
        else
        {
            [self callCategoryList];
        }
    }
    else//@"CATEGORY_LIST"
    {
        if([[[responseDictionary objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            if([[responseDictionary objectForKey:@"data"] count])
            {
            self.dictCategory = [NSDictionary dictionaryWithDictionary:[[[responseDictionary objectForKey:@"data"] objectForKey:@"category_list"] objectAtIndex:0]];
            }
        }
        //Either success/failure below data will avalibale;
       
        [[NSUserDefaults standardUserDefaults] setObject:[[[responseDictionary objectForKey:@"data"] objectForKey:@"product_in_cart"] objectForKey:@"iCartId"] forKey:CART_ID];
        [[NSUserDefaults standardUserDefaults] setObject:[[[responseDictionary objectForKey:@"data"] objectForKey:@"product_in_cart"] objectForKey:@"iTotalProduct"] forKey:PRODUCT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSelector:@selector(launchViewController) withObject:nil afterDelay:0.1];
        return;
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:APPLICATION_SETTINGS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self launchViewController];
}

-(void)btnSubmitClikced
{
    NSLog(@"drivers :%@",aryDrivers);
    
    [aryDrivers removeObjectAtIndex:0];
    
    if ([aryDrivers count])
    {
        NSMutableDictionary *dictDriver = [aryDrivers objectAtIndex:0];
        self.objRateView.dictDriver = dictDriver;
        [[GlobalManager getAppDelegateInstance].window  addSubview:self.objRateView.view];
        self.objRateView.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.objRateView.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        NSInteger productCount = [[[NSUserDefaults standardUserDefaults] objectForKey:PRODUCT_COUNT] integerValue];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:AUTO_LOGIN])
        {
            [self performSelector:@selector(launchViewController) withObject:nil afterDelay:0.1];
        }
        else if(productCount > 0)//Open checkout screen;
        {
            //            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
            self.objSidePanelviewController =[GlobalManager getAppDelegateInstance].objSidePanelviewController;
            self.objSidePanelviewController.shouldDelegateAutorotateToVisiblePanel = NO;
            
            MenuViewController *objMenuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
            LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            ListViewController *objList = [[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil];
            CheckOutViewController *objChkoutVC = [[CheckOutViewController alloc] initWithNibName:@"CheckOutViewController" bundle:nil];
            objChkoutVC.isProductAvailble = YES;
            self.objSidePanelviewController.rightPanel = objMenuVC;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:objList];
            navController.navigationBar.translucent = NO;
            
            NSArray *viewControllers = [NSArray arrayWithObjects:objList, objChkoutVC, nil];
            [navController setViewControllers:viewControllers animated:NO];
            self.objSidePanelviewController.centerPanel =navController;
            [self.navigationController setViewControllers:@[loginVC, self.objSidePanelviewController] animated:YES];
            
            return;
        }
        else if([[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID] == nil)
        {
            //            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
            self.objSidePanelviewController =[GlobalManager getAppDelegateInstance].objSidePanelviewController;
            self.objSidePanelviewController.shouldDelegateAutorotateToVisiblePanel = NO;
            
            LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            MenuViewController *objMenuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
            HomeViewController *objHomeVC = [AppDelegate sharedHomeViewController];
            [objHomeVC setIsChangingLocation:NO];
            
            self.objSidePanelviewController.rightPanel = objMenuVC;
            [objMenuVC chooseRightPanelIndex:1];
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:objHomeVC];
            navController.navigationBar.translucent = NO;
            
            self.objSidePanelviewController.centerPanel =navController;
            [self.navigationController setViewControllers:@[loginVC, self.objSidePanelviewController] animated:YES];
            
            return;
        }
        else
        {
            [self callCategoryList];
        }

    }
    
    
}


@end
