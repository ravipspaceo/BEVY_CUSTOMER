//
//  WS_Urls.h
//  PhotoBud
//
//  Created by CompanyName on 1/5/13.
//  Copyright (c) 2013 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WS_Urls : NSObject

+(NSString *) makeGetURL: (NSString *) url andParameters:(NSDictionary *) paramdata;
+(NSString *)getMainUrl;

#pragma mark - AUTHENTICATION

+(NSString *)getRegistrationURL:(NSDictionary *)parameters;

+(NSString *)getAccessCodeVerificationURL:(NSDictionary *)parameters;
+(NSString *)getFindUDIDURL:(NSDictionary *)parameters;

+(NSString *)getLoginURL:(NSDictionary *)parameters;
+(NSString *)getFacebookLoginURL:(NSDictionary *)parameters;
+(NSString *)getForgotPasswordURL:(NSDictionary *)parameters;

+(NSString *)getPhoneVerificationURL:(NSDictionary *)parameters;

#pragma mark - PROFILE

+(NSString *)getViewProfileURL:(NSDictionary *)parameters;
+(NSString *)getEditProfileURL:(NSDictionary *)parameters;
+(NSString *)getChangePasswordURL:(NSDictionary *)parameters;

#pragma mark - PRODUCTS

+(NSString *)getNearByStoreURL:(NSDictionary *)parameters;
+(NSString *)getChangeCartAddress:(NSDictionary *)parameters;
+(NSString *)getCategoryListURL:(NSDictionary *)parameters;
+(NSString *)getProductListURL:(NSDictionary *)parameters;

#pragma mark - SETTINGS

+(NSString *)getFeedbackForDriverURL:(NSDictionary *)parameters;
+(NSString *)getApplicationSettingsURL:(NSDictionary *)parameters;
+(NSString *)getStaticPagesURL:(NSDictionary *)parameters;

#pragma mark - ADD_CART

+(NSString *)getAddProductToCartURL:(NSDictionary *)parameters;
+(NSString *)getShowCartURL:(NSDictionary *)parameters;
+(NSString *)getRemoveProductFromCartURL:(NSDictionary *)parameters;
+(NSString *)getChangeQuantityURL:(NSDictionary *)parameters;
+(NSString *)getAddPromoCodeURL:(NSDictionary *)parameters;

#pragma mark - ORDER

+(NSString *)getPlaceORderURL:(NSDictionary *)parameters;
+(NSString *)getOrderStatusURL:(NSDictionary *)parameters;
+(NSString *)getOrderOnMapURL:(NSDictionary *)parameters;
+(NSString *)getOrderDetailsURL:(NSDictionary *)parameters;

#pragma mark - CARD

+(NSString *)getAddCardURL:(NSDictionary *)parameters;
+(NSString *)getCardListURL:(NSDictionary *)parameters;
+(NSString *)getDeleteCardURL:(NSDictionary *)parameters;

#pragma mark - Make Cart Empty

+(NSString *)getMakeCartEmptyURL:(NSDictionary *)parameters;

#pragma mark - FAQ ws
+(NSString *)getFAQURL:(NSDictionary *)parameters;

+(NSString *)getCountryListURL:(NSDictionary *)parameters;

+(NSString *)getMobileNumberVerificationURL:(NSDictionary *)parameters;
@end
