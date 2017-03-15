//
//  ShareViewController.h
//  Bevy
//
//  Created by CompanyName on 15/09/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

/**
 * This class is used to Share about application in social media.
 */
@interface ShareViewController : UIViewController<MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,FBSDKSharingDelegate>

@property (nonatomic,strong) MFMailComposeViewController *mailComposer;
@property (nonatomic, strong) IBOutlet UIImageView *imgBackGround;
@property (nonatomic, strong) IBOutlet UIButton *btnMsg,*btnMail,*btnFB,*btnTW;
@property (nonatomic, strong) IBOutlet UIButton *btnSeeMore;
@property (nonatomic, strong) JASidePanelController *objSidePanelviewController;
@property (nonatomic, weak) IBOutlet UIImageView *imgLine1,*imgLine2,*imgLine3;
@property (nonatomic, weak) IBOutlet UIView *viewButtons;
@property (nonatomic) UIActivityViewController *activityViewController;

/**
 *  btnBackClicked ,This method is called when user click on Back button.
 *  @param btnBackClicked, pop to previous view controller.
 */
-(IBAction)btnBackClicked:(UIButton*)sender;

/**
 *  btnSociaMediaClicked ,This method is called when user click on Social media button.
 *  @param btnSociaMediaClicked, to share the data via social media.
 */
-(IBAction)btnSociaMediaClicked:(UIButton*)sender;

/**
 *  btnSeeMoreClicked ,This method is called when user click on See more button.
 *  @param btnSeeMoreClicked, to select other UiActivitys for sharing the data.
 */
-(IBAction)btnSeeMoreClicked:(UIButton*)sender;

@end
