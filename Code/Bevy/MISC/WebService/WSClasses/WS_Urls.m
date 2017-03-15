//
//  WS_Urls.m
//  PhotoBud
//
//  Created by CompanyName on 1/5/13.
//  Copyright (c) 2013 CompanyName. All rights reserved.
//

#import "WS_Urls.h"

@implementation WS_Urls

//************ 108 Server and Local URLs ************//
//#define MAIN_URL @"http://108.170.62.152/webservice/bevy/WS/"
//#define MAIN_URL @"http://192.168.43.1/bevy_svn/WS/"
//************ - ************//

//************ STAGING URLs ************//
//#define MAIN_URL    @"http://staging.shopbevy.com/WS/"
//#define MAIN_URL @"http://52.19.110.72/WS/"
//************ - ************//


//************ APPLE STORE URLs ************//
//#define MAIN_URL @"https://shopbevy.com/WS/"
#define MAIN_URL @"https://shopbevy.com/mobile_itune/WS/"
//************ - ************//


#define REGISTRATION                @"registration?"
#define LOGIN                       @"login?"
#define FACEBOOK_LOGIN              @"facebook?"
#define FORGOT_PASSWORD             @"forgot_password?"

#define VIEW_PROFILE                @"view_profile?"
#define EDIT_PROFILE                @"edit_profile?"
#define CHANGE_PASSWORD             @"change_password?"

#define GET_NEAR_BY_STORE           @"get_near_by_store?"
#define CHANGE_CART_ADDRESS         @"change_cart_address?"

#define CATEGORY_LIST               @"category_list?"
#define PRODUCT_LIST                @"product_list?"
#define ORDER_STATUS                @"order_status?"

#define ORDER_ON_MAP                @"order_on_map_98?"
#define ORDER_DETAILS               @"order_details?"

#define FEEDBACK_FOR_DRIVER         @"feedback_for_driver?"
#define APPLICATION_SETTINGS_WS     @"application_settings?"
#define STATIC_PAGES                @"static_pages?"

#define ADD_PRODUCT_IN_CART         @"add_product_in_cart?"
#define SHOW_CART                   @"show_cart?"
#define REMOVE_CART_PRODUCT         @"remove_cart_product?"
#define CHANGE_QUANTITY             @"change_qty?"
#define ADD_PROMOCODE               @"add_promo_code?"
#define PLACE_ORDER                 @"place_new_order?"

#define ADD_CARD                    @"add_card?"
#define DELETE_CARD                 @"delete_card?"
#define CARD_LIST                   @"card_list?"
#define MAKE_CART_EMPTY             @"make_cart_empty?"

#define COUNTRY_LIST                @"country_list?"
#define MOBILE_NUMBER_VERIFICATION  @"mobile_number_verification?"

#define FAQ                         @"faq?"


#define ACCESS_CODE                 @"check_access?"
#define FIND_UDID                   @"find_udid?"
#define PHONE_VERIFICATION          @"phone_no_verified?"

#pragma mark - GLOBAL methods

+(NSString *)getMainUrl
{
    return MAIN_URL;
}

#pragma mark - AUTHENTICATION

+(NSString *)getRegistrationURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",REGISTRATION] andParameters:parameters];
}

+(NSString *)getAccessCodeVerificationURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",ACCESS_CODE] andParameters:parameters];
}

+(NSString *)getFindUDIDURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",FIND_UDID] andParameters:parameters];
}

+(NSString *)getLoginURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",LOGIN] andParameters:parameters];
}

+(NSString *)getFacebookLoginURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",FACEBOOK_LOGIN] andParameters:parameters];
}

+(NSString *)getForgotPasswordURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",FORGOT_PASSWORD] andParameters:parameters];
}

#pragma mark - PROFILE

+(NSString *)getViewProfileURL:(NSDictionary *)parameters
{
     return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",VIEW_PROFILE] andParameters:parameters];
}

+(NSString *)getEditProfileURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",EDIT_PROFILE] andParameters:parameters];
}

+(NSString *)getChangePasswordURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",CHANGE_PASSWORD] andParameters:parameters];
}

#pragma mark - PRODUCTS

+(NSString *)getNearByStoreURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",GET_NEAR_BY_STORE] andParameters:parameters];
}

+(NSString *)getChangeCartAddress:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",CHANGE_CART_ADDRESS] andParameters:parameters];
}

+(NSString *)getCategoryListURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",CATEGORY_LIST] andParameters:parameters];
}

+(NSString *)getProductListURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",PRODUCT_LIST] andParameters:parameters];
}

#pragma mark - Phone Number Verification
+(NSString *)getPhoneVerificationURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",PHONE_VERIFICATION] andParameters:parameters];
}

#pragma mark - SETTINGS

+(NSString *)getFeedbackForDriverURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",FEEDBACK_FOR_DRIVER] andParameters:parameters];
}

+(NSString *)getApplicationSettingsURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",APPLICATION_SETTINGS_WS] andParameters:parameters];
}

+(NSString *)getStaticPagesURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",STATIC_PAGES] andParameters:parameters];
}

#pragma mark - ADD_CART

+(NSString *)getAddProductToCartURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",ADD_PRODUCT_IN_CART] andParameters:parameters];
}

+(NSString *)getShowCartURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",SHOW_CART] andParameters:parameters];
}

+(NSString *)getRemoveProductFromCartURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",REMOVE_CART_PRODUCT] andParameters:parameters];
}

+(NSString *)getChangeQuantityURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",CHANGE_QUANTITY] andParameters:parameters];
}

+(NSString *)getAddPromoCodeURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",ADD_PROMOCODE] andParameters:parameters];
}

#pragma mark - ORDER

+(NSString *)getPlaceORderURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",PLACE_ORDER] andParameters:parameters];
}

+(NSString *)getOrderStatusURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",ORDER_STATUS] andParameters:parameters];
}

+(NSString *)getOrderOnMapURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",ORDER_ON_MAP] andParameters:parameters];
}

+(NSString *)getOrderDetailsURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",ORDER_DETAILS] andParameters:parameters];
}

#pragma mark - CARD

+(NSString *)getAddCardURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",ADD_CARD] andParameters:parameters];
}

+(NSString *)getCardListURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",CARD_LIST] andParameters:parameters];
}

+(NSString *)getDeleteCardURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",DELETE_CARD] andParameters:parameters];
}

+(NSString *)getCountryListURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",COUNTRY_LIST] andParameters:parameters];

}

+(NSString *)getMobileNumberVerificationURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",MOBILE_NUMBER_VERIFICATION] andParameters:parameters];
}

#pragma mark - Make Cart Empty
+(NSString *)getMakeCartEmptyURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",MAKE_CART_EMPTY] andParameters:parameters];
}

#pragma mark - FAQ
+(NSString *)getFAQURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",FAQ] andParameters:parameters];
}
#pragma mark - Url helper method

+(NSString *) makeGetURL: (NSString *) url andParameters:(NSDictionary *) paramdata
{
    if (paramdata==nil)
    {
        return url;
    }
    NSMutableDictionary *data=[NSMutableDictionary dictionaryWithDictionary:paramdata];    
    if ( [url rangeOfString:@"?"].length == 0)
    {
        url = [url stringByAppendingString:@"?"];
    }

    NSString *argStr=@"";
    NSArray *keyArray = [data allKeys];
    if ([keyArray count] > 0)
    {
        for ( int i = 0 ; i < [keyArray count]; i++ )
        {
            id tmp_data = [data objectForKey:[keyArray objectAtIndex:i]];
            NSString  *processed_string;
            if ([tmp_data isKindOfClass:[NSMutableArray class]])
            {
                NSMutableArray *tmp_arr;// = [[NSMutableArray alloc] init];
                tmp_arr = (NSMutableArray *) tmp_data;
                processed_string = [tmp_arr componentsJoinedByString:@","];
            }
            else
            {
                processed_string = (NSString *) tmp_data;
            }
            argStr = [argStr stringByAppendingFormat:@"&%@=%@" , [keyArray objectAtIndex:i] , processed_string];
        }
    }
    argStr = ([argStr length] > 0) ? [argStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""] : argStr;
    url=[url stringByAppendingFormat:@"%@",argStr];
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    return url;
}

@end
