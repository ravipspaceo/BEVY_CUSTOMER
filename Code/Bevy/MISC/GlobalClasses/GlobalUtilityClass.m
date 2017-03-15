//
//  GlobalUtilityClass.m
//  ChatAppBase
//
//  Created by CompanyName on 1/18/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "GlobalUtilityClass.h"

@implementation GlobalUtilityClass

+(NSString *) getImagePathForUserProfile:(NSString *)strUserJID{
    NSString *userProfilePath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *mediaPath = [libraryDirectory stringByAppendingPathComponent:@"Media"];
    NSString *profileDirectory = [mediaPath stringByAppendingPathComponent:@"Profile"];
    BOOL isDir = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:profileDirectory isDirectory:&isDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:profileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    userProfilePath = [profileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", strUserJID]];
    return userProfilePath;
}


+(NSString *) getThumbImagePathForUserProfile:(NSString *)strUserJID{
    NSString *userProfilePath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *mediaPath = [libraryDirectory stringByAppendingPathComponent:@"Media"];
    NSString *profileDirectory = [mediaPath stringByAppendingPathExtension:@"Profile"];
    BOOL isDir = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:profileDirectory isDirectory:&isDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:profileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    userProfilePath = [profileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_thumb.png", strUserJID]];
    return userProfilePath;
}

+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize andImage:(UIImage *)sourceImage
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
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
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


+(NSData *)getCompressDataFromImage:(UIImage *)image{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.05f;
    int maxFileSize = 120 * 120;
    NSData *imageDataTemp = UIImageJPEGRepresentation(image, compression);
    while ([imageDataTemp length] > maxFileSize && compression > maxCompression)
        {
        compression -= 0.1;
        imageDataTemp = UIImageJPEGRepresentation(image, compression);
        }
    return imageDataTemp;
}


+(NSString *)getImagePathForMedia{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *mediaPath = [libraryDirectory stringByAppendingPathComponent:@"Media"];

    mediaPath = [mediaPath stringByAppendingPathComponent:@"/Photo"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:mediaPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:mediaPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return mediaPath;
}

+ (GlobalUtilityClass *)sharedInstance
{
    static GlobalUtilityClass *objInstance = nil;
    if (nil == objInstance)
    {
        objInstance  = [[super allocWithZone:NULL] init];
    }
    return objInstance;
}

-(void)createUpgradePopUp
{
    self.viewBackground = [[UIImageView alloc]initWithFrame:[GlobalManager getAppDelegateInstance].window.frame];
    if (IS_IPHONE_6_PLUS) {
        [self.viewBackground setImage:[UIImage imageNamed:@"bg-736h"]];
    }
    else if (IS_IPHONE_6)
    {
        [self.viewBackground setImage:[UIImage imageNamed:@"bg-667h"]];
    }
    else if (IS_IPHONE_5)
    {
        [self.viewBackground setImage:[UIImage imageNamed:@"bg-568h"]];
    }
    else
    {
        [self.viewBackground setImage:[UIImage imageNamed:@"bg"]];
    }
    
    UIImageView *imgLogo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 182, 137)];
    imgLogo.frame = CGRectMake((self.viewBackground.frame.size.width- imgLogo.frame.size.width)/2, 44, 182, 137);
    imgLogo.image = [UIImage imageNamed:@"logo_s15"];
    
    UILabel *lblLine = [[UILabel alloc]initWithFrame:CGRectMake(20, 221, self.viewBackground.frame.size.width - 40, 2)] ;
    lblLine.backgroundColor = [UIColor whiteColor];

    
    UILabel *lblText = [[UILabel alloc]initWithFrame:CGRectMake(40, 230, self.viewBackground.frame.size.width - 80, 83)] ;
    [lblText setTextColor:[UIColor whiteColor]];
    [lblText setFont:[GlobalManager fontMuseoSans500:30]];
    lblText.text = @"UPGRADE YOUR BUTLER";
    [lblText setTextAlignment:NSTextAlignmentCenter];
    lblText.numberOfLines = 2;

    
    UILabel *lblLineBottom = [[UILabel alloc]initWithFrame:CGRectMake(20, 320, self.viewBackground.frame.size.width - 40, 2)] ;
    lblLineBottom.backgroundColor = [UIColor whiteColor];

    
    
    UILabel *lblUpgrade = [[UILabel alloc]initWithFrame:CGRectMake(20, 330, self.viewBackground.frame.size.width - 40, 74)] ;
    [lblUpgrade setTextColor:[UIColor whiteColor]];

    lblUpgrade.text = @"A newer sexier version of Bevy is available!";
    lblUpgrade.numberOfLines = 2;
    lblUpgrade.font = [GlobalManager fontMuseoSans300:25];
    lblUpgrade.textAlignment = NSTextAlignmentCenter;

    
    UIButton *btnUpgrade = [UIButton buttonWithType:UIButtonTypeCustom];
    btnUpgrade.exclusiveTouch = YES;
    btnUpgrade.backgroundColor = BasicAppThemeColor;
    btnUpgrade.frame = CGRectMake(50,(IS_IPHONE_4?415: 439), self.viewBackground.frame.size.width - 100, 40);

    btnUpgrade.titleLabel.font = [GlobalManager fontMuseoSans500:17];
    [btnUpgrade setTitle:@"UPGRADE NOW!" forState:UIControlStateNormal];
    [btnUpgrade setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnUpgrade setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    btnUpgrade.layer.cornerRadius = 3;
    
    [btnUpgrade addTarget:self action:@selector(btnUpgradeClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnUpgrade bringSubviewToFront:[GlobalManager getAppDelegateInstance].window];
    btnUpgrade.enabled = YES;
    
    [self.viewBackground removeFromSuperview];
    [self.viewBackground addSubview:imgLogo];
    
    [self.viewBackground addSubview:lblLine];
    
    [self.viewBackground addSubview:lblText];
    
    [self.viewBackground addSubview:lblLineBottom];
    
    [self.viewBackground addSubview:lblUpgrade];
    
    [[GlobalManager getAppDelegateInstance].window addSubview:self.viewBackground];

    [[GlobalManager getAppDelegateInstance].window  addSubview:btnUpgrade];

}

-(void)createRatingPopUp
{
    self.objRateView = [[RateViewController alloc]init];

    [[GlobalManager getAppDelegateInstance].window  addSubview:self.objRateView.view];

    self.objRateView.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.objRateView.view.transform = CGAffineTransformIdentity;

    } completion:^(BOOL finished) {
        
    }];
    
    
}

-(void)rateView:(RateView *)rateView didUpdateRating:(float)rating
{
    self.currentRating = [[NSString stringWithFormat:@"%.1f", rating] floatValue];
    NSLog(@"RATING: %f and Current Rating: %f", rating, self.currentRating);
}
-(void)btnRateClicked: (UIButton *)sender
{
    
}

-(void)btnUpgradeClicked:(UIButton*)sender
{
    NSURL *urlApp = [NSURL URLWithString: APP_STORE_URL];
    [[UIApplication sharedApplication] openURL:urlApp];
}

+(NSString *)getStringFromDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];

    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"dd-MM-yyyy hh:mm a"];
    NSString *strDate = [formatter stringFromDate:date];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    NSString *date1 = [formatter stringFromDate:date];
    NSString *date2 = [formatter stringFromDate:[NSDate date]];
    if ([date1 isEqualToString:date2]){
        [formatter setDateFormat:@"hh:mm a"];
        
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date];
        if (timeInterval<0)
            timeInterval = 0;
//        if (timeInterval>3600){
            strDate = [formatter stringFromDate:date];
//            strDate = [NSString stringWithFormat:@"%@ %@",@"Today",strDate];
            strDate = [NSString stringWithFormat:@"%@",strDate];

//        }
//        else{
//            if ((int)(timeInterval/60) < 1) {
//                strDate = @"Just now";
//            }
//            else
//                strDate = [NSString stringWithFormat:@"%d mins ago",(int)(timeInterval/60)];
        
//        }
    }else {
        [formatter setDateFormat:@"dd-MM-yyyy 00:00"];
        NSDate *tempdate = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
        if ([tempdate timeIntervalSinceDate:date]<3600*24*7){
            [formatter setDateFormat:@"EEE, hh:mm a"];
            strDate = [formatter stringFromDate:date];
            
            strDate = [NSString stringWithFormat:@"%@",strDate];
        }else{
//            [formatter setDateFormat:@"yyyy"];
//            date1 = [formatter stringFromDate:date];
//            date2 = [formatter stringFromDate:[NSDate date]];
            
                //            if ([date1 isEqualToString:date2]){
                [formatter setDateFormat:@"dd-MM hh:mm a"];
                strDate = [formatter stringFromDate:date];
                // }
        }
    }
    return strDate;
}


#pragma mark - Google Analytics Event Firing
+(void)googleAnalyticsScreenTrack :(NSString*)screenName
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    
    NSMutableDictionary *event = [[GAIDictionaryBuilder createScreenView] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    
    //isflurryenable
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_FLURRY]);
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_FLURRY] isEqualToString:@"YES"]) {
        [Flurry logEvent:screenName];
    }
    else{
        NSLog(@"Flurry disabled");
    }
}


@end
