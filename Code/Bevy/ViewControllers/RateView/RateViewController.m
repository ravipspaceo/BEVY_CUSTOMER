//
//  RateViewController.m
//  Bevy
//

#import "RateViewController.h"
#import "CustomActivityIndicator.h"


@interface RateViewController ()
{
    NSMutableDictionary *dictData;
}

@end

#define kFBShareSucess          @"Shared with facebook successfully."
#define kFBShareCancel          @"Sharing with facebook cancelled."

#define kTwitterShareCancel     @"Sharing with twitter cancelled."
#define ktwitterShareSucess     @"Shared with twitter successfully."
#define kNoTwitterAcc           @"No twitter accounts found."

@implementation RateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    
    self.imgRate1.image = self.imgRate2.image = self.imgRate3.image = self.imgRate4.image =self.imgRate5.image = [UIImage imageNamed:@"icon_rate_star_gray.png"];
    self.currentRating = 0;
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];

    self.view.frame =  [GlobalManager getAppDelegateInstance].window.frame ;
    
    self.viewRate.layer.cornerRadius = 5;
    self.viewRate.clipsToBounds = YES;
    
    self.imgDriverImage.layer.cornerRadius = self.imgDriverImage.frame.size.width/2;
    self.imgDriverImage.clipsToBounds = YES;
    
    if (self.dictDriver)
    {
        [self.imgDriverImage sd_setImageWithURL:[NSURL URLWithString:[self.dictDriver objectForKey:@"profile_image"]]
                               placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    if (IS_IPHONE_6_PLUS || IS_IPHONE_6) {
        self.viewInner.frame = CGRectMake(0, (IS_IPHONE_6_PLUS ? 90 : 60), self.viewInner.frame.size.width, self.viewInner.frame.size.height);
        
        self.lblLine1.frame = CGRectMake(self.lblLine1.frame.origin.x, self.lblLine1.frame.origin.y, (IS_IPHONE_6_PLUS ? 90 : 67), self.lblLine1.frame.size.height);
        
        self.lblLine2.frame = CGRectMake(self.lblLine2.frame.origin.x - (IS_IPHONE_6_PLUS ? 26 : 15), self.lblLine2.frame.origin.y, (IS_IPHONE_6_PLUS ? 93 : 72), self.lblLine2.frame.size.height);
        
         self.lblLine3.frame = CGRectMake(self.lblLine3.frame.origin.x, self.lblLine3.frame.origin.y, (IS_IPHONE_6_PLUS ? 60 : 43), self.lblLine3.frame.size.height);
        
            self.lblLine4.frame = CGRectMake(self.lblLine4.frame.origin.x - (IS_IPHONE_6_PLUS ? 34 : 20), self.lblLine4.frame.origin.y, (IS_IPHONE_6_PLUS ? 63 : 46), self.lblLine4.frame.size.height);
    }
    
    
    if (IS_IPHONE_4) {
        self.btnWApp.frame = CGRectMake(self.btnWApp.frame.origin.x, 280, self.btnWApp.frame.size.width, self.btnWApp.frame.size.height);
        self.btnFB.frame = CGRectMake(self.btnFB.frame.origin.x, 280, self.btnFB.frame.size.width, self.btnFB.frame.size.height);
        self.btnTW.frame = CGRectMake(self.btnTW.frame.origin.x, 280, self.btnTW.frame.size.width, self.btnTW.frame.size.height);
        self.btnSubmit.frame = CGRectMake(self.btnSubmit.frame.origin.x, 355, self.btnSubmit.frame.size.width, 30);
    }
    
}




#pragma mark - IBAction Methods

- (IBAction)btnSubmitClicked:(id)sender {
    if(self.currentRating > 0)
    {
        [self callFeedbackWS];
        return;
    }
    else
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please rate driver" handler:nil];
        return;
    }
}

-(IBAction)btnRateClicked:(UIButton*)sender
{
    if (sender.tag==1)
    {
        self.imgRate1.image = [UIImage imageNamed:@"icon_rate_star_yellow.png"];
        self.imgRate2.image = self.imgRate3.image = self.imgRate4.image =self.imgRate5.image = [UIImage imageNamed:@"icon_rate_star_gray.png"];
        self.currentRating =1;
    }
    else if (sender.tag==2)
    {
        self.imgRate1.image = self.imgRate2.image = [UIImage imageNamed:@"icon_rate_star_yellow.png"];
        self.imgRate3.image = self.imgRate4.image =self.imgRate5.image = [UIImage imageNamed:@"icon_rate_star_gray.png"];
        self.currentRating =2;
    }
    else if (sender.tag==3)
    {
        self.imgRate1.image = self.imgRate2.image = self.imgRate3.image = [UIImage imageNamed:@"icon_rate_star_yellow.png"];
        self.imgRate4.image =self.imgRate5.image = [UIImage imageNamed:@"icon_rate_star_gray.png"];
        self.currentRating =3;
    }
    else if (sender.tag==4)
    {
        self.imgRate1.image = self.imgRate2.image = self.imgRate3.image = self.imgRate4.image = [UIImage imageNamed:@"icon_rate_star_yellow.png"];
        self.imgRate5.image = [UIImage imageNamed:@"icon_rate_star_gray.png"];
        self.currentRating =4;
    }
    else if (sender.tag==5)
    {
        self.imgRate1.image = self.imgRate2.image = self.imgRate3.image = self.imgRate4.image =self.imgRate5.image = [UIImage imageNamed:@"icon_rate_star_yellow.png"];
        self.currentRating =5;
    }
}



-(IBAction)btnSociaMediaClicked:(UIButton*)sender
{
    int tagButton = (int)sender.tag;
    switch (tagButton) {
        case 1:
        {
            [self whatsAppSharing];
            
//            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
//            if([MFMessageComposeViewController canSendText])
//            {
//                controller.body = TEXT_SMS;
//                controller.messageComposeDelegate = self;
//                [self presentViewController:controller animated:YES completion:^{
//                }];
//            }
        }
            break;
        case 2:
            [self emailSharing];
            break;
        case 3:
            [self doFBSharing];
            break;
        case 4:
            [self doTwitterSharing];
            break;
        default:
            break;
    }
}

-(void)whatsAppSharing
{
    NSString * msg = TEXT_SMS;
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
    else
    {
        [UIAlertView showErrorWithMessage:@"Cannot open whatsapp on this device" myTag:0 handler:nil];
    }
}

-(void)emailSharing
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSString *msgSubject =@"Your new favourite app!";
        NSString *msgBody = TEXT_EMAIL;
        self.mailComposer = [[MFMailComposeViewController alloc] init];
        self.mailComposer.mailComposeDelegate = self;
        [self.mailComposer setSubject:msgSubject];
        [self.mailComposer setMessageBody:msgBody isHTML:NO];
        [self presentViewController:self.mailComposer animated:YES completion:nil];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
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


#pragma mark - FB Sharing
- (FBSDKShareDialog *)getShareDialogWithContentURL
{
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    shareDialog.mode = FBSDKShareDialogModeFeedBrowser;
    shareDialog.shareContent = [self getShareLinkContentWithContentURL];
    return shareDialog;
}

- (FBSDKShareLinkContent *)getShareLinkContentWithContentURL
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    [content setContentURL:[NSURL URLWithString:@"https://fb.me/643523119084521"]];
    [content setContentTitle:@"Bevy"]; //ignored??
    [content setContentDescription:TEXT_FACEBOOK];
    
    
    [content setImageURL:[NSURL URLWithString:@"http://www.bevy.co/wp-content/uploads/2015/11/bevy-logo-black-bg-90-hi-new1-cut.png"]];
    return content;
}

-(void)shareFbWithDialog
{
    FBSDKShareDialog *shareDialog = [self getShareDialogWithContentURL];
    shareDialog.delegate = self;
    [shareDialog show];
}

#pragma mark - FBSharing Delegates
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    
}
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
}

-(void)doFBSharing
{
    [self shareFbWithDialog];
}


-(void)doTwitterSharing
{
    NSString *text =TEXT_TWITTER;
    if (![GlobalManager checkInternetConnection])
    {
        [UIAlertView showWithTitle:kAppTitle message:kNetworkError handler:nil];
        return;
    }
    else
    {
        SLComposeViewController *slController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [slController addImage:[UIImage imageNamed:@"iTunesArtwork@2x"]];
        [slController setInitialText:text];
        [self presentViewController:slController animated:YES completion:^
         {
             dispatch_async(dispatch_get_main_queue(),^
                            {
                                [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
                            });
         }];
        [slController setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             NSString *outout = ktwitterShareSucess;
             switch (result)
             {
                 case SLComposeViewControllerResultCancelled:
                 {
                     outout = kTwitterShareCancel;
                     [UIAlertView showWithTitle:kAppTitle message:outout handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                      {
                      }];
                 }
                     break;
                 case SLComposeViewControllerResultDone:
                 {
                     outout = ktwitterShareSucess;
                     [UIAlertView showWithTitle:kAppTitle message:outout handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                      {
                      }];
                 }
                     break;
                 default:
                     break;
             }
         }];
    }
}


-(void)callOrderStatusWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    self.objWSHelper.serviceName = @"ORDER_STATUS";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getOrderStatusURL:params]];
}

-(void)callFeedbackWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:[NSString stringWithFormat:@"%.1f",self.currentRating] forKey:@"ratting"];
    [params setObject:[self.dictDriver objectForKey:@"driver_id"] forKey:@"driver_id"];
    [params setObject:[self.dictDriver objectForKey:@"order_id"] forKey:@"order_id"];
    
    [self.objWSHelper setServiceName:@"FEEDBACK_RATING"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getFeedbackForDriverURL:params]];
}
#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    
    [[CustomActivityIndicator getCustomIndicatorInstance] hideIndicatorForView:self];
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    
    if (!response)
    {
        return;
    }
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if([helper.serviceName isEqualToString:@"ORDER_STATUS"])
    {
        
        
        NSLog(@"%@",dictResults);

        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            self.dictDriver =  [[[dictResults objectForKey:@"data"] objectForKey:@"fetch_order_status"] objectAtIndex:0];
            [self.imgDriverImage sd_setImageWithURL:[NSURL URLWithString:[dictData objectForKey:@"profile_image"]]
                              placeholderImage:[UIImage imageNamed:@"placeholder"]];
            
        }
        else
        {
            
        }
    }
    else
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            NSLog(@"RateSuccess");
            [self.view removeFromSuperview];
            [self.objDelegate btnSubmitClikced];
        }

        else
            NSLog(@"RateFaliure");
        return;
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [[CustomActivityIndicator getCustomIndicatorInstance] hideIndicatorForView:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height);
    }];
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
