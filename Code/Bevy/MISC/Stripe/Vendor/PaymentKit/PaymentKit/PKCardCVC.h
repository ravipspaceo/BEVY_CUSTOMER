//
//  PKCardCVC.h
//  PKPayment Example
//
//  Created by CompanyName on 1/22/13.
//  Copyright (c) 2013 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKCardType.h"
#import "PKComponent.h"

@interface PKCardCVC : PKComponent

@property (nonatomic, readonly) NSString *string;

+ (instancetype)cardCVCWithString:(NSString *)string;
- (BOOL)isValidWithType:(PKCardType)type;
- (BOOL)isPartiallyValidWithType:(PKCardType)type;

@end
