//
//  AddProfileViewController.h
//  Bevy
//
//  Created by CompanyName on 22/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDateTimePicker.h"
#import "TPKeyboardAvoidingScrollView.h"
//#import "NPRImageView.h"
#import "JASidePanelController.h"
#import "UICustomPicker.h"

/**
 * This class is used to see the user profile details and also user can change the details.
 */

@interface AddProfileViewController : GAITrackedViewController<CustomDateTimePickerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate, ParseWSDelegate, UITextFieldDelegate,CustomPickerDelegate>
{
    NSDate *dateLimit;
}

@property (nonatomic,strong) IBOutlet UITextField *txtFirstName;
@property (nonatomic,strong) IBOutlet UITextField *txtLastName;
@property (nonatomic,strong) IBOutlet UITextField *txtEmailID;
@property (nonatomic,strong) IBOutlet UITextField *txtPhoneNumber;
@property (nonatomic,strong) IBOutlet UITextField *txtBirthDay;
@property (weak, nonatomic) IBOutlet UITextField *txtPostCode,*txtCode;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@property (weak, nonatomic) IBOutlet UIImageView *imgCover;

@property (nonatomic,strong) IBOutlet UILabel *lblStar;
@property (nonatomic,strong) IBOutlet UIImageView *imgProfile;
@property (nonatomic,strong) IBOutlet UIImageView *imgProfileBackGround;
@property (nonatomic,strong) IBOutlet UIButton *btnBack,*btnSubmit;
@property (nonatomic,strong) IBOutlet UIButton *btnBirthday,*btnImageSelect;
@property (strong ,nonatomic) IBOutlet TPKeyboardAvoidingScrollView *objScroll;

@property (nonatomic, retain) UIDateTimePicker *objDatePicker;

@property (nonatomic, retain) UICustomPicker *objCodePicker;

@property (nonatomic, strong) JASidePanelController *objSidePanelviewController;
@property (nonatomic, retain) UIImagePickerController *objImagePicker;
@property (nonatomic, strong) UIImage *imageSelected;
@property (nonatomic, retain) WS_Helper *objWSHelper;

@property (nonatomic, assign) BOOL isFB;
@property (nonatomic, retain) NSDictionary *dictDetails;

@property (nonatomic, retain) NSMutableArray *aryCountryCode;

/**
 *  btnSubmitclicked ,This method is called when user click on Submit button.
 *  @param btnSubmitclicked, to save the all profile details.
 */
-(IBAction)btnSubmitclicked:(id)sender;
/**
 *  btnDateOfBirthClicked ,This method is called when user click on Birthday button.
 *  @param btnDateOfBirthClicked, to select the user date of birth .
 */
-(IBAction)btnDateOfBirthClicked:(UIButton*)sender;
/**
 *  btnCountryCodeClicked ,This method is called when user click on country code button.
 *  @param btnCountryCodeClicked, it will open the list of country codes to choose one.
 */
- (IBAction)btnCountryCodeClicked:(UIButton *)sender;

@end
