//
//  CheckOutViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "CheckOutViewController.h"
#import "CheckOutCell.h"
#import "OrderSummaryViewController.h"
#import "GlobalManager.h"
#import "CardsViewController.h"
#import "HomeViewController.h"
#import "ListViewController.h"

@interface CheckOutViewController ()
{
    BOOL isAlreadyOrdered;
}

@end

@implementation CheckOutViewController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - viewDidLoad Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [self setUpLayout];
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Checkout Screen"];
//    [self.txtViewDeliveryNote setText:[[NSUserDefaults standardUserDefaults] objectForKey:DELIVERY_NOTE]];
    
    if ([GlobalManager getAppDelegateInstance].dictAddress) {
        NSString *strAddress = @"" ;

        if ([[[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"FLAT_NUMBER"] length]) {
            strAddress = [NSString stringWithFormat:@"%@\n%@",[[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"FLAT_NUMBER"],
                          [[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"ADDRESS"]];
        }
        else
        {
            strAddress = [[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"ADDRESS"];
        }
       
        
        self.lblPostalCode.text = [[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"POST_CODE"];
        
        self.lblDeliveryToAddres.text = strAddress;
        
    }
    else
    {
        self.lblPostalCode.text = @"";
        self.lblDeliveryToAddres.text = [[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LOCATION_NAME];
    }
//    [self.btnDeliveryToAddres setTitle:strAddress forState:UIControlStateNormal];
    if(self.isProductAvailble)
    {
        self.lblAlertmessage.hidden = NO;
    }
    else
    {
        self.lblAlertmessage.hidden = YES;
        CGRect rectTemp = self.tableCart.frame;
        rectTemp.size.height = CGRectGetHeight(self.tableCart.frame)+CGRectGetHeight(self.lblAlertmessage.frame);
        self.tableCart.frame =rectTemp;
    }
    [self callApplicationSettingsWS];
}

#pragma mark - Instance Methods

-(void)setUpLayout
{
    self.navigationItem.title =@"Checkout";
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans" size:18],NSFontAttributeName, nil]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],NSForegroundColorAttributeName,[GlobalManager fontMuseoSans300:18.0],NSFontAttributeName, nil]];
    self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"menu"];
    [self.tableCart registerNib:[UINib nibWithNibName:@"CheckOutCell" bundle:nil ] forCellReuseIdentifier:@"CheckOutCell"];
    
    if (!self.isFromMenu)
    {
        [self setBackButton];
    }
    [self commentTextView];

    UITapGestureRecognizer *tapLabelCost = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(priceLabelClicked)];
    [self.lblTotalCost addGestureRecognizer:tapLabelCost];
    [self promoCodeLayer];
}

-(void)promoCodeLayer
{
    self.btnPromoCode.layer.cornerRadius = 15;
    self.btnPromoCode.layer.borderWidth = 1.0;
    self.btnPromoCode.layer.borderColor = BasicAppTheme_CgColor;
    [self.btnPromoCode addTarget:self action:@selector(highlightBorder:) forControlEvents:UIControlEventTouchDown];
    [self.btnPromoCode addTarget:self action:@selector(btnPromoCodeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPromoCode addTarget:self action:@selector(unhighlightBorder:) forControlEvents:UIControlEventTouchUpOutside];
}

-(void)btnCancelClicked
{
    [self.view endEditing:YES];
    if ([self.navigationController.viewControllers count])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)btnMenuClicked
{
    [self.view endEditing:YES];
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

#pragma mark - Button Promo code border

-(void)highlightBorder:(UIButton*)sender
{
    sender.layer.borderColor = [[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]CGColor];
}

-(void)unhighlightBorder:(UIButton*)sender
{
    sender.layer.borderColor = BasicAppTheme_CgColor;
}

- (void)commentTextView
{
    self.txtViewDeliveryNote.placeholder=@"Enter Note here ";
    self.txtViewDeliveryNote.placeholderColor = [UIColor colorWithRed:185/255.0 green:185/255.0 blue:185/255.0 alpha:1.0];
    [self.txtViewDeliveryNote setFont:[GlobalManager fontMuseoSans100:14]];
    self.txtViewDeliveryNote.delegate = self;
}

#pragma mark - IBAction methods

-(IBAction)btnDeliverLocationClicked:(id)sender
{
    [self.view endEditing:YES];
    if(isAlreadyOrdered)
    {
        [UIAlertView showWithTitle:LOCATION_CHANGE_TITLE message:@"You cannot change your address until the previous order has been delivered.." handler:nil];
        return;
    }
    else
    {
        [UIAlertView showConfirmationDialogWithTitle:LOCATION_CHANGE_TITLE message:@"If you change the delivery address, The product may not available or the price of the item may get changed." firstButtonTitle:@"Cancel" secondButtonTitle:@"Ok" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
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

-(void)priceLabelClicked
{
    [self btnNextClicked:nil];
}

-(IBAction)btnNextClicked:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *deliveryNote = [self.txtViewDeliveryNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[NSUserDefaults standardUserDefaults] setObject:deliveryNote forKey:DELIVERY_NOTE];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self callCardListWS];
    return;
}

-(void)btnPromoCodeClicked:(UIButton*)sender
{
    [self.view endEditing:YES];
    sender.layer.borderColor = BasicAppTheme_CgColor;
    [UIAlertView showPromoCode:^(UIAlertView *alertView, NSInteger buttonIndex)
    {
        [self.view endEditing:YES];
        if (buttonIndex == 1)
        {
            UIAlertView *promoAlertView = alertView;
            NSString *promoCode = [alertView textFieldAtIndex:0].text;
            if ([promoCode length])
            {
                [self callAddPromoCodeWS:promoCode];
                return;
            }
            else
            {
                [UIAlertView showWithTitle:APPNAME message:@"Please enter promo code" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                {
                    [[promoAlertView textFieldAtIndex:0] becomeFirstResponder];
                    return;
                }];
            }
        }
        else
        {}
    }];
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.txtViewDeliveryNote.textColor = [UIColor blackColor];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *deliveryNote = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([deliveryNote length])
    {
        [[NSUserDefaults standardUserDefaults] setObject:deliveryNote forKey:DELIVERY_NOTE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:DELIVERY_NOTE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayCarts count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CheckOutCell *cell=[tableView dequeueReusableCellWithIdentifier:@"CheckOutCell"];
    [cell.btnincreaseQty setTag:indexPath.row];
    [cell.btndecreaseQty setTag:indexPath.row];
    [cell.btndelete setTag:indexPath.row];
    [cell.btnincreaseQty addTarget:self action:@selector(clickedOnQtyIncrease:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btndecreaseQty addTarget:self action:@selector(clickedOnQtyDecrease:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btndelete addTarget:self action:@selector(btnDeletePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *dict = [self.arrayCarts objectAtIndex:indexPath.row];
    [cell.lblProductTitle setText:[dict objectForKey:@"product_name"]];
    [cell.lblProductSubTitle setText:[dict objectForKey:@"product_subtitle"]];
    [cell.lblnumberOfQty setText:[dict objectForKey:@"qty"]];
    [cell.lbltotalAmount setText:[NSString stringWithFormat:@"£%@", [dict objectForKey:@"price"]]];

    [cell.itemImage sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"product_image"]]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [UIAlertView showConfirmationDialogWithTitle:APPNAME message:@"Are you sure you want to delete the product from cart?" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
            if(buttonIndex == 1)
            {
            }
        }];
    }
}

-(void)clickedOnQtyIncrease:(UIButton *)sender
{
    [self.view endEditing:YES];
    NSDictionary *dict = [self.arrayCarts objectAtIndex:[sender tag]];
    
    CheckOutCell *cell = (CheckOutCell *)[self.tableCart cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    NSInteger noOfQty =[cell.lblnumberOfQty.text integerValue];
    if (noOfQty >= 0 && noOfQty < 99)
    {
        noOfQty = noOfQty + 1;
        [self callChangeQuantityWS:[dict objectForKey:@"product_id"] andQuantity:[NSString stringWithFormat:@"%li",(long)noOfQty]];
    }
    else
    {}
}
-(void)clickedOnQtyDecrease:(UIButton *)sender
{
    [self.view endEditing:YES];
    NSDictionary *dict = [self.arrayCarts objectAtIndex:[sender tag]];

    CheckOutCell *cell=(CheckOutCell *)[self.tableCart cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    NSInteger noOfQty =[cell.lblnumberOfQty.text integerValue];
    if (noOfQty > 1)
    {
        noOfQty = noOfQty - 1;
        [self callChangeQuantityWS:[dict objectForKey:@"product_id"] andQuantity:[NSString stringWithFormat:@"%li",(long)noOfQty]];
    }
    else
    {}
}

-(void)btnDeletePressed:(UIButton *)sender
{
    [UIAlertView showConfirmationDialogWithTitle:APPNAME message:@"Are you sure you want to delete this product from cart?" firstButtonTitle:@"Yes" secondButtonTitle:@"No" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(buttonIndex == 0)
        {
            NSString *productId = [[self.arrayCarts objectAtIndex:sender.tag] objectForKey:@"product_id"];
            [self callRemoveCartWS:productId withIndex:[sender tag]];
        }
    }];
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

-(void)callRemoveCartWS:(NSString *)productId withIndex:(NSInteger)index
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    
    [self.objWSHelper setServiceName:@"REMOVE_PRODUCT_FROM_CART"];
    NSDictionary *params = @{@"cart_id": [[NSUserDefaults standardUserDefaults] objectForKey:CART_ID], @"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID], @"product_id" : productId};
    [self.objWSHelper setTagNumber:index];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getRemoveProductFromCartURL:params]];
}

-(void)callChangeQuantityWS:(NSString *)productId andQuantity:(NSString *)quantity
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    
    [self.objWSHelper setServiceName:@"CHANGE_QUANTITY"];
    NSDictionary *params = @{@"cart_id": [[NSUserDefaults standardUserDefaults] objectForKey:CART_ID], @"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID], @"product_id" : productId, @"qty" : quantity};
    [self.objWSHelper sendRequestWithURL:[WS_Urls getChangeQuantityURL:params]];
}

-(void)callAddPromoCodeWS:(NSString *)promocode
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    
    [self.objWSHelper setServiceName:@"ADD_PROMOCODE"];
    NSDictionary *params = @{@"cart_id": [[NSUserDefaults standardUserDefaults] objectForKey:CART_ID], @"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID], @"promocode" : promocode};
    [self.objWSHelper sendRequestWithURL:[WS_Urls getAddPromoCodeURL:params]];
}

-(void)callCardListWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    [self.objWSHelper setServiceName:@"CARD_LIST"];
    NSDictionary *params = @{@"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID]};
    [self.objWSHelper sendRequestWithURL:[WS_Urls getCardListURL:params]];
}

#pragma mark - ParseWSDelegate Methods

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
            self.dictCartDetails = [NSDictionary dictionaryWithDictionary:[[[dictResults objectForKey:@"data"] objectForKey:@"cart_details"] objectAtIndex:0]];
            self.arrayCarts = [NSMutableArray arrayWithArray:[self.dictCartDetails objectForKey:@"cart_products"]];
            
            if ([self.dictCartDetails objectForKey:@"is_discounted_price"]) {
                float orderAmount = [[self.dictCartDetails objectForKey:@"order_amout"] floatValue];
                float discountAmount = [[self.dictCartDetails objectForKey:@"discount_amount"] floatValue];
                float totalAmount = orderAmount - discountAmount;
                [self.lblTotalCost setText:[NSString stringWithFormat:@"£%.2f", totalAmount]];
            }
            else
            {
                [self.lblTotalCost setText:[NSString stringWithFormat:@"£%@", [self.dictCartDetails objectForKey:@"order_amout"]]];
            }
            
            NSString *remainingOrders = [[[[dictResults objectForKey:@"data"] objectForKey:@"remaining_orders"] objectAtIndex:0] objectForKey:@"remaining_orders"];
            NSDictionary *dictAppSettings = [[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS];
            if([remainingOrders integerValue] == [[dictAppSettings objectForKey:@"max_order_per_customer"] integerValue])
            {
                isAlreadyOrdered = NO;
            }
            else
                isAlreadyOrdered = YES;
            [self.tableCart reloadData];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:CART_ID];
                 [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:DELIVERY_NOTE];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
               //  NSLog(@"%@",self.navigationController.viewControllers);
                 
                 for (UIViewController *obj in self.navigationController.viewControllers)
                 {
                     if([obj isKindOfClass:[ListViewController class]])
                     {
                         ListViewController *objList = (ListViewController*)obj;
                         [self.navigationController popToViewController:objList animated:YES];
                         return ;
                     }
                 }
                 
                [self.navigationController popViewControllerAnimated:YES];
            }];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"REMOVE_PRODUCT_FROM_CART"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            [self.arrayCarts removeObjectAtIndex:helper.tagNumber];
            [self.tableCart beginUpdates];
            [self.tableCart deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:helper.tagNumber inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableCart endUpdates];
            
            [self callShowCartWS];
            return;
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"CHANGE_QUANTITY"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            [self callShowCartWS];
            return;
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"CARD_LIST"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            NSMutableArray *arrayList = [dictResults objectForKey:@"data"];
            OrderSummaryViewController *objOrderSummaryVC = [[OrderSummaryViewController alloc] initWithNibName:@"OrderSummaryViewController" bundle:nil];
            [objOrderSummaryVC setDictCardDetails:[NSDictionary dictionaryWithDictionary:[arrayList objectAtIndex:0]]];
            [self.navigationController pushViewController:objOrderSummaryVC animated:YES];
            return;
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            CardsViewController *cardsViewController = [[CardsViewController alloc] initWithNibName:@"CardsViewController" bundle:nil];
            [self.navigationController pushViewController:cardsViewController animated:YES];
        }
    }
    else//@"ADD_PROMOCODE"
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];

        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self callShowCartWS];
            }];
            return;
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end
