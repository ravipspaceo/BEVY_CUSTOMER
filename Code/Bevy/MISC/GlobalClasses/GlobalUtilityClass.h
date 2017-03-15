//
//  GlobalUtilityClass.h
//  ChatAppBase
//
//  Created by CompanyName on 1/18/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RateView.h"
#import "RateViewController.h"


@interface GlobalUtilityClass : NSObject <RateViewDelegate>
@property (strong, nonatomic)  UIImageView *viewBackground;
@property (strong, nonatomic)  UIView *viewForUpgrade;
@property(nonatomic, assign) CGFloat currentRating;

@property (nonatomic , strong) RateViewController *objRateView;

+ (GlobalUtilityClass *)sharedInstance;


+(NSString *) getImagePathForUserProfile:(NSString *)strUserJID;
+(NSString *) getThumbImagePathForUserProfile:(NSString *)strUserJID;
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize andImage:(UIImage *)sourceImage;
+ (NSData *)getCompressDataFromImage:(UIImage *)image;
//+ (void)addWaterMarkOnImage:(UIImage *)image withCompletionBlock:(void (^)(bool success, NSString *strFileName))completionBlock;
+(NSString *)getImagePathForMedia;
//+(UIImage *)addText:(UIImage *)img text:(NSString *)text1;

+(NSString *)getStringFromDate:(NSDate *)date;
-(void)createUpgradePopUp;
-(void)createRatingPopUp;

+(void)googleAnalyticsScreenTrack :(NSString*)screenName;
@end
