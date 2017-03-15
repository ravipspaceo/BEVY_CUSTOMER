//
//  LoginViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "JASidePanelController.h"
#import <FacebookSDK/FacebookSDK.h>

/**
 * This class is used to login to the application with valid credentials.
 */
@interface LoginViewController : GAITrackedViewController<ParseWSDelegate>

@property (nonatomic,strong) IBOutlet UIButton *btnLoginwithFacebook;
@property (nonatomic,strong) IBOutlet UIButton *btnLogin;
@property (nonatomic,strong) IBOutlet UIButton *btnForgotPwd;
@property (nonatomic,strong) IBOutlet UIButton *btnCreateNewAccount;
@property (nonatomic,strong) IBOutlet UITextField *txtEmailId;
@property (nonatomic,strong) IBOutlet UITextField *txtPwd;
@property (nonatomic,strong) IBOutlet UIScrollView *scrollVeiw;
@property (nonatomic,strong) IBOutlet UIImageView *imgOR;
@property (nonatomic,strong) IBOutlet UIImageView *imglogo;

@property (nonatomic,strong) IBOutlet UITextField *txtAccessCode;

@property (nonatomic, strong) IBOutlet UIView *accessCodeView;
@property (nonatomic, weak) IBOutlet UIImageView *imgBackGround;
@property (weak, nonatomic) IBOutlet UIView *innerView;

@property (nonatomic, assign) BOOL isbtnFbPressed;

@property (nonatomic, strong) JASidePanelController *objSidePanelviewController;
@property (nonatomic, strong) WS_Helper *objWSHelper;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, retain) NSString *strForgotEmailAddress;


@property (nonatomic, retain) NSDictionary *dictCategory;
@property (nonatomic, retain) NSMutableArray *arraySubCategories;

/**
 *  clickedOnCreateAccount ,This method is called when user click on Create new account button.
 *  @param clickedOnCreateAccount, to navigate the registration screen.
 */
-(IBAction)clickedOnCreateAccount:(id)sender;
/**
 *  clickedOnForgotPwd ,This method is called when user click on Forgot password button.
 *  @param clickedOnForgotPwd, user can get the password via email.
 */
-(IBAction)clickedOnForgotPwd:(id)sender;
/**
 *  btnLoginViaFBClicked ,This method is called when user click on Login with facebook button.
 *  @param btnLoginViaFBClicked, user can login with facebook acount details.
 */
-(IBAction)btnLoginViaFBClicked:(id)sender;
/**
 *  btnLoginClicked ,This method is called when user click on Login button.
 *  @param btnLoginClicked, to navigate to home view controller .
 */
-(IBAction)btnLoginClicked:(id)sender;

/**
 *
 * Access code pop up action Button
 *
 */
-(IBAction)btnOkClicked:(id)sender;

-(IBAction)btnCancelClicked:(id)sender;

-(IBAction)btnNoAccessCodeClicked:(id)sender;

@end
