//
//  Jupper
//
//  Created by CompanyName.
//  Copyright (c) 2012 CompanyName. All rights reserved.
//

#import "GlobalManager.h"
#import "Reachability.h"
#import <CommonCrypto/CommonDigest.h>
#import <AddressBook/AddressBook.h>
#import "AFJSONRequestOperation.h"
#import "SMPageControl.h"
#import "UIAlertView+Blocks.h"
#import "UIImage+FX.h"
#import "ListViewController.h"

static AFJSONRequestOperation *objOperation = nil;

@implementation GlobalManager

+ (void)setOperationInstance:(AFJSONRequestOperation *)instance
{
    objOperation = nil;
    objOperation = instance;
}

UIBarButtonItem *barButton;
static UIToolbar *topBar = nil;
static GlobalManager *sharedInstance = nil;
static AppDelegate *singletonObject = nil;

+ (GlobalManager *)sharedInstance
{
    static GlobalManager *objInstance = nil;
	if (nil == objInstance)
	{
		objInstance  = [[super allocWithZone:NULL] init];
	}
	return objInstance;
}

+(UIBarButtonItem *)getnavigationRightButtonWithTarget:(id)target :(NSString *)strImageName
{
    UIButton *btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setImage:[UIImage imageNamed:strImageName] forState:UIControlStateNormal];
    [btnMenu setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h",strImageName]] forState:UIControlStateHighlighted];
    [btnMenu setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h",strImageName]] forState:UIControlStateSelected];
    btnMenu.backgroundColor = [UIColor clearColor];
    [btnMenu addTarget:target action:@selector(btnMenuClicked) forControlEvents:UIControlEventTouchUpInside];
    btnMenu.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btnMenu];
    btnBackItem.imageInsets = IS_IOS_7 ? UIEdgeInsetsMake(0, 10, 3, -10) : UIEdgeInsetsMake(0, 0, 0, 0);
    return btnBackItem;
}

+(UIBarButtonItem *)getnavigationLeftButtonWithTarget:(id)target :(NSString *)strImageName
{
    UIButton *btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setImage:[UIImage imageNamed:strImageName] forState:UIControlStateNormal];
    [btnMenu setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h",strImageName]] forState:UIControlStateHighlighted];
    [btnMenu setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h",strImageName]] forState:UIControlStateSelected];
    btnMenu.backgroundColor = [UIColor clearColor];
    [btnMenu addTarget:target action:@selector(btnCancelClicked) forControlEvents:UIControlEventTouchUpInside];
    btnMenu.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btnMenu];
    btnBackItem.imageInsets = IS_IOS_7 ? UIEdgeInsetsMake(0, -25.0f, 0, 0) :UIEdgeInsetsMake(0, 0, 0, 0);

    return btnBackItem;
}
+(NSArray *)getnavigationRightButtonsWithTarget:(id)target withImageOne:(NSString *)strImageName andTarget2:(id)target2 andImageTwo:(NSString *)strImageName2
{
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setImage:[UIImage imageNamed:strImageName] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h",strImageName]] forState:UIControlStateHighlighted];
    [btnBack setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h",strImageName]] forState:UIControlStateSelected];
    btnBack.backgroundColor = [UIColor clearColor];
    [btnBack addTarget:target action:@selector(btnMenuClicked) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 30, 30);
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setImage:[UIImage imageNamed:strImageName2] forState:UIControlStateNormal];
    [btnSearch setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h",strImageName2]] forState:UIControlStateHighlighted];
    [btnSearch setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h",strImageName2]] forState:UIControlStateSelected];
    btnSearch.backgroundColor = [UIColor clearColor];
    [btnSearch addTarget:target action:@selector(btnSearchClicked) forControlEvents:UIControlEventTouchUpInside];
    btnSearch.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem *btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    btnBackItem.imageInsets = IS_IOS_7 ? UIEdgeInsetsMake(0, 10, 3, -10) : UIEdgeInsetsMake(0, 0, 0, 0);
    
    UIBarButtonItem *btnSearchItem = [[UIBarButtonItem alloc] initWithCustomView:btnSearch];
    btnSearchItem.imageInsets = IS_IOS_7 ? UIEdgeInsetsMake(0, 10, 3, -10) : UIEdgeInsetsMake(0, 0, 0, 0);
    
    return @[btnBackItem, btnSearchItem];
}

#pragma mark - ButtonSelectorActions

-(void)btnSearchClicked{}
-(void)btnMenuClicked{}
-(void)btnCancelClicked{
}

#pragma mark - ErrorHandling
+(NSString *) checkForNull:(id) obj
{
    if ([obj isEqual:[NSNull null]])
    {
        return @"";
    }
    else
    {
        return obj;
    }
}

+(NSDate *)getDateFromString:(NSString *)strDate{
    NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dtFormatter dateFromString:strDate];
}

+ (id)allocWithZone:(NSZone *)zone
{	
	@synchronized(self) 
	{
		if (sharedInstance == nil) 
		{
			sharedInstance = [super allocWithZone:zone];
			return sharedInstance;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone 
{	
	return self;	
}

//+ (void)setOperationInstance:(AFJSONRequestOperation *)instance
//{
//    objOperation = nil;
//    objOperation = instance;
//}
//
+ (UIImage*)getImageFromResource:(NSString*)imageName
{
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]];
}

#pragma mark - Check Connection
+ (BOOL) checkInternetConnection
{
	Reachability *reachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
	if (remoteHostStatus == NotReachable)
	{
        return FALSE;
	}
	else
	{
        return TRUE;
	}
}

+(void)showDidFailError:(NSError *)error
{
//    for (UIWindow* window in [UIApplication sharedApplication].windows) {
//        NSArray* subviews = window.subviews;
//        if ([subviews count] > 0)
//            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]])
//                [(UIAlertView *)[subviews objectAtIndex:0] dismissWithClickedButtonIndex:[(UIAlertView *)[subviews objectAtIndex:0] cancelButtonIndex] animated:NO];
//    }
    NSLog(@"Error ===> %ld",(long)error.code);
    if (error.code == -1009 || error.code == -1001) {
        [UIAlertView showWithTitle:kAppTitle message:kDidFailError handler:nil];
    }
    else{
       [UIAlertView showWithTitle:kAppTitle message:kDidFailBError handler:nil];
    }
}

+(NSInteger)getAgeFromDate:(NSDate*)birthDate
{
    NSDate *today = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]  components:NSYearCalendarUnit fromDate:birthDate toDate:today options:0];
   
    return ageComponents.year;
}

+(NSDate *)getDateFromBefore18Years
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *yearsComponents = [[NSDateComponents alloc] init];
    [yearsComponents setYear:-18];
    return [gregorian dateByAddingComponents:yearsComponents toDate:today options:0];
}


#pragma mark - UIImage from UIColor

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIImage *)imageWithColorAndArrow:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSDateFormatter *)DateFormatee{
    NSDateFormatter *FormatTime = [[NSDateFormatter alloc] init];
    [FormatTime setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [FormatTime setDateFormat:@"dd-MM-yyyy"];
        //    [FormatTime setTimeStyle:NSDateFormatterShortStyle];
    return FormatTime;
}

#pragma mark - Instance of AppDelegate
+ (AppDelegate*) getAppDelegateInstance
{
	if (singletonObject == nil)
	{
		singletonObject = (AppDelegate*) [[UIApplication sharedApplication] delegate];
	}
    return singletonObject;
}
#pragma mark - Open UDID

+ (NSString *)GetDeviceId
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+(void)addAnimationToView : (UIView *)view
{
//    [view.layer removeAllAnimations];
//    [view.layer removeAnimationForKey:@"bounce"];
//    [view.layer removeAllAnimations];
//    [view.layer removeAnimationForKey:@"bounce"];
//    
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
//    animation.values = @[@(0.01), @(1.2), @(0.9), @(1)];
//    animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
//    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
//    animation.duration = 0.5;
//    animation.delegate = self;
//    
//    [view.layer addAnimation:animation forKey:@"bouce"];
//    view.transform = CGAffineTransformIdentity;
    view.hidden = NO;
    
//    view.backgroundColor = [UIColor clearColor];
    view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        view.transform = CGAffineTransformMakeScale(1.2, 1.2);
        view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        view.transform = CGAffineTransformIdentity;
//        view.backgroundColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:0.8];
        // do something once the animation finishes, put it here
    }];

}

#pragma mark -  UIScrollview ContentOffset
+ (UIScrollView*) scrollViewToCenterOfScreenInProfile:(UIScrollView*)_scrlView theView:(UIView *)theView toShow:(BOOL)toShow
{
    float reqSize1=320,reqSize2=300;
    CGFloat viewMaxY = CGRectGetMaxY(theView.frame) + theView.superview.frame.origin.y + 75;
   	CGFloat availableHeight;
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGSize viewSize = CGSizeMake(isPortrait?reqSize1:([UIScreen mainScreen].applicationFrame.size.height), isPortrait?280:reqSize2);
	if (toShow)
	{
		availableHeight = viewSize.height - 216 - (CGRectGetMinY(_scrlView.frame));
	}
	else
	{
		availableHeight = viewSize.height + 216 + (CGRectGetMinY(_scrlView.frame));
	}
	CGFloat y = viewMaxY - availableHeight;
	if (y < 0)
	{
        y = 0;
	}
    if (toShow)
        [_scrlView setContentOffset:CGPointMake(_scrlView.contentOffset.x, y) animated:YES];
    else
    {
        CGFloat posY = ((_scrlView.contentOffset.y+_scrlView.frame.size.height)>_scrlView.contentSize.height)?(_scrlView.contentSize.height-_scrlView.frame.size.height):(_scrlView.contentOffset.y);
        
        [_scrlView setContentOffset:CGPointMake(_scrlView.contentOffset.x,(posY<0)?0:posY) animated:YES];
        
    }
    return _scrlView;
}

#pragma mark - check for key in dict
+(NSString*)getValurForKey :(NSMutableDictionary*)dict : (NSString*)key{
    if ([dict valueForKey:key] == nil || [[dict valueForKey:key] isKindOfClass:[NSNull class]]) {
        return @"";
    }
    return [dict valueForKey:key];
}

#pragma mark- DummyArray
+(NSMutableArray *)getDummyData
{
    NSMutableArray *arrayList = [[NSMutableArray alloc]init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"1" forKey:@"id"];
    [dict setObject:@"PORT BREWING WIPEOUT IPA" forKey:@"kName"];
    [dict setObject:@"West Coast Style IPA" forKey:@"kPlace"];
    [dict setObject:@"2 Devices" forKey:@"No_devices"];
    [dict setObject:@"25/11/2014 | 09:39AM" forKey:@"kDatetime"];
    [dict setObject:@"Abhinav" forKey:@"kReceivername"];
    [dict setObject:@"http://www.surfnsandliquors.com/webart/products/1354.jpg" forKey:@"product_link"];
    [arrayList addObject:dict];
    
    dict = nil;
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"1" forKey:@"id"];
    [dict setObject:@"ARROGANT BASTARD" forKey:@"kName"];
    [dict setObject:@"American Strong Ale" forKey:@"kPlace"];
    
    [dict setObject:@"Auditorium" forKey:@"kAlertmessage"];
    [dict setObject:@"Waiting Room" forKey:@"kLocation"];
    [dict setObject:@"1 Devices" forKey:@"No_devices"];
    [dict setObject:@"07/01/2014 | 12:49PM" forKey:@"kDatetime"];
    [dict setObject:@"Aakash Vidyan" forKey:@"kReceivername"];
    [dict setObject:@"http://www.surfnsandliquors.com/webart/products/1365.jpg" forKey:@"product_link"];
    [arrayList addObject:dict];

    dict = nil;
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"1" forKey:@"id"];
    [dict setObject:@"PORT BREWING WIPEOUT IPA" forKey:@"kName"];
    [dict setObject:@"West Coast Style IPA" forKey:@"kPlace"];
    
    [dict setObject:@"Hall Floor" forKey:@"kAlertmessage"];
    [dict setObject:@"Entrence Room" forKey:@"kLocation"];
    [dict setObject:@"4 Devices" forKey:@"No_devices"];
    [dict setObject:@"09/11/2014 | 11:39PM" forKey:@"kDatetime"];
    [dict setObject:@"Ram Gopal Varma" forKey:@"kReceivername"];
    [dict setObject:@"http://www.surfnsandliquors.com/webart/products/1354.jpg" forKey:@"product_link"];
    [arrayList addObject:dict];

    dict = nil;
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"1" forKey:@"id"];
    [dict setObject:@"ARROGANT BASTARD" forKey:@"kName"];
    [dict setObject:@"American Strong Ale" forKey:@"kPlace"];
    
    [dict setObject:@"Balcony" forKey:@"kAlertmessage"];
    [dict setObject:@"Auditorium" forKey:@"kAlertmessage"];
    [dict setObject:@"Waiting Room" forKey:@"kLocation"];
    [dict setObject:@"3 Devices" forKey:@"No_devices"];
    [dict setObject:@"06/04/2014 | 12:39PM" forKey:@"kDatetime"];
    [dict setObject:@"Sangatdkara" forKey:@"kReceivername"];
    [dict setObject:@"http://www.surfnsandliquors.com/webart/products/1365.jpg" forKey:@"product_link"];
    [arrayList addObject:dict];

    dict = nil;
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"1" forKey:@"id"];
    [dict setObject:@"PORT BREWING WIPEOUT IPA" forKey:@"kName"];
    [dict setObject:@"West Coast Style IPA" forKey:@"kPlace"];

    [dict setObject:@"Open Gate" forKey:@"kAlertmessage"];
    [dict setObject:@"All Views" forKey:@"kLocation"];
    [dict setObject:@"5 Devices" forKey:@"No_devices"];
    [dict setObject:@"07/11/2014 | 12:39PM" forKey:@"kDatetime"];
    [dict setObject:@"Kohli Arora" forKey:@"kReceivername"];
    [dict setObject:@"http://www.surfnsandliquors.com/webart/products/1354.jpg" forKey:@"product_link"];
    [arrayList addObject:dict];
    
    dict = nil;
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"1" forKey:@"id"];
    [dict setObject:@"ARROGANT BASTARD" forKey:@"kName"];
    [dict setObject:@"American Strong Ale" forKey:@"kPlace"];

    [dict setObject:@"Auditorium" forKey:@"kAlertmessage"];
    [dict setObject:@"1 Devices" forKey:@"No_devices"];
    [dict setObject:@"07/01/2014 | 12:49PM" forKey:@"kDatetime"];
    [dict setObject:@"Mana Sahara" forKey:@"kReceivername"];
    [dict setObject:@"http://www.surfnsandliquors.com/webart/products/1365.jpg" forKey:@"product_link"];
    [arrayList addObject:dict];
    
    dict = nil;
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"1" forKey:@"id"];
    [dict setObject:@"PORT BREWING WIPEOUT IPA" forKey:@"kName"];
    [dict setObject:@"West Coast Style IPA" forKey:@"kPlace"];
    [dict setObject:@"Hall Floor" forKey:@"kAlertmessage"];
    [dict setObject:@"Entrence Room" forKey:@"kLocation"];
    [dict setObject:@"4 Devices" forKey:@"No_devices"];
    [dict setObject:@"09/11/2014 | 11:39PM" forKey:@"kDatetime"];
    [dict setObject:@"Kowshik Raths" forKey:@"kReceivername"];
    [dict setObject:@"http://www.surfnsandliquors.com/webart/products/1354.jpg" forKey:@"product_link"];
    [arrayList addObject:dict];
    
    dict = nil;
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"1" forKey:@"id"];
    [dict setObject:@"ARROGANT BASTARD" forKey:@"kName"];
    [dict setObject:@"American Strong Ale" forKey:@"kPlace"];
    [dict setObject:@"Balcony" forKey:@"kAlertmessage"];
    [dict setObject:@"Exit door" forKey:@"kLocation"];
    [dict setObject:@"3 Devices" forKey:@"No_devices"];
    [dict setObject:@"06/04/2014 | 12:39PM" forKey:@"kDatetime"];
    [dict setObject:@"Shanmai thami" forKey:@"kReceivername"];
    [dict setObject:@"http://www.surfnsandliquors.com/webart/products/1365.jpg" forKey:@"product_link"];
    [arrayList addObject:dict];
    
    dict = nil;
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"1" forKey:@"id"];
    [dict setObject:@"PORT BREWING WIPEOUT IPA" forKey:@"kName"];
    [dict setObject:@"West Coast Style IPA" forKey:@"kPlace"];
    [dict setObject:@"Open Gate" forKey:@"kAlertmessage"];
    [dict setObject:@"All Views" forKey:@"kLocation"];
    [dict setObject:@"5 Devices" forKey:@"No_devices"];
    [dict setObject:@"07/11/2014 | 12:39PM" forKey:@"kDatetime"];
    [dict setObject:@"Lokesh Madav" forKey:@"kReceivername"];
    [dict setObject:@"http://www.surfnsandliquors.com/webart/products/1365.jpg" forKey:@"product_link"];
    [arrayList addObject:dict];

    return arrayList;
}

//Text Field border effects:

#pragma mark IMAGE OPs

+ (UIImage *)scaleAndRotateImage:(UIImage *)imgPic
{
    if (imgPic.size.width<imgPic.size.height)
    {
        if (!CGRectContainsRect(CGRectMake(0, 0, 640, 1136), CGRectMake(0, 0, imgPic.size.width, imgPic.size.height)))
            imgPic = [UIImage makeResizedImage:CGSizeMake(640, 1136) quality:kCGInterpolationDefault withImage:imgPic];
    }
    else
    {
        if (!CGRectContainsRect(CGRectMake(0, 0, 1136, 640), CGRectMake(0, 0, imgPic.size.width, imgPic.size.height)))
            imgPic = [UIImage makeResizedImage:CGSizeMake(1136, 640) quality:kCGInterpolationDefault withImage:imgPic];
    }
    
    int kMaxResolution = imgPic.size.width;
    CGImageRef imgRef = imgPic.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = imgPic.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            
            boundHeight = bounds.size.height;
            
            bounds.size.height = bounds.size.width;
            
            bounds.size.width = boundHeight;
            
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            
            boundHeight = bounds.size.height;
            
            bounds.size.height = bounds.size.width;
            
            bounds.size.width = boundHeight;
            
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            
            boundHeight = bounds.size.height;
            
            bounds.size.height = bounds.size.width;
            
            bounds.size.width = boundHeight;
            
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            
            boundHeight = bounds.size.height;
            
            bounds.size.height = bounds.size.width;
            
            bounds.size.width = boundHeight;
            
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            
            break;
            
        default:
            
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        
        CGContextTranslateCTM(context, -height, 0);
        
    }
    
    else {
        
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        
        CGContextTranslateCTM(context, 0, -height);
        
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageCopy;
    
}

+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize andImage:(UIImage *) sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    // UIGraphicsBeginImageContext(targetSize); // this will crop
    UIGraphicsBeginImageContextWithOptions(targetSize, 1.0f, 0.0f);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        //        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (UIImage *)makeResizedImage:(CGSize)newSize quality:(CGInterpolationQuality)interpolationQuality withImage:(UIImage*)oldImage isAspectFit:(BOOL)isAspectFit
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    oldImage = [self rotateImage:oldImage];
    CGImageRef imageRef = [oldImage CGImage];
    CGSize mySize = [oldImage size];
    CGFloat imageWidth = mySize.width;
    CGFloat imageHeight = mySize.height;
    CGRect tempRect;
    if(isAspectFit)
    {
        tempRect = [self aspectFittedRect:CGRectMake(0, 0,imageWidth, imageHeight) max:newRect];
        newRect = tempRect;
    }
    size_t bytesPerRow = CGImageGetBitsPerPixel(imageRef) / CGImageGetBitsPerComponent(imageRef) * newRect.size.width;
    bytesPerRow = (bytesPerRow + 15) & ~15;
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                bytesPerRow,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    CGContextSetInterpolationQuality(bitmap, interpolationQuality);
    CGContextDrawImage(bitmap, newRect, imageRef);
    CGImageRef resizedImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *resizedImage = [UIImage imageWithCGImage:resizedImageRef];
    
    CGContextRelease(bitmap);
    CGImageRelease(resizedImageRef);
    
    return resizedImage;
}
+ (CGRect) aspectFittedRect:(CGRect)inRect max:(CGRect)maxRect
{
    float currentHeight = CGRectGetHeight(inRect);
    float currentWidth = CGRectGetWidth(inRect);
    float liChange ;
    CGSize newSize ;
    if (currentWidth == currentHeight) // image is square
    {
        liChange = CGRectGetHeight(maxRect) / currentHeight;
        newSize.height = currentHeight * liChange;
        newSize.width = currentWidth * liChange;
    }
    else if (currentHeight > currentWidth) // image is landscape
    {
        liChange  = CGRectGetWidth(maxRect) / currentWidth;
        newSize.height = currentHeight * liChange;
        newSize.width = CGRectGetWidth(maxRect);
    }
    else                                // image is Portrait
    {
        liChange =CGRectGetHeight(maxRect) / currentHeight;
        newSize.height= CGRectGetHeight(maxRect);
        newSize.width = currentWidth * liChange;
    }
    return CGRectMake(0, 0,floorf(newSize.width), floorf(newSize.height));
}

+ (UIImage*)rotateImage:(UIImage*)image
{
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}
+ (NSString*) getDirectoryPathForMessageAttachmentWith:(NSString*)attachmentURL
{
    NSString *filePath = [NSString stringWithFormat: @"%@/VideoCache/", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    filePath = [filePath stringByAppendingFormat:@"%@.%@", [self UniqueNameGeneratorFromUrl:attachmentURL], [attachmentURL pathExtension]];
    return filePath;
}

// image caching code
+ (NSString*) UniqueNameGeneratorFromUrl:(NSString*)StringUrl
{
    if(!StringUrl)
        return @"";
    StringUrl = [StringUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	const char *str = [StringUrl UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return filename;
}

+(void)manageDirectoryForPath:(NSString*)pathString
{
	if(![[NSFileManager defaultManager] fileExistsAtPath:pathString])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:pathString withIntermediateDirectories:YES attributes:nil error:nil];
	}
}

+(NSString *) formatPhoneNumberToUS:(NSString *) normalPhoneNo
{
    if (normalPhoneNo.length < 10)
    {
        return normalPhoneNo;
    }
    NSString *firstThreeDigits = [normalPhoneNo substringWithRange:NSMakeRange(0,3)];
    NSString *secondThreeDigits = [normalPhoneNo substringWithRange:NSMakeRange(3,3)];
    NSString *lastFourDigits = [normalPhoneNo substringWithRange:NSMakeRange(6,4)];
    NSString *usFormatNumber = [NSString stringWithFormat:@"(%@) %@-%@",firstThreeDigits,secondThreeDigits,lastFourDigits];
    return usFormatNumber;
}


+(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)destSize
{
    float currentHeight = image.size.height;
    float currentWidth = image.size.width;
    float liChange ;
    CGSize newSize ;
    //    if (currentWidth < destSize.width && currentHeight < destSize.height){
    //        return image;
    //    }
    if (currentWidth == currentHeight) // image is square
    {
        liChange = destSize.height / currentHeight;
        newSize.height = currentHeight * liChange;
        newSize.width = currentWidth * liChange;
    }
    else if (currentHeight > currentWidth) // image is landscape
    {
        liChange  = destSize.width / currentWidth;
        newSize.height = currentHeight * liChange;
        newSize.width = destSize.width;
    }
    else                                // image is Portrait
    {
        liChange = destSize.height / currentHeight;
        newSize.height= destSize.height;
        newSize.width = currentWidth * liChange;
    }
    
    
    UIGraphicsBeginImageContext( newSize );
    CGContextRef                context;
    UIImage                     *outputImage = nil;
    
    context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [image drawInRect:CGRectMake( 0, 0, newSize.width, newSize.height )];
    outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef;
    int x = (newSize.width == destSize.width) ? 0 : (newSize.width - destSize.width)/2;
    int y = (newSize.height == destSize.height) ? 0 : (newSize.height - destSize.height )/2;
    if ( ( imageRef = CGImageCreateWithImageInRect( outputImage.CGImage, CGRectMake(x, y, destSize.width, destSize.height) ) ) ) {
        outputImage = [[UIImage alloc] initWithCGImage: imageRef] ;
        CGImageRelease( imageRef );
    }
    return  outputImage;
}


#pragma mark - Font & Color
+ (UIFont *)FontLightForSize:(int)size{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}
+ (UIFont *)FontForSize:(int)size{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}
+ (UIFont *)FontMediumForSize:(int)size{
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}
+ (UIFont *)FontBoldForSize:(int)size{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

+(UIFont *)fontMuseoSans100:(int)size
{
    return [UIFont fontWithName:@"OpenSans-Light" size:size];
}
+(UIFont *)fontMuseoSans300:(int)size
{
    return [UIFont fontWithName:@"OpenSans" size:size];
}
+(UIFont *)fontMuseoSans500:(int)size
{
    return [UIFont fontWithName:@"OpenSans-Semibold" size:size];
}
+(UIFont *)fontOswaldStncil:(int)size
{
    return [UIFont fontWithName:@"OswaldStencil-Bold" size:size];
}
#pragma mark - UITableView LoadMore
+ (NSInteger)loadMore : (NSInteger)numberOfItemsToDisplay arrayTemp:(NSMutableArray*)aryItems tblView:(UITableView*)tblList
{
    int count =0;
    NSUInteger i, totalNumberOfItems = [aryItems count];
    NSUInteger newNumberOfItemsToDisplay = MAX(25, numberOfItemsToDisplay + 25);
    newNumberOfItemsToDisplay = MIN(totalNumberOfItems, newNumberOfItemsToDisplay);
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (i=numberOfItemsToDisplay; i<newNumberOfItemsToDisplay; i++)
    {
        count++;
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    numberOfItemsToDisplay = newNumberOfItemsToDisplay;
    [tblList beginUpdates];
    [tblList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    if (numberOfItemsToDisplay == totalNumberOfItems)
        [tblList deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationLeft];
    NSIndexPath *scrollPointIndexPath;
    scrollPointIndexPath = (/* DISABLES CODE */ (0) < 0)?[NSIndexPath indexPathForRow:numberOfItemsToDisplay-0 inSection:0]:[NSIndexPath indexPathForRow:i-count inSection:0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100000000), dispatch_get_main_queue(), ^(void){
        [tblList scrollToRowAtIndexPath:scrollPointIndexPath atScrollPosition:UITableViewScrollPositionNone  animated:YES];
    });
    return numberOfItemsToDisplay;
}



#pragma mark - Toolbar for navigationbar
+ (UIToolbar*) setToolBar
{
    if (topBar == nil)
    {
        topBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 20.0, 320.0, 44.01)];
        topBar.clearsContextBeforeDrawing = NO;
        topBar.clipsToBounds= YES;
        topBar.tintColor = [UIColor colorWithWhite:0.305f alpha:0.0f];
        topBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        topBar.barStyle = -1;
    }
    topBar.frame= CGRectMake(0.0, 20.0, 320.0, 44.01);
//    if (![[[GlobalManager getAppDelegateInstance].navigationController.view subviews] containsObject:topBar])
//    {
//        [[GlobalManager getAppDelegateInstance].navigationController.view addSubview:topBar];
//    }
    return topBar;
}

+ (UIToolbar*) getToolBar
{
    return topBar;
}

+(id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)ta action:(SEL)act
{
	barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:systemItem target:ta action:act];
	return barButton;
}

+(id)initWithStyle:(UIBarButtonItemStyle)Style target:(id)ta action:(SEL)act defaultImg:(NSString*)defaultImage selectedImg:(NSString*)selectedImage
{
	UIImage* image = [UIImage imageNamed:defaultImage];
	CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
	UIButton* button = [[UIButton alloc] initWithFrame:frame];
    button.imageView.contentMode=UIViewContentModeScaleAspectFit;
	[button setImage:image forState:UIControlStateNormal];
	[button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
	[button addTarget:ta action:act forControlEvents:UIControlEventTouchUpInside];
	barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [barButton setImageInsets:UIEdgeInsetsMake(0.0f, 2.0f, 0.0f, 0.0f)];
	return barButton;
}


+ (UIToolbar*) setTopBar
{
    [[GlobalManager setToolBar] setItems:Nil animated:NO];
    return [GlobalManager setToolBar];
}

+ (UIColor*)BlackButtonTintColor
{
    return [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
}

+ (UIColor*)BlackButtonHeighlightedTintColor
{
    return [UIColor colorWithRed:63/255.0 green:63/255.0 blue:63/255.0 alpha:1.0];
}

#pragma mark - to get days numbers array

+(NSString*)converTodateFormate:(NSString *)dateString :(BOOL)isCurrentdateSendToserver
{
    NSDateFormatter *dateWriter = [[NSDateFormatter alloc] init];

    if(isCurrentdateSendToserver)
    {
       
            [dateWriter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            [dateWriter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            [dateWriter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:@"en_US"]];
            NSString *newdateString = [dateWriter stringFromDate:[NSDate date]];
            if (newdateString) {
                return newdateString;
            }
            return @"";
          
    }
    else
    {
        [dateWriter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [dateWriter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:@"en_US"]];
        [dateWriter setDateFormat:@"MMMM dd, yyyy hh:mm a"];
        NSDate *dateTmp = [dateWriter dateFromString:dateString];
        [dateWriter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *newdateString = [dateWriter stringFromDate:dateTmp];
        if (newdateString) {
            return newdateString;
        }
        return @"";
    }
   
}
+ (void) showStartProgress : (UIViewController*) parentView
{
//    [[[GlobalManager sharedInstance] ProgressTracker] hide:TRUE];
//    [GlobalManager sharedInstance].ProgressTracker = [[CustomProgress alloc] initWithWindow:[GlobalManager getAppDelegateInstance].window];
//	[[GlobalManager getAppDelegateInstance].window addSubview:[GlobalManager sharedInstance].ProgressTracker];
//	[GlobalManager sharedInstance].ProgressTracker.labelText = NSLocalizedStringFromTable(@"Please wait...", @"Localization", nil);
//    [GlobalManager sharedInstance].ProgressTracker.progress = 0.0;
//	[[GlobalManager sharedInstance].ProgressTracker show:TRUE];
}
+ (SMPageControl *)pageControl : (CGRect)frame{
    SMPageControl *_pageControl = [[SMPageControl alloc] initWithFrame:frame];
    _pageControl.userInteractionEnabled = NO;
    _pageControl.pageIndicatorImage = [UIImage imageNamed:@"slider_icon"];
    _pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"slider_icon_act@2x.png"];
    _pageControl.hidesForSinglePage = YES;
    _pageControl.clipsToBounds = YES;
    _pageControl.currentPage = 0;
    return _pageControl;
}


+ (UIFont *) getMediumFontForSize:(int)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize ];
}


+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}





@end

/*--------------------*/
// UIViewController + Cammon methods for the all screen
/*--------------------*/
@implementation UIViewController (CustomeAction)

-(void)setBackButton
{
    self.navigationItem.hidesBackButton = TRUE;
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_back_white"] forState:UIControlStateNormal];
//    [button setBackgroundImage:[UIImage imageNamed:@"back_h.png"] forState:UIControlStateHighlighted];
    button.contentMode = UIViewContentModeCenter;
    button.frame = CGRectMake(15, 0, 30, 29);//16,13
//      button.frame = CGRectMake(15, 0, 16,13);
    [button setExclusiveTouch:YES];
    [button addTarget:self action:@selector(btnBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *bnt_flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [bnt_flex setWidth:-7];
    
    self.navigationItem.leftBarButtonItems = @[bnt_flex,[[UIBarButtonItem alloc] initWithCustomView:button]];
}

-(void)setCancelButton:(SEL)selector withTarget:(id)target
{
    self.navigationItem.hidesBackButton = TRUE;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button setTitle:@"Cancel" forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeCenter;
    button.frame = CGRectMake(15, 0, 50, 30);
    [button setExclusiveTouch:YES];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    //    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *bnt_flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [bnt_flex setWidth:-7];
    
    self.navigationItem.rightBarButtonItems = @[bnt_flex,[[UIBarButtonItem alloc] initWithCustomView:button]];
}

-(void)setLeftButton
{
    self.navigationItem.hidesBackButton = TRUE;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setBackgroundImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    
    [button setImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];

    button.frame = CGRectMake(15, 0, 80, 15);
    [button setExclusiveTouch:YES];
    UIBarButtonItem *bnt_flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [bnt_flex setWidth:-7];
    
    self.navigationItem.leftBarButtonItems = @[bnt_flex,[[UIBarButtonItem alloc] initWithCustomView:button]];
}

-(void)setLeftBarButtonWithTitle:(NSString *)buttonTitle
{
    self.navigationItem.hidesBackButton = TRUE;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"btn_back_white"] forState:UIControlStateNormal];//@"menu_line.png"
//    [button setBackgroundImage:[UIImage imageNamed:@"menu_line_h.png"] forState:UIControlStateHighlighted];
    [button setTitle:buttonTitle forState:0];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button.titleLabel setFont:[GlobalManager fontMuseoSans500:16.0]];
    [button setTitleColor:[UIColor whiteColor] forState:0];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    button.contentMode = UIViewContentModeLeft;
    button.frame = CGRectMake(15, 0, 200, 29);
    [button setExclusiveTouch:YES];
    [button addTarget:self action:@selector(btnBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bnt_flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [bnt_flex setWidth:-7];
    
    self.navigationItem.leftBarButtonItems = @[bnt_flex,[[UIBarButtonItem alloc] initWithCustomView:button]];

}

//
-(void)removeBackButton
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}
/**
 *	Helps to navigate to previous screen From any where in App.
 *
 *	@param	sender	Button Actions
 */
-(void)btnBackButtonClicked:(id)sender
{
//    if ([GlobalManager getAppDelegateInstance].isFromOrderSummery == YES)
//    {
//        [GlobalManager getAppDelegateInstance].isFromOrderSummery = NO;
        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else
//    {
//        UINavigationController *navController = (UINavigationController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.centerPanel;
//        for(UIViewController *viewController in [navController viewControllers])
//        {
//            if([viewController isKindOfClass:[ListViewController class]])
//            {
//                [navController popToViewController:viewController animated:YES];
//                return;
//            }
//        }
//    }
}
/*--------------------*/
//Right Bar Button set up and action
/*--------------------*/
-(void)setRightBarButton
{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_notification.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_notification_h.png"] forState:UIControlStateHighlighted];
    [button setExclusiveTouch:YES];
    button.frame = CGRectMake(0, 0, 30, 30);
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:BADGE_COUNT] isEqualToString:@"0"]) {
        //        [button addSubview:lblBadge];
    }
    
    UIBarButtonItem *bnt_flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [bnt_flex setWidth:10];
    
    
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = @[bnt_flex,[[UIBarButtonItem alloc] initWithCustomView:button]];
    
    
}





@end




@implementation UIImageView(iPhone5Adjustments)
//
//-(void)awakeFromNib
//{
//    [super awakeFromNib];
//    if([UIScreen mainScreen].bounds.size.height<568) return;
//    //     self.contentMode = UIViewContentModeScaleAspectFit;
//    if([self.image isEqual:[UIImage imageNamed:@"Default.png"]])
//    {
//        NSString *strImage = [NSString stringWithFormat:@"Default-%.f.png",iPhoneType];
//        [self setImage:[UIImage imageNamed:strImage]];
//        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.image.size.height)];
//    }
//    else if([self.image isEqual:[UIImage imageNamed:@"bg_white.png"]])
//    {
//        [self setImage:[UIImage imageNamed:@"bg_white_568h.png"]];
//        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.image.size.height)];
//    }
//    else if([self.image isEqual:[UIImage imageNamed:@"splash.png"]])
//    {
//        [self setImage:[UIImage imageNamed:@"splash-568h.png"]];
//        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.image.size.height)];
//    }
//    else if([self.image isEqual:[UIImage imageNamed:@"background.png"]])
//    {
//        [self setImage:[UIImage imageNamed:@"background-568h.png"]];
//        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.image.size.height)];
//    }
//    else if([self.image isEqual:[UIImage imageNamed:@"Default.png"]])
//    {
//        [self setImage:[UIImage imageNamed:@"Default-568h.png"]];
//        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.image.size.height)];
//    }
//    else if([self.image isEqual:[UIImage imageNamed:@"bgPassword.png"]])
//    {
//        [self setImage:[UIImage imageNamed:@"bgPassword-568h.png"]];
//        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.image.size.height)];
//    }
//}
@end

@implementation UITextField (keyboardAppearance)

-(void)awakeFromNib
{
    if (self.tag == 500 || self.tag == 501 )
    {
        [self setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    }
    else if ( self.tag == 502 )
    {
        [self setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    }
  
    else
    {
        [self setValue:[UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    }

    if(self.tag == 100 || self.tag == 1000)
    {
        [self setFont:[GlobalManager  fontMuseoSans100:self.font.pointSize]];
    }
    else if(self.tag == 300 )
    {
        [self setFont:[GlobalManager  fontMuseoSans300:self.font.pointSize]];
    }
    else if(self.tag == 500 || self.tag == 501 )
    {
        [self setFont:[GlobalManager  fontMuseoSans500:self.font.pointSize]];
    }
    else
        [self setFont:[GlobalManager  FontForSize:self.font.pointSize]];
    
    if ( self.tag == 502 ) {
     
    }
    else{
        self.layer.cornerRadius = 2.0;
        self.keyboardAppearance = UIKeyboardAppearanceDark;
    }
}
+(void)customPlaceHoder:(UITextField*)textField placeHoderStr:(NSString*)placeHoderSr
{
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:placeHoderSr];
    NSDictionary* attributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    [attributedString setAttributes:attributes range:NSMakeRange(0, [attributedString length])];
    [textField setAttributedPlaceholder:attributedString];
}

-(CGRect)textRectForBounds:(CGRect)bounds
{
    if(self.tag==500)
        
    {
         return CGRectMake(30, bounds.origin.y, bounds.size.width-30, bounds.size.height);
    }
    else if(self.tag==501)
    {
        return CGRectMake(30, bounds.origin.y, bounds.size.width-47, bounds.size.height);
    }
    else if(self.tag==502)
    {
        return CGRectMake(10, bounds.origin.y, bounds.size.width-47, bounds.size.height);
    }
    else if(self.tag==1000)
    {
        return CGRectMake(12, bounds.origin.y, bounds.size.width-5, bounds.size.height);
    }
    else
    {
         return CGRectMake(5, bounds.origin.y, bounds.size.width-5, bounds.size.height);
    }
        
   
}
- (CGRect)editingRectForBounds:(CGRect)bounds
{
     if(self.tag==500)
     {
         return CGRectMake(30, bounds.origin.y, bounds.size.width-30, bounds.size.height);
     }
     else if(self.tag==501)
     {
         return CGRectMake(30, bounds.origin.y, bounds.size.width-47, bounds.size.height);
     }
     else if(self.tag==502)
     {
         return CGRectMake(10, bounds.origin.y, bounds.size.width-40, bounds.size.height);
     }
     else if(self.tag==1000)
     {
         return CGRectMake(12, bounds.origin.y, bounds.size.width-5, bounds.size.height);
     }
    else
    {
         return CGRectMake(5, bounds.origin.y, bounds.size.width-5, bounds.size.height);
    }
   
}
- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    
    
    
     if(self.tag==500)
     {
         return CGRectMake(30, bounds.origin.y, bounds.size.width-30, bounds.size.height);
     }
     else if(self.tag==501)
     {
         return CGRectMake(30, bounds.origin.y, bounds.size.width-47, bounds.size.height);
     }
     else if(self.tag==502)
     {
         return CGRectMake(10, bounds.origin.y, bounds.size.width-40, bounds.size.height);
     }
     else if(self.tag==1000)
     {
         return CGRectMake(12, bounds.origin.y, bounds.size.width-5, bounds.size.height);
     }
    else if(self.tag == 350)
    {
        return CGRectMake(0, bounds.origin.y, bounds.size.width, bounds.size.height);

    }
    else
    {
         return CGRectMake(5, bounds.origin.y, bounds.size.width-5, bounds.size.height);
    }
   
}

@end
@implementation UILabel (CustomFont)

-(void)awakeFromNib
{
    if(self.tag == 100)
    {
        [self setFont:[GlobalManager  fontMuseoSans100:self.font.pointSize]];
    }
    else if(self.tag == 300 )
    {
      [self setFont:[GlobalManager  fontMuseoSans300:self.font.pointSize]];
    }
    else if(self.tag == 500)
    {
        [self setFont:[GlobalManager  fontMuseoSans500:self.font.pointSize]];
    }
    else if (self.tag == 5000)
    {
        
    }
    else
        [self setFont:[GlobalManager  FontForSize:self.font.pointSize]];
}

@end

#pragma mark - UIButton

@implementation UIButton (CustomFont)
-(void)awakeFromNib
{
    if(self.tag == 500)
    {
        [self.titleLabel setFont:[GlobalManager fontMuseoSans500:self.titleLabel.font.pointSize]];
    }
    else if(self.tag == 300 )
    {
        [self.titleLabel setFont:[GlobalManager fontMuseoSans300:self.titleLabel.font.pointSize]];
    }
    else if(self.tag == 100)
    {
        [self.titleLabel setFont:[GlobalManager fontMuseoSans100:self.titleLabel.font.pointSize]];
    }
    else
    {
        [self.titleLabel setFont:[GlobalManager FontForSize:self.titleLabel.font.pointSize]];
    }
    [self setExclusiveTouch:YES];
}

@end
