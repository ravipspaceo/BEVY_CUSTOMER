/*
 * Copyright (c) 28/01/2013 Mario Negro (@emenegro)
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "UIAlertView+Blocks.h"
#import <objc/runtime.h>

/*
 * Runtime association key.
 */
static NSString *kHandlerAssociatedKey = @"kHandlerAssociatedKey";

@implementation UIAlertView (Blocks)

#pragma mark - Showing

/*
 * Shows the receiver alert with the given handler.
 */
- (void)showWithHandler:(UIAlertViewHandler)handler {
    
    objc_setAssociatedObject(self, (__bridge const void *)(kHandlerAssociatedKey), handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setDelegate:self];
    [self show];
}

#pragma mark - UIAlertViewDelegate

/*
 * Sent to the delegate when the user clicks a button on an alert view.
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIAlertViewHandler completionHandler = objc_getAssociatedObject(self, (__bridge const void *)(kHandlerAssociatedKey));
    
    if (completionHandler != nil) {
        
        completionHandler(alertView, buttonIndex);
    }
}

#pragma mark - Utility methods

/*
 * Utility selector to show an alert with a title, a message and a button to dimiss.
 */
+ (void)showWithTitle:(NSString *)title message:(NSString *)message handler:(UIAlertViewHandler)handler
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"InfoPlist", nil)
                                          otherButtonTitles:nil];
    
    [alert showWithHandler:handler];
}

/*
 * Utility selector to show an alert with an "Error" title, a message and a button to dimiss.
 */
+ (void)showErrorWithMessage:(NSString *)message myTag:(int)myTag handler:(UIAlertViewHandler)handler
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APPNAME
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"InfoPlist", nil)
                                          otherButtonTitles:nil];
    alert.tag = myTag;
    [alert showWithHandler:handler];
}



/*
 * Utility selector to show an alert with a "Warning" title, a message and a button to dimiss.
 */
+ (void)showWarningWithMessage:(NSString *)message handler:(UIAlertViewHandler)handler
{    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Warning", @"InfoPlist", nil)
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"InfoPlist", nil)
                                          otherButtonTitles:nil];
    
    [alert showWithHandler:handler];
}

/*
 * Utility selector to show a confirmation dialog with a title, a message and two buttons to accept or cancel.
 */
+ (void)showConfirmationDialogWithTitle:(NSString *)title message:(NSString *)message handler:(UIAlertViewHandler)handler
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"No", @"InfoPlist", nil)
                                          otherButtonTitles:NSLocalizedStringFromTable(@"Yes", @"InfoPlist", nil), nil];
    
    [alert showWithHandler:handler];
}

+ (void)showConfirmationDialogWithTitle:(NSString *)title message:(NSString *)message firstButtonTitle:(NSString *) title1 secondButtonTitle:(NSString *) title2 handler:(UIAlertViewHandler)handler 
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:title1
                                          otherButtonTitles:title2, nil];
    
    [alert showWithHandler:handler];
}

+ (void)showConfirmationDialogWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *) btntitle handler:(UIAlertViewHandler)handler
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:btntitle
                                          otherButtonTitles:nil, nil];
    
    [alert showWithHandler:handler];
}
/*
 * Utility selector to show a forgot password dialog with a title, an input box, a message and two buttons to submit or cancel.
 */
+ (void)showForgotPassword:(UIAlertViewHandler)handler
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Forgot Password ?", @"InfoPlist", nil)
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"InfoPlist", nil)
                                          otherButtonTitles:NSLocalizedStringFromTable(@"OK", @"InfoPlist", nil), nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"language"] isEqualToString:@"AR"]) {
        [alert textFieldAtIndex:0].textAlignment = NSTextAlignmentRight;
    }
    else{
        [alert textFieldAtIndex:0].textAlignment = NSTextAlignmentLeft;
    }
    [[alert textFieldAtIndex:0] setPlaceholder:NSLocalizedStringFromTable(@"Enter Your Email",@"InfoPlist", nil)];
    [[alert textFieldAtIndex:0] setBorderStyle:UITextBorderStyleNone];
    [[alert textFieldAtIndex:0] setFont:[GlobalManager fontMuseoSans100:14.0]];
    [[[alert textFieldAtIndex:0] layer] setCornerRadius:4];
    [[alert textFieldAtIndex:0] setTag:100];
//    [[[alert textFieldAtIndex:0] layer] setMasksToBounds:YES];
//    [[alert textFieldAtIndex:0] setBackground:[GlobalManager getImageFromResource:@"inputbox"]];
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[alert textFieldAtIndex:0] setKeyboardAppearance:UIKeyboardAppearanceDark];
    [alert showWithHandler:handler];
}



+(void)showChangeMobileNumber:(UIAlertViewHandler)handler PhoneNumber :(NSString *)phoneNumber
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Edit Phone Number", @"InfoPlist", nil)
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"InfoPlist", nil)
                                          otherButtonTitles:NSLocalizedStringFromTable(@"Save", @"InfoPlist", nil), nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"language"] isEqualToString:@"AR"]) {
        [alert textFieldAtIndex:0].textAlignment = NSTextAlignmentRight;
    }
    else{
        [alert textFieldAtIndex:0].textAlignment = NSTextAlignmentLeft;
    }
    [[alert textFieldAtIndex:0] setText:NSLocalizedStringFromTable(phoneNumber,@"InfoPlist",nil)];
    [[alert textFieldAtIndex:0] setPlaceholder:NSLocalizedStringFromTable(@"Enter Your Phone Number",@"InfoPlist", nil)];
    [[alert textFieldAtIndex:0] setBorderStyle:UITextBorderStyleNone];
    [[alert textFieldAtIndex:0] setFont:[GlobalManager fontMuseoSans100:14.0]];
    [[[alert textFieldAtIndex:0] layer] setCornerRadius:4];
    [[alert textFieldAtIndex:0] setTag:100];
    //    [[[alert textFieldAtIndex:0] layer] setMasksToBounds:YES];
    //    [[alert textFieldAtIndex:0] setBackground:[GlobalManager getImageFromResource:@"inputbox"]];
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[alert textFieldAtIndex:0] setKeyboardAppearance:UIKeyboardAppearanceDark];
    [alert showWithHandler:handler];

}

+ (void)showPromoCode:(UIAlertViewHandler)handler
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Promo code?", @"InfoPlist", nil)
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"InfoPlist", nil)
                                          otherButtonTitles:NSLocalizedStringFromTable(@"OK", @"InfoPlist", nil), nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"language"] isEqualToString:@"AR"]) {
        [alert textFieldAtIndex:0].textAlignment = NSTextAlignmentRight;
    }
    else{
        [alert textFieldAtIndex:0].textAlignment = NSTextAlignmentLeft;
    }
    [[alert textFieldAtIndex:0] setPlaceholder:NSLocalizedStringFromTable(@"Enter Your promo code",@"InfoPlist", nil)];
    [[alert textFieldAtIndex:0] setBorderStyle:UITextBorderStyleNone];
    [[alert textFieldAtIndex:0] setFont:[GlobalManager fontMuseoSans100:14.0]];
    [[[alert textFieldAtIndex:0] layer] setCornerRadius:4];
    [[alert textFieldAtIndex:0] setTag:100];
    //    [[[alert textFieldAtIndex:0] layer] setMasksToBounds:YES];
    //    [[alert textFieldAtIndex:0] setBackground:[GlobalManager getImageFromResource:@"inputbox"]];
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[alert textFieldAtIndex:0] setKeyboardAppearance:UIKeyboardAppearanceDark];
    [alert showWithHandler:handler];
}

+ (void)showAddCompanyAlert:(UIAlertViewHandler)handler
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Add Company", @"InfoPlist", nil)
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"InfoPlist", nil)
                                          otherButtonTitles:NSLocalizedStringFromTable(@"Enter Company", @"InfoPlist", nil), nil];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"language"] isEqualToString:@"AR"]) {
        [alert textFieldAtIndex:0].textAlignment = NSTextAlignmentRight;
        [alert textFieldAtIndex:1].textAlignment = NSTextAlignmentRight;
    }
    else{
        [alert textFieldAtIndex:0].textAlignment = NSTextAlignmentLeft;
        [alert textFieldAtIndex:1].textAlignment = NSTextAlignmentLeft;
    }
    [[alert textFieldAtIndex:0] setPlaceholder:NSLocalizedStringFromTable(@"Enter Username",@"InfoPlist", nil)];
    [[alert textFieldAtIndex:1] setPlaceholder:NSLocalizedStringFromTable(@"Enter Password",@"InfoPlist", nil)];
    [[alert textFieldAtIndex:0] setBorderStyle:UITextBorderStyleNone];
    
    [[alert textFieldAtIndex:0] setFont:[GlobalManager FontLightForSize:16.0]];
    [[[alert textFieldAtIndex:0] layer] setCornerRadius:4];
    
    [[alert textFieldAtIndex:1] setFont:[GlobalManager FontLightForSize:16.0]];
    [[[alert textFieldAtIndex:1] layer] setCornerRadius:4];
    
    [[alert textFieldAtIndex:0] setTag:100];
    [[alert textFieldAtIndex:1] setTag:100];
    
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[alert textFieldAtIndex:0] setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    [alert textFieldAtIndex:1].secureTextEntry = YES;
    [[alert textFieldAtIndex:1] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[alert textFieldAtIndex:1] setKeyboardAppearance:UIKeyboardAppearanceDark];
    [alert showWithHandler:handler];
}


@end
