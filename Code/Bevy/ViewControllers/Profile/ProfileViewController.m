//
//  ProfileViewController.m
//  Bevy
//
//  Created by CompanyName on 12/20/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "ProfileViewController.h"
#import "ChangePasswordViewController.h"
#import "CardsViewController.h"
#import "LoginViewController.h"
#import "VerifivationViewController.h"
#import "MenuViewController.h"

@interface ProfileViewController ()
{
    NSDate *dateLimit;
    NSString *strOldPhoneNumber;
    NSString* str;
}

@end

@implementation ProfileViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
//    [self.view setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
    NSLog(@"%@",self.navigationController.viewControllers);
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setLeftButton];
    [self setUpUI];
    [self.objScroll setContentSize:CGSizeMake(0, CGRectGetMaxY(self.btnLogout.frame))];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Profile Screen"];
    dateLimit = [GlobalManager getDateFromBefore18Years];
    [self.imgCover sd_setImageWithURL:[NSURL URLWithString:[GlobalManager getAppDelegateInstance].coverImage] placeholderImage:[UIImage imageNamed:@"profile_back"]];
    if(!self.isPickerOpened)
    {
        [self callViewProfileWS];
        return;
    }
    else
        self.isPickerOpened = NO;
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}
#pragma mark - Instance methods

-(void)setUpUI
{
    self.title =@"Profile";
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans" size:18],NSFontAttributeName, nil]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],NSForegroundColorAttributeName,[GlobalManager fontMuseoSans300:18.0],NSFontAttributeName, nil]];
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.height/2;
    self.imgProfile.clipsToBounds = YES;
    self.imgProfile.layer.borderWidth=3.0f;
    self.imgProfile.layer.borderColor=BasicAppTheme_CgColor;//[UIColor colorWithRed:69/255.0 green:220/255.0 blue:188/255.0 alpha:1.0].CGColor;
    
    self.txtFirstName.tag=self.txtLasatName.tag=self.txtPhoneNumber.tag=self.txtEmailID.tag=100;
    self.btnChangePassword.tag=self.btnMyCards.tag=self.btnLogout.tag=100;
    self.txtPhoneNumber.inputAccessoryView  = [self addToolBar];
//    self.txtCode.inputAccessoryView  = [self addToolBar];

    
    if (IS_IPHONE_6)
    {
        self.btnChangePassword.imageEdgeInsets = UIEdgeInsetsMake(0,355,0,0);
        self.btnMyCards.imageEdgeInsets = UIEdgeInsetsMake(0,355,0,0);
    }
    else if (IS_IPHONE_6_PLUS)
    {
        self.btnChangePassword.imageEdgeInsets = UIEdgeInsetsMake(0,394,0,0);
        self.btnMyCards.imageEdgeInsets = UIEdgeInsetsMake(0,394,0,0);
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD] == nil)
        [self.btnChangePassword setEnabled:NO];
    
    self.navigationController.navigationBarHidden = YES;
}



-(void)btnMenuClicked
{
    [self.view endEditing:YES];
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

-(void)btnBackClicked:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IBAction Methods

-(IBAction)clickOnChangePwd:(id)sender
{
    [self.view endEditing:YES];
    ChangePasswordViewController *objChangepwd=[[ChangePasswordViewController alloc] init];
    [self.navigationController pushViewController:objChangepwd animated:YES];
}

-(IBAction)clickOnMycards:(id)sender
{
    [self.view endEditing:YES];
    
    CardsViewController *objCardsVC = [[CardsViewController alloc] initWithNibName:@"CardsViewController" bundle:nil];
    objCardsVC.isFromProfile = YES;
    [self.navigationController pushViewController:objCardsVC animated:YES];
}

-(IBAction)doneClicked:(id)sender
{
     str =[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text,self.txtPhoneNumber.text];

    self.txtPhoneNumber.text = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.txtPhoneNumber.text = [self.txtPhoneNumber.text stringByReplacingOccurrencesOfString:@"(Unverified)" withString:@""];
    NSString *strError;
    if([self.txtFirstName.text length]==0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter first name" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtFirstName becomeFirstResponder];
        }];
    }
        else  if([self.txtLasatName.text length]==0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter last name" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtLasatName becomeFirstResponder];
        }];
    }
    else if ([self.txtPhoneNumber.text length]==0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter phone number" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPhoneNumber becomeFirstResponder];
        }];
    }
    else if (![Validations validatePhone:[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text,self.txtPhoneNumber.text]])
    {//@"Please enter 10-11 digits phone number"
        [UIAlertView showWithTitle:APPNAME message:@"Please enter phone number in international format" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPhoneNumber becomeFirstResponder];
        }];
    }
//    else if ([self.txtPostCode.text length]==0)
//    {
//        [UIAlertView showWithTitle:APPNAME message:@"Please enter post code" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            [self.txtPostCode becomeFirstResponder];
//        }];
//    }
    else if ([self.txtPostCode.text length] > 10)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter valid post code " handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPostCode becomeFirstResponder];
        }];
    }
    else if (![Validations validateEmail:self.txtEmailID.text error:&strError])
    {
        [UIAlertView showWithTitle:APPNAME message:strError handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtEmailID becomeFirstResponder];
        }];
    }
    else if ([self.btnBirthday.titleLabel.text isEqualToString:@"Birth date"] )
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please select birthday" handler:nil];
    }
    else
    {
        [self callEditProfileWS];
    }
}

-(IBAction)LogoutClicked:(id)sender
{
    [UIAlertView showConfirmationDialogWithTitle:APPNAME message:@"Are you sure want to logout?" firstButtonTitle:@"Cancel" secondButtonTitle:@"Ok" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex == 1)
         {
             [[NSUserDefaults standardUserDefaults] setBool:NO forKey:STORE_DONT_SHOW_OUTSIDE_ZONE];
             [[NSUserDefaults standardUserDefaults] setBool:NO forKey:STORE_DONT_SHOW_CLOSE];

             [self callMakeCartEmptyWS];
             

         }
         else
             return;
     }];
}
- (IBAction)btnMenuClicked:(id)sender
{
    [self.view endEditing:YES];
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}


-(IBAction)btnResendCodeClicked:(id)sender
{
    
    VerifivationViewController *objVerify = [[VerifivationViewController alloc]init];
    objVerify.isFromProfile = YES;
    [self.navigationController pushViewController:objVerify animated:YES];
    
//    [self.view endEditing:YES];
//    self.txtPhoneNumber.text = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    self.txtPhoneNumber.text = [self.txtPhoneNumber.text stringByReplacingOccurrencesOfString:@"(Unverified)" withString:@""];
//    self.txtPhoneNumber.text = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    if (![Validations validatePhone:[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text,self.txtPhoneNumber.text ]])
//    {//@"Please enter 10-11 digits phone number"
//        [UIAlertView showWithTitle:APPNAME message:@"Please enter phone number in international format" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            [self.txtPhoneNumber becomeFirstResponder];
//        }];
//    }
//    else
//    {
//        [self callResendVerificationWS];
//    }
}




#pragma mark - CustomDatePicker

-(IBAction)btnDateOfBirthClicked:(UIButton*)sender
{
    [self.view endEditing:YES];
    if (!self.objDatePicker)
    {
        self.objDatePicker = [[UIDateTimePicker alloc] init];
        self.objDatePicker.delegate = self;
    }
    if (!(IS_IPHONE_6 || IS_IPHONE_6_PLUS))
        [self.objScroll setContentOffset:CGPointMake(0, 260) animated:YES];
    
    [self.objDatePicker initWithDatePicker:CGRectMake(0,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 432) inView:self.view ContentSize:CGSizeMake([GlobalManager getAppDelegateInstance].window.frame.size.width, 216) pickerSize:CGRectMake(0, 20, [GlobalManager getAppDelegateInstance].window.frame.size.width, 216) pickerMode:UIDatePickerModeDate dateFormat:@"MM/dd/yyyy" minimumDate:nil maxDate:dateLimit setCurrentDate:
     [NSDate date] Recevier:(UIButton*)sender barStyle:UIBarStyleDefault toolBartitle:@"Select Birthdate" textColor:[UIColor whiteColor]];
}

-(void)pickerDoneWithDate:(NSDate *)doneDate
{
    [self.btnBirthday setSelected:YES];
    [self.objScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)cancel_clicked:(id)sender
{
    [self.objScroll setContentOffset:CGPointMake(0, 0) animated:YES];
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
            [self.objScroll setContentOffset:CGPointMake(0,100) animated:YES];
    }
    
    if (!self.objCodePicker)
    {
        self.objCodePicker = [[UICustomPicker alloc] init];
        self.objCodePicker.delegate = self;
    }
 
    [self.objCodePicker initWithCustomPicker:CGRectMake(0,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 260) inView:self.view ContentSize:CGSizeMake([GlobalManager getAppDelegateInstance].window.frame.size.width, 216) pickerSize:CGRectMake(0, 20, [GlobalManager getAppDelegateInstance].window.frame.size.width, 216) barStyle:UIBarStyleBlack Recevier:sender componentArray:self.aryCountryCode toolBartitle:@"Select Country Code" textColor:[UIColor whiteColor] needToSort:NO withDictKey:@"countryNameAndId"];
   
    
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
    self.txtPhoneNumber.inputAccessoryView = toolbar;
//    self.txtCode.inputAccessoryView = toolbar;

    return toolbar;
}

-(void)doneButtonClicked
{
    [self.txtPhoneNumber endEditing:YES];
//    [self.txtCode endEditing:YES];
    [self.txtEmailID becomeFirstResponder];
}

#pragma mark - UIImagePickerController Methods

-(IBAction)btnChangeImageClick:(id)sender
{
    UIActionSheet *objActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use camera", @"Choose existing", nil];
    objActionSheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    [objActionSheet showInView:self.view];
}

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
    self.isPickerOpened = YES;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.imageSelected = [GlobalManager scaleAndRotateImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [self.imgProfile setImage:self.imageSelected];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([self.txtLasatName isEqual:textField])
        [self.txtPhoneNumber becomeFirstResponder];
    else if([self.txtPostCode isEqual:textField])
        [self.txtPostCode resignFirstResponder];

    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.txtPhoneNumber && [self.txtPhoneNumber.text length]) {
        self.txtPhoneNumber.text = [self.txtPhoneNumber.text stringByReplacingOccurrencesOfString:@"(Unverified)" withString:@""];
        self.txtPhoneNumber.font = [GlobalManager fontMuseoSans100:16];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   //
{
//    if (textField == self.txtPhoneNumber ) {
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
//     if (textField == self.txtCode ) {
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
#pragma mark - WS Calling Methods

-(void)callViewProfileWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    self.objWSHelper.serviceName = @"ViewProfile";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getViewProfileURL:params]];
}

-(void)callEditProfileWS
{
    [self.view endEditing:YES];
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
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    self.txtFirstName.text = [self.txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.txtLasatName.text = [self.txtLasatName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [params setObject:self.txtEmailID.text forKey:@"email_id"];
    [params setObject:self.txtFirstName.text forKey:@"first_name"];
    [params setObject:self.txtLasatName.text forKey:@"last_name"];
    
    if([str isEqualToString: [self.dictProfileDetails valueForKey:@"pending_mobile_no"]])
    {
        [params setObject:@"No" forKey:@"is_new_mobile"];
    }
    else
    {
        [params setObject:@"Yes" forKey:@"is_new_mobile"];

    }
//    NSString *strPhoneNumber = [self.txtPhoneNumber.text stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//    NSString *strPhone = [NSString stringWithFormat:@"%@%@",self.txtCode.text,self.txtPhoneNumber.text];

    [params setObject:self.txtPhoneNumber.text forKey:@"mobile_no"];
    [params setObject:self.btnCountryCode.titleLabel.text forKey:@"mobile_code"];
    [params setObject:self.txtPostCode.text forKey:@"postcode"];

    [params setObject:birthDate forKey:@"date_of_birth"];
    
    [self.objWSHelper setServiceName:@"UPDATE_PROFILE"];
    if(self.imageSelected == nil)
    {
        [self.objWSHelper sendRequestWithURL:[WS_Urls getEditProfileURL:params]];
    }
    else
    {
        NSData *imageData =  UIImagePNGRepresentation(self.imageSelected);
        [self.objWSHelper sendRequestWithPostURL:[WS_Urls getEditProfileURL:nil] andParametrers:params andData:imageData andFileKey:@"profile_image" andExtention:@"png" andMymeTye:@"image/png"];
    }
}

-(void)callMakeCartEmptyWS
{
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    self.objWSHelper.serviceName = @"Make_Cart_Empty";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getMakeCartEmptyURL:params]];
}

-(void)callPhoneVerificationWS
{
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [self.objWSHelper setServiceName:@"PHONE_NUMBER_VERIFICATION"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getPhoneVerificationURL:params]];
//    [self.objWSHelper sendRequestWithPostURL:[WS_Urls getPhoneVerificationURL:nil] andParametrers:params];
}

-(void)callResendVerificationWS
{
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
//    NSString *strPhoneNumber = [self.txtPhoneNumber.text stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [params setObject:self.txtPhoneNumber.text forKey:@"mobile_no"];
    [params setObject:self.btnCountryCode.titleLabel.text forKey:@"mobile_code"];

    [self.objWSHelper setServiceName:@"RESEND_VERIFICATION"];
    
    [self.objWSHelper sendRequestWithURL:[WS_Urls getEditProfileURL:params]];
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
    if (!response)
    {
        return;
    }
    
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if([helper.serviceName isEqualToString:@"ViewProfile"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            self.dictProfileDetails = [NSDictionary dictionaryWithDictionary:[[dictResults objectForKey:@"data"] objectAtIndex:0]];
            
            NSString *dateOfBirth = [self.dictProfileDetails valueForKey:@"date_of_birth"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSDate *date = [NSDate date];
            
            if([dateOfBirth isEqualToString:@"0000-00-00"])
            {
                dateOfBirth = @"Birth date";
            }
            else
            {
                [formatter setDateFormat:@"yyyy-MM-dd"];
                date = [formatter dateFromString:dateOfBirth];
                [formatter setDateFormat:@"MM/dd/yyyy"];
                dateOfBirth = [formatter stringFromDate:date];
            }
            
            NSString *name = [NSString stringWithFormat:@"%@ %@", [self.dictProfileDetails valueForKey:@"first_name"], [self.dictProfileDetails valueForKey:@"last_name"]];
            [self.lblProfileName setText:[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            [self.txtFirstName setText:[self.dictProfileDetails valueForKey:@"first_name"]];
            [self.txtLasatName setText:[self.dictProfileDetails valueForKey:@"last_name"]];
            [self.txtPostCode setText:[self.dictProfileDetails valueForKey:@"post_code"]];

            
            NSString* strng = [self.dictProfileDetails valueForKey:@"pending_mobile_no"];
            NSString* result = strng;
            NSRange replaceRange = [strng rangeOfString:[self.dictProfileDetails valueForKey:@"mobile_code"]];
            if (replaceRange.location != NSNotFound){
                 result = [strng stringByReplacingCharactersInRange:replaceRange withString:@""];
            }
            [self.txtPhoneNumber setText:result];
            
            [self.btnCountryCode setTitle:([[self.dictProfileDetails valueForKey:@"mobile_code"] length]?[self.dictProfileDetails valueForKey:@"mobile_code"] : @"+44") forState:UIControlStateNormal];
            
            strOldPhoneNumber = [self.dictProfileDetails valueForKey:@"mobile_no_only"];
            
            if ([[[self.dictProfileDetails objectForKey:@"is_mobile_verified"] uppercaseString] isEqualToString:@"YES"]) {
                self.btnResend.hidden = YES;
                [[NSUserDefaults standardUserDefaults] setObject:strOldPhoneNumber forKey:MOBILE_NUMBER];
            }
            else
            {
                self.btnResend.hidden = NO;
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_NUMBER] length]) {
                    NSString *strPhone = [NSString stringWithFormat:@"%@%@",strOldPhoneNumber,@"(Unverified)"];
                    [self.txtPhoneNumber setText:strPhone];
                }
                else
                {
//                    NSString *strPhone = @"Unverified Phone No";
                    self.btnResend.hidden = YES;
                    [self.txtPhoneNumber setText:@""];
//                    self.txtPhoneNumber.placeholder = @"Phone number";
                }
                
            }
            
            [self.btnBirthday setTitle:dateOfBirth forState:UIControlStateNormal];
            [self.btnBirthday setTitle:dateOfBirth forState:UIControlStateSelected];
            [self.txtEmailID setText:[self.dictProfileDetails valueForKey:@"email_id"]];

            [self.imgProfile sd_setImageWithURL:[NSURL URLWithString:[self.dictProfileDetails valueForKey:@"profile_image"]]
                              placeholderImage:[UIImage imageNamed:@"listview_placeholder"]];
//            [self callPhoneVerificationWS];
            
            [[NSUserDefaults standardUserDefaults] setObject: [self.dictProfileDetails valueForKey:@"mobile_no_only"] forKey:MOBILE_NUMBER];
            
            [[NSUserDefaults standardUserDefaults] setObject:[self.dictProfileDetails valueForKey:@"mobile_code"] forKey:MOBILE_CODE];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
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

    else if([helper.serviceName isEqualToString:@"UPDATE_PROFILE"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            NSString *name = [NSString stringWithFormat:@"%@ %@", self.txtFirstName.text, self.txtLasatName.text];
            [self.lblProfileName setText:[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            [[NSUserDefaults standardUserDefaults] setObject:self.txtPhoneNumber.text forKey:MOBILE_NUMBER];

            [[NSUserDefaults standardUserDefaults] setObject:self.btnCountryCode.titleLabel.text forKey:MOBILE_CODE];

//            NSString* strng =[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text,self.txtPhoneNumber.text];
            
            if(![str isEqualToString: [self.dictProfileDetails valueForKey:@"pending_mobile_no"]])
            {
                [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    VerifivationViewController *objVerify = [[VerifivationViewController alloc]init];
                    objVerify.isFromProfile = YES;
                    [self.navigationController pushViewController:objVerify animated:YES];
                }];
                return ;

            }
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
                [menuViewcontroller menuItemHomeClikced:nil];
                
            }];
            return;
        }
        else{
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
            return;
        }
        
    }
    else if ([helper.serviceName isEqualToString:@"Make_Cart_Empty"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            for (UIViewController *objVC in [GlobalManager getAppDelegateInstance].objNavController.viewControllers)
            {
                if ([objVC isKindOfClass:[LoginViewController class]])
                {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AUTO_LOGIN];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_ID];
                    [FBSession.activeSession closeAndClearTokenInformation];
                    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:CART_ID];
                    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:PRODUCT_COUNT];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:STORE_ID];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:REQUIRED_LOCATION_NAME];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:REQUIRED_LATITUDE];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[GlobalManager getAppDelegateInstance].objNavController popToViewController:objVC animated:YES];
                    break;
                }
            }
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[GlobalManager getValurForKey:[dictResults objectForKey:@"settings"] :@"message"] handler:nil];
        }
    }
    else if([helper.serviceName isEqualToString:@"PHONE_NUMBER_VERIFICATION"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            NSMutableDictionary *dictPhoneDetails = [[dictResults objectForKey:@"data"] lastObject];
            if ([[[dictPhoneDetails objectForKey:@"is_mobile_verified"] uppercaseString] isEqualToString:@"YES"]) {
                self.btnResend.hidden = YES;
            }
            else
            {
                self.btnResend.hidden = NO;
                strOldPhoneNumber= [self.dictProfileDetails valueForKey:@"mobile_no_only"];
                NSString* result = strOldPhoneNumber;
                NSRange replaceRange = [strOldPhoneNumber rangeOfString:[self.dictProfileDetails valueForKey:@"mobile_code"]];
                if (replaceRange.location != NSNotFound){
                    result = [strOldPhoneNumber stringByReplacingCharactersInRange:replaceRange withString:@""];
                }
                [self.btnCountryCode setTitle:[self.dictProfileDetails valueForKey:@"mobile_code"] forState:UIControlStateNormal];
                [[NSUserDefaults standardUserDefaults] setObject:strOldPhoneNumber forKey:MOBILE_NUMBER];
                NSString *strPhone = [NSString stringWithFormat:@"%@%@",result,@"(Unverified)"];
                [self.txtPhoneNumber setText:strPhone];
                self.txtPhoneNumber.adjustsFontSizeToFitWidth = YES;
            }
            
        }
        else
        {
            
        }
    }
    else if([helper.serviceName isEqualToString:@"RESEND_VERIFICATION"])
    {
        [UIAlertView showWithTitle:APPNAME message:[GlobalManager getValurForKey:[dictResults objectForKey:@"settings"] :@"message"] handler:nil];
    }
    else
    {
        [UIAlertView showWithTitle:APPNAME message:[GlobalManager getValurForKey:[dictResults objectForKey:@"settings"] :@"message"] handler:nil];
        return;
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}


@end
