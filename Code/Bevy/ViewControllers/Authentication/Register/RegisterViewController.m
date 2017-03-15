//
//  RegisterViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "AddProfileViewController.h"
#import "TandCViewController.h"
#import "MenuViewController.h"
#import "ListViewController.h"
#import "CheckOutViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.objHelper = [[WS_Helper alloc] initWithDelegate:self];
    if (IS_IPHONE_6_PLUS) {
        self.innerView.frame = CGRectMake(self.innerView.frame.origin.x, self.innerView.frame.origin.y+65, self.innerView.frame.size.width , self.innerView.frame.size.height);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Registration Screen"];
    self.navigationController.navigationBarHidden = YES;
//    NSString *btnText =self.btnTermsConditions.titleLabel.text;
//    NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:btnText];
//    NSDictionary *attrsReg = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]};
//    [hogan addAttributes:attrsReg range:[btnText rangeOfString:@"&"]];
//    [self.btnTermsConditions setAttributedTitle:hogan forState:UIControlStateNormal];
    
        NSString *btnText =self.lbltermsAndConditions.text;
        NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:btnText];
    [self.lbltermsAndConditions setFont:[GlobalManager fontMuseoSans100:11.0]];
    [self.lbltermsAndConditions setTextColor:[UIColor blackColor]];

    NSDictionary *attrsReg = @{NSFontAttributeName: [GlobalManager fontMuseoSans500:11.0], NSForegroundColorAttributeName : [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]};
        [hogan addAttributes:attrsReg range:[btnText rangeOfString:@"Terms"]];
        [self.lbltermsAndConditions setAttributedText:hogan];
        [hogan addAttributes:attrsReg range:[btnText rangeOfString:@"Conditions"]];
        [self.lbltermsAndConditions setAttributedText:hogan];
        [hogan addAttributes:attrsReg range:[btnText rangeOfString:@"Privacy Policy"]];
        [self.lbltermsAndConditions setAttributedText:hogan];
    
    
    
    self.txtAccessCode.autocorrectionType = UITextAutocorrectionTypeNo;
    if (self.showAccessCodePopup) {
        self.accessCodeView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.accessCodeView.frame = [GlobalManager getAppDelegateInstance].window.frame;
//            [self.txtAccessCode becomeFirstResponder];
            [[GlobalManager getAppDelegateInstance].window addSubview:self.accessCodeView];
        }];
    }
    else
    {
        self.accessCodeView.hidden = YES;
    }
}

#pragma mark - UITextFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtAccessCode) {
        [self.txtAccessCode resignFirstResponder];
    }
    return YES;
}


#pragma mark - IBAction Methods

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
        [self.navigationController popViewControllerAnimated:YES];
        [self.accessCodeView removeFromSuperview];
    }];
}

- (IBAction)btnSignUpWithFBClicked:(id)sender {
    
    [self fbLoginClicked];
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




-(IBAction)btnNoAccessCodeClicked:(id)sender{
    NSURL *url = [NSURL URLWithString:BEVY_CO];
    [[UIApplication sharedApplication] openURL:url];
}


-(IBAction)clickedOnHaveAccount:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickedOnRegister:(id)sender
{
    [self.view endEditing:YES];
    NSString *strError;
    if (self.txtEmailID.text.length == 0) {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter email address" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtEmailID becomeFirstResponder];
        }];
    }
    else if (![Validations validateEmail:self.txtEmailID.text error:&strError])
    {
        [UIAlertView showWithTitle:APPNAME message:strError handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtEmailID becomeFirstResponder];
        }];
    }else if (self.txtPwd.text.length == 0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter password" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPwd becomeFirstResponder];
        }];
    }
    else if (![Validations validatePasswordLength:self.txtPwd.text error:&strError])
    {
        [UIAlertView showWithTitle:APPNAME message:strError handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPwd becomeFirstResponder];
        }];
    }
    else if (self.txtConformPwd.text.length == 0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter confirm password" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             [self.txtConformPwd becomeFirstResponder];
         }];
    }
    else if (![self.txtPwd.text isEqualToString:self.txtConformPwd.text])
    {
        [UIAlertView showWithTitle:APPNAME message:@"Password Mismatched" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             [self.txtConformPwd becomeFirstResponder];
         }];
    }
//    else if (!self.btnRadio.selected)
//    {
//        [UIAlertView showWithTitle:APPNAME message:@"Please accept our terms and conditions" handler:nil];
//    }
    else
    {
        [self callLoginWS];
        return;
    }
}

-(IBAction)clickedOnTerms:(UIButton *)sender
{
    [self.view endEditing:YES];
    TandCViewController *objTandCVC = [[TandCViewController alloc] initWithNibName:@"TandCViewController" bundle:nil];
    if (sender.tag == 111111111) {
        objTandCVC.strTitle = @"Privacy Policy";

    }
    else
    {
        objTandCVC.strTitle = @"Terms & Conditions";

    }
    objTandCVC.isFromReg = YES;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:objTandCVC animated:YES];
}

-(IBAction)btnRadioTermsClicked:(UIButton*)sender
{
    sender.selected = !sender.selected;
}

-(void)btnBackClicked:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Instance Methods

-(void)callFacebookWS
{
    
    NSString *udid = ([[GlobalManager GetDeviceId] length])?[GlobalManager GetDeviceId]:@"";
    
    NSString *accessCode = ([self.txtAccessCode.text length])?self.txtAccessCode.text:@"";
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_USER_DETAILS];
    
    NSString *email = [dict objectForKey:@"email"];
    if (![email length]) {
        [UIAlertView showWithTitle:kAppTitle message:@"Your Facebook privacy settings doesn't allow to get email id so please sign up manually." handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[dict objectForKey:@"id"] forKey:@"facebook_id"];
    [params setObject:[dict objectForKey:@"email"] forKey:@"email_id"];
    [params setObject:[dict objectForKey:@"first_name"] forKey:@"first_name"];
    [params setObject:[dict objectForKey:@"last_name"] forKey:@"last_name"];
    [params setObject:kDeviceType forKey:@"device_type"];
    
    [params setObject:udid forKey:@"udid"];
    [params setObject:accessCode forKey:@"access_code"];
    
    [params setObject:([[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN] length])?[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]:@"1111111111" forKey:@"device_token"];
    [self.objHelper setServiceName:@"FACEBOOK_LOGIN"];
    [self.objHelper sendRequestWithURL:[WS_Urls getFacebookLoginURL:params]];
}


-(void)callLoginWS
{
    NSString *udid = ([[GlobalManager GetDeviceId] length])?[GlobalManager GetDeviceId]:@"";
    
    NSString *accessCode = ([self.txtAccessCode.text length])?self.txtAccessCode.text:@"";
    
    NSDictionary *params = @{@"email_id" : self.txtEmailID.text, @"password" : self.txtPwd.text, @"device_type" : @"iOS", @"device_token" : ([[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN] length])?[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]:@"1111111111",@"udid":udid,@"access_code":accessCode};
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    self.objHelper.serviceName = @"REGISTER";
    
//    [self.objHelper sendRequestWithURL:[WS_Urls getRegistrationURL:params]];
    [self.objHelper sendRequestWithPostURL:[WS_Urls getRegistrationURL:nil] andParametrers:params];
}

-(void)callAccessCodeVerificationWS
{
    NSDictionary *params = @{@"access_code":self.txtAccessCode.text};
    
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    self.objHelper.serviceName = @"VERIFY_ACCESS_CODE";
    [self.objHelper sendRequestWithURL:[WS_Urls getAccessCodeVerificationURL:params]];

}

#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if (!response) {
        return;
    }
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if ([helper.serviceName isEqualToString:@"REGISTER"]) {
        if([[[response objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            AddProfileViewController *addProfileViewController=[[AddProfileViewController alloc] initWithNibName:@"AddProfileViewController" bundle:nil];
            addProfileViewController.isFB = NO;
            [addProfileViewController setDictDetails:@{@"email" : self.txtEmailID.text, @"password" : self.txtPwd.text, @"userId" : [[[response objectForKey:@"data"] objectAtIndex:0] objectForKey:@"user_id"]}];
            [self.navigationController pushViewController:addProfileViewController animated:YES];
        }
        else
        {
            [UIAlertView showWithTitle:kAppTitle message:[[response objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if ([helper.serviceName isEqualToString:@"VERIFY_ACCESS_CODE"]) {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.accessCodeView removeFromSuperview];
            }];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"FACEBOOK_LOGIN"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
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
            NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID];
            
            NSDictionary *dictionary = [[dictResults objectForKey:@"data"] objectAtIndex:0];
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
            
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            [self goToNextViewController];

        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
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
