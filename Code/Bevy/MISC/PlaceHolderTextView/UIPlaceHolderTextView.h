//
//  UIPlaceHolderTextView.h
//  Scanner
//
//  Created by CompanyName on 19/06/13.
//
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor,*borderColor;
@property (nonatomic, assign) BOOL needBorder;
@property (nonatomic, retain) UILabel *placeHolderLabel;
@property (nonatomic, assign) CGRect placeHolderFrame;
@property (nonatomic, assign) float horizontalPadding;

-(void)textChanged:(NSNotification*)notification;

@end
