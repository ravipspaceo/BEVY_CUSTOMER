//
//  Jupper
//
//  Created by CompanyName.
//  Copyright (c) 2012 CompanyName. All rights reserved.
//

#import "Validations.h"

@implementation Validations
UITextField *CurrentTextField;
UITextView *CurrentTextView;
#pragma mark - Email address validation.
+ (BOOL) validateEmail: (NSString *) myEmail error:(NSString**)error
{
    BOOL isValid = FALSE;
    if ([Validations isValidData:myEmail])
    {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if (![emailTest evaluateWithObject:myEmail])
        {
            *error = @"Please enter valid email address";
            isValid = FALSE;
        }
        else
        {
            isValid = TRUE;
            *error = @"";
        }
    }
    else
    {
        *error = @"Please enter email address";
        isValid = FALSE;
    }
    return isValid;
}
+ (BOOL) validateSpecialChars:(NSString *) strText{
    BOOL isValid = FALSE;
    NSString *emailRegex = @"[A-Z0-9a-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![emailTest evaluateWithObject:strText])
    {
        isValid = FALSE;
    }
    else
    {
        isValid = TRUE;
    }
    return isValid;
}

#pragma mark - Website address validation.
+ (BOOL) validateWebsite: (NSString *) myWebsite error:(NSString**)error
{
    BOOL isValid = FALSE;
    if ([Validations isValidData:myWebsite])
    {
        NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
        NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
        if (![urlTest evaluateWithObject:myWebsite])
        {
            *error = @"Invalid Website address";
            isValid = FALSE;
        }
        else
        {
            isValid = TRUE;
            *error = @"";
        }
    }
    else
    {
        *error = @"Website should not be blank";
        isValid = FALSE;
    }
    return isValid;
}

+ (BOOL) validateIPAddress:(NSString *) myIP error:(NSString **)error
{
    BOOL isValid = FALSE;
    if ([Validations isValidData:myIP])
    {
        //        NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
        NSString *urlRegEx = @"^((([2][5][0-5]|([2][0-4]|[1][0-9]|[0-9])?[0-9])\\.){3})([2][5][0-5]|([2][0-4]|[1][0-9]|[0-9])?[0-9])$";
        NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
        if (![urlTest evaluateWithObject:myIP])
        {
            *error = @"Invalid IP address";
            isValid = FALSE;
        }
        else
        {
            isValid = TRUE;
            *error = @"";
        }
    }
    else
    {
        *error = @"IP address should not be blank";
        isValid = FALSE;
    }
    return isValid;
}

#pragma mark - Password validations
+ (BOOL) validatePasswordLength : (NSString*) PasswordValue error:(NSString**)error
{
    BOOL isValid;
    NSString *phoneNumberRegex=@"((?=.*[0-9]).{5,25})";
    NSPredicate *phoneNumberTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneNumberRegex];
    
    if ([PasswordValue length] < 8 || [PasswordValue length] > 16)
    {
        isValid = FALSE;
        *error = @"Password must be between 8-16 character long. It should contain at least one digit.";
    }
    else
    {
        if ([phoneNumberTest evaluateWithObject:PasswordValue]) {
            isValid = TRUE;
            *error = @"";
        }
        else{
            isValid = FALSE;
            *error = @"Password must be between 8-16 character long. It should contain at least one digit.";
        }
        
    }
    return isValid;
}

+ (BOOL) comparePasswords:(NSString*) password confirmPassword:(NSString*)confirmPassword error:(NSString**)error
{
    if (![password isEqualToString:confirmPassword])
    {
        *error = @"New password must match with the confirm password.";
    }
    return [password isEqualToString:confirmPassword];
}

#pragma mark - Blank value validations
+ (BOOL) isValidData : (NSString*) activeValue
{
    BOOL isValid = FALSE;
    if ([[activeValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] || activeValue == NULL)
    {
        isValid = FALSE;
    }
    else
    {
        isValid = TRUE;
    }
    return isValid;
}


+(BOOL)validatePostCode : (NSString *)postCode
{
    BOOL testBool=NO;
    NSString *phoneNumberRegex = @"[A-Za-z][0-9]{1,10}$";
    
    NSPredicate *phoneNumberTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneNumberRegex];
    testBool = [phoneNumberTest evaluateWithObject:postCode];
    return testBool;
}

// Accepts US phone numbers
+ (BOOL)validatePhone:(NSString*)phone
{
//    if ([phone length] < 10 || [phone length] > 12)
//    {
//        return NO;
//    }
    BOOL testBool=NO;
    //UK number vaildation.
    //    NSString *phoneRegexUS2 = @"^[4-5]{2} [0-9]{2} [0-9]{2} [0-9]{2} [0-9]{2}$";
    //    NSString *phoneRegexUS = @"^[+]{1}[4]{2} [0-9]{3} [0-9]{3} [0-9]{4}$";
    
    NSString *phoneNumberRegex = @"^((\\+)|(00))[0-9]{8,15}$";

    NSPredicate *phoneNumberTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneNumberRegex];

    
//    NSString *phoneRegexUS5 = @"[0-9]*";
    //    NSString *phoneRegexUS1 = @"^[0]{2} [0-9]{10}$";
    //    NSString *phoneRegexUS2 = @"^[0][0-9]{3} [-] [0-9]{3} [0-9]{4}$";
    //    NSString *phoneRegexUS3 = @"^[0][0-9]{2} [-] [0-9]{4} [0-9]{4}$";
    //     NSString *phoneRegexUS4 = @"^[0][0-9]{4} [-] [0-9]{6}$";
//    NSPredicate *test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegexUS5];
    testBool = [phoneNumberTest evaluateWithObject:phone];
    
    //    if (!testBool) {
    //        test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegexUS];
    //        testBool = [test2 evaluateWithObject:phone];
    //    }
    //
    //    if (!testBool) {
    //        test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegexUS1];
    //        testBool = [test2 evaluateWithObject:phone];
    //    }
    //    if (!testBool) {
    //        test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegexUS2];
    //        testBool = [test2 evaluateWithObject:phone];
    //    }
    //    if (!testBool) {
    //        test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegexUS3];
    //        testBool = [test2 evaluateWithObject:phone];
    //    }
    //    if (!testBool) {
    //        test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegexUS4];
    //        testBool = [test2 evaluateWithObject:phone];
    //    }
    
    return testBool;
}

+(BOOL) validateAlphaNumeric:(NSString *) textValue
{
    BOOL isValid = FALSE;
    NSString *urlRegEx = @"^(?=.*\\d)(?=.*[A-Za-z]).{5,20}$";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    if (![urlTest evaluateWithObject:textValue])
    {
        isValid = FALSE;
    }
    else
    {
        isValid = TRUE;
    }
    return isValid;
}

// Works for 5 digit zipcodes
+ (BOOL)validateZipcode:(NSString*)zipcode
{
    if ([[NSNumberFormatter alloc] numberFromString:zipcode] == NULL || [zipcode length] < 3 || [zipcode length] > 10)
    {
        return NO;
    }
    return YES;
}

+ (NSString*) getPlainTextForDatabase : (NSString*) originalText
{
    return [originalText stringByReplacingOccurrencesOfString:@"'" withString:@""];
}

+ (BOOL) isValidInput:(UITextField *)inputTextField
{
    if (![Validations isValidData:inputTextField.text])
    {
        CurrentTextField = inputTextField;
        return NO;
    }
    return YES;
}
+(BOOL) checkUsernameValidation:(NSString *) username{
    BOOL isValid=NO;
    NSString *nameRegex = @"^[A-Z0-9a-z.]{5,90}$";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    if (![test evaluateWithObject:username])
    {
        isValid = NO;
    }
    else
    {
        isValid = YES;
    }
    username= [username stringByReplacingOccurrencesOfString:@"." withString:@""];
    BOOL iSecondTest = [username isEqualToString:@""];
    return isValid && !iSecondTest;
}  
+ (void)setWrongInputField:(UITextField *)textField
{
    CurrentTextField = textField;
}

+(void)setWrongInputView:(UITextView *)textView
{
    CurrentTextView = textView;
}

+ (UITextField *)getWrongInputField
{
    return CurrentTextField;
}

+ (UITextView *)getWrongInputView
{
    return CurrentTextView;
}

+ (BOOL)validateTitleFirstChar:(NSString*)enterdName
{
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    BOOL valid = [[[enterdName substringToIndex:1] stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
    return valid;
}

@end