//
//  OrderSummaryViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "OrderSummaryViewController.h"
#import "OrderStatusViewController.h"
#import "OrderCell.h"
#import "CardsViewController.h"
#import "CardsViewController.h"
#import "ProductsViewController.h"
#import "HomeViewController.h"
#import "MenuViewController.h"
#import "ListViewController.h"

@interface OrderSummaryViewController ()
{
    BOOL isAlreadyOrdered;
    BOOL isDateOfBirthNeed;
}

@end

@implementation OrderSummaryViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [self setUpLayout];
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Order Summary Screen"];
    if ([GlobalManager getAppDelegateInstance].dictAddress) {
        NSString *strAddress;
//        NSString *strAddress = [NSString stringWithFormat:@"%@\n%@",[[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"FLAT_NUMBER"],
//                                [[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"ADDRESS"]];
        if ([[[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"FLAT_NUMBER"] length]) {
            strAddress = [NSString stringWithFormat:@"%@\n%@",[[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"FLAT_NUMBER"],
                          [[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"ADDRESS"]];
        }
        else
        {
            strAddress = [[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"ADDRESS"];
        }
        
        
        self.lblPostalCode.text = [[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"POST_CODE"];
        
        self.lblDeliverAddress.text = strAddress;

    }
    else
    {
        self.lblPostalCode.text = @"";
        [self.lblDeliverAddress setText:[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LOCATION_NAME]];
    }

}

-(void)viewDidAppear:(BOOL)animated
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    [self callShowCartWS];
}

#pragma mark - Instance methods

-(void)setUpLayout
{
    self.navigationItem.title = @"Order Summary";
    self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"menu"];
    [self setBackButton];
    [self.tblOrderedProducts registerNib:[UINib nibWithNibName:@"OrderCell" bundle:nil] forCellReuseIdentifier:@"OrderCell"];
    self.confirmationPopUp.layer.borderWidth = 1.0;
    self.confirmationPopUp.layer.borderColor = [[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]CGColor];
    self.confirmationPopUp.layer.cornerRadius = 5.0;
    [self.lblCardDetails setText:[NSString stringWithFormat:@"%@#*************%@", [self.dictCardDetails objectForKey:@"brand"], [self.dictCardDetails objectForKey:@"card_number"]]];
}

-(void)btnMenuClicked
{
    [self.view endEditing:YES];
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderCell *cell=[self.tblOrderedProducts dequeueReusableCellWithIdentifier:@"OrderCell"];
    NSDictionary *dict = [self.arrayProducts objectAtIndex:indexPath.row];
    
    [cell.lblProductTitle setText:[dict objectForKey:@"product_name"]];
    [cell.lblProductSubTitle setText:[dict objectForKey:@"product_subtitle"]];
    [cell.lblQuantity setText:[dict objectForKey:@"qty"]];
    [cell.lblPrice setText:[NSString stringWithFormat:@"£%@", [dict objectForKey:@"price"]]];
    [cell.imgProduct sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"product_image"]]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    return cell;    
}

#pragma mark - IBACtion Methods

-(IBAction)btnDeliveryDetailsClicked:(id)sender
{
    if(isAlreadyOrdered)
    {
        [UIAlertView showWithTitle:LOCATION_CHANGE_TITLE message:@"You cannot change your address until the previous order has been delivered." handler:nil];
        return;
    }
    else
    {
        [UIAlertView showConfirmationDialogWithTitle:LOCATION_CHANGE_TITLE message:@"If you change the delivery address, the product price or availability may change. This will automatically update in your cart." firstButtonTitle:@"Cancel" secondButtonTitle:@"Ok" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             if(buttonIndex == 1)
             {
                 HomeViewController *objHomeVC = [AppDelegate sharedHomeViewController];
                 [objHomeVC setIsChangingLocation:YES];
                 [self.navigationController pushViewController:objHomeVC animated:YES];
             }
         }];
    }
}

-(IBAction)btnCardDetailsClicked:(id)sender
{
    CardsViewController *objCardsVC=[[CardsViewController alloc] initWithNibName:@"CardsViewController" bundle:nil];
    [self.navigationController pushViewController:objCardsVC animated:YES];
}

-(IBAction)btnPlaceOrderClicked:(id)sender
{
    [self.view endEditing:YES];
    [self.viewPopUp setFrame:[[UIScreen mainScreen] bounds]];
    [[GlobalManager getAppDelegateInstance].window addSubview:self.viewPopUp];
    [GlobalManager addAnimationToView:self.confirmationPopUp];
    self.confirmationPopUp.clipsToBounds = YES;
}

-(IBAction)btPopYesClicked:(id)sender
{
    [self.viewPopUp removeFromSuperview];
    [self callPlaceOrderWS];
}

-(IBAction)btPopNoClicked:(id)sender
{
    [self.viewPopUp removeFromSuperview];
}

#pragma mark - AttributeText
-(NSAttributedString*)getAttrStringWithDiscount : (NSString *)str1 :(NSString*)str2 :(NSString*)str3{
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",str1,str2,str3]];
    UIFont *fontReg=[UIFont fontWithName:@"OpenSans" size:16];
    NSDictionary *attrsReg = @{ NSFontAttributeName : fontReg,
                                NSForegroundColorAttributeName : [UIColor blackColor]};
    
    NSDictionary *attrsMed = @{ NSFontAttributeName : fontReg,
                                NSForegroundColorAttributeName : [UIColor redColor]};
    
    [attString addAttributes:attrsMed range:NSMakeRange(0, 1)];
    
    [attString addAttributes:attrsReg range:NSMakeRange(1, 2)];
    [attString addAttributes:attrsReg range:NSMakeRange(2, str3.length)];
    return attString;
}

#pragma mark - Webservice methods

-(void)callApplicationSettingsWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    
    [self.objWSHelper setServiceName:@"APPLICATION_SETTINGS"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getApplicationSettingsURL:nil]];
}

-(void)callShowCartWS
{
    [self.objWSHelper setServiceName:@"SHOW_CART"];
    NSDictionary *params = @{@"cart_id": [[NSUserDefaults standardUserDefaults] objectForKey:CART_ID], @"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID]};
    [self.objWSHelper sendRequestWithURL:[WS_Urls getShowCartURL:params]];
}

-(void)callPlaceOrderWS
{
    if(isDateOfBirthNeed)
    {
        [UIAlertView showWithTitle:APPNAME message:@"If you want to place the order, you have to update the date of birth in your profile" handler:nil];
        MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
        [menuViewcontroller menuItemProfileClicked:nil];
        return;
    }
    
    NSString *strPhoneNumber = [[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"CONTACT_NUMBER"];
    
    strPhoneNumber  = ([strPhoneNumber length])?strPhoneNumber:[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_NUMBER];
    
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    [self.objWSHelper setServiceName:@"PLACE_ORDER"];
    NSDictionary *params = @{@"cart_id": [[NSUserDefaults standardUserDefaults] objectForKey:CART_ID], @"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID], @"delivery_note" : [[NSUserDefaults standardUserDefaults] objectForKey:DELIVERY_NOTE], @"card_token" : [self.dictCardDetails objectForKey:@"card_token"],@"delivery_contact_number":strPhoneNumber};
    [self.objWSHelper sendRequestWithURL:[WS_Urls getPlaceORderURL:params]];
}

#pragma mark - ParseWSDelegate methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    if(!response)
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        return;
    }

    NSMutableDictionary *dictResults = (NSMutableDictionary *)response;
    if([helper.serviceName isEqualToString:@"APPLICATION_SETTINGS"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            NSDictionary *dictSupport = [NSDictionary dictionaryWithDictionary:[[dictResults objectForKey:@"data"] objectForKey:@"app_settings"]];
            [[NSUserDefaults standardUserDefaults] setObject:dictSupport forKey:APPLICATION_SETTINGS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:APPLICATION_SETTINGS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self callShowCartWS];
    }
    else if([helper.serviceName isEqualToString:@"SHOW_CART"])
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            NSString *dateOfBirthResult = [[[[dictResults objectForKey:@"data"] objectForKey:@"fetch_dob"] objectAtIndex:0] objectForKey:@"dob_result"];
            self.dictCartDetails = [NSDictionary dictionaryWithDictionary:[[[dictResults objectForKey:@"data"] objectForKey:@"cart_details"] objectAtIndex:0]];
            self.arrayProducts = [NSMutableArray arrayWithArray:[self.dictCartDetails objectForKey:@"cart_products"]];
            [self.lblSubTotal setText:[NSString stringWithFormat:@"£%@", [self.dictCartDetails objectForKey:@"order_amout"]]];
            [self.lblDeliveryFee setText:[NSString stringWithFormat:@"£%@", [self.dictCartDetails objectForKey:@"delivery_fee"]]];
            
            if ([[self.dictCartDetails objectForKey:@"discount_amount"] floatValue] == 0) {
                [self.lblDiscountCode setText:[NSString stringWithFormat:@"£%@", [self.dictCartDetails objectForKey:@"discount_amount"]]];
            }
            else
            {
                [self.lblDiscountCode setText:[NSString stringWithFormat:@"- £%@", [self.dictCartDetails objectForKey:@"discount_amount"]]];
                [self.lblDiscountCode setTextColor:[UIColor redColor]];
            }
            
            [self.lblGrandTotal setText:[NSString stringWithFormat:@"£%@", [self.dictCartDetails objectForKey:@"total_amount"]]];
            isDateOfBirthNeed = ([@"1" isEqualToString:dateOfBirthResult] ? NO : YES);
            
            NSString *remainingOrders = [[[[dictResults objectForKey:@"data"] objectForKey:@"remaining_orders"] objectAtIndex:0] objectForKey:@"remaining_orders"];
            NSDictionary *dictAppSettings = [[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS];
            if([remainingOrders integerValue] == [[dictAppSettings objectForKey:@"max_order_per_customer"] integerValue])
            {
                isAlreadyOrdered = NO;
            }
            else
                isAlreadyOrdered = YES;
            
            [self.tblOrderedProducts reloadData];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"PLACE_ORDER"])
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:CART_ID];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:PRODUCT_COUNT];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:DELIVERY_NOTE];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
            [menuViewcontroller menuItemStatusClicked:nil];
        }
        else if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"2"])
        {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:CART_ID];
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:PRODUCT_COUNT];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:DELIVERY_NOTE];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
                [menuViewcontroller menuItemStatusClicked:nil];
            return;
        }
        else if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"6"])
        {
            if([[dictResults objectForKey:@"data"] isKindOfClass:[NSArray class]])
            {
                [UIAlertView showWithTitle:APPNAME message:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"msg"] handler:nil];
                return;
            }
            else{
                [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            }
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
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
