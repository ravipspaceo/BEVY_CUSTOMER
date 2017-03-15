//
//  FAQViewController.h
//  Bevy
//
//  Created by CompanyName on 03/01/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class is used to load the web view for FAQ's.
 */
@interface FAQViewController : UIViewController

@property (nonatomic,strong) IBOutlet UIWebView *webViewFAQ;

@property (nonatomic,strong) MBProgressHUD *HUD;
@property(nonatomic, retain) WS_Helper *objWSHelper;

@end
