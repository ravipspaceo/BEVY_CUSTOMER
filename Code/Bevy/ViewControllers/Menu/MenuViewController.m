//
//  MenuViewController.m
//  Bevy
//
//  Created by CompanyName on 12/20/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "MenuViewController.h"
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "SupportViewController.h"
#import "ProductsViewController.h"
#import "ListViewController.h"
#import "OrderSummaryViewController.h"
#import "CheckOutViewController.h"
#import "OrderStatusViewController.h"
#import "ShareViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    if (self.panelIndex == 1)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:RUNNING_FIRST];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.btnLocation.selected = YES;
    }
    else if(self.panelIndex == 0)
        self.btnHome.selected = YES;
    else if(self.panelIndex == 2)
        self.btnStatus.selected = YES;
    else if(self.panelIndex == 3)
        self.btnProfile.selected = YES;
    else if(self.panelIndex == 4)
        self.btnSupport.selected = YES;
    else
        self.btnShare.selected = YES;
    [self.scrollContainer setContentSize:CGSizeMake(0, CGRectGetMaxY(self.btnShare.frame)+10)];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480.0 || IS_IPHONE_5) {
        self.imgArrow.hidden = NO;
        self.scrollContainer.delegate = self;
    }
    else
    {
        self.imgArrow.hidden = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0 && scrollView.contentOffset.y == 0) {
        [self.imgArrow setImage:[UIImage imageNamed:@"down_arrow"]];
    }
    else if (scrollView.contentOffset.x == 0 && scrollView.contentOffset.y != 0) {
        [self.imgArrow setImage:[UIImage imageNamed:@"up_arrow"]];
    }
}

#pragma mark - IBAction Methods

-(IBAction)menuItemHomeClikced:(id)sender
{
    [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
    if([[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID] == nil)
    {
        [self menuItemLocationClicked:nil];
        return;
    }
    self.panelIndex = 0;
    [self.btnHome setSelected:YES];
    [self.btnLocation setSelected:NO];
    [self.btnStatus setSelected:NO];
    [self.btnProfile setSelected:NO];
    [self.btnSupport setSelected:NO];
    [self.btnShare setSelected:NO];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:RUNNING_FIRST] isEqualToString:@"YES"])
    {
        HomeViewController *objHomeVC = [AppDelegate sharedHomeViewController];
        [objHomeVC setIsChangingLocation:NO];
        UINavigationController *obj = [[UINavigationController alloc] initWithRootViewController:objHomeVC];
        obj.navigationBar.translucent = NO; 
        self.sidePanelController.centerPanel = obj;
    }
    else
    {
        UINavigationController *obj = [[UINavigationController alloc] initWithRootViewController:[[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil]];
        obj.navigationBar.translucent = NO;
        self.sidePanelController.centerPanel =obj;
    }
}

-(IBAction)menuItemLocationClicked:(id)sender
{
    [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
    [self callOrderStatusWS:1];
    return;
}

-(void)gotoLocationScreen:(BOOL)isChangingLocation
{
    self.panelIndex = 1;
    [self.btnHome setSelected:NO];
    [self.btnLocation setSelected:YES];
    [self.btnStatus setSelected:NO];
    [self.btnProfile setSelected:NO];
    [self.btnSupport setSelected:NO];
    [self.btnShare setSelected:NO];
    HomeViewController *objVC = [AppDelegate sharedHomeViewController];
    [objVC setIsChangingLocation:isChangingLocation];
    UINavigationController *obj = [[UINavigationController alloc] initWithRootViewController:objVC];
    obj.navigationBar.translucent = NO;
    self.sidePanelController.centerPanel = obj;
}

-(IBAction)menuItemStatusClicked:(id)sender
{
    self.panelIndex = 2;
    [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
    [self callOrderStatusWS:0];
    return;
}

-(IBAction)menuItemProfileClicked:(id)sender
{
    self.panelIndex = 3;
    [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
    [self.btnHome setSelected:NO];
    [self.btnLocation setSelected:NO];
    [self.btnProfile setSelected:YES];
    [self.btnStatus setSelected:NO];
    [self.btnSupport setSelected:NO];
    [self.btnShare setSelected:NO];
    ProfileViewController *objProfileVC = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    UINavigationController *obj = [[UINavigationController alloc] initWithRootViewController:objProfileVC];
    obj.navigationBar.translucent = NO;
    self.sidePanelController.centerPanel = obj;
}

-(IBAction)menuItemSupportClicked:(id)sender
{
    self.panelIndex = 4;
    [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
    [self.btnHome setSelected:NO];
    [self.btnLocation setSelected:NO];
    [self.btnStatus setSelected:NO];
    [self.btnProfile setSelected:NO];
    [self.btnSupport setSelected:YES];
    [self.btnShare setSelected:NO];
    SupportViewController *objSupportVC = [[SupportViewController alloc] initWithNibName:@"SupportViewController" bundle:nil];
    UINavigationController *obj = [[UINavigationController alloc] initWithRootViewController:objSupportVC];
    obj.navigationBar.translucent = NO;
    self.sidePanelController.centerPanel = obj;
}

-(IBAction)menuItemShareClicked:(id)sender
{
    self.panelIndex = 5;
    [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
    [self.btnHome setSelected:NO];
    [self.btnLocation setSelected:NO];
    [self.btnStatus setSelected:NO];
    [self.btnProfile setSelected:NO];
    [self.btnSupport setSelected:NO];
    [self.btnShare setSelected:YES];
    ShareViewController *objShareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
    UINavigationController *obj = [[UINavigationController alloc] initWithRootViewController:objShareVC];
    obj.navigationBar.translucent = NO;
    self.sidePanelController.centerPanel = obj;
}

-(void)showPanelIndex:(NSInteger)index
{
    self.panelIndex = index;
}

-(void)chooseRightPanelIndex:(NSInteger)index
{
    self.panelIndex = index;
    switch (index)
    {
        case 0:
        {
            [self.btnHome setSelected:YES];
            [self.btnLocation setSelected:NO];
        }
            break;
        case 1:
        {
            [self.btnHome setSelected:NO];
            [self.btnLocation setSelected:YES];
        }
            break;
        case 2:
            [self.btnStatus setSelected:YES];
            break;
        case 3:
            [self.btnProfile setSelected:YES];
            break;
        case 4:
            [self.btnSupport setSelected:YES];
            break;
        default:
            [self.btnHome setSelected:YES];
            break;
    }
}

#pragma mark - WS calling methods

-(void)callOrderStatusWS:(NSInteger)tag
{
    if(self.objWSHelper == nil)
        self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];

    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [self.objWSHelper setTagNumber:tag];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getOrderStatusURL:params]];
}

#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if (!response)
    {
        return;
    }
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
    {
        if(helper.tagNumber == 0)
        {
            [self.btnHome setSelected:NO];
            [self.btnLocation setSelected:NO];
            [self.btnStatus setSelected:YES];
            [self.btnProfile setSelected:NO];
            [self.btnSupport setSelected:NO];
            OrderStatusViewController *objOrderStatVC = [[OrderStatusViewController alloc] initWithNibName:@"OrderStatusViewController" bundle:nil];
            UINavigationController *obj = [[UINavigationController alloc] initWithRootViewController:objOrderStatVC];
            obj.navigationBar.translucent = NO;
            self.sidePanelController.centerPanel = obj;
        }
        else
        {
            NSString *remainingOrders = [[[dictResults objectForKey:@"data"] objectForKey:@"remaining_order"] objectForKey:@"remaining_orders"];
            NSDictionary *dictAppSettings = [[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS];
            if([remainingOrders integerValue] == [[dictAppSettings objectForKey:@"max_order_per_customer"] integerValue])
            {
                if([[[NSUserDefaults standardUserDefaults] objectForKey:CART_ID] isEqualToString:@"0"])
                {
                    [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
                    [self gotoLocationScreen:NO];
                    return;
                }
                else
                {
                    //@"If you change the delivery address, The product may not available or the price of the item may get changed."
                    [UIAlertView showConfirmationDialogWithTitle:LOCATION_CHANGE_TITLE message:@"If you change the delivery address, the product price or availability may change. This will automatically update in your cart." firstButtonTitle:@"Cancel" secondButtonTitle:@"Ok" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                     {
                         if(buttonIndex == 1)
                         {
                             [GlobalManager getAppDelegateInstance].isFromHomeTab = YES;
                             [self gotoLocationScreen:YES];
                         }
                         else
                         {
                             [self.sidePanelController showCenterPanelAnimated:YES];
                         }
                     }];
                }
            }
            else
            {
                [self.sidePanelController showCenterPanelAnimated:YES];
                [UIAlertView showWithTitle:LOCATION_CHANGE_TITLE message:@"You cannot change your address until the previous order has been delivered." handler:nil];
                return;
            }
        }
    }
    else
    {
        [self.sidePanelController showCenterPanelAnimated:YES];
        if(helper.tagNumber == 0)
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
        else
        {
            if([[[NSUserDefaults standardUserDefaults] objectForKey:CART_ID] isEqualToString:@"0"])
            {
                [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
                [self gotoLocationScreen:NO];
                return;
            }
            else
            {
                [UIAlertView showConfirmationDialogWithTitle:LOCATION_CHANGE_TITLE message:@"If you change the delivery address, the product price or availability may change. This will automatically update in your cart." firstButtonTitle:@"Cancel" secondButtonTitle:@"Ok" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                 {
                     if(buttonIndex == 1)
                     {
                         [GlobalManager getAppDelegateInstance].isFromHomeTab = YES;
                         [self gotoLocationScreen:YES];
                     }
                     else
                     {
                         [self.sidePanelController showCenterPanelAnimated:YES];
                     }
                 }];
            }
        }
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
    [self.sidePanelController showCenterPanelAnimated:YES];
}

@end
