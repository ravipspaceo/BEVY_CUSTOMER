//
//  ChangePhoneNumberViewController.m
//  Bevy
//
//  Copyright © 2016 com.companyname. All rights reserved.
//

#import "ChangePhoneNumberViewController.h"

@interface ChangePhoneNumberViewController ()

@end

@implementation ChangePhoneNumberViewController

- (void)viewDidLoad {
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
        [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.title = @"Change Phone Number";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],NSForegroundColorAttributeName,[GlobalManager fontMuseoSans300:18.0],NSFontAttributeName, nil]];
    self.txtPhoneNumber.inputAccessoryView  = [self addToolBar];
    [self setBackButton];
    
    self.txtPhoneNumber.text = [[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_NUMBER];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_CODE] length]) {
            [self.btnCountryCode setTitle:[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_CODE] forState:UIControlStateNormal];
    }
    else
    {
           [self.btnCountryCode setTitle:@"+44" forState:UIControlStateNormal];
    }


}

-(void)btnBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [GlobalManager getAppDelegateInstance].isNumber_Changed = NO;
}

-(void)viewWillDisappear:(BOOL)animated

{
    self.navigationController.navigationBarHidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnSaveClicked:(id)sender
{
    [self.view endEditing:YES];

    self.txtPhoneNumber.text = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.txtPhoneNumber.text = [self.txtPhoneNumber.text stringByReplacingOccurrencesOfString:@"(Unverified)" withString:@""];
    if ([self.txtPhoneNumber.text length]==0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter phone number" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPhoneNumber becomeFirstResponder];
        }];
    }
    else if (![Validations validatePhone:[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text,self.txtPhoneNumber.text]])
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter phone number in international format" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPhoneNumber becomeFirstResponder];
        }];
    }
    else
    {
        [self callEditProfileWs];
    }
}
- (IBAction)btnCountryCodeClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (![self.aryCountryCode count]) {
        [self callCountryListWs];
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
}
-(void)pickerCancelClicked:(NSString*)doneValue withType:(NSString *)picker_type andSender:(UIButton *)sender
{
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


-(void)callEditProfileWs
{
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    //    NSString *strPhoneNumber = [self.txtPhoneNumber.text stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [params setObject:self.txtPhoneNumber.text forKey:@"mobile_no"];
    [params setObject:self.btnCountryCode.titleLabel.text forKey:@"mobile_code"];
    
    NSString* str =[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text,self.txtPhoneNumber.text];
    NSString *oldStr =  [NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_CODE],[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_NUMBER]];
    
    
    if([str isEqualToString: oldStr])
    {
        [params setObject:@"No" forKey:@"is_new_mobile"];
        [GlobalManager getAppDelegateInstance].isNumber_Changed = NO;
    }
    else
    {
        [params setObject:@"Yes" forKey:@"is_new_mobile"];
        [GlobalManager getAppDelegateInstance].isNumber_Changed = YES;
    }
    [self.objWSHelper setServiceName:@"EDIT_PROFILE"];
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
    if([helper.serviceName isEqualToString:@"EDIT_PROFILE"])
    {
        
        
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.txtPhoneNumber.text forKey:MOBILE_NUMBER];
            [[NSUserDefaults standardUserDefaults] setObject:self.btnCountryCode.titleLabel.text forKey:MOBILE_CODE];

             [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 [self.navigationController popViewControllerAnimated:YES];
             }];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
