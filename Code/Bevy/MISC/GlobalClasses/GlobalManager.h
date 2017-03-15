//
//  Jupper
//
//  Created by CompanyName.
//  Copyright (c) 2012 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>
#import "SMPageControl.h"
//#import "CustomProgress.h"

typedef enum
{
    OnGoingEvents,
    RecomendedEvents,
    PopularEvents
} EventsType;

typedef enum
{
    FavoriteView,
    PointsEarnedView
} ViewType;

@interface GlobalManager : NSObject
+ (void)setOperationInstance:(AFJSONRequestOperation *)instance;
@property (nonatomic, assign) BOOL isLoggedOut;
@property (nonatomic, assign) BOOL hasAppLaunched;
@property (nonatomic, strong) NSString *strDeviceToken;
@property (nonatomic, assign) BOOL profileNeedsToRefresh;
@property (strong, nonatomic) CLLocation *mySessionLocation;
@property (assign, nonatomic) EventsType myEventType;
@property (nonatomic, strong) NSMutableArray *arCategories;
@property (nonatomic, assign) BOOL eventsNeedsToRefresh;
//@property (nonatomic, strong) CustomProgress *ProgressTracker;

+(UIBarButtonItem *)getnavigationRightButtonWithTarget:(id)target :(NSString *)strImageName;
+(UIBarButtonItem *)getnavigationLeftButtonWithTarget:(id)target :(NSString *)strImageName;
+(NSArray *)getnavigationRightButtonsWithTarget:(id)target withImageOne:(NSString *)strImageName andTarget2:(id)target2 andImageTwo:(NSString *)strImageName2;


//Valid Email and phone number
//+ (BOOL) validateEmail: (NSString *) myEmail error:(NSString**)error;
//+ (BOOL) validatePhoneNumber: (NSString*)myPhoneNumber error:(NSString**)error;

+ (GlobalManager*) sharedInstance;
+(void)addAnimationToView : (UIView *)view;
+ (BOOL) checkInternetConnection;
+(NSInteger)getAgeFromDate:(NSDate*)birthDate;
+(void)showDidFailError:(NSError *)error;
+ (UIImage *)scaleAndRotateImage:(UIImage *)imgPic;
+ (AppDelegate*) getAppDelegateInstance;
//+ (void) setOperationInstance:(AFJSONRequestOperation *)instance;
+(NSMutableArray *)getDummyData;
+(NSString*)getValurForKey :(NSMutableDictionary*)dict : (NSString*)key;
+ (UIScrollView*) scrollViewToCenterOfScreenInProfile:(UIScrollView*)_scrlView theView:(UIView *)theView toShow:(BOOL)toShow;
+ (UIImage*)getImageFromResource:(NSString*)imageName;

+(NSString *) checkForNull:(id) obj;

+(NSDate *)getDateFromString:(NSString *)strDate;
+(NSDate *)getDateFromBefore18Years;

#pragma mark - load more
+ (NSInteger)loadMore : (NSInteger)numberOfItemsToDisplay arrayTemp:(NSMutableArray*)aryItems tblView:(UITableView*)tblList;

#pragma mark Custom setup methods
//Custom setup methods
+(NSString *) formatPhoneNumberToUS:(NSString *) normalPhoneNo;
+ (void) showStartProgress : (UIViewController*) parentView;
+ (SMPageControl *)pageControl : (CGRect)frame;
#pragma mark IMAGE Ops
+ (UIImage *)makeResizedImage:(CGSize)newSize quality:(CGInterpolationQuality)interpolationQuality withImage:(UIImage*)oldImage isAspectFit:(BOOL)isAspectFit;
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize andImage:(UIImage *) sourceImage;
+(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)destSize;

#pragma mark - Table Font & Color
+ (UIFont *)FontLightForSize:(int)size;
+ (UIFont *)FontForSize:(int)size;
+ (UIFont *)FontMediumForSize:(int)size;
+ (UIFont *)FontBoldForSize:(int)size;

+(UIFont *)fontMuseoSans100:(int)size;
+(UIFont *)fontMuseoSans300:(int)size;
+(UIFont *)fontMuseoSans500:(int)size;
+(UIFont *)fontOswaldStncil:(int)size;

+ (UIColor*)BlackButtonTintColor;
+ (UIColor*)BlackButtonHeighlightedTintColor;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColorAndArrow:(UIColor *)color;
+ (NSString *)GetDeviceId;
+ (NSDateFormatter *)DateFormatee;
#pragma mark - Toolbar for navigationbar
+ (UIToolbar*) setTopBar;

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
+ (UIFont *) getMediumFontForSize:(int)fontSize;
@end

//Category for UINavigation bar
@interface UIViewController (CustomeAction)
-(void)setBackButton;
-(void)setCancelButton:(SEL)selector withTarget:(id)target;
-(void)setLeftButton;
-(void)setLeftBarButtonWithTitle:(NSString *)buttonTitle;
-(void)setRightBarButton;
-(void)removeBackButton;
-(void)btnBackButtonClicked:(id)sender;

//+ (void) showStartProgress : (UIViewController*) parentView;
//-(void)setRightBarButtonsOnAttendees;
//-(void)setRightBarButtonsForMessageScreen;
//-(void)goToNotificationView:(UIButton *)sender;
@end