//
//  SupportViewController.m
//  Bevy
//
//  Created by CompanyName on 12/20/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "SupportViewController.h"
#import "TandCViewController.h"
#import "FAQViewController.h"


@interface SupportViewController ()
{
    NSString *strBody;
}

@end

@implementation SupportViewController

#pragma mark- viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [self viewTitleFont];
    [self setLeftButton];
    self.navigationController.navigationBar.backgroundColor = [UIColor lightGrayColor];
    self.viewCallSupport.layer.borderWidth = 1.0;
    self.viewCallSupport.layer.borderColor = [[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]CGColor];
    self.viewCallSupport.layer.cornerRadius = 5.0;
    self.imgCallsupport.layer.cornerRadius = self.imgCallsupport.frame.size.height/2;
    
    if (IS_IPHONE_6){
        self.btnPolicy.imageEdgeInsets = UIEdgeInsetsMake(0,355,0,0);
        self.btnTerms.imageEdgeInsets = UIEdgeInsetsMake(0,355,0,0);
    }
    else if (IS_IPHONE_6_PLUS){
        self.btnPolicy.imageEdgeInsets = UIEdgeInsetsMake(0,394,0,10);
        self.btnTerms.imageEdgeInsets = UIEdgeInsetsMake(0,394,0,10);
    }
}

-(void)viewTitleFont
{
    self.title =@"Support";
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Support Screen"];
//    [self.navigationController.navigationBar setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:
//      [UIFont fontWithName:@"OpenSans" size:18],
//      NSFontAttributeName, nil]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],NSForegroundColorAttributeName,[GlobalManager fontMuseoSans300:18.0],NSFontAttributeName, nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnMenuClicked
{
    [self.view endEditing:YES];
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self callApplicationSettingsWS];
}

#pragma mark - IBAction Methods

-(IBAction)clickedContactCustome:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSString *msgSubject =@"Help!";
        NSString *msgBody = @"How can Bevy help?";
        NSArray *toRecipents= @[[self.dictSupport objectForKey:@"customer_support_email_id"]];//dev@developer.com
        
        self.mailComposer = [[MFMailComposeViewController alloc] init];
        self.mailComposer.mailComposeDelegate = self;
        [self.mailComposer setToRecipients:toRecipents];
        [self.mailComposer setSubject:msgSubject];
        [self.mailComposer setMessageBody:msgBody isHTML:NO];
        [self.navigationController presentViewController:self.mailComposer animated:YES completion:nil];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

-(IBAction)clickedCallCustomer:(id)sender
{
    self.popUpView.frame = [[UIScreen mainScreen] bounds];
    [[GlobalManager getAppDelegateInstance].window addSubview:self.popUpView];
    
    [self.imgCallsupport sd_setImageWithURL:[NSURL URLWithString:@"http://www.visa.com/blogarchives/us/wp-content/uploads/Russia-Visa-Office-300x199.jpg"]
                           placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    [GlobalManager addAnimationToView:self.viewCallSupport];
    [self.btnNumber setTitle:[NSString stringWithFormat:@"%@",[self.dictSupport objectForKey:@"customer_suppourt_phone"]] forState:UIControlStateNormal];
}

-(void)clickedFAQ:(id)sender
{
    FAQViewController *objFAQ = [[FAQViewController alloc] init];
    [self.navigationController pushViewController:objFAQ animated:YES];
}

-(void)clickedPolicy:(id)sender
{
    TandCViewController *objTandCVC = [[TandCViewController alloc] initWithNibName:@"TandCViewController" bundle:nil];
    objTandCVC.strTitle = @"Privacy Policy";
    [self.navigationController pushViewController:objTandCVC animated:YES];
}

-(void)clickedTerms:(id)sender
{
    TandCViewController *objTandCVC = [[TandCViewController alloc] initWithNibName:@"TandCViewController" bundle:nil];
    objTandCVC.strTitle = @"Terms & Conditions";
    [self.navigationController pushViewController:objTandCVC animated:YES];
}

-(void)btnClickedOnCall:(id)sender
{
    [self.popUpView removeFromSuperview];
    if(!TARGET_IPHONE_SIMULATOR)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"tel://+%@",[self.dictSupport objectForKey:@"customer_suppourt_phone"]]]];
    }
    else
    {
        [self.btnNumber setTitle:[NSString stringWithFormat:@"%@",[self.dictSupport objectForKey:@"customer_suppourt_phone"]] forState:UIControlStateNormal];
    }
}

-(void)btnClickedOnCancel:(id)sender
{
    [self.popUpView removeFromSuperview];
}

-(void)btnClickedOnNumber:(id)sender
{
    [self.popUpView removeFromSuperview];
}

#pragma mark - MailComposer Delegate Method
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ParseWSDelegate Methods

-(void)callApplicationSettingsWS
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS] == nil)
    {
        [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
        [self.objWSHelper sendRequestWithURL:[WS_Urls getApplicationSettingsURL:nil]];
    }
    else
    {
        self.dictSupport = [NSDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS]];
    }
}

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if (!response)
    {
        return;
    }
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
    {
        self.dictSupport = [NSDictionary dictionaryWithDictionary:[[dictResults objectForKey:@"data"] objectForKey:@"app_settings"]];
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
