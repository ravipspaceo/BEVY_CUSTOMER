//
//  OrderStatusViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderStatusView.h"
#import "RateView.h"
#import "TYMActivityIndicatorView.h"
#import "RateViewController.h"

/**
 * This class is used to show the orders status.
 */

@interface OrderStatusViewController : GAITrackedViewController<ParseWSDelegate, StatusViewDelegate, RateViewDelegate,RateViewControllerDelegate>
@property (nonatomic , strong) RateViewController *objRateView;


@property (nonatomic, strong) IBOutlet UIButton *btnRate1,*btnRate2,*btnRate3,*btnRate4,*btnRate5;
@property (nonatomic, strong) IBOutlet UIImageView *imgRate1,*imgRate2,*imgRate3,*imgRate4,*imgRate5;

@property (nonatomic, strong) TYMActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UILabel *lblNoOrders;


@property (strong, nonatomic) IBOutlet UILabel *lblTransaction,*lblTransactionStatic;
@property (strong, nonatomic) IBOutlet UIButton *btnPlaceNewOrder;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollContainer;
@property (strong, nonatomic) IBOutlet UIView *viewOrderSta1,*viewOrderSta2;

@property (strong, nonatomic) IBOutlet UIView *viewPopupRate;
@property (strong, nonatomic) IBOutlet UIView *innerPopupView;
@property (strong, nonatomic) IBOutlet UIButton *btnSubmit;
@property (strong, nonatomic) IBOutlet UITableView *tblRateView;

@property (nonatomic, assign) NSInteger currentPage;
@property(nonatomic, assign) CGFloat currentRating;
@property(nonatomic, assign) BOOL isHideNewPlaceOrder;

@property(nonatomic, retain) NSMutableArray *arrayOfOderViews;
@property (nonatomic, strong) WS_Helper *objWSHelper;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property(nonatomic, retain) NSMutableArray *arrayOrderStatus;

/**
 *  btnPlaceNewOrderPressed ,This method is called when user click on place new order  button.
 *  @param btnPlaceNewOrderPressed, user can place new order.
 */
-(IBAction)btnPlaceNewOrderPressed:(id)sender;
/**
 *  btnSubmitPressed ,This method is called when user click on Submit  button.
 *  @param btnSubmitPressed, user can submit the star rate about the driver.
 */
-(IBAction)btnSubmitPressed:(id)sender;

/**
 *  btnCancelRating ,This method is called when user click on cancel  button.
 *  @param btnCancelRating, to dissmiss the rate popup with out giving any rate.
 */
-(IBAction)btnCancelRating:(id)sender;
/**
 *  @param callOrderStatusWS, to call web service for order status.
 */
-(void)callOrderStatusWS;

@end
