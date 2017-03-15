//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by CompanyName on 30/09/2013.
//  Copyright 2013 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+TPKeyboardAvoidingAdditions.h"

@interface TPKeyboardAvoidingScrollView : UIScrollView <UITextFieldDelegate, UITextViewDelegate>
- (void)contentSizeToFit;
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;
@end
