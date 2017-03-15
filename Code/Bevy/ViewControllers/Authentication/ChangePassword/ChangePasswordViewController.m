//
//  ChangePasswordViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
    [self setBackButton];
    [self viewTitleFont];
    [self setUpUI];
}

#pragma mark - Instance Methods

-(void)setUpUI
{
      self.txtOldPassword.placeholder=@"Old Password";
      self.txtNewPassword.placeholder=@"New Password";
      self.txtConfirmPassword.placeholder=@"Confirm Password";
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Change Password Screen"];
    
}

-(void)viewTitleFont
{
    self.title =@"Change Password";
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"OpenSans" size:18], NSFontAttributeName, nil]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],NSForegroundColorAttributeName,[GlobalManager fontMuseoSans300:18.0],NSFontAttributeName, nil]];
}

#pragma mark - IBAction Methods

-(IBAction)clickedOnDone:(id)sender
{
    [self.view endEditing:YES];
    NSString *strError;
    if (self.txtOldPassword.text.length == 0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter current password" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtOldPassword becomeFirstResponder];
        }];
    }
    else if (self.txtNewPassword.text.length == 0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter new password" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtNewPassword becomeFirstResponder];
        }];
    }
    else if (![Validations validatePasswordLength:self.txtNewPassword.text error:&strError])
    {
        [UIAlertView showWithTitle:APPNAME message:@"New password must be between 8-16 character long. It should contain at least one digit." handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtNewPassword becomeFirstResponder];
        }];
    }
    else if(self.txtConfirmPassword.text.length == 0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter confirm password" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtConfirmPassword becomeFirstResponder];
        }];
    }
    else if(![self.txtNewPassword.text isEqualToString:self.txtConfirmPassword.text])
    {
        [UIAlertView showWithTitle:APPNAME message:@"New password must match with the confirm password." handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             [self.txtConfirmPassword becomeFirstResponder];
         }];
    }
    else if(![self.txtOldPassword.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD]])
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter correct current password" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             [self.txtOldPassword becomeFirstResponder];
         }];
    }
    else if([self.txtOldPassword.text isEqualToString:self.txtNewPassword.text])
    {
        [UIAlertView showWithTitle:APPNAME message:@"Current password and New password should not be equal" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
            [self.txtNewPassword becomeFirstResponder];
        }];
    }
    else
    {
        [self callChangePassword];
        return;
    }
}

-(void)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}
#pragma mark - WS calling methods

-(void)callChangePassword
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:self.txtNewPassword.text  forKey:@"new_password"];
    [params setObject:self.txtOldPassword.text  forKey:@"old_password"];    
    self.objWSHelper.serviceName = @"ChangePassword";
//    [self.objWSHelper sendRequestWithURL:[WS_Urls getChangePasswordURL:params]];
    [self.objWSHelper sendRequestWithPostURL:[WS_Urls getChangePasswordURL:nil] andParametrers:params];
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
        [[NSUserDefaults standardUserDefaults] setValue:self.txtNewPassword.text forKey:PASSWORD];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [UIAlertView showWithTitle:@"Success" message:@" Your password has been successfully changed" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else
    {
        [UIAlertView showWithTitle:APPNAME message:[GlobalManager getValurForKey:[dictResults objectForKey:@"settings"] :@"message"] handler:nil];
        return;
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end
