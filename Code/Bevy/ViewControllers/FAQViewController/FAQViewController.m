//
//  FAQViewController.m
//  Bevy
//
//  Created by CompanyName on 03/01/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "FAQViewController.h"

@interface FAQViewController ()

@end

@implementation FAQViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackButton];
    self.navigationItem.title=@"FAQ";
    self.navigationItem.rightBarButtonItem=[GlobalManager getnavigationRightButtonWithTarget:self :@"menu"];
   
    [self callFAQ];
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"FAQ Screen"];
    [self performSelector:@selector(triggerNotification) withObject:self afterDelay:2.0];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(triggerNotification) object:nil];
}

#pragma mark - Instance methods

-(void)triggerNotification
{
}

-(void)webViewBodyContent :(NSString*)htmlStr
{
    [self.webViewFAQ loadHTMLString:htmlStr baseURL:nil];
}

-(void)btnMenuClicked
{
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

#pragma mark - UIWebViewDelegate Method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return false;
    }
    return true;
}

-(void)callFAQ
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getFAQURL:nil]];
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
    if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
    {
        [self webViewBodyContent:[[[dictResults objectForKey:@"data"] lastObject] valueForKey:@"faq_content"]];
        
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
