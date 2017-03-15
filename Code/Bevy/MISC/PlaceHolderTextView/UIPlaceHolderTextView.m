//
//  UIPlaceHolderTextView.m
//  Scanner
//
//  Created by CompanyName on 19/06/13.
//
//

#import "UIPlaceHolderTextView.h"

@interface UIPlaceHolderTextView ()
@end

@implementation UIPlaceHolderTextView

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if __has_feature(objc_arc)
#else
    [_placeHolderLabel release]; _placeHolderLabel = nil;
    [_placeholderColor release]; _placeholderColor = nil;
    [_placeholder release]; _placeholder = nil;
    [super dealloc];
#endif
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    if (!self.borderColor) {
        self.borderColor = [UIColor grayColor];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0]];
    }
    
    self.layer.cornerRadius = 5;
    if (self.tag == 10001)
    {
        self.layer.borderColor = self.borderColor.CGColor;
        self.layer.borderWidth = 1.0;
    }
    else if(self.tag == 10002)
    {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 1.0;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    [self addToolBar];
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}
- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}
- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    return bounds;
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        
        if (_placeHolderLabel == nil )
        {
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(7,10,self.bounds.size.width - 16,0)];
            
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            [self setTextContainerInset:UIEdgeInsetsMake(10,4,0,5)];
            [self addSubview:_placeHolderLabel];
        }
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

#pragma mark- Button for Key Board
-(void)addToolBar
{
    UIToolbar *numberPadButton = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberPadButton.barStyle = UIBarStyleBlackTranslucent;
    numberPadButton.items = [NSArray arrayWithObjects:
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton)],
                             nil];
    [numberPadButton sizeToFit];
      numberPadButton.tintColor=[UIColor whiteColor];
    self.inputAccessoryView = numberPadButton;
}

-(void)doneButton{
    [self resignFirstResponder];

}

@end
