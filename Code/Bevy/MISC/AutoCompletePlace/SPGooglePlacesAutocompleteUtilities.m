//
//  SPGooglePlacesAutocompleteUtilities.m
//  SPGooglePlacesAutocomplete
//
//  Created by CompanyName on 7/18/12.
//  Copyright (c) 2012 CompanyName. All rights reserved.
//

#import "SPGooglePlacesAutocompleteUtilities.h"

@implementation NSArray(SPFoundationAdditions)
- (id)onlyObject {
    return [self count] == 1 ? [self objectAtIndex:0] : nil;
}
@end

SPGooglePlacesAutocompletePlaceType SPPlaceTypeFromDictionary(NSDictionary *placeDictionary) {
    return [[placeDictionary objectForKey:@"types"] containsObject:@" "] ? SPPlaceTypeEstablishment : SPPlaceTypeGeocode;//@"establishment"
}

NSString *SPBooleanStringForBool(BOOL boolean) {
    return boolean ? @"true" : @"false";
}

NSString *SPPlaceTypeStringForPlaceType(SPGooglePlacesAutocompletePlaceType type) {
    return (type == SPPlaceTypeGeocode) ? @"geocode" : @"address";//@"establishment"
}

BOOL SPEnsureGoogleAPIKey() {
    BOOL userHasProvidedAPIKey = YES;
    if ([kGoogleAPIKey isEqualToString:@"YOUR_API_KEY"]) {
        userHasProvidedAPIKey = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"API Key Needed" message:@"Please replace kGoogleAPIKey with your Google API key." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    return userHasProvidedAPIKey;
}

void SPPresentAlertViewWithErrorAndTitle(NSError *error, NSString *title) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

extern BOOL SPIsEmptyString(NSString *string) {
    return !string || ![string length];
}