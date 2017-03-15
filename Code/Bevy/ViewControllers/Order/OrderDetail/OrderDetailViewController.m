//
//  OrderDetailViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderCell.h"
#import "RateDriverTableViewCell.h"
#import "ProductsViewController.h"

@interface OrderDetailViewController ()

@end

@implementation OrderDetailViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [self setUpUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Order Detail Screen"];

    [self callOrderDetailWS];
}

#pragma mark - Instance methods

-(void)setUpUI
{
    self.navigationItem.title = @"Order Detail";
    self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"menu"];
    [self setBackButton];
    [self.tblOrderedProducts registerNib:[UINib nibWithNibName:@"OrderCell" bundle:nil] forCellReuseIdentifier:@"OrderCell"];
    [self.tblRatePopUp registerNib:[UINib nibWithNibName:@"RateDriverTableViewCell" bundle:nil] forCellReuseIdentifier:@"RateDriverTableViewCell"];
    
    self.viewCallpopUp.layer.borderWidth = 1.0;
    self.viewCallpopUp.layer.borderColor = [[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]CGColor];
    self.viewCallpopUp.layer.cornerRadius = 5.0;
    self.imgDriver.layer.cornerRadius = self.imgDriver.frame.size.height/2;
    
    self.viewRatePopUp.layer.borderWidth = 1.0;
    self.viewRatePopUp.layer.borderColor = [[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]CGColor];
    self.viewRatePopUp.layer.cornerRadius = 5.0;
    driverCount = 1;
}

-(void)btnMenuClicked
{
    [self.view endEditing:YES];
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

#pragma mark - IBAction Methods

-(IBAction)btnCallDriverClicked:(id)sender
{
    [self.view endEditing:YES];
    self.viewPopUp.frame = [[UIScreen mainScreen] bounds];
    [self.lblDriverName setText:[[[self.dictDetails objectForKey:@"fetch_order"] objectAtIndex:0] objectForKey:@"driver_name"]];
    [self.btnNumber setTitle:[[[self.dictDetails objectForKey:@"fetch_order"] objectAtIndex:0] objectForKey:@"driver_mobile_no"] forState:UIControlStateNormal];
    [[GlobalManager getAppDelegateInstance].window addSubview:self.viewPopUp];
    [GlobalManager addAnimationToView:self.viewCallpopUp];
}

-(IBAction)btnPopUpCallDriverClicked:(id)sender;
{
    [self.viewPopUp removeFromSuperview];
    if(!TARGET_IPHONE_SIMULATOR)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"tel://+%@",[[[self.dictDetails objectForKey:@"fetch_order"] objectAtIndex:0] objectForKey:@"driver_mobile_no"]]]];
    }
    [self performSelector:@selector(showRatingView) withObject:nil afterDelay:0.2];
}

-(void)showRatingView
{
    self.viewPopUpRate.frame = [[UIScreen mainScreen] bounds];
    [[GlobalManager getAppDelegateInstance].window addSubview:self.viewPopUpRate];
    [GlobalManager addAnimationToView:self.viewRatePopUp];
}

-(IBAction)btnPopUpCancelDriverClicked:(id)sender
{
    [self.viewPopUp removeFromSuperview];
}

-(IBAction)btnPopUpSubmitClicked:(id)sender
{
    [self callFeedbackWS];
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblOrderedProducts)
    {
        return self.arrayProducts.count;
    }
    else
    {
        if (driverCount > 1)
        {
            self.viewRatePopUp.frame = CGRectMake(self.viewRatePopUp.frame.origin.x, self.viewRatePopUp.frame.origin.y, self.viewRatePopUp.frame.size.width, 374);
        }
        else
        {
            self.tblRatePopUp.scrollEnabled = NO;
        }
        self.viewRatePopUp.center = [[GlobalManager getAppDelegateInstance].window center];
        return driverCount;
    }
    return self.arrayProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblOrderedProducts)
    {
        OrderCell *cell=[self.tblOrderedProducts dequeueReusableCellWithIdentifier:@"OrderCell"];
        NSDictionary *dict = [self.arrayProducts objectAtIndex:indexPath.row];
        
        [cell.lblProductTitle setText:[dict objectForKey:@"product_name"]];
        [cell.lblProductSubTitle setText:[dict objectForKey:@"product_sub_title"]];
        [cell.lblPrice setText:[NSString stringWithFormat:@"£%@", ([[dict objectForKey:@"product_price"] isEqualToString:@""] ? @"0.00" : [dict objectForKey:@"product_price"])]];
        [cell.lblQuantity setText:[NSString stringWithFormat:@"%@", [dict objectForKey:@"product_qty"]]];
        
        [cell.imgProduct sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"product_image"]]
                               placeholderImage:[UIImage imageNamed:@"listview_placeholder"]];


        return cell;
    }
    else
    {
        RateDriverTableViewCell *cell=[self.tblRatePopUp dequeueReusableCellWithIdentifier:@"RateDriverTableViewCell"];
        cell.backgroundColor = [UIColor clearColor];
        [cell.rateDriver setDelegate:self];
        [cell.lblDriverName setText:[[[self.dictDetails objectForKey:@"fetch_order"] objectAtIndex:0] objectForKey:@"driver_name"]];
        
        [cell.imgDriver sd_setImageWithURL:[NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/8/86/Driver_Dave_Marshall_The_Friendly_Bus_Driver.jpg"]
                           placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        
        [self.imgDriver sd_setImageWithURL:[NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/8/86/Driver_Dave_Marshall_The_Friendly_Bus_Driver.jpg"]
                          placeholderImage:[UIImage imageNamed:@"placeholder"]];
        [cell.rateDriver setStarFillColor:[UIColor colorWithRed:254/255.0 green:203/255.0 blue:47/255.0 alpha:1.0]];
        [cell.rateDriver setStarNormalColor:[UIColor whiteColor]];
        cell.rateDriver.canRate = YES;
        return cell;
    }
}

-(void)rateView:(RateView *)rateView didUpdateRating:(float)rating
{
    self.currentRating = [[NSString stringWithFormat:@"%.1f", rating] floatValue];
    NSLog(@"RATING: %f and Current Rating: %f", rating, self.currentRating);
}

#pragma mark - WS calling methods

-(void)callOrderDetailWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:self.strOrderId forKey:@"order_id"];
    [self.objWSHelper setServiceName:@"ORDER_DETAILS"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getOrderDetailsURL:params]];
}

-(void)callFeedbackWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:[NSString stringWithFormat:@"%.1f",self.currentRating] forKey:@"ratting"];
  
    [self.objWSHelper setServiceName:@"FEEDBACK_RATING"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getFeedbackForDriverURL:params]];
}

#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if (!response)
        return;

    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if([helper.serviceName isEqualToString:@"ORDER_DETAILS"] )
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            self.dictDetails = [NSDictionary dictionaryWithDictionary:[[[dictResults objectForKey:@"data"] objectForKey:@"fetch_order"] objectAtIndex:0]];
            self.arrayProducts = [NSMutableArray arrayWithArray:[[dictResults objectForKey:@"data"] objectForKey:@"order_details"]];
            
            [self.lblTransactionNumber setText:[self.dictDetails objectForKey:@"transaction_no"]];
            [self.lblSubTotal setText:[NSString stringWithFormat:@"£%@", [self.dictDetails objectForKey:@"sub_total"]]];
            [self.lblPromCode setText:([[self.dictDetails objectForKey:@"promo_code"] isEqualToString:@""] ? @"---" : [self.dictDetails objectForKey:@"promo_code"])];
            self.lblDeleveryAddress.marqueeType = MLContinuous;
             self.lblDeleveryNote.marqueeType = MLContinuous;
            
            [self.lblDeleveryAddress setText:(([[self.dictDetails objectForKey:@"delivery_address"] isEqualToString:@""] || ![self.dictDetails objectForKey:@"delivery_address"]) ? @"---" : [NSString stringWithFormat:@"%@.          ",[self.dictDetails objectForKey:@"delivery_address"]])];
             [self.lblDeleveryNote setText:(([[self.dictDetails objectForKey:@"delivery_note"] isEqualToString:@""] || ![self.dictDetails objectForKey:@"delivery_note"]) ? @"---" : [self.dictDetails objectForKey:@"delivery_note"])];
            [self.lblDeliveryFee setText:[NSString stringWithFormat:@"£%@", [self.dictDetails objectForKey:@"delivery_fee"]]];
            [self.lblGrandTotal setText:[NSString stringWithFormat:@"£%@", [self.dictDetails objectForKey:@"grand_total"]]];
            
            [self.tblOrderedProducts reloadData];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"FEEDBACK_RATING"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
            NSLog(@"RateSuccess");
        else
            NSLog(@"RateFaliure");
        [self.viewPopUpRate removeFromSuperview];
        for (UINavigationController *viewController in self.navigationController.viewControllers)
        {
            if ([viewController isKindOfClass:[ProductsViewController class]])
            {
                [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:PRODUCT_COUNT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.navigationController popToViewController:viewController animated:YES];
                break;
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
        return;
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end
