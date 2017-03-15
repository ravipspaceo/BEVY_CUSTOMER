//
//  TandCViewController.m
//  Bevy
//
//  Created by CompanyName on 12/30/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "TandCViewController.h"

@interface TandCViewController ()

@end

@implementation TandCViewController
{
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [self calltermsconditionsWS];
    [self setBackButton];
    if (!self.isFromReg)
        self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"menu"];
   
    self.navigationItem.title = self.strTitle;
//    Privacy Policy
    
    [GlobalUtilityClass googleAnalyticsScreenTrack:[NSString stringWithFormat:@"%@ %@",self.strTitle,@"Screen"]];
    
    for(UIView *wview in [[[self.webView subviews] objectAtIndex:0] subviews])
    {
        if([wview isKindOfClass:[UIImageView class]])
        { wview.hidden = YES;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear
{
}

-(void)btnMenuClicked
{
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return false;
    }
    return true;
}

#pragma mark - Load WebView
-(void)loadWebView :(NSString*)helpString
{
    
    NSString *htmlString = [NSString stringWithFormat:@"<html>"
                            "<head>"
                            "</head>"
                            "<body>"
                            "<span style=\"font-family: OpenSans; font-size: 15px; color:rgb(0, 0, 0); line-height:15px;background-color: rgb(255, 255, 255);\"><p style=\"text-align:justify; \">%@</p></span>"
                            "</body>"
                            "</html>",helpString];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

#pragma mark - ParseWSDelegate Methods

-(void)calltermsconditionsWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    self.objWSHelper.serviceName = @"termsconditions";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getStaticPagesURL:params]];
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
        NSMutableArray *array=[[NSMutableArray alloc] initWithArray:[dictResults objectForKey:@"data"]];
        if([self.strTitle isEqualToString:@"Terms & Conditions"])
        {
            NSString *strText=[NSString stringWithFormat:@"%@",[GlobalManager getValurForKey:[array objectAtIndex:0] :@"mps_page_code"]];
            [self loadWebView:strText];
        }
        else
        {
            NSString *strText=[NSString stringWithFormat:@"%@",[GlobalManager getValurForKey:[array objectAtIndex:1] :@"mps_page_code"]];
            [self loadWebView:strText];
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
