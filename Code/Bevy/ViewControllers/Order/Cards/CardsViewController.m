    //
//  CardsViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "CardsViewController.h"
#import "CardsCell.h"
#import "OrderStatusViewController.h"
#import "OrderSummaryViewController.h"
#import "ProductsViewController.h"

@interface CardsViewController ()

@end

@implementation CardsViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [self viewTitleFont];
    [self callCardListWS];
    self.navigationItem.hidesBackButton = YES;
    [self.tblCardsView registerNib:[UINib nibWithNibName:@"CardsCell" bundle:nil] forCellReuseIdentifier:@"CardsCell"];
    [CardIOUtilities preload];
}
-(void)btnMenuClicked
{
    [self.view endEditing:YES];
    
    if (!self.isFromProfile && self.isFromOrderDetails)
    {
        if (self.arrayCards.count)
        {
            OrderSummaryViewController *objOrderSummaryVC = [[OrderSummaryViewController alloc] initWithNibName:@"OrderSummaryViewController" bundle:nil];
            [objOrderSummaryVC setDictCardDetails:[NSDictionary dictionaryWithDictionary:[self.arrayCards firstObject]]];
            [self.navigationController pushViewController:objOrderSummaryVC animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewTitleFont
{
    self.title =@"Cards";
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"OpenSans" size:18], NSFontAttributeName, nil]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],NSForegroundColorAttributeName,[GlobalManager fontMuseoSans300:18.0],NSFontAttributeName,nil]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Cards List Screen"];
}

#pragma mark - UITableViewDataSource Methods

-(IBAction)btnAddCardsClicked:(id)sender
{
    if([sender tag] == 999)
    {
        self.isCardFunctionality = YES;
        
        CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
        [scanViewController setDisableManualEntryButtons:YES];
        [scanViewController setHideCardIOLogo:YES];
        [self presentViewController:scanViewController animated:YES completion:nil];
    }
    else
    {
        AddCardViewController *addViewController = [[AddCardViewController alloc] initWithNibName:@"AddCardViewController" bundle:nil];
        [addViewController setCardListDelegate:self];
        UINavigationController *navigation  = [[UINavigationController alloc] initWithRootViewController:addViewController];
        [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];

        [self presentViewController:navigation animated:YES completion:^{
            self.isCardFunctionality = YES;
        }];
        
        
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Manual", nil];
//        [actionSheet showInView:[GlobalManager getAppDelegateInstance].window];
    }
    [self.btnAdd setTag:0];//IT SHOULD BE ZERO
}

#pragma mark - UIActionSheetDelegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)//Camera
    {
        self.isCardFunctionality = YES;
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusDenied){
            
            
            [UIAlertView showConfirmationDialogWithTitle:APPNAME message:@"Camera permission is disabled Please allow camera permission in settings." firstButtonTitle:@"Cancel" secondButtonTitle:@"Settings" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url];
                }
                return;
            }];

            return;
        }
        
        CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
        [scanViewController setDisableManualEntryButtons:YES];
        [scanViewController setCollectPostalCode:YES];
        [scanViewController setHideCardIOLogo:YES];
        [self presentViewController:scanViewController animated:YES completion:nil];
    }
    else if(buttonIndex == 1)//Manual
    {
        AddCardViewController *addViewController = [[AddCardViewController alloc] initWithNibName:@"AddCardViewController" bundle:nil];
        [addViewController setCardListDelegate:self];
        UINavigationController *navigation  = [[UINavigationController alloc] initWithRootViewController:addViewController];
        [self presentViewController:navigation animated:YES completion:^{
            self.isCardFunctionality = YES;
        }];
    }
    else
    {}
}

#pragma mark - ScannerViewControllerDelegate Methods

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController
{
    NSLog(@"User canceled payment info");
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController
{
    //NSLog(@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@", info.redactedCardNumber, (unsigned long)info.expiryMonth, (unsigned long)info.expiryYear, info.cvv);
    NSMutableString *cardNumber = [NSMutableString stringWithString:info.cardNumber];
    [cardNumber insertString:@" " atIndex:4];
    [cardNumber insertString:@" " atIndex:9];
    [cardNumber insertString:@" " atIndex:14];
    NSString *expYear = [NSString stringWithFormat:@"%02lu/%lu", (unsigned long)info.expiryMonth, (unsigned long)info.expiryYear%100];
    NSLog(@"%@", expYear);
    NSDictionary *params = @{@"vCardNumber" : cardNumber, @"vExpireMonth" : expYear, @"vCVVNumber" : info.cvv, @"vPostalCode" : info.postalCode};
    
    [scanViewController dismissViewControllerAnimated:YES completion:nil];

    AddCardViewController *addViewController = [[AddCardViewController alloc] initWithNibName:@"AddCardViewController" bundle:nil];
    [addViewController setCardListDelegate:self];
    [addViewController setIsFromScanner:YES];
    [addViewController setDictCardDetails:[NSDictionary dictionaryWithDictionary:params]];
    UINavigationController *navigation  = [[UINavigationController alloc] initWithRootViewController:addViewController];
    [self presentViewController:navigation animated:YES completion:^{
        self.isCardFunctionality = YES;
    }];
}

#pragma mark - UITableViewDataSource Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayCards count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardsCell *cell=[self.tblCardsView dequeueReusableCellWithIdentifier:@"CardsCell"];
    NSDictionary *dict = [self.arrayCards objectAtIndex:indexPath.row];
    if(indexPath.row == 0)
        [cell.btnCheckMark setSelected:NO];
    cell.lblEndingNumber.text=[dict objectForKey:@"card_number"];
    cell.lblCardsEnd.tag=100;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.isFromProfile)
    {
        OrderSummaryViewController *objOrderSummaryVC = [[OrderSummaryViewController alloc] initWithNibName:@"OrderSummaryViewController" bundle:nil];
        [objOrderSummaryVC setDictCardDetails:[NSDictionary dictionaryWithDictionary:[self.arrayCards objectAtIndex:indexPath.row]]];
        [self.navigationController pushViewController:objOrderSummaryVC animated:YES];
    }
    else{/*No Action*/}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (self.arrayCards.count == 1)
        {
            [UIAlertView showErrorWithMessage:@"There should be at least one card to process your order. Please add new card to remove this card." myTag:1 handler:nil];
        }
        else
        {
            [UIAlertView showConfirmationDialogWithTitle:APPNAME message:@"Are you sure you want to delete this card?" firstButtonTitle:@"Yes" secondButtonTitle:@"No" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                if(buttonIndex == 0)
                {
                    [self callDeleteCardWS:indexPath.row];
                }
                else{}
            }];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - WebService methods

-(void)callCardListWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    [self.objWSHelper setServiceName:@"CARD_LIST"];
    NSDictionary *params = @{@"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID]};
    [self.objWSHelper sendRequestWithURL:[WS_Urls getCardListURL:params]];
}

-(void)callDeleteCardWS:(NSInteger)index
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    [self.objWSHelper setServiceName:@"DELETE_CARD"];
    NSDictionary *params = @{@"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID], @"card_token" : [[self.arrayCards objectAtIndex:index] objectForKey:@"card_token"]};
    [self.objWSHelper setTagNumber:index];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getDeleteCardURL:params]];
}

#pragma mark - ParseWSDelegate methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if(!response)
    {
        return;
    }
    
    NSMutableDictionary *dictResults = (NSMutableDictionary *)response;
    if([helper.serviceName isEqualToString:@"CARD_LIST"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            self.arrayCards = [NSMutableArray arrayWithArray:[dictResults objectForKey:@"data"]];
            [self.labelNoRecords setHidden:[self.arrayCards count]];
            [self.btnAdd setTag:0];
            
            [self removeBackButton];
            self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"arrow_white"];
            
            self.navigationItem.leftBarButtonItem = [GlobalManager getnavigationLeftButtonWithTarget:self :@""];
            [self.navigationItem.leftBarButtonItem setEnabled:NO];
            
            [self.tblCardsView reloadData];
            if (!self.isFromProfile && self.isFromOrderDetails)
            {
                if (self.arrayCards.count)
                {
                    [self setBackButton];
                    OrderSummaryViewController *objOrderSummaryVC = [[OrderSummaryViewController alloc] initWithNibName:@"OrderSummaryViewController" bundle:nil];
                    [objOrderSummaryVC setDictCardDetails:[NSDictionary dictionaryWithDictionary:[self.arrayCards firstObject]]];
                    [self.navigationController pushViewController:objOrderSummaryVC animated:YES];
                    return;
                }
            }
        }
        else
        {
            self.arrayCards = [NSMutableArray array];
            [self.labelNoRecords setHidden:[self.arrayCards count]];
            [self setBackButton];
            
            self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@""];
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
            
            if (!self.isFromProfile)
            {
                self.isFromOrderDetails = YES;
            }
            else
            {
                self.isFromOrderDetails = NO;
            }
//            [self.btnAdd setTag:999];//DIRECT OPENS CAMERA WHEN NO CARDS ARE FOUND;
//            [self performSelector:@selector(btnAddCardsClicked:) withObject:self.btnAdd afterDelay:0.2];
        }
    }
    else if([helper.serviceName isEqualToString:@"DELETE_CARD"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            [self.arrayCards removeObjectAtIndex:helper.tagNumber];
            [self.tblCardsView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:helper.tagNumber inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            
            [self.labelNoRecords setHidden:[self.arrayCards count]];
            
            if(![self.arrayCards count])
            {
//                [self.btnAdd setTag:999];//DIRECT OPENS CAMERA WHEN NO CARDS ARE FOUND;
                [self setBackButton];
                
                self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@""];
                [self.navigationItem.rightBarButtonItem setEnabled:NO];

//                [self performSelector:@selector(btnAddCardsClicked:) withObject:self.btnAdd afterDelay:0.2];
            }
            else
            {
                [self.btnAdd setTag:0];
            }
            
            if (!self.isFromProfile) {
                self.isFromOrderDetails = YES;
            }
            [self callCardListWS];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else
    {
        [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
        return;
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@""];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self setBackButton];

    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

#pragma mark - StripCardDelegate methods

-(void)stripCardAddedSuccessfully
{
    self.isCardFunctionality = NO;
    [UIAlertView showWithTitle:APPNAME message:@"Card added successfully" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         [self.navigationController dismissViewControllerAnimated:YES completion:^{
             
             if(!self.isCardFunctionality)
             {
                 self.isFromOrderDetails = YES;
                [self callCardListWS];
                 
                 return;
             }
             else
                 self.isCardFunctionality = NO;
             
         }];
     }];
    
}

@end
