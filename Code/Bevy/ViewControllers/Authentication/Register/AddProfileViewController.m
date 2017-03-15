//
//  AddProfileViewController.m
//  Bevy
//
//  Created by CompanyName on 22/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "AddProfileViewController.h"
#import "MenuViewController.h"
#import "HomeViewController.h"
#import "VerifivationViewController.h"

@interface AddProfileViewController ()
{
    BOOL isFirstTime;
}
@end

@implementation AddProfileViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Profile";
    isFirstTime = YES;
//    [self.view setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
    [self setUpUI];
    
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    
}

-(void)setUpUI
{
    [self.imgCover sd_setImageWithURL:[NSURL URLWithString:[GlobalManager getAppDelegateInstance].coverImage] placeholderImage:[UIImage imageNamed:@"profile_back"]];
    if (self.isFB)
    {
        self.txtEmailID.text = [self.dictDetails valueForKey:@"email"];
        self.txtEmailID.userInteractionEnabled = NO;
        self.txtFirstName.text = [self.dictDetails valueForKey:@"first_name"];
        self.txtLastName.text = [self.dictDetails valueForKey:@"last_name"];
        [self.imgProfile sd_setImageWithURL:[[[self.dictDetails valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"] placeholderImage:[UIImage imageNamed:@"listview_placeholder"]];
    }
    self.imgProfile.layer.cornerRadius=40;
    self.imgProfile.clipsToBounds=YES;
    self.imgProfile.layer.borderWidth=3.0f;
    self.imgProfile.layer.borderColor = BasicAppTheme_CgColor;
    self.txtPhoneNumber.inputAccessoryView  = [self addToolBar];
//    self.txtPostCode.inputAccessoryView  = [self addToolBar];

//    self.txtPhoneNumber.layer.borderWidth = 1.0;
//    self.txtPhoneNumber.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    [self.btnBirthday setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    if([self.dictDetails objectForKey:@"email"])
    {
        [self.txtEmailID setText:[self.dictDetails objectForKey:@"email"]];
    }
    dateLimit = [GlobalManager getDateFromBefore18Years];
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Add Profile Screen"];
}

#pragma mark - Instance Methods

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
    self.txtPhoneNumber.inputAccessoryView = toolbar;
    return toolbar;
}

-(void)doneButtonClicked
{
    [self.txtPhoneNumber endEditing:YES];
//    [self.txtPostCode endEditing:YES];
}

#pragma mark - IBAction Methods

-(IBAction)btnChangeImageClick:(id)sender
{
    [self.view endEditing:YES];
    UIActionSheet *objActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use camera", @"Choose existing", nil];
    objActionSheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    [objActionSheet showInView:self.view];
}

-(NSString *) getFormattedStringFrom:(NSString *) strFormat fromFormat:(NSString *) fromFormat toFormat:(NSString *) toFormat{
    if (!strFormat) {
        return @"";
    }
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fromFormat];
    NSDate *dateobj =[dateFormatter dateFromString:strFormat];
    if (!dateobj) {
        return @"";
    }
    [dateFormatter setDateFormat:toFormat];
    
    return [dateFormatter stringFromDate:dateobj];
}

-(IBAction)btnDateOfBirthClicked:(UIButton*)sender
{
    [self.view endEditing:YES];
    if (!self.objDatePicker)
    {
        self.objDatePicker = [[UIDateTimePicker alloc] init];
        self.objDatePicker.delegate = self;
    }
    
    if (isFirstTime) {
        
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *yearsComponents = [[NSDateComponents alloc] init];
        [yearsComponents setYear:-19];
        NSDate *date = [gregorian dateByAddingComponents:yearsComponents toDate:today options:0];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        NSLog(@"String %@",dateString);
        NSString *stringFinal = [self getFormattedStringFrom:dateString fromFormat:@"dd-MM-yyyy HH:mm:ss" toFormat:@"MM/dd/yyyy"];
        
        [self.btnBirthday setTitle:stringFinal forState:UIControlStateNormal];
    }
    if (!(IS_IPHONE_6 || IS_IPHONE_6_PLUS))
        [self.objScroll setContentOffset:CGPointMake(0,130) animated:YES];
    
    [self.objDatePicker initWithDatePicker:CGRectMake(0,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 260) inView:self.view ContentSize:CGSizeMake([GlobalManager getAppDelegateInstance].window.frame.size.width, 216) pickerSize:CGRectMake(0, 20, [GlobalManager getAppDelegateInstance].window.frame.size.width, 216) pickerMode:UIDatePickerModeDate dateFormat:@"MM/dd/yyyy" minimumDate:nil maxDate:dateLimit setCurrentDate:
     [NSDate date] Recevier:(UIButton*)sender barStyle:UIBarStyleDefault toolBartitle:@"Select Birthdate" textColor:[UIColor whiteColor]];
}


- (IBAction)btnCountryCodeClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (![self.aryCountryCode count]) {
        [self callCountryListWs];
    }
    else
    {
        if (IS_IPHONE_4)
            [self.objScroll setContentOffset:CGPointMake(0,140) animated:YES];
    }
    
    if (!self.objCodePicker)
    {
        self.objCodePicker = [[UICustomPicker alloc] init];
        self.objCodePicker.delegate = self;
    }
    
    [self.objCodePicker initWithCustomPicker:CGRectMake(0,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 260) inView:self.view ContentSize:CGSizeMake([GlobalManager getAppDelegateInstance].window.frame.size.width, 216) pickerSize:CGRectMake(0, 20, [GlobalManager getAppDelegateInstance].window.frame.size.width, 216) barStyle:UIBarStyleBlack Recevier:sender componentArray:self.aryCountryCode toolBartitle:@"Select Country Code" textColor:[UIColor whiteColor] needToSort:NO withDictKey:@"countryNameAndId"];
}

-(IBAction)btnSubmitclicked:(id)sender
{
    [self.view endEditing:YES];
    NSString *strError;
    
    if([self.txtFirstName.text length]==0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter first name" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtFirstName becomeFirstResponder];
        }];
    }else  if([self.txtLastName.text length]==0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter last name" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtLastName becomeFirstResponder];
        }];
   }
//        else if (![Validations validateEmail:self.txtEmailID.text error:&strError])
//    {
//        [UIAlertView showWithTitle:APPNAME message:strError handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            [self.txtEmailID becomeFirstResponder];
//        }];
//    }
    else if ([self.btnCountryCode.titleLabel.text length]==1)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter country code" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
    }
    else if ([self.txtPhoneNumber.text length]==0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter phone number" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPhoneNumber becomeFirstResponder];
        }];
    }
//    else if ([self.txtPostCode.text length]==0)
//    {
//        [UIAlertView showWithTitle:APPNAME message:@"Please enter post code" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            [self.txtPostCode becomeFirstResponder];
//        }];
//    }
    else if (![Validations validatePhone:[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text,self.txtPhoneNumber.text]])
    {//@"Please enter 10-11 digits phone number"
        [UIAlertView showWithTitle:APPNAME message:@"Please enter phone number in international format" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPhoneNumber becomeFirstResponder];
        }];
    }
    else if ([self.btnBirthday.titleLabel.text isEqualToString:@"Birth date"] )
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please select birthday" handler:nil];
    }
    else
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        
        NSDate *birthdate = [formatter dateFromString:self.btnBirthday.titleLabel.text];
        if (![@"Birth date" isEqualToString:self.btnBirthday.titleLabel.text] &&[GlobalManager getAgeFromDate:birthdate] < 18)
        {
            [UIAlertView showWithTitle:APPNAME message:@"Age should be greater than 18 years" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self.btnBirthday becomeFirstResponder];
            }];
            return;
        }
        else
        {
            NSString *firstChar = [self.txtPhoneNumber.text substringToIndex:1];
            if ([firstChar isEqualToString:@"0"]) {
                NSString *newStr = [self.txtPhoneNumber.text substringWithRange:NSMakeRange(1, [self.txtPhoneNumber.text length]-1)];
                self.txtPhoneNumber.text = newStr;
            }
                [self callProfileWS];
                return;
        }
    }
}

-(void)callFacebookLoginWS
{
    if(self.imageSelected == nil)
        [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    else
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
        [hud setLabelText:@"Please wait"];
        [hud setMode:MBProgressHUDModeAnnularDeterminate];
        [hud setDimBackground:YES];
    }
    
    self.imageSelected = self.imgProfile.image;
    NSString *birthDate = @"0000-00-00";
    if(![self.btnBirthday.titleLabel.text isEqualToString:@"Birth date"])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        NSDate *date = [formatter dateFromString:self.btnBirthday.titleLabel.text];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        birthDate = [formatter stringFromDate:date];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[self.dictDetails objectForKey:@"id"] forKey:@"facebook_id"];
    [params setObject: [self.dictDetails valueForKey:@"email"] forKey:@"email_id"];
    [params setObject:self.txtFirstName.text forKey:@"first_name"];
    [params setObject:self.txtLastName.text forKey:@"last_name"];
    
    
    [params setObject:self.txtPhoneNumber.text forKey:@"mobile_no"];
    [params setObject:self.btnCountryCode.titleLabel.text forKey:@"mobile_code"];
    [params setObject:@"Yes" forKey:@"is_new_mobile"];

    
    
//    NSString *strPhone = [NSString stringWithFormat:@"%@%@",self.txtCode.text,self.txtPhoneNumber.text];
//    [params setObject:strPhone forKey:@"mobile_no"];
    [params setObject:birthDate forKey:@"date_of_birth"];
    [params setObject:kDeviceType forKey:@"device_type"];
    [params setObject:([[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN] length])?[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]:@"1111111111" forKey:@"device_token"];
    [self.objWSHelper setServiceName:@"PROFILE"];

    if(self.imageSelected == nil)
    {
        [self.objWSHelper sendRequestWithURL:[WS_Urls getFacebookLoginURL:params]];
    }
    else
    {
        NSData *imageData =  UIImagePNGRepresentation(self.imageSelected);
        [self.objWSHelper sendRequestWithPostURL:[WS_Urls getFacebookLoginURL:nil] andParametrers:params andData:imageData andFileKey:@"profile_image" andExtention:@"png" andMymeTye:@"image/png"];
    }
}

-(void)callProfileWS
{
    if(self.imageSelected == nil)
        [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    else
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
        [hud setLabelText:@"Please wait"];
        [hud setMode:MBProgressHUDModeAnnularDeterminate];
        [hud setDimBackground:YES];
    }
    
    NSString *birthDate = @"0000-00-00";

    if(![self.btnBirthday.titleLabel.text isEqualToString:@"Birth date"])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        NSDate *date = [formatter dateFromString:self.btnBirthday.titleLabel.text];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        birthDate = [formatter stringFromDate:date];
    }
    if(self.isFB)
        self.imageSelected = self.imgProfile.image;

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[self.dictDetails objectForKey:@"userId"] forKey:@"user_id"];
    [params setObject: [self.dictDetails valueForKey:@"email"] forKey:@"email_id"];
    
    self.txtFirstName.text = [self.txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.txtLastName.text = [self.txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [params setObject:self.txtFirstName.text forKey:@"first_name"];
    [params setObject:self.txtLastName.text forKey:@"last_name"];
    [params setObject:@"Yes" forKey:@"is_new_mobile"];

    
//    NSString *strPhone = [NSString stringWithFormat:@"%@%@",self.txtCode.text,self.txtPhoneNumber.text];
    [params setObject:self.txtPhoneNumber.text forKey:@"mobile_no"];
    [params setObject:self.btnCountryCode.titleLabel.text forKey:@"mobile_code"];

    [params setObject:self.txtPostCode.text forKey:@"postcode"];

//    [params setObject:self.txtCode.text forKey:@"mobile_code"];
//    [params setObject:strPhone forKey:@"mobile_no"];
    [params setObject:birthDate forKey:@"date_of_birth"];
    
//    [params setObject:self.txtCode.text forKey:@"country_code"];
    [self.objWSHelper setServiceName:@"PROFILE"];

    if(self.imageSelected == nil)
    {
        [self.objWSHelper sendRequestWithURL:[WS_Urls getEditProfileURL:params]];
    }
    else
    {
        NSData *imageData =  UIImagePNGRepresentation(self.imageSelected);
        [self.objWSHelper sendRequestWithPostURL:[WS_Urls getEditProfileURL:params] andParametrers:nil andData:imageData andFileKey:@"profile_image" andExtention:@"png" andMymeTye:@"image/png"];
    }
}

#pragma mark - CustomPickerDelegate Methods



-(void)pickerDoneClicked:(NSString*)doneValue withType:(NSString *)picker_type andSender:(UIButton *)sender
{
    [self.objScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}
-(void)pickerCancelClicked:(NSString*)doneValue withType:(NSString *)picker_type andSender:(UIButton *)sender
{
    [self.objScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([self.txtLastName isEqual:textField])
        [self.txtPhoneNumber becomeFirstResponder];
    else if([self.txtPostCode isEqual:textField])
        [self.txtPostCode resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   //
{

    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

#pragma mark - CustomDateTimePickerDelegate Methods

-(void)pickerDoneWithDate:(NSDate *)doneDate
{
    isFirstTime = NO;
    [self.btnBirthday setSelected:YES];
    [self.btnBirthday setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.objScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)cancel_clicked:(id)sender
{
    if (isFirstTime) {
        [self.btnBirthday setTitle:@"Birth date" forState:UIControlStateNormal];
    }
    [self.objScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.btnBirthday.titleLabel.text isEqualToString:@"Birth date"]?[self.btnBirthday setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal]:[self.btnBirthday setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        // From Gallery
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self performSelector:@selector(openPicker:) withObject:imagePicker afterDelay:0.1];
        }
    }
    else if (buttonIndex == 0)
    {
        // Use Camera
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self performSelector:@selector(openPicker:) withObject:imagePicker afterDelay:0.1];
        }
        else
        {
            [UIAlertView showWarningWithMessage:@"Your device don't have camera" handler:nil];
        }
    }
}

-(void) openPicker:(UIImagePickerController *)imagePicker
{
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.imageSelected = [GlobalManager scaleAndRotateImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [self.imgProfile setImage:self.imageSelected];
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.height/2;
    self.imgProfile.clipsToBounds = YES;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


-(void)callCountryListWs
{
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    
    [self.objWSHelper setServiceName:@"COUNTRY_LIST"];
    
    [self.objWSHelper sendRequestWithURL:[WS_Urls getCountryListURL:nil]];
}


#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if (!response) {
        return;
    }
    
  
    if([helper.serviceName isEqualToString:@"PROFILE"])
    {
        if([[[response objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"] || [[[response objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"2"])
        {
            [UIAlertView showWithTitle:APPNAME message:@"Your account has been created successfully. We have sent you an SMS to verify your account" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AUTO_LOGIN];
                 [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:PRODUCT_COUNT];
                 [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:CART_ID];
                 [[NSUserDefaults standardUserDefaults] setObject:@"-99" forKey:REMAINING_ORDERS];
                 [[NSUserDefaults standardUserDefaults] setObject:nil forKey:STORE_ID];
                 [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:DELIVERY_NOTE];
                 
                 [[NSUserDefaults standardUserDefaults] setObject:self.txtPhoneNumber.text forKey:MOBILE_NUMBER];
                 [[NSUserDefaults standardUserDefaults] setObject:self.btnCountryCode.titleLabel.text forKey:MOBILE_CODE];

                 
                 // Saving Mobile number for delivery address screen
//                              NSString *strPhone = [NSString stringWithFormat:@"%@%@",self.txtCode.text,self.txtPhoneNumber.text];
//                              [[NSUserDefaults standardUserDefaults] setObject:strPhone forKey:MOBILE_NUMBER];
                 [[NSUserDefaults standardUserDefaults] setObject:nil forKey:REQUIRED_LOCATION_NAME];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", [GlobalManager getAppDelegateInstance].currentLocation.coordinate.latitude] forKey:REQUIRED_LATITUDE];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", [GlobalManager getAppDelegateInstance].currentLocation.coordinate.longitude] forKey:REQUIRED_LONGITUDE];
                 
                 if([[[response objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
                 {
                     [[NSUserDefaults standardUserDefaults] setObject:[self.dictDetails objectForKey:@"userId"] forKey:USER_ID];
                     [[NSUserDefaults standardUserDefaults] setObject:[self.dictDetails objectForKey:@"email"] forKey:EMAIL_ADDRESS];
                     [[NSUserDefaults standardUserDefaults] setObject:[self.dictDetails objectForKey:@"password"] forKey:PASSWORD];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                 }
                 else
                 {
                     NSDictionary *dictFBDetails = [[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_USER_DETAILS];
                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AUTO_LOGIN];
                     [[NSUserDefaults standardUserDefaults] setObject:[dictFBDetails objectForKey:@"email"] forKey:EMAIL_ADDRESS];
                     [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PASSWORD];
                     [[NSUserDefaults standardUserDefaults] setObject:[self.dictDetails objectForKey:@"userId"] forKey:USER_ID];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                 }
                 
                VerifivationViewController *objVerify = [[VerifivationViewController alloc]init];
                 objVerify.isFromProfile = NO;
                 [self.navigationController pushViewController:objVerify animated:YES];
             }];
        }
        else
        {
            [UIAlertView showWithTitle:kAppTitle message:[[response objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
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
    
    }

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end
