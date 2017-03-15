//
//  ShareViewController.m
//  Bevy
//
//  Created by CompanyName on 15/09/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "ShareViewController.h"
#import "MenuViewController.h"
#import "ListViewController.h"


@interface ShareViewController ()

@end
#define kFBShareSucess          @"Shared with facebook successfully."
#define kFBShareCancel          @"Sharing with facebook cancelled."

#define kTwitterShareCancel     @"Sharing with twitter cancelled."
#define ktwitterShareSucess     @"Shared with twitter successfully."
#define kNoTwitterAcc           @"No twitter accounts found."

@implementation ShareViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    if (IS_IPHONE_6_PLUS) {
        [self.imgBackGround setImage:[UIImage imageNamed:@"share_bg6plus@3x.png"]];
    }
    else if (IS_IPHONE_6)
    {
        [self.imgBackGround setImage:[UIImage imageNamed:@"share_bg6@2x.png"]];
    }
    else if (IS_IPHONE_5)
    {
        [self.imgBackGround setImage:[UIImage imageNamed:@"share_bg5@2x.png"]];
    }
    else
    {
        [self.imgBackGround setImage:[UIImage imageNamed:@"share_bg4@2x.png"]];
        self.imgLine1.frame = CGRectMake(self.imgLine1.frame.origin.x, self.imgLine1.frame.origin.y+65, self.imgLine1.frame.size.width, self.imgLine1.frame.size.height);
        self.viewButtons.frame = CGRectMake(self.viewButtons.frame.origin.x, self.viewButtons.frame.origin.y+50, self.viewButtons.frame.size.width, self.viewButtons.frame.size.height);
        self.imgLine2.frame = CGRectMake(self.imgLine2.frame.origin.x, self.imgLine2.frame.origin.y+25, self.imgLine2.frame.size.width, self.imgLine2.frame.size.height);
        self.imgLine3.frame = CGRectMake(self.imgLine3.frame.origin.x, self.imgLine3.frame.origin.y+25, self.imgLine3.frame.size.width, self.imgLine3.frame.size.height);
        self.btnSeeMore.frame = CGRectMake(self.btnSeeMore.frame.origin.x, self.btnSeeMore.frame.origin.y+25, self.btnSeeMore.frame.size.width, self.btnSeeMore.frame.size.height);
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Share Screen"];
    [self.navigationController.navigationBar setHidden:YES];
}

-(IBAction)btnBackClicked:(UIButton*)sender
{
    MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
    [menuViewcontroller menuItemHomeClikced:nil];
}

-(IBAction)btnSeeMoreClicked:(UIButton*)sender
{
    [self shareText:TEXT_TWITTER andImage:nil andUrl:nil];
}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
  [controller dismissViewControllerAnimated:YES completion:^{
      
  }];
}

-(IBAction)btnSociaMediaClicked:(UIButton*)sender
{
    int tagButton = (int)sender.tag;
    switch (tagButton) {
        case 1:
        {
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            if([MFMessageComposeViewController canSendText])
            {
                controller.body = TEXT_SMS;
                controller.messageComposeDelegate = self;
                [self presentViewController:controller animated:YES completion:^{
                }];
            }
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
        [self.navigationController presentViewController:self.mailComposer animated:YES completion:nil];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
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
        [self.navigationController presentViewController:slController animated:YES completion:^
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

-(void)viewDidDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
