//
//  CustomTextField.m
//  OnlineHunter
//
//  Created by CompanyName on 12/19/12.
//  Copyright (c) 2012 CompanyName. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField
@synthesize horizontalPadding, verticalPadding;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    if (![self.placeholder isEqualToString:@"Enter Email"]) {
        self.placeholder = @"";
    }
//    if ([self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
//        UIColor *color = [UIColor lightGrayColor];
//        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: color}];
//    } else {
//    }
    self.font = [UIFont systemFontOfSize:self.font.pointSize];
    self.keyboardAppearance = UIKeyboardAppearanceAlert;
}

- (void) drawPlaceholderInRect:(CGRect)rect
{
    [[UIColor blackColor] setFill];
    CGRect placeholderRect = CGRectMake(rect.origin.x, (rect.size.height- self.font.pointSize)/2, rect.size.width, self.font.pointSize);
    if (self.tag == 10020) {
        placeholderRect = CGRectMake(rect.origin.x, (rect.size.height- self.font.pointSize)/2+2, rect.size.width-60, self.font.pointSize);
    }
    [[self placeholder] drawInRect:placeholderRect withFont:[UIFont systemFontOfSize:self.font.pointSize]];
   
    
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    [[UIColor blackColor] setFill];
    horizontalPadding = 5;
    CGRect textRect = CGRectMake(bounds.origin.x+horizontalPadding, bounds.origin.y, bounds.size.width-horizontalPadding, bounds.size.height);
    if (self.tag == 10020) {
        textRect = CGRectMake(bounds.origin.x+30, bounds.origin.y, bounds.size.width-60, bounds.size.height);
    }
    return textRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    [[UIColor blackColor] setFill];
    CGRect textRect = CGRectMake(bounds.origin.x+horizontalPadding, bounds.origin.y, bounds.size.width-8-horizontalPadding, bounds.size.height);
    if (self.tag == 10020) {
        textRect = CGRectMake(bounds.origin.x+30, bounds.origin.y, bounds.size.width-8-60, bounds.size.height);
    }
    return textRect;

}

@end
