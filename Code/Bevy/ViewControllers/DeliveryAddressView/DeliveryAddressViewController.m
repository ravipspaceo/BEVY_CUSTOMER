//
//  DeliveryAddressViewController.m
//  Bevy
//
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "DeliveryAddressViewController.h"
#import "MenuViewController.h"
#import "CheckOutViewController.h"
#import "ListViewController.h"
#import "VerifivationViewController.h"
@interface DeliveryAddressViewController ()

@end

@implementation DeliveryAddressViewController

#pragma mark - View life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Delivery Address";
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [self setBackButton];
    self.storeId = [[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID];
    NSLog(@"%@",self.navigationController.viewControllers);
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LOCATION_NAME]);
    self.txtFlatNumber.inputAccessoryView  = [self addToolBar];
    self.txtAddress.inputAccessoryView  = [self addToolBar];
    self.txtPostCode.inputAccessoryView  = [self addToolBar];
    self.txtContactNumber.inputAccessoryView  = [self addToolBar];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Delivery Address Screen"];
    self.txtAddress.text = self.strAddress;
    self.btnSave.hidden = self.btnShopNow.hidden = YES;
    
    if (self.isFromLocationChange) {
        self.btnSave.hidden = NO;
    }
    else
    {
        self.btnShopNow.hidden = NO;
    }
    [self getPostCodeFromLatLong];
    if (IS_IPHONE_6 || IS_IPHONE_6_PLUS)
    {
        [self.btnShopNow setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, (IS_IPHONE_6 ? -405 : -445))];
    }
}


#pragma mark - ToolBar

-(UIToolbar *)addToolBar
{
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.items = [NSArray arrayWithObjects:
                     [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                     [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked)],
                     nil];
    toolbar.tintColor=[UIColor whiteColor];
    
    [toolbar sizeToFit];
    //    self.txtContactNumber.inputAccessoryView = toolbar;
    return toolbar;
}

-(void)doneButtonClicked
{
    if ([self.txtFlatNumber isFirstResponder]) {
        [self.view endEditing:YES];
    }
    else if ([self.txtAddress isFirstResponder])
    {
        [self.view endEditing:YES];
    }
    else if ([self.txtContactNumber isFirstResponder])
    {
        [self.view endEditing:YES];
        [self.txtContactNumber resignFirstResponder];
    }
    else
    {
        [self.txtPostCode resignFirstResponder];
        if (![self.strPostCode isEqualToString:self.txtPostCode.text]) {
            self.strPostCode = self.txtPostCode.text;
            [self getLatLongFromPostalCode];
        }
    }
    [self.objScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)loadAddress
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    
    for (NSMutableDictionary *dict in [self.dictAddressDetails valueForKey:@"address_components"]) {
        NSArray *array = [NSArray arrayWithArray:[dict valueForKeyPath:@"types"]];
        if ([array containsObject:@"postal_code"]) {
            self.txtPostCode.text = [dict objectForKey:@"long_name"];
            self.strPostCode = [dict objectForKey:@"long_name"];
            break;
        }else{
            self.txtPostCode.text = @"";
            self.strPostCode = @"";
        }
    }
    
    
    self.txtAddress.text = self.strAddress;
    self.txtContactNumber.text = [[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_NUMBER];
    [self.btnCountryCode setTitle:[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_CODE] forState:UIControlStateNormal];
    //    if (![self.txtContactNumber.text length]) {
    [self callPhoneVerificationWS];
    //    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.txtContactNumber) {
        [self.objScrollView setContentOffset:CGPointMake(0, (IS_IPHONE_4)?110:50) animated:YES];
        if (textField == self.txtContactNumber && [self.txtContactNumber.text length]) {
            self.txtContactNumber.text = [self.txtContactNumber.text stringByReplacingOccurrencesOfString:@"(Unverified)" withString:@""];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   //
{
//    if (textField == self.txtContactNumber ) {
//        NSString *str = textField.text;
//        str = [str stringByReplacingCharactersInRange:range withString:string];
//        NSLog(@"%@",str);
//        if ([str isEqualToString:@""]) {
//            return NO;
//        }
//        else
//        {
//            return YES;
//        }
//    }
    return YES;
}

#pragma mark - UITextFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtFlatNumber) {
        [self.txtFlatNumber resignFirstResponder];
        [self.txtAddress becomeFirstResponder];
    }
    else if (textField == self.txtAddress) {
        [self.txtAddress resignFirstResponder];
        [self.txtPostCode becomeFirstResponder];
    }
    else if (textField == self.txtPostCode) {
        [self.txtPostCode resignFirstResponder];
        [self.objScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        if (![self.strPostCode isEqualToString:self.txtPostCode.text]) {
            [self getLatLongFromPostalCode];
        }
    }
    else
    {
        [self.txtContactNumber resignFirstResponder];
        [self.objScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    return YES;
}

#pragma mark - Get Lat Long From Postal Code
-(void)getLatLongFromPostalCode
{
    [self.view endEditing:YES];
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.postcodes.io/postcodes/%@",self.txtPostCode.text];
    
    NSURL *URL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",URL);
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            //            dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            //            });
            NSLog(@"----> Error");
        }
        else{
            
            //            dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            //            });
            
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([[json valueForKey:@"status"] integerValue] == 200) {
                NSLog(@"%@ %@",[[json valueForKey:@"result"]valueForKey:@"longitude"],[[json valueForKey:@"result"]valueForKey:@"latitude"]);
                
                self.strLong = [[json valueForKey:@"result"]valueForKey:@"longitude"];
                self.strLat = [[json valueForKey:@"result"]valueForKey:@"latitude"];
                
                [[NSUserDefaults standardUserDefaults] setObject:self.strLat forKey:REQUIRED_LATITUDE];
                [[NSUserDefaults standardUserDefaults] setObject:self.strLong forKey:REQUIRED_LONGITUDE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self callGetNearStoreWSLatitude:self.strLat longitude:self.strLong];
            }
            else
            {
                
                [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
                [UIAlertView showWithTitle:APPNAME message:[json valueForKey:@"error"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                }];
                
            }
            
            NSLog(@"%@",json);
        }
    }];
}


#pragma mark - Get Postal Code From Lat Long
-(void)getPostCodeFromLatLong
{
    [self.view endEditing:YES];
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@",self.locationLatLon.coordinate.latitude,self.locationLatLon.coordinate.longitude,kGoogleAPIKey];
    
    self.strLat = [NSString stringWithFormat:@"%f",self.locationLatLon.coordinate.latitude];
    self.strLong = [NSString stringWithFormat:@"%f",self.locationLatLon.coordinate.longitude];
    
    NSURL *URL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",URL);
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            //            dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            //            });
            NSLog(@"----> Error");
        }
        else{
            //            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            //            NSLog(@"%@",[json valueForKey:@"results"]);
            
            NSMutableArray *arrayAddress = [[NSMutableArray alloc] initWithArray:[json valueForKey:@"results"]];
            
            for (NSMutableDictionary *dict in arrayAddress) {
                NSArray *array = [NSArray arrayWithArray:[dict valueForKeyPath:@"types"]];
                NSString *strPostalCodeChecking = [array objectAtIndex:0];
                [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
                if ([strPostalCodeChecking isEqualToString:@"postal_code"]) {
                    self.dictAddressDetails = dict;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
                        [self loadAddress];
                    });
                    break;
                }else{
                    if ([strPostalCodeChecking isEqualToString:@"postal_code_prefix"]) {
                        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
                        self.dictAddressDetails = dict;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self loadAddress];
                        });
                        break;
                    }
                }
            }
        }
    }];
}



#pragma mark - Action methods
-(IBAction)btnShopNowClicked:(UIButton*)sender
{
    
    self.txtContactNumber.text = [self.txtContactNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.txtContactNumber.text = [self.txtContactNumber.text stringByReplacingOccurrencesOfString:@"(Unverified)" withString:@""];
    
    if (![self.txtAddress.text length]) {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter address" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            return;
        }];
        return;
    }
    else if (![self.txtPostCode.text length])
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter post code" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            return;
        }];
        return;
    }
    else if (![self.txtContactNumber.text length])
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter contact number" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            return;
        }];
        return;
    }
    else if (![Validations validatePhone:[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text,self.txtContactNumber.text]])
    {//@"Please enter 10-11 digits phone number"
        [UIAlertView showWithTitle:APPNAME message:@"Please enter phone number in international format" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtContactNumber becomeFirstResponder];
        }];
        return;
    }
    else
    {
        [GlobalManager getAppDelegateInstance].dictAddress = [[NSMutableDictionary alloc] init];
        
        NSString *strFlatNumber = ([self.txtFlatNumber.text length])?self.txtFlatNumber.text:@"";
        NSString *strAddress = ([self.txtAddress.text length])?self.txtAddress.text:@"";
        NSString *strPostCode = ([self.txtPostCode.text length])?self.txtPostCode.text:@"";
        NSString *strContactNumber = ([self.txtContactNumber.text length])?[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text, self.txtContactNumber.text]:[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_CODE], [[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_NUMBER]] ;
        
        [[GlobalManager getAppDelegateInstance].dictAddress setObject:strFlatNumber forKey:@"FLAT_NUMBER"];
        [[GlobalManager getAppDelegateInstance].dictAddress setObject:strAddress forKey:@"ADDRESS"];
        [[GlobalManager getAppDelegateInstance].dictAddress setObject:strPostCode forKey:@"POST_CODE"];
        [[GlobalManager getAppDelegateInstance].dictAddress setObject:strContactNumber forKey:@"CONTACT_NUMBER"];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@, %@, %@",strFlatNumber,strAddress,strPostCode] forKey:REQUIRED_LOCATION_NAME];
        
        if (![self.strPostCode isEqualToString:self.txtPostCode.text] || [self.txtFlatNumber.text length])
        {
            [self callAddFlatNumberWS];
        }
        else
        {
            [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
            MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
            [menuViewcontroller chooseRightPanelIndex:0];
            [menuViewcontroller menuItemHomeClikced:nil];
        }
        
    }
    
}


-(IBAction)btnResendCodeClicked:(id)sender
{
    
    
    
    VerifivationViewController *objVerify = [[VerifivationViewController alloc]init];
    objVerify.isFromProfile = YES;
    [self.navigationController pushViewController:objVerify animated:YES];
    //    self.txtContactNumber.text = [self.txtContactNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //    self.txtContactNumber.text = [self.txtContactNumber.text stringByReplacingOccurrencesOfString:@"(Unverified)" withString:@""];
    //
    //    if (![Validations validatePhone:self.txtContactNumber.text ])
    //    {//@"Please enter 10-11 digits phone number"
    //        [UIAlertView showWithTitle:APPNAME message:@"Please enter phone number in international format" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
    //            [self.txtContactNumber becomeFirstResponder];
    //        }];
    //    }
    //    else
    //    {
    //        [self callResendVerificationWS];
    //    }
}

- (IBAction)btnCountryCodeClicked:(id)sender
{
    
    [self.view endEditing:YES];
    
    if (![self.aryCountryCode count]) {
        [self callCountryListWs];
    }
    else {
        if (IS_IPHONE_4 || IS_IPHONE_5) {
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 110, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
    }
    
    if (!self.objCodePicker)
    {
        self.objCodePicker = [[UICustomPicker alloc] init];
        self.objCodePicker.delegate = self;
    }
    
    //    if (IS_IPHONE_4 ) {
    //        [UIView animateWithDuration:0.3 animations:^{
    //            self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 80, self.view.frame.size.width, self.view.frame.size.height);
    //        }];
    //    }
    
    
    [self.objCodePicker initWithCustomPicker:CGRectMake(0,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 260) inView:self.view ContentSize:CGSizeMake([GlobalManager getAppDelegateInstance].window.frame.size.width, 216) pickerSize:CGRectMake(0, 20, [GlobalManager getAppDelegateInstance].window.frame.size.width, 216) barStyle:UIBarStyleBlack Recevier:sender componentArray:self.aryCountryCode toolBartitle:@"Select Country Code" textColor:[UIColor whiteColor] needToSort:NO withDictKey:@"countryNameAndId"];
    
}

#pragma mark - CustomPickerDelegate Methods



-(void)pickerDoneClicked:(NSString*)doneValue withType:(NSString *)picker_type andSender:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
-(void)pickerCancelClicked:(NSString*)doneValue withType:(NSString *)picker_type andSender:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height);
    }];
}



-(IBAction)btnSaveClicked:(UIButton*)sender
{
    
    self.txtContactNumber.text = [self.txtContactNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.txtContactNumber.text = [self.txtContactNumber.text stringByReplacingOccurrencesOfString:@"(Unverified)" withString:@""];
    

    if (![self.txtAddress.text length]) {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter address" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            return;
        }];
        return;
    }
    else if (![self.txtPostCode.text length])
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter post code" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            return;
        }];
        return;
    }
    else if (![self.txtContactNumber.text length])
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter contact number" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            return;
        }];
        return;
    }
    else if (![Validations validatePhone:[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text,self.txtContactNumber.text]])
    {//@"Please enter 10-11 digits phone number"
        [UIAlertView showWithTitle:APPNAME message:@"Please enter phone number in international format" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtContactNumber becomeFirstResponder];
        }];
        return;
    }
    
    else
    {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:STORE_OPEN_STATUS] isEqualToString:STORE_CLOSE]) {
//            [UIAlertView showWithTitle:APPNAME message:[[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                return;
//            }];
            
            
            [UIAlertView showWithTitle:[[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE_TITLE] message:[[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
            
            return;
        }
        
        [GlobalManager getAppDelegateInstance].dictAddress = [[NSMutableDictionary alloc] init];
        
        NSString *strFlatNumber = ([self.txtFlatNumber.text length])?self.txtFlatNumber.text:@"";
        NSString *strAddress = ([self.txtAddress.text length])?self.txtAddress.text:@"";
        NSString *strPostCode = ([self.txtPostCode.text length])?self.txtPostCode.text:@"";
        NSString *strContactNumber = ([self.txtContactNumber.text length])?[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text, self.txtContactNumber.text]:[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_CODE], [[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_NUMBER]] ;
        
        [[GlobalManager getAppDelegateInstance].dictAddress setObject:strFlatNumber forKey:@"FLAT_NUMBER"];
        [[GlobalManager getAppDelegateInstance].dictAddress setObject:strAddress forKey:@"ADDRESS"];
        [[GlobalManager getAppDelegateInstance].dictAddress setObject:strPostCode forKey:@"POST_CODE"];
        [[GlobalManager getAppDelegateInstance].dictAddress setObject:strContactNumber forKey:@"CONTACT_NUMBER"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@, %@, %@",strFlatNumber,strAddress,strPostCode] forKey:REQUIRED_LOCATION_NAME];
        
        
        [self callChangeCartAddressWSLatitude:self.strLat longitude:self.strLong];
        
    }
}


-(void)popToCheckOutScreen
{
    UINavigationController *navController = (UINavigationController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.centerPanel;
    
    NSLog(@"%@",self.navigationController.viewControllers);
    for(UIViewController *viewController in [navController viewControllers])
    {
        
        if([viewController isKindOfClass:[CheckOutViewController class]])
        {
            [navController popToViewController:viewController animated:YES];
            return;
        }
        //new change
        else if ([viewController isKindOfClass:[HomeViewController class]]&& [[self.navigationController.viewControllers objectAtIndex:0] isKindOfClass:[HomeViewController class]])
        {
            //            ListViewController *listVC = [[ListViewController alloc] init];
            UINavigationController *obj = [[UINavigationController alloc] initWithRootViewController:[[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil]];
            obj.navigationBar.translucent = NO;
            self.sidePanelController.centerPanel =obj;
            //            [self.sidePanelController setCenterPanel:listVC];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - WS Call methods
-(void)callGetNearStoreWSLatitude:(NSString*)latitude longitude:(NSString*)longitude
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    });
    
    NSDictionary *params = @{@"user_lat" : [NSString stringWithFormat:@"%@", latitude], @"user_long" : [NSString stringWithFormat:@"%@", longitude]};
    [self.objWSHelper setServiceName:@"GET_NEAR_STORES"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getNearByStoreURL:params]];
}


-(void)callAddFlatNumberWS
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    });
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:CART_ID] forKey:@"cart_id"];
    
    NSString *strAddress = [NSString stringWithFormat:@"%@\n%@\n%@",self.txtFlatNumber.text,self.txtAddress.text,self.txtPostCode.text];
    
    [params setObject:strAddress forKey:@"delivery_address"];
    
    [params setObject:[NSString stringWithFormat:@"%@",self.strLat] forKey:@"delivery_lat"];
    [params setObject:[NSString stringWithFormat:@"%@",self.strLong] forKey:@"delivery_long"];
    [params setObject:self.storeId forKey:@"store_id"];
    
    [self.objWSHelper setServiceName:@"ADD_FLAT_ADDRESS"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getChangeCartAddress:params]];
}



-(void)callChangeCartAddressWSLatitude:(NSString*)latitude longitude:(NSString*)longitude
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    });
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:CART_ID] forKey:@"cart_id"];
    
    NSString *strAddress = [NSString stringWithFormat:@"%@\n%@\n%@",self.txtFlatNumber.text,self.txtAddress.text,self.txtPostCode.text];
    
    [params setObject:strAddress forKey:@"delivery_address"];
    
    [params setObject:[NSString stringWithFormat:@"%@",latitude] forKey:@"delivery_lat"];
    [params setObject:[NSString stringWithFormat:@"%@",longitude] forKey:@"delivery_long"];
    [params setObject:self.storeId forKey:@"store_id"];
    
    [self.objWSHelper setServiceName:@"CHANGE_CART_ADDRESS"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getChangeCartAddress:params]];
}


-(void)callPhoneVerificationWS
{
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [self.objWSHelper setServiceName:@"PHONE_NUMBER_VERIFICATION"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getPhoneVerificationURL:params]];
}

-(void)callResendVerificationWS
{
    self.txtContactNumber.text = [self.txtContactNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:self.txtContactNumber.text forKey:@"mobile_no"];
    [self.objWSHelper setServiceName:@"RESEND_VERIFICATION"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getEditProfileURL:params]];
}

-(void)callCountryListWs
{
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    
    [self.objWSHelper setServiceName:@"COUNTRY_LIST"];
    
    [self.objWSHelper sendRequestWithURL:[WS_Urls getCountryListURL:nil]];
}



#pragma mark - WS Delegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    NSLog(@"response --- %@", response);
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if(!response)
        return;
    NSDictionary *dictResults = (NSMutableDictionary *)response;
    
    if ([helper.serviceName isEqualToString:@"CHANGE_CART_ADDRESS"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 [[NSUserDefaults standardUserDefaults] setObject:self.storeId forKey:STORE_ID];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",self.locationLatLon.coordinate.latitude] forKey:REQUIRED_LATITUDE];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",self.locationLatLon.coordinate.longitude] forKey:REQUIRED_LONGITUDE];
                 //                 [[NSUserDefaults standardUserDefaults] setObject:self.btnLocationTitle.titleLabel.text forKey:REQUIRED_LOCATION_NAME];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 if(![GlobalManager getAppDelegateInstance].isFromHomeTab)
                 {
                     [self popToCheckOutScreen];
                     
                 }
                 else
                 {
                     
                 }
             }];
        }
        else
        {
            if(![GlobalManager getAppDelegateInstance].isFromHomeTab)
                [self popToCheckOutScreen];
            else
                [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
        }
    }
    else if ([helper.serviceName isEqualToString:@"ADD_FLAT_ADDRESS"])
    {
        [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
        MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
        [menuViewcontroller chooseRightPanelIndex:0];
        [menuViewcontroller menuItemHomeClikced:nil];
    }
    else if ([helper.serviceName isEqualToString:@"PHONE_NUMBER_VERIFICATION"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            NSMutableDictionary *dictPhoneDetails = [[dictResults objectForKey:@"data"] lastObject];
            NSString *strPhone = @"";
            if ([[[dictPhoneDetails objectForKey:@"is_mobile_verified"] uppercaseString] isEqualToString:@"YES"]) {
                self.btnResend.hidden = YES;
                self.strOldPhoneNumber = [dictPhoneDetails objectForKey:@"mobile_no_only"];
                [[NSUserDefaults standardUserDefaults] setObject:self.strOldPhoneNumber forKey:MOBILE_NUMBER];
                [[NSUserDefaults standardUserDefaults] setObject:[dictPhoneDetails objectForKey:@"mobile_code"] forKey:MOBILE_CODE];
                
                strPhone = self.strOldPhoneNumber;
            }
            else
            {
                self.btnResend.hidden = NO;
                
                self.strOldPhoneNumber = [dictPhoneDetails objectForKey:@"mobile_no_only"];
                [[NSUserDefaults standardUserDefaults] setObject:self.strOldPhoneNumber forKey:MOBILE_NUMBER];
                [[NSUserDefaults standardUserDefaults] setObject:[dictPhoneDetails objectForKey:@"mobile_code"] forKey:MOBILE_CODE];
                strPhone = [NSString stringWithFormat:@"%@%@",self.strOldPhoneNumber,@"(Unverified)"];
            }
            [self.txtContactNumber setText:strPhone];
            [self.btnCountryCode setTitle:[dictPhoneDetails objectForKey:@"mobile_code"] forState:UIControlStateNormal];
        }
        else
        {
            
        }
    }
    else if([helper.serviceName isEqualToString:@"COUNTRY_LIST"])
    {
        if([[[response objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            self.aryCountryCode = [[NSMutableArray arrayWithArray:[response objectForKey:@"data"]] mutableCopy];
            for (int i =0; i<self.aryCountryCode.count; i++) {
                NSMutableDictionary *dictData = [[self.aryCountryCode objectAtIndex:i] mutableCopy];
                [dictData setObject:[NSString stringWithFormat:@"(%@)  %@",[[self.aryCountryCode objectAtIndex:i] valueForKey:@"mobile_code"],[[self.aryCountryCode objectAtIndex:i] valueForKey:@"country"]] forKey:@"countryNameAndId"];
                [self.aryCountryCode replaceObjectAtIndex:i withObject:dictData];
            }
            for (int i =0; i<self.aryCountryCode.count; i++)
            {
                if (![[[self.aryCountryCode objectAtIndex:i] valueForKey:@"mobile_code"] length] ) {
                    [self.aryCountryCode removeObjectAtIndex:i];
                    
                }
            }
            [self btnCountryCodeClicked:self.btnCountryCode];
        }
    }
    
    else if([helper.serviceName isEqualToString:@"RESEND_VERIFICATION"])
    {
        [UIAlertView showWithTitle:APPNAME message:[GlobalManager getValurForKey:[dictResults objectForKey:@"settings"] :@"message"] handler:nil];
    }
    else
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:STORE_OPEN forKey:STORE_OPEN_STATUS];
            self.storeId = [[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"store_id"];
            NSLog(@"STORE ID FOUND: %@", self.storeId);
            [[NSUserDefaults standardUserDefaults] setObject:self.storeId forKey:STORE_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSUserDefaults standardUserDefaults] setObject:@"STORE IS OPEN" forKey:STORE_OPEN_CLOSE_MESSAGE];
        }
        else if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"2"])
        {
            self.storeId = [[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"store_id"];
            [[NSUserDefaults standardUserDefaults] setObject:STORE_CLOSE forKey:STORE_OPEN_STATUS];
//            [[NSUserDefaults standardUserDefaults] setObject:[[dictResults objectForKey:@"settings"] valueForKey:@"message"] forKey:STORE_STATUS_MESSAGE];
            
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] valueForKey:@"message_desc"] objectAtIndex:0] forKey:STORE_STATUS_MESSAGE];
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] valueForKey:@"message_title"] objectAtIndex:0] forKey:STORE_STATUS_MESSAGE_TITLE];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.storeId forKey:STORE_ID];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"STORE IS CLOSED" forKey:STORE_OPEN_CLOSE_MESSAGE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
//            [[NSUserDefaults standardUserDefaults] setObject:[[dictResults objectForKey:@"settings"] valueForKey:@"message"] forKey:STORE_STATUS_MESSAGE];
            
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] valueForKey:@"message_desc"] objectAtIndex:0] forKey:STORE_STATUS_MESSAGE];
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] valueForKey:@"message_title"] objectAtIndex:0] forKey:STORE_STATUS_MESSAGE_TITLE];
            
            
            
            [[NSUserDefaults standardUserDefaults] setObject:STORE_CLOSE forKey:STORE_OPEN_STATUS];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:STORE_ID];
            NSLog(@"%@",[[dictResults objectForKey:@"settings"] valueForKey:@"message"]);
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSUserDefaults standardUserDefaults] setObject:@"OUTSIDE DELIVERY ZONE" forKey:STORE_OPEN_CLOSE_MESSAGE];
        }
    }
    
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}


@end
