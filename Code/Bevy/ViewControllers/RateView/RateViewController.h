//
//  RateViewController.h
//  Bevy
//

#import <UIKit/UIKit.h>
#import "TYMActivityIndicatorView.h"
#import <MessageUI/MessageUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Social/Social.h>

#import <FacebookSDK/FacebookSDK.h>
/**
 * This class is used to rate the Butler.
 */

@protocol RateViewControllerDelegate <NSObject>

-(void)btnSubmitClikced;

@end



@interface RateViewController : UIViewController<ParseWSDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,FBSDKSharingDelegate>
@property (strong, nonatomic) IBOutlet UILabel *lblThanks;
@property (strong, nonatomic) IBOutlet UILabel *lblLine1;
@property (strong, nonatomic) IBOutlet UILabel *lblLine2;

@property (strong, nonatomic) IBOutlet UILabel *lblLine3;
@property (strong, nonatomic) IBOutlet UILabel *lblLine4;

@property (nonatomic,strong) MFMailComposeViewController *mailComposer;

@property (strong, nonatomic) IBOutlet UIView *viewInner;
@property (nonatomic, assign) id<RateViewControllerDelegate> objDelegate;

@property (nonatomic, strong) IBOutlet UIButton *btnWApp,*btnFB,*btnTW,*btnSubmit;
@property (nonatomic, strong ) NSMutableDictionary *dictDriver;


@property (nonatomic, strong) IBOutlet UIButton *btnRate1,*btnRate2,*btnRate3,*btnRate4,*btnRate5;
@property (nonatomic, strong) IBOutlet UIImageView *imgRate1,*imgRate2,*imgRate3,*imgRate4,*imgRate5;
@property(nonatomic, assign) CGFloat currentRating;
@property (strong, nonatomic) IBOutlet UIImageView *imgDriverImage;

@property (strong, nonatomic) IBOutlet UIView *viewRate;

@property (nonatomic, strong) WS_Helper *objWSHelper;

@property (nonatomic, strong) TYMActivityIndicatorView *activityIndicator;

/**
 *  btnSubmitClicked ,This method is called when user click on Submit button.
 *  @param btnSubmitClicked, By clicking on this user will give the rating to the butler.
 */
- (IBAction)btnSubmitClicked:(id)sender;
/**
 *  btnRateClicked ,This method is called when user click on Rate Button.
 *  @param btnRateClicked, user can select the rating.
 */
- (IBAction)btnRateClicked:(UIButton*)sender;
/**
 *  btnSociaMediaClicked ,This method is called when user click on Social media button.
 *  @param btnSociaMediaClicked, to share the data via social media.
 */
- (IBAction)btnSociaMediaClicked:(UIButton*)sender;

@end
