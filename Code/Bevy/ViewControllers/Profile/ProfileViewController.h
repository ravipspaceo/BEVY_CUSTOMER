//
//  ProfileViewController.h
//  Bevy
//
//  Created by CompanyName on 12/20/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "UIDateTimePicker.h"
#import "UICustomPicker.h"

//#import "NPRImageView.h"

/**
 * This class is used to show user Profile details.
 */

@interface ProfileViewController : GAITrackedViewController<CustomDateTimePickerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate,ParseWSDelegate,CustomPickerDelegate>

@property (nonatomic,strong) IBOutlet UITextField *txtFirstName;
@property (nonatomic,strong) IBOutlet UITextField *txtLasatName;
@property (nonatomic,strong) IBOutlet UITextField *txtEmailID;
@property (nonatomic,strong) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtPostCode;

@property (nonatomic,strong) IBOutlet UILabel *lblProfileName;
@property (nonatomic,strong) IBOutlet UILabel *lblFirstName;
@property (nonatomic,strong) IBOutlet UILabel *lblLastName;
@property (nonatomic,strong) IBOutlet UILabel *lblEmailID;
@property (nonatomic,strong) IBOutlet UILabel *lblPhoneNumber;
@property (nonatomic,strong) IBOutlet UILabel *lblBirthDay;
@property (weak, nonatomic) IBOutlet UIImageView *imgCover;

@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property (nonatomic,strong) IBOutlet UIImageView *lineChangePwd;
@property (nonatomic,strong) IBOutlet UIImageView *lineMycards;

@property (nonatomic,strong) IBOutlet UIButton *btnResend;

@property (nonatomic,strong) IBOutlet UIButton *btnLogout;
@property (nonatomic,strong) IBOutlet UIButton *btnChangePassword;
@property (nonatomic,strong) IBOutlet UIButton *btnMyCards;

@property(nonatomic, retain) UIImagePickerController *objImagePicker;
@property (nonatomic, strong) UIImage *imageSelected;
@property (nonatomic,strong) IBOutlet UIImageView *imgProfile;
@property (nonatomic,strong) IBOutlet UIButton *btnBirthday,*btnImageSelect;
@property (strong ,nonatomic) UIDateTimePicker *objDatePicker;
@property (strong ,nonatomic) IBOutlet TPKeyboardAvoidingScrollView *objScroll;
@property (nonatomic, retain) UICustomPicker *objCodePicker;


@property (nonatomic,strong) MBProgressHUD *HUD;
@property(nonatomic, retain) WS_Helper *objWSHelper;
@property(nonatomic, assign) BOOL isPickerOpened;

@property(nonatomic, retain) NSDictionary *dictProfileDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@property (nonatomic, retain) NSMutableArray *aryCountryCode;
- (IBAction)btnCountryCodeClicked:(UIButton *)sender;

/**
 *  btnBackClicked ,This method is called when user click on Back  button.
 *  @param btnBackClicked, pop to previus screen.
 */
-(IBAction)btnBackClicked:(id)sender;
/**
 *  clickOnChangePwd ,This method is called when user click on Change password  button.
 *  @param clickOnChangePwd, navigates to change password screen.
 */
-(IBAction)clickOnChangePwd:(id)sender;
/**
 *  clickOnMycards ,This method is called when user click on My Cards  button.
 *  @param clickOnMycards, navigates to cards screen.
 */
-(IBAction)clickOnMycards:(id)sender;

/**
 *  btnResendCodeClicked ,This method is called when user click on Resend code button.
 *  @param btnResendCodeClicked
 */
-(IBAction)btnResendCodeClicked:(id)sender;

@end
