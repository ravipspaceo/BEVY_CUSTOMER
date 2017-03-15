//
//  CheckOutViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

/**
 * This class is used to show cart items and delivery address, promocods.
 */
@interface CheckOutViewController : GAITrackedViewController<UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *lblDeleveryTo;
@property (nonatomic, weak) IBOutlet UILabel *lblDeliveryToAddres;
@property (nonatomic, weak) IBOutlet UILabel *lblPostalCode;

@property (nonatomic, weak) IBOutlet UIButton *btnDelivery;
@property (nonatomic, weak) IBOutlet UIButton *btnPromoCode;

@property (nonatomic, weak) IBOutlet UILabel *lblDeliveryNote,*lblTotalCost;
@property (nonatomic, weak) IBOutlet UIPlaceHolderTextView *txtViewDeliveryNote;
@property (nonatomic, weak) IBOutlet UIView *viewDeliveryTo;
@property (nonatomic, weak) IBOutlet UIView *viewDeliveryNote;
@property (nonatomic, weak) IBOutlet UITableView *tableCart;
@property (nonatomic, strong) IBOutlet UILabel *lblAlertmessage;

@property (nonatomic, retain) NSMutableArray *arrayCarts;
@property (nonatomic, retain) NSDictionary *dictCartDetails;
@property (nonatomic,assign) BOOL isFromMenu ,isProductAvailble;
@property (nonatomic, retain) WS_Helper *objWSHelper;

/**
 *  btnNextClicked ,This method is called when user click on Next  button.
 *  @param btnNextClicked, navigates to Order summery screen.
 */
-(IBAction)btnNextClicked:(id)sender;
/**
 *  btnDeliverLocationClicked ,This method is called when user click on delivery location  button.
 *  @param btnDeliverLocationClicked, navigates to home view controller.
 */
-(IBAction)btnDeliverLocationClicked:(id)sender;

@end
