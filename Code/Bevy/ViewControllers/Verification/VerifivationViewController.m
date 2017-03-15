 //
//  VerifivationViewController.m
//  Bevy
//
//  Copyright © 2016 com.companyname. All rights reserved.
//

#import "VerifivationViewController.h"
#import "ChangePhoneNumberViewController.h"
#import "MenuViewController.h"

@interface VerifivationViewController ()<LTLinkTextViewDelegate,ParseWSDelegate>
{
    NSString *phoneNumber;
}

@end

@implementation VerifivationViewController

- (void)viewDidLoad {
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    
    self.viewAnimate.frame = CGRectMake(self.viewAnimate.frame.origin.x, self.viewAnimate.frame.origin.y+(IS_IPHONE_6_PLUS? 95: IS_IPHONE_6? 50:  0), self.viewAnimate.frame.size.width, self.viewAnimate.frame.size.height);
    self.btnResendPin.hidden = YES;
    [self performSelector:@selector(unhideResendButton) withObject:nil afterDelay:420.0];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(void)unhideResendButton
{
    self.btnResendPin.hidden = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([GlobalManager getAppDelegateInstance].isNumber_Changed) {
        self.btnResendPin.hidden = YES;
        [self performSelector:@selector(unhideResendButton) withObject:nil afterDelay:420.0];
    }
    
    self.navigationController.navigationBarHidden = YES;
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_CODE] length])
    {
        phoneNumber = [NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_CODE],[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_NUMBER]];
    }
    else
    {
         phoneNumber = [NSString stringWithFormat:@"%@%@",@"+44",[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_NUMBER]];
    }
//    phoneNumber = @"123456789";
    if (!self.isFromProfile) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Verification_Incomplete"];
        self.btnback.hidden = YES;

    }
    else
    {
        self.btnback.hidden = NO;
    }
    [self setupUI];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    self.navigationController.navigationBarHidden = NO;
}
-(void)setupUI
{
    self.btnResendPin.layer.cornerRadius = self.btnResendPin.frame.size.height/2;
    self.btnResendPin.layer.borderWidth = 1.0;
    self.btnResendPin.layer.borderColor = BasicAppTheme_CgColor;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    
    NSString *text = [NSString stringWithFormat:@"Enter the verification code we sent to \n%@ Edit Number",phoneNumber];
    
    NSDictionary *textAttributes = @{LTTextStringParameterKey : NSLocalizedString(text, @""),
                                     NSFontAttributeName : [GlobalManager fontMuseoSans300:17.0], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName :BasicAppThemeColor};
    
    NSArray *buttonsAttributes = @[@{LTTextStringParameterKey : NSLocalizedString(@"Edit Number", @""),NSFontAttributeName : [GlobalManager fontMuseoSans300:17.0],
                                     NSForegroundColorAttributeName : [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0], NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}
                                   ];
    
    [self.lblPhoneView setStringAttributes:textAttributes withButtonsStringsAttributes:buttonsAttributes];
    self.lblPhoneView.delegate = self;
    self.txtverificationCode.inputAccessoryView = [self addToolBar];
    [self.txtverificationCode setTextAlignment:NSTextAlignmentCenter];
    self.txtverificationCode.font = [GlobalManager fontMuseoSans500:24];
    

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return toolbar;
}

-(void)doneButtonClicked
{
    [self.txtverificationCode endEditing:YES];
    [self animationToView: 0];
    
}

-(void)animationToView : (CGFloat)y
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, y, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
#pragma mark - LTLinkTextViewDelegate
- (void)linkTextView:(LTLinkTextView*)termsTextView didSelectButtonWithIndex:(NSUInteger)buttonIndex title:(NSString*)title
{
    
    ChangePhoneNumberViewController *objPhone = [[ChangePhoneNumberViewController alloc]init];
    [self.navigationController pushViewController:objPhone animated:YES];
}
- (IBAction)btnSubmitClicked:(id)sender
{
    [self.view endEditing:YES];
    if ([self.txtverificationCode.text isEqualToString:@""]) {
        [UIAlertView showWarningWithMessage:@"Please Enter Verification Code" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtverificationCode becomeFirstResponder];
        }];
    }
    else
    {
        [self callSendVerificationCodeWS];
    }
}

- (IBAction)btnResendPinClicked:(id)sender
{
    [self.view endEditing:YES];

    [self callResendVerificationWS];
}

- (IBAction)btnBackClicked:(id)sender
{
    [self.view endEditing:YES];

    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnEditNumberCliucked:(id)sender
{
    ChangePhoneNumberViewController *objPhone = [[ChangePhoneNumberViewController alloc]init];
    [self.navigationController pushViewController:objPhone animated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(IS_IPHONE_4)
    {
        [self animationToView: -100];
    }
    return YES;
}


-(void)callResendVerificationWS
{
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_NUMBER] forKey:@"mobile_no"];
    [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:MOBILE_CODE] forKey:@"mobile_code"];
    [params setObject:@"Yes" forKey:@"is_new_mobile"];
    [self.objWSHelper setServiceName:@"RESEND_VERIFICATION"];
    
    [self.objWSHelper sendRequestWithURL:[WS_Urls getEditProfileURL:params]];
}

-(void)callSendVerificationCodeWS
{
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:self.txtverificationCode.text forKey:@"verify_pin"];
    [self.objWSHelper setServiceName:@"VERIFICATION"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getMobileNumberVerificationURL:params]];


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
    
    if([helper.serviceName isEqualToString:@"VERIFICATION"]) {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Verification_Incomplete"];

            if (self.isFromProfile) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                self.objSidePanelviewController =[GlobalManager getAppDelegateInstance].objSidePanelviewController;
                self.objSidePanelviewController.shouldDelegateAutorotateToVisiblePanel = NO;
                MenuViewController *menuObjVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
                [menuObjVC chooseRightPanelIndex:1];
                HomeViewController *homeVC = [AppDelegate sharedHomeViewController];
                [homeVC setIsChangingLocation:NO];
                UINavigationController *obj = [[UINavigationController alloc] initWithRootViewController:homeVC];
                obj.navigationBar.translucent = NO;
                self.objSidePanelviewController.centerPanel =obj;
                self.objSidePanelviewController.rightPanel = menuObjVC;
                [self.navigationController pushViewController:self.objSidePanelviewController animated:YES];
                
            }
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }

    }
    else  if([helper.serviceName isEqualToString:@"RESEND_VERIFICATION"])
    {
        
        [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];

    }
    
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}



@end
