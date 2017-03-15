//
//  LoginViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "MenuViewController.h"
#import "RegisterViewController.h"
#import "ChangePasswordViewController.h"
#import "ProductsViewController.h"
#import "ListViewController.h"
#import "AddProfileViewController.h"
#import "MNPageViewController.h"
#import "CheckOutViewController.h"

@interface LoginViewController ()<MNPageViewControllerDataSource, MNPageViewControllerDelegate>

@end

@implementation LoginViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
//    [self.view setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
    NSLog(@"%@",[GlobalManager GetDeviceId]);
    if(TARGET_IPHONE_SIMULATOR)
    {
        self.txtEmailId.text = @"test108@mailinator.com";
        self.txtPwd.text = @"12345678";
    }
    
    self.txtAccessCode.autocorrectionType = UITextAutocorrectionTypeNo;
    
    
    if (IS_IPHONE_6_PLUS) {
        self.innerView.frame = CGRectMake(self.innerView.frame.origin.x, self.innerView.frame.origin.y+50, self.innerView.frame.size.width , self.innerView.frame.size.height);
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Login Screen"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD] != nil)
    {
        [self.txtEmailId setText:[[NSUserDefaults standardUserDefaults] objectForKey:EMAIL_ADDRESS]];
        [self.txtPwd setText:[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD]];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Instance Methods

-(void)btnLoginClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    sender.layer.borderColor = [[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0]CGColor];
    NSString *strError;
    if (![Validations validateEmail:self.txtEmailId.text error:&strError])
    {
        [UIAlertView showWithTitle:APPNAME message:strError handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtEmailId becomeFirstResponder];
        }];
    }
    else if ([self.txtPwd.text isEqualToString:@""])
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter password" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             [self.txtPwd becomeFirstResponder];
         }];
    }
    else
    {
        [self callLoginWS];
        return;
    }
}

-(IBAction)btnLoginViaFBClicked:(UIButton *)sender
{
    self.isbtnFbPressed = YES;
    [self callFindUDIDWS];
    
    [self.view endEditing:YES];
    sender.layer.borderColor = [[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0]CGColor];
}

-(void)fbLoginClicked
{
    if([GlobalManager checkInternetConnection])
    {
        [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
        NSArray *readPermissions = [[NSArray alloc] initWithObjects:@"email", @"user_birthday", nil];
        [FBSession openActiveSessionWithReadPermissions:readPermissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error)
         {
             [self sessionStateChanged:session state:status error:error];
             return;
         }];
    }
    else
    {
        [UIAlertView showErrorWithMessage:kNetworkError myTag:0 handler:nil];
        return;
    }
}



#pragma mark - IBAction Methods

-(IBAction)clickedOnCreateAccount:(id)sender
{
    self.isbtnFbPressed = NO;
    [self callFindUDIDWS];
    [self.view endEditing:YES];
}

-(IBAction)clickedOnForgotPwd:(id)sender
{
    [self.view endEditing:YES];
    [UIAlertView showForgotPassword:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex == 1)
         {
             [self.view endEditing:YES];
             NSString *error;
             if ([Validations validateEmail:[alertView textFieldAtIndex:0].text error:&error])
             {
                 self.strForgotEmailAddress =[alertView textFieldAtIndex:0].text;
                 [self callForgotpassword:[alertView textFieldAtIndex:0].text];
                 return;
             }
             else
             {
                 [UIAlertView showErrorWithMessage:NSLocalizedStringFromTable(error, @"InfoPlist", nil) myTag:444 handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                  {
                      [self clickedOnForgotPwd:nil];
                  }];
             }
         }
         else
         {
             [self.view endEditing:YES];
         }
     }];
}


-(IBAction)btnOkClicked:(id)sender
{
    [self.view endEditing:YES];
    [self.txtAccessCode resignFirstResponder];
    if([self.txtAccessCode.text length])
    {
        [self callAccessCodeVerificationWS];
    }
    else
    {

    }
}

-(IBAction)btnCancelClicked:(id)sender
{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [self.accessCodeView removeFromSuperview];
    }];
}

-(IBAction)btnNoAccessCodeClicked:(id)sender
{
    NSURL *url = [NSURL URLWithString:BEVY_CO];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - UITextFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtAccessCode) {
        [self.txtAccessCode resignFirstResponder];
    }
    return YES;
}


#pragma mark - FBsession Delegate

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    switch (state)
    {
        case FBSessionStateClosed:
        {
            NSLog(@"FBSessionStateClosed");
            [FBSession.activeSession closeAndClearTokenInformation];
        }
            break;
            
        case FBSessionStateClosedLoginFailed:
        {
            NSLog(@"FBSessionStateClosedLoginFailed");
            
            [UIAlertView showWithTitle:kAppTitle message:@"Please check your Facebook settings on your phone." handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
//            [UIAlertView showWithTitle:kAppTitle message:@"This app does not have access to your facebook account. You can enable access in Privacy Settings" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            }];
            
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            [FBSession.activeSession closeAndClearTokenInformation];
        }
            break;
            
        case FBSessionStateCreated:
        case FBSessionStateOpen:
        {
            NSLog(@"FBSessionStateCreated | FBSessionStateOpen");
            if(FBSession.activeSession.isOpen)
            {
                NSString *accessToken = [session accessTokenData].accessToken;
                [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:FACEBOOK_ACCESSTOKEN];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSDictionary *parameters = [NSDictionary dictionaryWithObject: @"id, email, name, first_name, last_name, picture" forKey:@"fields"];
                [FBRequestConnection startWithGraphPath:@"me" parameters:parameters HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                 {
                     if(error)
                     {
                         [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
                         [UIAlertView showErrorWithMessage:@"This app does not have access to your facebook account. You can enable access in Privacy Settings" myTag:0 handler:nil];
                     }
                     else
                     {
                         NSMutableDictionary *dict = (NSMutableDictionary*)result;
                         [[NSUserDefaults standardUserDefaults] setObject:dict forKey:FACEBOOK_USER_DETAILS];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         [self callFacebookWS];
                     }
                 }];
            }
            else
            {
                [FBSession setActiveSession:session];
            }
        }
            break;
            
        default:
            break;
    }
    if(error != nil)
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        NSLog(@"Facebook Error: %@", [error localizedDescription]);
    }
}

#pragma mark - WS calling methods

-(void)callAccessCodeVerificationWS
{
    NSDictionary *params = @{@"access_code":self.txtAccessCode.text};
    
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    self.objWSHelper.serviceName = @"VERIFY_ACCESS_CODE";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getAccessCodeVerificationURL:params]];
    
}

-(void)callFindUDIDWS
{
    NSString *udid = ([[GlobalManager GetDeviceId] length])?[GlobalManager GetDeviceId]:@"";

    NSDictionary *params = @{@"udid":udid};
    
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    
    self.objWSHelper.serviceName = @"FIND_UDID";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getFindUDIDURL:params]];
    
}


-(void)callLoginWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:self.txtEmailId.text  forKey:@"email_id"];
    [params setObject:self.txtPwd.text  forKey:@"password"];
    [params setObject:kDeviceType  forKey:@"device_type"];
    [params setObject:([[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN] length])?[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]:@"1111111111"  forKey:@"device_token"];
    self.objWSHelper.serviceName = @"Login";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getLoginURL:params]];
}

-(void)callFacebookWS
{
    
    NSString *udid = ([[GlobalManager GetDeviceId] length])?[GlobalManager GetDeviceId]:@"";
    
    NSString *accessCode = ([self.txtAccessCode.text length])?self.txtAccessCode.text:@"";
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_USER_DETAILS];
    NSString *email = [dict objectForKey:@"email"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[dict objectForKey:@"id"] forKey:@"facebook_id"];
    [params setObject:[email length]?email:@"" forKey:@"email_id"];
    [params setObject:[dict objectForKey:@"first_name"] forKey:@"first_name"];
    [params setObject:[dict objectForKey:@"last_name"] forKey:@"last_name"];
    [params setObject:kDeviceType forKey:@"device_type"];
    
    [params setObject:udid forKey:@"udid"];
    [params setObject:accessCode forKey:@"access_code"];
    
    [params setObject:([[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN] length])?[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]:@"1111111111" forKey:@"device_token"];
    [self.objWSHelper setServiceName:@"FACEBOOK_LOGIN"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getFacebookLoginURL:params]];    
}

-(void)callForgotpassword:(NSString *)emailAddress
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:emailAddress  forKey:@"email_id"];
    self.objWSHelper.serviceName = @"ForgotPassword";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getForgotPasswordURL:params]];
}

-(void)callCategoryList
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    [self.objWSHelper setServiceName:@"CATEGORY_LIST"];
    NSDictionary *params = @{@"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID], @"store_id" :[[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID]};
    [self.objWSHelper sendRequestWithURL:[WS_Urls getCategoryListURL:params]];
}

-(void)goToNextViewController
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:RUNNING_FIRST] isEqualToString:@"YES"])
    {
        [GlobalManager getAppDelegateInstance].isRunningFirstTime = YES;
        self.objSidePanelviewController =[GlobalManager getAppDelegateInstance].objSidePanelviewController;
        self.objSidePanelviewController.shouldDelegateAutorotateToVisiblePanel = NO;
        
        MenuViewController *objMenuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        self.objSidePanelviewController.rightPanel = objMenuVC;
        
        [objMenuVC chooseRightPanelIndex:1];
        HomeViewController *objHomeVC = [AppDelegate sharedHomeViewController];
        [objHomeVC setIsChangingLocation:NO];
        UINavigationController *obj = [[UINavigationController alloc] initWithRootViewController:objHomeVC];
        obj.navigationBar.translucent = NO;
        self.objSidePanelviewController.centerPanel =obj;
        [self.navigationController pushViewController:self.objSidePanelviewController animated:YES];
    }
    else
    {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.objSidePanelviewController =[GlobalManager getAppDelegateInstance].objSidePanelviewController;
        self.objSidePanelviewController.shouldDelegateAutorotateToVisiblePanel = NO;
        MenuViewController *objMenuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        self.objSidePanelviewController.rightPanel = objMenuVC;
        
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:PRODUCT_COUNT] integerValue];
        if(count > 0)//Open checkout screen;
        {
            LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            ListViewController *objList = [[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil];
            CheckOutViewController *objChkoutVC = [[CheckOutViewController alloc] initWithNibName:@"CheckOutViewController" bundle:nil];
            objChkoutVC.isFromMenu = NO;
            objChkoutVC.isProductAvailble = YES;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:objList];
            NSArray *viewControllers = [NSArray arrayWithObjects:objList, objChkoutVC, nil];
            [navController setViewControllers:viewControllers animated:NO];
            self.objSidePanelviewController.centerPanel =navController;
            [self.navigationController setViewControllers:@[loginVC, self.objSidePanelviewController] animated:YES];
            
            return;
        }
       
        if([[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID] == nil || count == 0 )
        {
            [objMenuVC chooseRightPanelIndex:1];
            HomeViewController *objHomeVC = [AppDelegate sharedHomeViewController];
            [objHomeVC setIsChangingLocation:NO];
            UINavigationController *obj = [[UINavigationController alloc] initWithRootViewController:objHomeVC];
            obj.navigationBar.translucent = NO;
            self.objSidePanelviewController.centerPanel =obj;
            [self.navigationController pushViewController:self.objSidePanelviewController animated:YES];
            return;
        }
        
        ListViewController *objList = [[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:objList];
        
        navController.navigationBar.translucent = NO;
        self.objSidePanelviewController.centerPanel =navController;
        [self.navigationController pushViewController:self.objSidePanelviewController animated:YES];
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

#pragma mark - ParseWSDelegate Methods
-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    if (!response)
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        return;
    }
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    
    if([helper.serviceName isEqualToString:@"Login"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID];
            NSDictionary *dictionary = [[dictResults objectForKey:@"data"] objectAtIndex:0];
            [[NSUserDefaults standardUserDefaults] setValue:self.txtEmailId.text forKey:EMAIL_ADDRESS];
            [[NSUserDefaults standardUserDefaults] setValue:self.txtPwd.text forKey:PASSWORD];

            if (![[dictionary objectForKey:@"mobile_no"] length]) {
                [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
                if (![[dictionary objectForKey:@"first_name"] length] && ![[dictionary objectForKey:@"last_name"] length]) {
                    AddProfileViewController *addProfileViewController=[[AddProfileViewController alloc] initWithNibName:@"AddProfileViewController" bundle:nil];
                    addProfileViewController.isFB = NO;
                    [addProfileViewController setDictDetails:@{@"email" : self.txtEmailId.text, @"password" : self.txtPwd.text, @"userId" : [dictionary objectForKey:@"user_id"]}];
                    [self.navigationController pushViewController:addProfileViewController animated:YES];
                    return;
                }
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:MOBILE_NUMBER];
                [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:MOBILE_CODE];

            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"mobile_no"] forKey:MOBILE_NUMBER];
                [[NSUserDefaults standardUserDefaults] setValue:[dictionary objectForKey:@"mobile_code"] forKey:MOBILE_CODE];

            }
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AUTO_LOGIN];
            
            if(userId != nil && ![userId isEqualToString:[dictionary objectForKey:@"user_id"]])//Means another user
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:REQUIRED_LOCATION_NAME];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", [GlobalManager getAppDelegateInstance].currentLocation.coordinate.latitude] forKey:REQUIRED_LATITUDE];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", [GlobalManager getAppDelegateInstance].currentLocation.coordinate.longitude] forKey:REQUIRED_LONGITUDE];
            }
            if([dictionary objectForKey:@"cart_id"])
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:RUNNING_FIRST];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"cart_store_id"] forKey:STORE_ID];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"cart_address"] forKey:REQUIRED_LOCATION_NAME];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"cart_latitude"] forKey:REQUIRED_LATITUDE];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"cart_longitude"] forKey:REQUIRED_LONGITUDE];
            }
            else if([dictionary objectForKey:@"store_id"])
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:RUNNING_FIRST];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"store_id"] forKey:STORE_ID];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"delivery_address"] forKey:REQUIRED_LOCATION_NAME];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"delivery_latitude"] forKey:REQUIRED_LATITUDE];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"delivery_longitude"] forKey:REQUIRED_LONGITUDE];
            }
            else{}
            
            [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"user_id"] forKey:USER_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:RUNNING_FIRST] isEqualToString:@"YES"] || [[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID] == nil)
            {
                [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
                [self goToNextViewController];
                return;
            }
            else
            {
                [self callCategoryList];
                return;
            }
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"FACEBOOK_LOGIN"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            NSLog(@"success 1");
            NSDictionary *dictFBDetails = [[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_USER_DETAILS];
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AUTO_LOGIN];
            [[NSUserDefaults standardUserDefaults] setObject:[dictFBDetails objectForKey:@"email"] forKey:EMAIL_ADDRESS];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PASSWORD];
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"user_id"] forKey:USER_ID];            
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_USER_DETAILS]];
            [dict setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"user_id"] forKey:@"userId"];
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            AddProfileViewController *objAPVC = [[AddProfileViewController alloc] initWithNibName:@"AddProfileViewController" bundle:nil];
            [objAPVC setIsFB:YES];
            [GlobalManager getAppDelegateInstance].isfromFB=YES;
            [objAPVC setDictDetails:[NSDictionary dictionaryWithDictionary:dict]];
            [self.navigationController pushViewController:objAPVC animated:YES];
        }
        else if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 2)
        {
            NSLog(@"success 2");
            NSDictionary *dictionary = [[dictResults objectForKey:@"data"] objectAtIndex:0];

            if (![[dictionary objectForKey:@"mobile_no"] length]) {
                NSDictionary *dictFBDetails = [[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_USER_DETAILS];
                //            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AUTO_LOGIN];
                [[NSUserDefaults standardUserDefaults] setObject:[dictFBDetails objectForKey:@"email"] forKey:EMAIL_ADDRESS];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PASSWORD];
                [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"user_id"] forKey:USER_ID];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_USER_DETAILS]];
                [dict setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"user_id"] forKey:@"userId"];
                [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
                AddProfileViewController *objAPVC = [[AddProfileViewController alloc] initWithNibName:@"AddProfileViewController" bundle:nil];
                [objAPVC setIsFB:YES];
                [GlobalManager getAppDelegateInstance].isfromFB=YES;
                [objAPVC setDictDetails:[NSDictionary dictionaryWithDictionary:dict]];
                [self.navigationController pushViewController:objAPVC animated:YES];
                return;
            }
            NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID];
            

            NSDictionary *dictFBDetails = [[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_USER_DETAILS];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AUTO_LOGIN];
            [[NSUserDefaults standardUserDefaults] setObject:[dictFBDetails objectForKey:@"email"] forKey:EMAIL_ADDRESS];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PASSWORD];

            if(userId != nil && ![userId isEqualToString:[dictionary objectForKey:@"user_id"]])//Means another user
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:REQUIRED_LOCATION_NAME];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", [GlobalManager getAppDelegateInstance].currentLocation.coordinate.latitude] forKey:REQUIRED_LATITUDE];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", [GlobalManager getAppDelegateInstance].currentLocation.coordinate.longitude] forKey:REQUIRED_LONGITUDE];
            }
            if([dictResults objectForKey:@"store_id"])
            {
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"store_id"] forKey:STORE_ID];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"delivery_address"] forKey:REQUIRED_LOCATION_NAME];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"delivery_latitude"] forKey:REQUIRED_LATITUDE];
                [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"delivery_longitude"] forKey:REQUIRED_LONGITUDE];
            }
            [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"user_id"] forKey:USER_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:RUNNING_FIRST] isEqualToString:@"YES"] || [[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID] == nil)
            {
                [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
                NSLog(@"goToNextViewController %@",dictionary);
                [self goToNextViewController];
                return;
            }
            else
            {
                NSLog(@"callCategoryList");
                [self callCategoryList];
                return;
            }
        }
        else
        {
            NSLog(@"Error");
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"VERIFY_ACCESS_CODE"]){
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.accessCodeView removeFromSuperview];
            }];
            if (self.isbtnFbPressed) {
                [self fbLoginClicked];
            }
            else
            {
                RegisterViewController *objRegisterVC=[[RegisterViewController alloc] init];
                objRegisterVC.showAccessCodePopup = NO;
                [self.navigationController pushViewController:objRegisterVC animated:YES];
            }
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"FIND_UDID"])
    {
        
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            if (self.isbtnFbPressed) {
                [self fbLoginClicked];
            }
            else
            {
                RegisterViewController *objRegisterVC=[[RegisterViewController alloc] init];
                objRegisterVC.showAccessCodePopup = NO;
                [self.navigationController pushViewController:objRegisterVC animated:YES];
            }
        }
        else
        {
            if (self.isbtnFbPressed) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.accessCodeView.frame = [GlobalManager getAppDelegateInstance].window.frame;
                    [self.txtAccessCode becomeFirstResponder];
                    [[GlobalManager getAppDelegateInstance].window addSubview:self.accessCodeView];
                }];
            }
            else
            {
                RegisterViewController *objRegisterVC=[[RegisterViewController alloc] init];
                objRegisterVC.showAccessCodePopup = YES;
                [self.navigationController pushViewController:objRegisterVC animated:YES];
            }
        }
    }
    else if([helper.serviceName isEqualToString:@"CATEGORY_LIST"])
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            if([[dictResults objectForKey:@"data"] count])
            {
            self.dictCategory = [NSDictionary dictionaryWithDictionary:[[[dictResults objectForKey:@"data"] objectForKey:@"category_list"] objectAtIndex:0]];
            }
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectForKey:@"product_in_cart"] objectForKey:@"iCartId"] forKey:CART_ID];
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectForKey:@"product_in_cart"] objectForKey:@"iTotalProduct"] forKey:PRODUCT_COUNT];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self goToNextViewController];
        return;
    }
    else//@"ForgotPassword"
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            [UIAlertView showWithTitle:APPNAME message:[NSString stringWithFormat:@"A link to reset your password will be sent to %@", self.strForgotEmailAddress] handler:nil];
            return;
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end
