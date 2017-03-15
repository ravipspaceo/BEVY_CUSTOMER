//
//  RegisterViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

/**
 * This class is used to create new account for use the application.
 */

@interface RegisterViewController : GAITrackedViewController<ParseWSDelegate>

@property (nonatomic,strong) IBOutlet UITextField *txtEmailID;
@property (nonatomic,strong) IBOutlet UITextField *txtPwd;
@property (nonatomic,strong) IBOutlet UITextField *txtConformPwd;
@property (nonatomic,strong) IBOutlet UITextField *txtAccessCode;

@property (nonatomic, strong) IBOutlet UIView *accessCodeView;
@property (nonatomic, weak) IBOutlet UIImageView *imgBackGround;

@property (nonatomic, assign) BOOL showAccessCodePopup;

@property (nonatomic,strong) IBOutlet UIButton *btnRegister;
@property (nonatomic,strong) IBOutlet UIButton *btnTermsConditions,*btnRadio;
@property (nonatomic,strong) IBOutlet UIButton *btnHaveAccount;
@property (nonatomic,strong) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic,strong) IBOutlet UIButton *btnBack;
@property(nonatomic, retain) WS_Helper *objHelper;
@property (weak, nonatomic) IBOutlet UILabel *lbltermsAndConditions;
@property (nonatomic, strong) JASidePanelController *objSidePanelviewController;

@property (weak, nonatomic) IBOutlet UIView *innerView;

/**
 *  btnBackClicked ,This method is called when user click on Back button.
 *  @param btnBackClicked, pop to previus view controller.
 */
-(IBAction)btnBackClicked:(id)sender;
/**
 *  clickedOnRegister ,This method is called when user click on Register button.
 *  @param clickedOnRegister, it validate all manditory entries and create new account.
 */
-(IBAction)clickedOnRegister:(id)sender;
/**
 *  clickedOnTerms ,This method is called when user click on Terms and conditions button.
 *  @param clickedOnTerms, user can able to see terms and consitions page.
 */
-(IBAction)clickedOnTerms:(UIButton *)sender;
/**
 *  clickedOnHaveAccount ,This method is called when user click on i have account button.
 *  @param clickedOnHaveAccount, pop to previus controller.
 */
-(IBAction)clickedOnHaveAccount:(id)sender;

/**
 *  btnSignUpWithFBClicked ,This method is called when user click on SignUp with Facebbok button.
 *  @param btnSignUpWithFBClicked, user can signup with facebook acount details.
 */

- (IBAction)btnSignUpWithFBClicked:(id)sender;

/**
 *
 * Access code pop up action Button
 *
 */

-(IBAction)btnOkClicked:(id)sender;

-(IBAction)btnCancelClicked:(id)sender;

-(IBAction)btnNoAccessCodeClicked:(id)sender;

@end
