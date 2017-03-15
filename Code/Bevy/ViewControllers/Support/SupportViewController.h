
//
//  SupportViewController.h
//  Bevy
//
//  Created by CompanyName on 12/20/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

/**
 * This class is used to show Supports like Privacy policy, Terms and Conditions, etc..
 */
@interface SupportViewController : UIViewController<MFMailComposeViewControllerDelegate,ParseWSDelegate>
@property (nonatomic,strong) MFMailComposeViewController *mailComposer;

@property (nonatomic,strong) IBOutlet UIWebView *webView;

@property (nonatomic,strong) IBOutlet UIButton *btnContactCustomer;
@property (nonatomic,strong) IBOutlet UIButton *btnCallCustomer;
@property (nonatomic,strong) IBOutlet UIButton *btnFAQ;
@property (nonatomic,strong) IBOutlet UIButton *btnPolicy;
@property (nonatomic,strong) IBOutlet UIButton *btnTerms;
@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic,strong) IBOutlet UIView *popUpView;
@property (nonatomic,strong) IBOutlet UIView *viewCallSupport;
@property (nonatomic, strong) IBOutlet UILabel *lblExecutiveName;
@property (nonatomic, strong) IBOutlet UIButton *btnNumber,*btnCall,*btnCancel;
@property (nonatomic, strong) IBOutlet UIImageView *imgCallsupport;

@property(nonatomic, retain) NSDictionary *dictSupport;
@property (nonatomic, strong) WS_Helper *objWSHelper;
@property (nonatomic, strong) MBProgressHUD *HUD;

/**
 *  clickedContactCustome ,This method is called when user click on Contacts customer support button.
 *  @param clickedContactCustome, shre via email page will appeared.
 */
-(IBAction)clickedContactCustome:(id)sender;

-(IBAction)clickedCallCustomer:(id)sender;
/**
 *  clickedFAQ ,This method is called when user click on FAQ  button.
 *  @param clickedFAQ, navigates to FAQ screen.
 */
-(IBAction)clickedFAQ:(id)sender;
/**
 *  clickedPolicy ,This method is called when user click on privacy policy  button.
 *  @param clickedPolicy, navigates to privacy policy screen.
 */
-(IBAction)clickedPolicy:(id)sender;
/**
 *  clickedTerms ,This method is called when user click on Terms & Conditions  button.
 *  @param clickedTerms, navigates to Terms & Conditions screen.
 */
-(IBAction)clickedTerms:(id)sender;
/**
 *  btnClickedOnCall ,This method is called when user click on call  button.
 */
-(IBAction)btnClickedOnCall:(id)sender;
/**
 *  btnClickedOnCancel ,This method is called when user click on cancel  button.
 */
-(IBAction)btnClickedOnCancel:(id)sender;
/**
 *  btnClickedOnNumber ,This method is called when user click on Number.
 */
-(IBAction)btnClickedOnNumber:(id)sender;

@end
