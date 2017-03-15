//
//  TandCViewController.h
//  Bevy
//
//  Created by CompanyName on 12/30/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class is used to show Terms and conditions.
 */
@interface TandCViewController : UIViewController<ParseWSDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *strTitle;
@property (nonatomic, assign) BOOL isFromReg;

@property (nonatomic, strong) WS_Helper *objWSHelper;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end
