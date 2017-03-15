//
//  OrderDetailViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

/**
 * This class is used to show the orders details, user can rate the driver and user can call.
 */
@interface OrderDetailViewController : GAITrackedViewController<RateViewDelegate,ParseWSDelegate>
{
    int driverCount;
}
@property (nonatomic, strong) IBOutlet UIButton *btnRate1,*btnRate2,*btnRate3,*btnRate4,*btnRate5;
@property (nonatomic, strong) IBOutlet UIImageView *imgRate1,*imgRate2,*imgRate3,*imgRate4,*imgRate5;

@property (nonatomic, strong) IBOutlet UIView *viewPopUp;
@property (nonatomic, strong) IBOutlet UIView *viewCallpopUp;

@property (nonatomic, strong) IBOutlet UIView *viewPopUpRate;
@property (nonatomic, strong) IBOutlet UIView *viewRatePopUp;

@property (nonatomic, strong) IBOutlet UILabel *lblTransactionNumber;
@property (nonatomic, strong) IBOutlet UILabel *lblSubTotal;
@property (nonatomic, strong) IBOutlet UILabel *lblDeliveryFee;
@property (nonatomic, strong) IBOutlet UILabel *lblPromCode;
@property (nonatomic, strong) IBOutlet MarqueeLabel *lblDeleveryAddress;
@property (nonatomic, strong) IBOutlet MarqueeLabel *lblDeleveryNote;
@property (nonatomic, strong) IBOutlet UILabel *lblGrandTotal;
@property (nonatomic, strong) IBOutlet UITableView *tblOrderedProducts,*tblRatePopUp;
@property (nonatomic, strong) IBOutlet UIButton *btnCallDriver;

@property (nonatomic, strong) IBOutlet UIImageView *imgDriver;
@property (nonatomic, strong) IBOutlet UILabel *lblDriverName;
@property (nonatomic, strong) IBOutlet UIButton *btnNumber,*btnCall,*btnCancel,*btnSubmit;

@property (nonatomic, strong) WS_Helper *objWSHelper;
@property(nonatomic, assign) CGFloat currentRating;

@property (nonatomic, retain) NSString *strOrderId;
@property (nonatomic, retain) NSDictionary *dictDetails;
@property (nonatomic, strong) NSMutableArray *arrayProducts;

/**
 *  btnCallDriverClicked ,This method is called when user click on callDriver button.
 *  @param btnCallDriverClicked, to show a popup with driver's phone number.
 */
-(IBAction)btnCallDriverClicked:(id)sender;
/**
 *  btnPopUpCallDriverClicked ,This method is called when user click on call  button.
 *  @param btnPopUpCallDriverClicked, user able to make a call.
 */
-(IBAction)btnPopUpCallDriverClicked:(id)sender;
/**
 *  btnPopUpCancelDriverClicked ,This method is called when user click on cancel  button.
 *  @param btnPopUpCancelDriverClicked, to dismiss the driver call popup.
 */
-(IBAction)btnPopUpCancelDriverClicked:(id)sender;

@end
