//
//  ChangePhoneNumberViewController.h
//  Bevy
//
//  Copyright © 2016 com.companyname. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomPicker.h"

/**
 * This class is used to change the phone number of user.
 */

@interface ChangePhoneNumberViewController : UIViewController<ParseWSDelegate,CustomPickerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;


@property (nonatomic, retain) UICustomPicker *objCodePicker;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@property (nonatomic, retain) NSMutableArray *aryCountryCode;
@property(nonatomic, retain) WS_Helper *objWSHelper;


/**
 *  btnSaveClicked ,This method is called when user click on Save button.
 *  @param btnSaveClicked, it will validate phone number and change phone number of user.
 */
-(IBAction)btnSaveClicked:(id)sender;

/**
 *  btnCountryCodeClicked ,This method is called when user click on country code button.
 *  @param btnCountryCodeClicked, it will open the list of country codes to choose one.
 */

- (IBAction)btnCountryCodeClicked:(UIButton *)sender;


@end
