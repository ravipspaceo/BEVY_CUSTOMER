//
//  VerifivationViewController.h
//  Bevy
//
//  Copyright © 2016 com.companyname. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTLinkTextView.h"
#import "JASidePanelController.h"
/**
 * This class is used to verift the phone number of user.
 */

@interface VerifivationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btnResendPin;
@property (weak, nonatomic) IBOutlet LTLinkTextView *lblPhoneView;

@property (weak, nonatomic) IBOutlet UITextField *txtverificationCode;
@property(nonatomic, retain) WS_Helper *objWSHelper;
@property (nonatomic, strong) JASidePanelController *objSidePanelviewController;
@property (weak, nonatomic) IBOutlet UIButton *btnback;
@property (weak, nonatomic) IBOutlet UIView *viewAnimate;


@property (nonatomic, assign) BOOL isFromProfile;
;
/**
 *  btnBackClicked ,This method is called when user click on Back button.
 *  @param btnBackClicked, pop to previus view controller.
 */
- (IBAction)btnBackClicked:(id)sender;

/**
 *  btnSubmitClicked ,This method is called when user click on Submit button.
 *  @param btnSubmitClicked, it will validate the verification code and verify the user phone number.
 */
- (IBAction)btnSubmitClicked:(id)sender;
/**
 *  btnResendPinClicked ,This method is called when user click on Resend button.
 *  @param btnResendPinClicked, it will create a new verification code and send it to user mobile.
 */

- (IBAction)btnResendPinClicked:(id)sender;
/**
 *  btnEditNumberCliucked ,This method is called when user click on Edit Number button.
 *  @param btnEditNumberCliucked, it will navigate the user to edit phone number screen.
 */
- (IBAction)btnEditNumberCliucked:(id)sender;

@end
