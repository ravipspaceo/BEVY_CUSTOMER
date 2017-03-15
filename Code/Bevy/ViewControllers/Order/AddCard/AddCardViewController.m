//
//  AddCardViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "AddCardViewController.h"
#import "ProductsViewController.h"
#import "OrderSummaryViewController.h"

@interface AddCardViewController ()
{
    BOOL is_valid;
}
@end

@implementation AddCardViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.view setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
    [self.navigationController setNavigationBarHidden:NO];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    
    NSLog(@"%@",[[[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS] valueForKey:@"stripe_public_key"]);
   
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Add Card Screen"];
    [self.btnVerification setEnabled:NO];
    if(self.isFromScanner)
        [self.btnVerification setEnabled:YES];
    [self setUpLayout];
    [self setBackButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(txtFiledbecomeResponder) name:@"textFiledBecomeFirstREsponder" object:nil];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardResign)];
    [self.view addGestureRecognizer:tapGes];
}
-(void)keyboardResign
{
    [self.view endEditing:YES];
}
-(void)btnBackButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)txtFiledbecomeResponder
{
    [self.txtCardName becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    if (IS_IPHONE_4) {
        CGRect imgSSLFrame = self.imgSSL.frame;
        imgSSLFrame.origin.y = 352-8;
        imgSSLFrame.size.width = 70;
        imgSSLFrame.size.height = 70;
        self.imgSSL.frame = imgSSLFrame;
    }
    
    if(self.dictCardDetails !=nil)
    {
        is_valid = YES;
        [self.txtCardName becomeFirstResponder];
        NSString * experyMonth =[self.dictCardDetails objectForKey:@"vExpireMonth"];
        [self.stripeView.paymentView.cardNumberField setText:[self.dictCardDetails objectForKey:@"vCardNumber"]];
        [self.stripeView.paymentView setPlaceholderToCardType];
        [self.stripeView.paymentView.cardExpiryField setText:experyMonth];
        [self.stripeView.paymentView.cardCVCField setText:[self.dictCardDetails objectForKey:@"vCVVNumber"]];
        [self.stripeView.paymentView.cardCVCField setSecureTextEntry:YES];
        [self.stripeView.paymentView.cardADDRESSZip setText:[self.dictCardDetails objectForKey:@"vPostalCode"]];
    }
    else
    {
        [self.stripeView removeFromSuperview];
        self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(2,100,self.view.frame.size.width -30,190) andKey:[[[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS] valueForKey:@"stripe_public_key"]];
        [self.stripeView setDelegate:self];
        [self.view addSubview:self.stripeView];
        [self.view bringSubviewToFront:self.txtCardName];
        [self.view bringSubviewToFront:self.btnVerification];
        [self.view bringSubviewToFront:self.lblSeparator];
    }
    
}

#pragma mark - Instance methods

-(void)setUpLayout
{
    [self.navigationController.navigationItem setHidesBackButton:YES];
    [self.navigationItem setTitle:@"Add Card"];
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans" size:18], NSFontAttributeName, nil]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],NSForegroundColorAttributeName,[GlobalManager fontMuseoSans300:18.0],NSFontAttributeName, nil]];
//    [self setCancelButton:@selector(btnCancelClicked:) withTarget:self];
}

-(void)btnCancelClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBAction Methods

-(IBAction)btnVerificationClicked:(id)sender
{
    [self.view endEditing:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    [self performSelector:@selector(generateTokenFromCard) withObject:nil afterDelay:0.3];
}

- (IBAction)btnScanCardClicked:(id)sender
{
    
    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        [UIAlertView showWithTitle:kAppTitle message:@"Camera not available" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        return;
    }
       
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
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    [self presentViewController:scanViewController animated:YES completion:nil];
    
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
    self.dictCardDetails = [NSDictionary dictionaryWithDictionary:params];

    [scanViewController dismissViewControllerAnimated:YES completion:^{
    }];
    
    
    
//    AddCardViewController *addViewController = [[AddCardViewController alloc] initWithNibName:@"AddCardViewController" bundle:nil];
//    [addViewController setCardListDelegate:self];
//    [addViewController setIsFromScanner:YES];
//    [addViewController setDictCardDetails:[NSDictionary dictionaryWithDictionary:params]];
//    UINavigationController *navigation  = [[UINavigationController alloc] initWithRootViewController:addViewController];
//    [self presentViewController:navigation animated:YES completion:^{
//    }];
}



#pragma mark - StripPayment methods

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    is_valid = valid;
    
    if ([[self.txtCardName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]) {
        [self.btnVerification setEnabled:valid];

    }
}

-(void)generateTokenFromCard
{
    if ([self.txtCardName.text length]) {
        [GlobalManager getAppDelegateInstance].cardHolderName = self.txtCardName.text;
    }
    else{
        [GlobalManager getAppDelegateInstance].cardHolderName = @"";
    }
    [self.stripeView createToken:^(STPToken *token, NSError *error)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error)
        {
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window  animated:YES];
            NSLog(@"createToken Error %@",error);
            
            NSString *strErrorMsg = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            
            if ([strErrorMsg length]) {
                [UIAlertView showWithTitle:APPNAME message:strErrorMsg handler:nil];
            }
            else{
                [UIAlertView showWithTitle:APPNAME message:@"Credit card checking failed" handler:nil];
            }
        }
        else
        {
            [self callAddCardWS:token.tokenId];
        }
    }];
}

//THIS IS FOR PAYMENT... >> NOT USING RIGHT NOW.
- (void)hasToken:(STPToken *)token
{
    NSLog(@"Received token %@", token.tokenId);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://example.com"]];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
       [UIAlertView showWithTitle:APPNAME message:@"Your card was charged successfully" handler:nil];
    }];
}

#pragma mark - textFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.stripeView.paymentView.cardExpiryField becomeFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = textField.text;
    str = [str stringByReplacingCharactersInRange:range withString:string];
    if (str.length>0)
    {
          [self.btnVerification setEnabled:is_valid];
    }
    else
    {
        [self.btnVerification setEnabled:NO];

    }
    return YES;
}

#pragma mark - WebService methods

-(void)callAddCardWS:(NSString *)cardToken
{
    [self.objWSHelper setServiceName:@"ADD_CARD"];
    NSDictionary *params = @{@"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID], @"card_token" : cardToken};
    [self.objWSHelper sendRequestWithURL:[WS_Urls getAddCardURL:params]];
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
    if([helper.serviceName isEqualToString:@"ADD_CARD"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            if(self.cardListDelegate && [self.cardListDelegate respondsToSelector:@selector(stripCardAddedSuccessfully)])
            {
                [self.cardListDelegate stripCardAddedSuccessfully];
            }
            else
            {
                [UIAlertView showWithTitle:APPNAME message:@"Card added successfully" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                 {
                     [self dismissViewControllerAnimated:YES completion:^{
                     }];
                 }];
            }
            return;
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
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end
