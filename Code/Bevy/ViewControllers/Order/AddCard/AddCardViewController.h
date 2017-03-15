//
//  AddCardViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDateTimePicker.h"
#import "STPView.h"
#import "PKTextField.h"
#import "CardIO.h"


/**
 * This class is used to add the payment cards.
 */

@protocol StripCardDelegate <NSObject>

@optional
-(void)stripCardAddedSuccessfully;

@end

@interface AddCardViewController : UIViewController<STPViewDelegate, PKViewDelegate,CardIOPaymentViewControllerDelegate>

@property(nonatomic, retain) id<StripCardDelegate> cardListDelegate;
@property (nonatomic, strong) IBOutlet UIButton *btnVerification;

@property(nonatomic, retain) STPView *stripeView;
@property (nonatomic, assign) BOOL isEditCard;
@property (weak, nonatomic) IBOutlet UILabel *lblSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *imgSSL;
@property(nonatomic, retain) WS_Helper *objWSHelper;
@property(nonatomic, retain) NSDictionary *dictCardDetails;
@property(nonatomic, assign) BOOL isFromScanner;
@property(nonatomic, strong) IBOutlet UITextField *txtCardName;

/**
 *  btnVerificationClicked ,This method is called when user click on Verification  button.
 *  @param btnVerificationClicked, to generate token from card for verification.
 */
-(IBAction)btnVerificationClicked:(id)sender;
/**
 *  btnScanCardClicked ,This method is called when user click on scan card button.
 *  @param btnScanCardClicked, by this user can directly scan the card without entering the details of card.
 */
- (IBAction)btnScanCardClicked:(id)sender;

@end
