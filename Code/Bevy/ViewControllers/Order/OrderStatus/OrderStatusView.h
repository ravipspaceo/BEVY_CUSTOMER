//
//  OrderStatusView.h
//  Bevy
//
//  Created by CompanyName on 1/23/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This view is used to show the orders status.
 */

@class OrderStatusView;

@protocol StatusViewDelegate <NSObject>

-(void)OrderStatusView:(OrderStatusView *)statusView orderDetailPressed:(UIButton *)sender;
-(void)OrderStatusView:(OrderStatusView *)statusView placeNewOrderPressed:(UIButton *)sender;
-(void)OrderStatusView:(OrderStatusView *)statusView gpsTrackPressed:(UIButton *)sender;
-(void)OrderStatusView:(OrderStatusView *)statusView rateDriverPressed:(UIButton *)sender;

@end

@interface OrderStatusView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *imgOrderStatus;
@property (nonatomic, retain) IBOutlet UILabel *lblPending;
@property (nonatomic, retain) IBOutlet UILabel *lblPacaked;
@property (nonatomic, retain) IBOutlet UILabel *lblRouteMap;
@property (nonatomic, retain) IBOutlet UILabel *lblDelivered;
@property (nonatomic, retain) IBOutlet UIButton *btnMap;
@property (nonatomic, retain) IBOutlet UIButton *btnRateDriver;
@property (nonatomic, retain) IBOutlet UIButton *btnOrderDetail;
@property (nonatomic, retain) IBOutlet UIButton *btnPlaceNewOrder;
@property (nonatomic, retain) IBOutlet UILabel *lblLine;

@property(nonatomic, retain) IBOutlet UIView *viewOrder;
@property(nonatomic, retain) IBOutlet UIView *viewCancel;

@property(nonatomic, retain) id<StatusViewDelegate> statusDelegate;

/**
 *  btnOrderDetailsClicked ,This method is called when user click on see order detail  button.
 *  @param btnOrderDetailsClicked, navigates to order detail screen.
 */
-(IBAction)btnOrderDetailsClicked:(id)sender;
/**
 *  btnMapPressed ,This method is called when user click on GPS TRAKE  button.
 *  @param btnMapPressed, user can trake the order.
 */
-(IBAction)btnMapPressed:(id)sender;

@end
