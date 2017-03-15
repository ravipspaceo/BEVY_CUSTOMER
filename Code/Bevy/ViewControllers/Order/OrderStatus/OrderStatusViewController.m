//
//  OrderStatusViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "OrderStatusViewController.h"
#import "TrackOrderViewController.h"
#import "OrderDetailViewController.h"
#import "ProductsViewController.h"
#import "ListViewController.h"
#import "MenuViewController.h"
#import "RateDriverTableViewCell.h"
#import "CustomActivityIndicator.h"
#import <UIKit/UIKit.h>

#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480)

@interface OrderStatusViewController ()
{
    NSInteger driverCount;
    NSInteger indexOfOrder;
    
    NSMutableArray *aryDrivers;
    
}

@end

@implementation OrderStatusViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentPage = 0;
    [self setUpLayout];
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Order Status Screen"];
    [self callOrderStatusWS];
    [self refreshController];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"is_push_Notifcation"];
}

#pragma mark - Instance methods

-(void)setUpLayout
{
    self.navigationItem.title = @"Order Status";
    
    self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"menu"];
    self.navigationItem.leftBarButtonItem = [GlobalManager getnavigationLeftButtonWithTarget:self :@"refresh"];
    [self.tblRateView registerNib:[UINib nibWithNibName:@"RateDriverTableViewCell" bundle:nil] forCellReuseIdentifier:@"RateDriverTableViewCell"];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    
    if(IS_IPHONE_4)
    {
        self.pageControl.frame = CGRectMake(self.pageControl.frame.origin.x, self.pageControl.frame.origin.y+30, self.pageControl.frame.size.width, self.pageControl.frame.size.height);
    }
    self.pageControl.currentPage = 0;
    
    self.lblNoOrders = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [GlobalManager getAppDelegateInstance].window.frame.size.width, 40)];
    self.lblNoOrders.text = @"No orders found";
    self.lblNoOrders.center = self.view.center;
    self.lblNoOrders.textAlignment = NSTextAlignmentCenter;
    
    self.innerPopupView.layer.borderWidth = 1.0;
    self.innerPopupView.layer.borderColor = [[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]CGColor];
    self.innerPopupView.layer.cornerRadius = 5.0;
    driverCount = 1;
}
/// Refreshing
-(void)btnCancelClicked
{
    [self.view endEditing:YES];
    [self callOrderStatusWS];
}

-(void)btnMenuClicked
{
    [self.view endEditing:YES];
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

-(void)showOrderStatusView
{
    for(UIView *view in [self.scrollContainer subviews])
    {
        [view removeFromSuperview];
    }
    
    self.arrayOfOderViews = [NSMutableArray array];
    self.pageControl.numberOfPages = self.arrayOrderStatus.count;
    NSMutableArray *arrayCancel = [NSMutableArray arrayWithArray:self.arrayOrderStatus];
    
    for (NSMutableDictionary *dict in arrayCancel) {
        NSString *orderStatus = [dict objectForKey:@"order_status"];
        if([orderStatus isEqualToString:@"Cancelled"] || [orderStatus isEqualToString:@"Time Out"]){
            [self.arrayOrderStatus removeObjectAtIndex:[self.arrayOrderStatus indexOfObject:dict]];
        }
    }
    
    for(NSInteger index = 0; index < [self.arrayOrderStatus count]; index++)
    {
        NSString *orderStatus = [[self.arrayOrderStatus objectAtIndex:index] objectForKey:@"order_status"];
        
        OrderStatusView *orderStatusView = [[[NSBundle mainBundle] loadNibNamed:@"OrderStatusView" owner:self options:nil] lastObject];
        [orderStatusView setStatusDelegate:self];
        if(IS_IPHONE_4)
        {
            orderStatusView.viewOrder.frame = CGRectMake(orderStatusView.viewOrder.frame.origin.x, orderStatusView.viewOrder.frame.origin.y-9, orderStatusView.viewOrder.frame.size.width, orderStatusView.viewOrder.frame.size.height);
            [orderStatusView.btnOrderDetail setFrame:CGRectMake(orderStatusView.btnOrderDetail.frame.origin.x, orderStatusView.btnOrderDetail.frame.origin.y+50, orderStatusView.btnOrderDetail.frame.size.width, 25)];
            [orderStatusView.btnOrderDetail bringSubviewToFront:self.view];
            
            orderStatusView.btnPlaceNewOrder.frame = CGRectMake(orderStatusView.btnPlaceNewOrder.frame.origin.x, orderStatusView.btnPlaceNewOrder.frame.origin.y+17, orderStatusView.btnPlaceNewOrder.frame.size.width, orderStatusView.btnPlaceNewOrder.frame.size.height-10);
            
            orderStatusView.lblLine.frame = CGRectMake(0, CGRectGetMaxY(orderStatusView.btnOrderDetail.frame)+3, orderStatusView.lblLine.frame.size.width, orderStatusView.lblLine.frame.size.height);
        }
        [orderStatusView.btnPlaceNewOrder setHidden:self.isHideNewPlaceOrder];
        [orderStatusView.lblLine setHidden:self.isHideNewPlaceOrder];
        
        [orderStatusView setTag:index];
        CGRect frame = CGRectMake((self.scrollContainer.frame.size.width *index), 0, self.scrollContainer.frame.size.width, self.scrollContainer.frame.size.height);
        [orderStatusView setFrame:frame];
        if([orderStatus isEqualToString:@"Cancelled"] || [orderStatus isEqualToString:@"Time Out"])
        {
            [orderStatusView.viewOrder setHidden:YES];
            [orderStatusView.viewCancel setHidden:YES];
        }
        
        [self.scrollContainer addSubview:orderStatusView];
        [self.arrayOfOderViews addObject:orderStatusView];
    }
    [self.scrollContainer setContentSize:CGSizeMake((self.scrollContainer.frame.size.width * [self.arrayOrderStatus count]), self.scrollContainer.frame.size.height)];
    self.pageControl.numberOfPages = self.arrayOrderStatus.count;
    if (self.arrayOrderStatus.count) {
        [self updateOrderStatusView:self.currentPage];
    }
    else
    {
        self.lblNoOrders.textColor = BasicAppThemeColor;
        [self.scrollContainer addSubview:self.lblNoOrders];
        [UIAlertView showWithTitle:APPNAME message:@"Currently you have no orders" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
            [menuViewcontroller menuItemLocationClicked:nil];
            return;
        }];
    }
}

-(void)updateOrderStatusView:(NSInteger)pageNumber
{
    OrderStatusView *orderStatusView = (OrderStatusView *)[self.arrayOfOderViews objectAtIndex:pageNumber];
    CGRect rectFrame = orderStatusView.lblRouteMap.frame;
    if (IS_IPHONE_6 || IS_IPHONE_6_PLUS) {
        rectFrame.size.width = 140;
        orderStatusView.lblRouteMap.frame = rectFrame;
    }
    [orderStatusView.btnPlaceNewOrder setHidden:self.isHideNewPlaceOrder];
    [orderStatusView.lblLine setHidden:self.isHideNewPlaceOrder];
    [orderStatusView.btnRateDriver setHidden:YES];
    [orderStatusView.btnOrderDetail setHidden:NO];
    [orderStatusView.btnMap setUserInteractionEnabled:NO];
    orderStatusView.btnMap.selected = NO;
    
    [self.lblTransaction setText:[[self.arrayOrderStatus objectAtIndex:pageNumber] objectForKey:@"transaction_id"]];
    NSString *orderStatus = [[self.arrayOrderStatus objectAtIndex:pageNumber] objectForKey:@"order_status"];
    if(![orderStatus isEqualToString:@"Cancelled"] || ![orderStatus isEqualToString:@"Time Out"])
    {
        //'Pending','Packaged','Rejected','En Route','Delivered','Cancelled'
        if([orderStatus isEqualToString:@"Rejected"])
        {
            [orderStatusView.lblPending setText:@"Rejected"];
        }
        else if([orderStatus isEqualToString:@"Pending"])
        {
            orderStatusView.lblPending.textColor = [UIColor whiteColor];
            [orderStatusView.imgOrderStatus setImage:[UIImage imageNamed:@"order_status_2"]];
        }
        else if([orderStatus isEqualToString:@"Packaged"])
        {
            orderStatusView.lblPending.textColor = [UIColor whiteColor];
            orderStatusView.lblPacaked.textColor = [UIColor whiteColor];
            [orderStatusView.imgOrderStatus setImage:[UIImage imageNamed:@"order_status_3"]];
        }
        else if([orderStatus isEqualToString:@"En Route"])
        {
            [orderStatusView.btnMap setUserInteractionEnabled:YES];
            orderStatusView.btnMap.selected = YES;
            orderStatusView.lblPending.textColor = [UIColor whiteColor];
            orderStatusView.lblPacaked.textColor = [UIColor whiteColor];
            orderStatusView.lblRouteMap.textColor = [UIColor whiteColor];
            [orderStatusView.imgOrderStatus setImage:[UIImage imageNamed:@"order_status_4"]];
        }
        else//Delivered
        {
            [orderStatusView.btnRateDriver setHidden:NO];
            orderStatusView.lblPending.textColor = [UIColor whiteColor];
            orderStatusView.lblPacaked.textColor = [UIColor whiteColor];
            orderStatusView.lblRouteMap.textColor = [UIColor whiteColor];
            orderStatusView.lblDelivered.textColor = [UIColor whiteColor];
            [orderStatusView.imgOrderStatus setImage:[UIImage imageNamed:@"order_status_5"]];
            
            
        }
    }
    else
    {
        [orderStatusView.btnOrderDetail setHidden:YES];
    }
}

#pragma mark - StatusViewDelegate Methods

-(void)OrderStatusView:(OrderStatusView *)statusView orderDetailPressed:(UIButton *)sender
{
    OrderDetailViewController *objOrderDetailVC = [[OrderDetailViewController alloc] initWithNibName:@"OrderDetailViewController" bundle:nil];
    [objOrderDetailVC setStrOrderId:[[self.arrayOrderStatus objectAtIndex:[statusView tag]] objectForKey:@"order_id"]];
    [self.navigationController pushViewController:objOrderDetailVC animated:YES];
}

-(void)OrderStatusView:(OrderStatusView *)statusView placeNewOrderPressed:(UIButton *)sender
{
    MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
    [menuViewcontroller menuItemHomeClikced:nil];
}

-(void)OrderStatusView:(OrderStatusView *)statusView gpsTrackPressed:(UIButton *)sender
{
    TrackOrderViewController *objTrackOrderVC = [[TrackOrderViewController alloc] initWithNibName:@"TrackOrderViewController" bundle:nil];
    [objTrackOrderVC setDictDetails:[NSDictionary dictionaryWithDictionary:[self.arrayOrderStatus objectAtIndex:[statusView tag]]]];
    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
}

-(void)OrderStatusView:(OrderStatusView *)statusView rateDriverPressed:(UIButton *)sender
{
    indexOfOrder = statusView.tag;
    self.viewPopupRate.frame = [[UIScreen mainScreen] bounds];
    [self.tblRateView reloadData];
    [[GlobalManager getAppDelegateInstance].window addSubview:self.viewPopupRate];
    [GlobalManager addAnimationToView:self.innerPopupView];
}

#pragma mark - IBAction Methods

-(IBAction)btnRateClicked:(UIButton*)sender
{
    if (sender.tag==1)
    {
        self.imgRate1.image = [UIImage imageNamed:@"starfill.png"];
        self.imgRate2.image = self.imgRate3.image = self.imgRate4.image =self.imgRate5.image = [UIImage imageNamed:@"starempty.png"];
        self.currentRating =1;
    }
    else if (sender.tag==2)
    {
        self.imgRate1.image = self.imgRate2.image = [UIImage imageNamed:@"starfill.png"];
        self.imgRate3.image = self.imgRate4.image =self.imgRate5.image = [UIImage imageNamed:@"starempty.png"];
        self.currentRating =2;
    }
    else if (sender.tag==3)
    {
        self.imgRate1.image = self.imgRate2.image = self.imgRate3.image = [UIImage imageNamed:@"starfill.png"];
        self.imgRate4.image =self.imgRate5.image = [UIImage imageNamed:@"starempty.png"];
        self.currentRating =3;
    }
    else if (sender.tag==4)
    {
        self.imgRate1.image = self.imgRate2.image = self.imgRate3.image = self.imgRate4.image = [UIImage imageNamed:@"starfill.png"];
        self.imgRate5.image = [UIImage imageNamed:@"starempty.png"];
        self.currentRating =4;
    }
    else if (sender.tag==5)
    {
        self.imgRate1.image = self.imgRate2.image = self.imgRate3.image = self.imgRate4.image =self.imgRate5.image = [UIImage imageNamed:@"starfill.png"];
        self.currentRating =5;
    }
}

-(IBAction)btnPlaceNewOrderPressed:(id)sender
{
    MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
    [menuViewcontroller menuItemHomeClikced:nil];
}

-(IBAction)btnSubmitPressed:(id)sender
{
    if(self.currentRating > 0)
    {
        [self callFeedbackWS:indexOfOrder];
        return;
    }
    else
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please rate driver" handler:nil];
        return;
    }
}

-(IBAction)btnCancelRating:(id)sender
{
    [self.viewPopupRate removeFromSuperview];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = [GlobalManager getAppDelegateInstance].window.frame.size.width; // you need to have a **iVar** with getter for scrollView
    float fractionalPage = self.scrollContainer.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
    self.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateOrderStatusView:self.currentPage];
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tblRateView.scrollEnabled = NO;
    self.innerPopupView.center = [[GlobalManager getAppDelegateInstance].window center];
    return driverCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.imgRate1.image = self.imgRate2.image = self.imgRate3.image = self.imgRate4.image =self.imgRate5.image = [UIImage imageNamed:@"starempty.png"];
    self.currentRating = 0.0f;
    
    RateDriverTableViewCell *cell=[self.tblRateView dequeueReusableCellWithIdentifier:@"RateDriverTableViewCell"];
    [cell.rateDriver setDelegate:self];
    [cell.rateDriver setRating:0.0f];
    [cell.rateDriver setStarFillColor:[UIColor colorWithRed:254/255.0 green:203/255.0 blue:47/255.0 alpha:1.0]];
    [cell.rateDriver setStarNormalColor:[UIColor whiteColor]];
    cell.rateDriver.canRate = YES;
    
    NSDictionary *dict = [self.arrayOrderStatus objectAtIndex:indexOfOrder];
    [cell.lblDriverName setText:[dict objectForKey:@"driver_name"]];
    [cell.imgDriver sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"profile_image"]]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]];

    
    return cell;
}

-(void)rateView:(RateView *)rateView didUpdateRating:(float)rating
{
    self.currentRating = [[NSString stringWithFormat:@"%.1f", rating] floatValue];
    NSLog(@"RATING: %f and Current Rating: %f", rating, self.currentRating);
}


-(void)refreshController
{
    [self dragDownGesture];
}

-(void)dragDownGesture
{
    UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [GlobalManager getAppDelegateInstance].window.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
    [self.scrollContainer addGestureRecognizer:swipeUpGestureRecognizer];
}

- (void)handleSwipeDown:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"DOWN");
    if (!self.activityIndicator)
    {
        self.activityIndicator = [[TYMActivityIndicatorView alloc] initWithActivityIndicatorStyle:TYMActivityIndicatorViewStyleNormal];
        self.activityIndicator.hidesWhenStopped = NO;
    }
    self.activityIndicator.frame = CGRectMake((self.view.frame.size.width-60)/2, 79, 50, 50);
    self.activityIndicator.backgroundColor = [UIColor whiteColor];
    self.activityIndicator.layer.cornerRadius = self.activityIndicator.frame.size.height/2;
    self.activityIndicator.clipsToBounds = YES;

    //    [self addSubview:self.activityIndicator];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+100, self.view.frame.size.width, self.view.frame.size.height);
        [self.activityIndicator startAnimating];
        [[GlobalManager getAppDelegateInstance].window addSubview:self.activityIndicator];
    }];
    
    [self callOrderStatusRefreshWS];
}


#pragma mark - WS calling methods

-(void)callOrderStatusRefreshWS
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    self.objWSHelper.serviceName = @"ORDER_STATUS";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getOrderStatusURL:params]];
}

-(void)callOrderStatusWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    self.objWSHelper.serviceName = @"ORDER_STATUS";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getOrderStatusURL:params]];
}

-(void)callFeedbackWS:(NSInteger)index
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    
    NSDictionary *dict = [self.arrayOrderStatus objectAtIndex:index];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:[NSString stringWithFormat:@"%.1f",self.currentRating] forKey:@"ratting"];
    [params setObject:[dict objectForKey:@"driver_id"] forKey:@"driver_id"];
    [params setObject:[dict objectForKey:@"order_id"] forKey:@"order_id"];
    
    [self.objWSHelper setServiceName:@"FEEDBACK_RATING"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getFeedbackForDriverURL:params]];
}

#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    
    [[CustomActivityIndicator getCustomIndicatorInstance] hideIndicatorForView:self];
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    
    if (!response)
    {
        return;
    }
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if([helper.serviceName isEqualToString:@"ORDER_STATUS"])
    {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height);
        }];
        
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            
            self.arrayOrderStatus = [NSMutableArray arrayWithArray:[[dictResults objectForKey:@"data"] objectForKey:@"fetch_order_status"]];
            
            aryDrivers = [[NSMutableArray alloc]init];
            
            for (NSMutableDictionary *dict in self.arrayOrderStatus)
            {
                NSString *orderStatus = [dict objectForKey:@"order_status"];
                if([orderStatus isEqualToString:@"Delivered"]){
                    [aryDrivers addObject:dict];
                   
                }
            }

            if ([aryDrivers count])
            {
                NSMutableDictionary *dictDriver = [aryDrivers objectAtIndex:0];
                self.objRateView = [[RateViewController alloc]init];
                self.objRateView.objDelegate = self;
                self.objRateView.dictDriver = dictDriver;
                [[GlobalManager getAppDelegateInstance].window  addSubview:self.objRateView.view];
                self.objRateView.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
                [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.objRateView.view.transform = CGAffineTransformIdentity;
                    
                } completion:^(BOOL finished) {
                    
                }];
            }

            
            
            NSDictionary *dictAppSettings = [[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS];
            if(([self.arrayOrderStatus count] > [[dictAppSettings objectForKey:@"max_order_per_customer"] integerValue]) || [[NSUserDefaults standardUserDefaults] boolForKey:ORDER_TRACE])
            {
                self.isHideNewPlaceOrder = YES;
            }
            else
            {
                self.isHideNewPlaceOrder = NO;
            }
            
            [self showOrderStatusView];
            
           
            
            return;
        }
        else
        {
            MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
            [menuViewcontroller menuItemHomeClikced:nil];
            return;
        }
    }
    else
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
            NSLog(@"RateSuccess");
        else
            NSLog(@"RateFaliure");
        [self.viewPopupRate removeFromSuperview];
        [self callOrderStatusWS];
        return;
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [[CustomActivityIndicator getCustomIndicatorInstance] hideIndicatorForView:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height);
    }];
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

-(void)btnSubmitClikced
{
    NSLog(@"drivers :%@",aryDrivers);
    
    [self callOrderStatusWS];
    
//    [aryDrivers removeObjectAtIndex:0];
//    
//    if ([aryDrivers count])
//    {
//        NSMutableDictionary *dictDriver = [aryDrivers objectAtIndex:0];
//        self.objRateView.dictDriver = dictDriver;
//        [[GlobalManager getAppDelegateInstance].window  addSubview:self.objRateView.view];
//        self.objRateView.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
//        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
//            self.objRateView.view.transform = CGAffineTransformIdentity;
//        } completion:^(BOOL finished) {
//            
//        }];
//    }
    
    
}

@end
