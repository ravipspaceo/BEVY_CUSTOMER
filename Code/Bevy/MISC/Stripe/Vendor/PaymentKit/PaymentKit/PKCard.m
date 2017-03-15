//
//  PKCard.m
//  PKPayment Example
//
//  Created by CompanyName on 1/31/13.
//  Copyright (c) 2013 CompanyName. All rights reserved.
//

#import "PKCard.h"

@implementation PKCard

- (NSString *)last4
{
    if (_number.length >= 4) {
        return [_number substringFromIndex:([_number length] - 4)];
    } else {
        return nil;
    }
}

@end
