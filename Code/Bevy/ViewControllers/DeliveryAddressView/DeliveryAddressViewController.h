//
//  DeliveryAddressViewController.h
//  Bevy
//
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomPicker.h"
/**
 * This class is used to provide the delivery address of the order.
 */

@interface DeliveryAddressViewController : GAITrackedViewController<CustomPickerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *objScrollView;

@property(nonatomic, strong) IBOutlet UITextField *txtFlatNumber;

@property(nonatomic, strong) IBOutlet UITextField *txtAddress;

@property(nonatomic, strong) IBOutlet UITextField *txtPostCode;

@property(nonatomic, strong) IBOutlet UITextField *txtContactNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;

@property(nonatomic, strong) IBOutlet UIButton *btnShopNow;

@property(nonatomic, strong) IBOutlet UIButton *btnSave;

@property (nonatomic, retain) CLLocation *locationLatLon;

@property (nonatomic, strong) WS_Helper *objWSHelper;

@property(nonatomic, strong) NSMutableDictionary *dictAddressDetails;

@property (nonatomic, assign) BOOL isFromLocationChange;

@property (nonatomic, strong) NSString *strAddress;

@property (nonatomic, assign) BOOL isPopToCheckOutScreen;

@property (nonatomic, retain) NSString *storeId,*strPostCode,*strLat,*strLong;

@property (nonatomic, retain) NSString *strOldPhoneNumber;

@property (nonatomic,strong) IBOutlet UIButton *btnResend;


@property (nonatomic, retain) UICustomPicker *objCodePicker;
@property (nonatomic, retain) NSMutableArray *aryCountryCode;

/**
 *  btnShopNowClicked ,This method is called when user click on Shop Now button.
 *  @param btnShopNowClicked, it will navigate user to product page.
 */
-(IBAction)btnShopNowClicked:(UIButton*)sender;

/**
 *  btnSaveClicked ,This method is called when user click on Save button.
 *  @param btnSaveClicked, it validate all manditory entries and change the delivery address.
 */

-(IBAction)btnSaveClicked:(UIButton*)sender;

/**
 *  btnResendCodeClicked ,This method is called when user click on Resend button.
 *  @param btnResendCodeClicked, it will create a new verification code and send it to user mobile.
 */
-(IBAction)btnResendCodeClicked:(id)sender;

/**
 *  btnCountryCodeClicked ,This method is called when user click on country code button.
 *  @param btnCountryCodeClicked, it will open the list of country codes to choose one.
 */
- (IBAction)btnCountryCodeClicked:(id)sender;


@end
