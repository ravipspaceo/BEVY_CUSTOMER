//
//  Jupper
//
//  Created by CompanyName.
//  Copyright (c) 2012 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Validations : NSObject 

// Email Address validation
+ (BOOL) validateEmail: (NSString *) myEmail error:(NSString**)error;

// Website Address validation
+ (BOOL) validateWebsite: (NSString *) myWebsite error:(NSString**)error;

// IP Address validation
+ (BOOL) validateIPAddress:(NSString *) myIP error:(NSString **)error;

// Password validation
+ (BOOL) validatePasswordLength : (NSString*) PasswordValue error:(NSString**)error;
+ (BOOL) comparePasswords:(NSString*) password confirmPassword:(NSString*)confirmPassword error:(NSString**)error;

// Validate data
+ (BOOL) isValidData : (NSString*) activeValue;

//Validate Post Code
+(BOOL)validatePostCode : (NSString *)postCode;


// Accepts US phone numbers
+ (BOOL)validatePhone:(NSString*)phone;

// Works for 5 digit zipcodes
+ (BOOL)validateZipcode:(NSString*)zipcode;

+(NSString*) getPlainTextForDatabase : (NSString*) originalText;

+ (BOOL) isValidInput:(UITextField *)inputTextField;
+(UITextField *)getWrongInputField;
+(void)setWrongInputField:(UITextField *)textField;
+(BOOL)validateTitleFirstChar:(NSString*)enterdName;
+ (void)setWrongInputView:(UITextView *)textView;
+ (UITextView *)getWrongInputView;

+(BOOL) checkUsernameValidation:(NSString *) username;
+(BOOL) validateAlphaNumeric:(NSString *) textValue;
+ (BOOL) validateSpecialChars:(NSString *) strText;
@end
