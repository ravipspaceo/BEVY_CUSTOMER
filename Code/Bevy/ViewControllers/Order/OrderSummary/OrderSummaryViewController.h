//
//  OrderSummaryViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class is used to show order summary.
 */
@interface OrderSummaryViewController : GAITrackedViewController

@property (nonatomic, strong) IBOutlet UIView *viewHeader;
@property (nonatomic, strong) IBOutlet UIView *viewPopUp;
@property (nonatomic, strong) IBOutlet UIView *confirmationPopUp;
@property (nonatomic, strong) IBOutlet UIButton *btnDeliveryDetails;
@property (nonatomic, strong) IBOutlet UIButton *btnCardDetails;
@property (nonatomic, strong) IBOutlet UILabel *lblDeliverAddress;
@property (nonatomic, strong) IBOutlet UILabel *lblPostalCode;

@property (nonatomic, strong) IBOutlet UILabel *lblCardDetails;
@property (nonatomic, strong) IBOutlet UILabel *lblSubTotal;
@property (nonatomic, strong) IBOutlet UILabel *lblDeliveryFee;
@property (nonatomic, strong) IBOutlet UILabel *lblDiscountCode;
@property (nonatomic, strong) IBOutlet UILabel *lblGrandTotal;
@property (nonatomic, strong) IBOutlet UITableView *tblOrderedProducts;
@property (nonatomic, strong) IBOutlet UIButton *btnPlaceOrder;

@property(nonatomic, retain) WS_Helper *objWSHelper;

@property(nonatomic, retain) NSMutableArray *arrayProducts;
@property(nonatomic, retain) NSDictionary *dictCartDetails;
@property(nonatomic, retain) NSDictionary *dictCardDetails;

/**
 *  btnDeliveryDetailsClicked ,This method is called when user click on Deliver to  button.
 *  @param btnDeliveryDetailsClicked, to change delivery address.
 */
-(IBAction)btnDeliveryDetailsClicked:(id)sender;
/**
 *  btnCardDetailsClicked ,This method is called when user click on Payment  button.
 *  @param btnCardDetailsClicked, navigates to cards screen.
 */
-(IBAction)btnCardDetailsClicked:(id)sender;
/**
 *  btnPlaceOrderClicked ,This method is called when user click on Place Order  button.
 *  @param btnPlaceOrderClicked, show popup with age verification.
 */
-(IBAction)btnPlaceOrderClicked:(id)sender;
/**
 *  btPopYesClicked ,This method is called when user click on Ok  button.
 *  @param btPopYesClicked, navigates to Orders screen.
 */
-(IBAction)btPopYesClicked:(id)sender;
/**
 *  btPopNoClicked ,This method is called when user click on Cancel  button.
 *  @param btPopNoClicked, Dismiss the age verification popup.
 */
-(IBAction)btPopNoClicked:(id)sender;

@end
