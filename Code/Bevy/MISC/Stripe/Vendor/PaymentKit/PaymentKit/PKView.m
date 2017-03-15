//
//  PKPaymentField.m
//  PKPayment Example
//
//  Created by CompanyName on 1/22/13.
//  Copyright (c) 2013 CompanyName. All rights reserved.
//

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define DarkGreyColor RGB(0,0,0)
#define RedColor RGB(253,0,17)
#define DefaultBoldFont [UIFont boldSystemFontOfSize:17]

#define kPKViewPlaceholderViewAnimationDuration 0.25

#define kPKViewCardExpiryFieldStartX 84 + 200
#define kPKViewCardCVCFieldStartX 177 + 200

#define kPKViewCardExpiryFieldEndX 84
#define kPKViewCardCVCFieldEndX 150

#define kPKViewCardADDRESSZIPFieldX 177
#define kPKViewCardADDRESSZIPFieldEndX 230


#import "PKView.h"
#import "PKTextField.h"
#import "AddCardViewController.h"

@interface PKView () <PKTextFieldDelegate> {
@private
    BOOL _isInitialState;
    BOOL _isValidState;
}

@property (nonatomic, readonly, assign) UIResponder *firstResponderField;
@property (nonatomic, readonly, assign) PKTextField *firstInvalidField;
@property (nonatomic, readonly, assign) PKTextField *nextFirstResponder;

- (void)setup;
- (void)setupPlaceholderView;
- (void)setupCardNumberField;
- (void)setupCardExpiryField;
- (void)setupCardCVCField;
- (void)setupAddressZipField;

- (void)pkTextFieldDidBackSpaceWhileTextIsEmpty:(PKTextField *)textField;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardNumberFieldShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardCVCShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;

- (BOOL)cardAddressZipShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;



@property (nonatomic) UIView *opaqueOverGradientView;
@property (nonatomic) PKCardNumber *cardNumber;
@property (nonatomic) PKCardExpiry *cardExpiry;
@property (nonatomic) PKCardCVC *cardCVC;
@property (nonatomic) PKAddressZip *addressZip;
@end

#pragma mark -

@implementation PKView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    _isInitialState = YES;
    _isValidState = NO;

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [GlobalManager getAppDelegateInstance].window.frame.size.width, 190);
    self.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    backgroundImageView.image = [[UIImage imageNamed:@"textfield"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
//    [self addSubview:backgroundImageView];

    self.innerView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, self.frame.size.width - 32, 190)];
    self.innerView.clipsToBounds = YES;
    self.innerView.backgroundColor = [UIColor clearColor];
    [self setupCardNumberFieldLine];

    [self setupPlaceholderView];
    [self setupCardNumberField];
    [self setupCardExpiryField];
    [self setupCardCVCField];
    [self setupAddressZipField];

    [self.innerView addSubview:self.cardNumberField];
    [self.innerView addSubview:self.cardExpiryField];
    [self.innerView addSubview:self.cardCVCField];
    [self.innerView addSubview:self.cardADDRESSZip];
    [self.innerView addSubview:self.lblCardNo];
    [self.innerView addSubview:self.lblMMYY];
    [self.innerView addSubview:self.lblCVC];
    [self.innerView addSubview:self.lblPostelCode];
    self.innerView.userInteractionEnabled = YES;



    UIImageView *gradientImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 34)];
    gradientImageView.image = [UIImage imageNamed:@""];
    [self.innerView addSubview:gradientImageView];

//    self.opaqueOverGradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 9, 34)];
//    self.opaqueOverGradientView.backgroundColor = [UIColor colorWithRed:0.9686 green:0.9686
//                                                                   blue:0.9686 alpha:1.0000];
//    self.opaqueOverGradientView.alpha = 0.0;
//    [self.innerView addSubview:self.opaqueOverGradientView];

    [self addSubview:self.innerView];
    [self addSubview:self.placeholderView];

    [self stateCardNumber];
    self.userInteractionEnabled = YES;
}


- (void)setupPlaceholderView
{
    self.placeholderView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 0, 35, 25)];
//    self.placeholderView.backgroundColor = [UIColor clearColor];
    self.placeholderView.image = [UIImage imageNamed:@"img_card"];

    CALayer *clip = [CALayer layer];
    clip.frame = CGRectMake(32, 0, 4, 20);
//    clip.backgroundColor = [UIColor clearColor].CGColor;
    [self.placeholderView.layer addSublayer:clip];
}

- (void)setupCardNumberField
{
    self.cardNumberField = [[PKTextField alloc] initWithFrame:CGRectMake(50, 2, self.frame.size.width - 32, 20)];

    self.cardNumberField.delegate = self;

    self.cardNumberField.placeholder = NSLocalizedStringFromTable(@"placeholder.card_number", @"STPaymentLocalizable", nil);
    self.cardNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardNumberField.keyboardAppearance = UIKeyboardAppearanceDark;

    self.cardNumberField.textColor = DarkGreyColor;
    self.cardNumberField.font = [GlobalManager fontMuseoSans100:15];
    [self.cardNumberField setValue:[UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];

    [self.cardNumberField.layer setMasksToBounds:YES];
}


-(void)setupCardNumberFieldLine
{
    self.lblCardNo = [[UILabel alloc]initWithFrame:CGRectMake(0, 35, self.frame.size.width - 32, 1)];
    self.lblCardNo.backgroundColor = BasicSeparatorColor;
    
    self.lblMMYY = [[UILabel alloc]initWithFrame:CGRectMake(0, 135, self.frame.size.width/2 - 29, 1)];
    self.lblMMYY.backgroundColor = BasicSeparatorColor;
    
    self.lblCVC = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2 -2, 135, self.frame.size.width/2 - 29, 1)];
    self.lblCVC.backgroundColor = BasicSeparatorColor;
    
    self.lblPostelCode = [[UILabel alloc]initWithFrame:CGRectMake(0, 183, self.frame.size.width/2 - 29, 1)];
    self.lblPostelCode.backgroundColor = BasicSeparatorColor;
    
}

- (void)setupCardExpiryField
{
    self.cardExpiryField = [[PKTextField alloc] initWithFrame:CGRectMake(42, 110, 60, 20)];
    self.cardExpiryField.delegate = self;
    self.cardExpiryField.placeholder = NSLocalizedStringFromTable(@"placeholder.card_expiry", @"STPaymentLocalizable", nil);
    self.cardExpiryField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardExpiryField.keyboardAppearance = UIKeyboardAppearanceDark;

    self.cardExpiryField.textColor = DarkGreyColor;
    self.cardExpiryField.font = [GlobalManager fontMuseoSans100:15];
    [self.cardExpiryField setValue:[UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    
    CGFloat x = self.lblMMYY.frame.size.width/2 - self.cardExpiryField.frame.size.width/2;
    
    self.cardExpiryField.frame = CGRectMake(x,  110, 60, 20);
    [self.cardExpiryField.layer setMasksToBounds:YES];
}

- (void)setupCardCVCField
{
    self.cardCVCField = [[PKTextField alloc] initWithFrame:CGRectMake(self.frame.size.width/2 + 50, 110, 55, 20)];
    self.cardCVCField.delegate = self;
    self.cardCVCField.placeholder = NSLocalizedStringFromTable(@"placeholder.card_cvc", @"STPaymentLocalizable", nil);
    self.cardCVCField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardCVCField.keyboardAppearance = UIKeyboardAppearanceDark;

    self.cardCVCField.textColor = DarkGreyColor;
    self.cardCVCField.font = [GlobalManager fontMuseoSans100:15];
    [self.cardCVCField setValue:[UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    CGFloat x = self.frame.size.width/2 + self.lblCVC.frame.size.width/2 - self.cardCVCField.frame.size.width/2;
    
    self.cardCVCField.frame = CGRectMake(x,  110, 55, 20);

    [self.cardCVCField.layer setMasksToBounds:YES];
}

- (void)setupAddressZipField
{
    self.cardADDRESSZip = [[PKTextField alloc] initWithFrame:CGRectMake(15, 158, 100, 20)];
    self.cardADDRESSZip.delegate = self;
    self.cardADDRESSZip.placeholder = NSLocalizedStringFromTable(@"placeholder.card_zipcode", @"STPaymentLocalizable", nil);
    self.cardADDRESSZip.keyboardType = UIKeyboardTypeNamePhonePad;
    self.cardADDRESSZip.keyboardAppearance = UIKeyboardAppearanceDark;

    [self.cardADDRESSZip setReturnKeyType:UIReturnKeyDone];
    self.cardADDRESSZip.autocorrectionType = NO;
    self.cardADDRESSZip.textColor = DarkGreyColor;
    self.cardADDRESSZip.font = [GlobalManager fontMuseoSans100:15];
    [self.cardADDRESSZip setValue:[UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [self.cardADDRESSZip.layer setMasksToBounds:YES];
    CGFloat x = self.lblPostelCode.frame.size.width/2 - self.cardADDRESSZip.frame.size.width/2;
    
    self.cardADDRESSZip.frame = CGRectMake(x,  158, 100, 20);
    [self.cardADDRESSZip setAutocorrectionType:UITextAutocorrectionTypeNo];
}

#pragma mark - Accessors

- (PKCardNumber *)cardNumber
{
    return [PKCardNumber cardNumberWithString:self.cardNumberField.text];
}

- (PKCardExpiry *)cardExpiry
{
    return [PKCardExpiry cardExpiryWithString:self.cardExpiryField.text];
}

- (PKCardCVC *)cardCVC
{
    return [PKCardCVC cardCVCWithString:self.cardCVCField.text];
}

-(PKAddressZip *)cardAddressZipCode
{
    return [PKAddressZip addressZipWithString:self.cardADDRESSZip.text];
}

#pragma mark - State

- (void)stateCardNumber
{
    if (!_isInitialState) {
        // Animate left
        _isInitialState = YES;
//
//        [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             self.opaqueOverGradientView.alpha = 0.0;
//                         } completion:^(BOOL finished) {
//        }];
//        [UIView animateWithDuration:0.400
//                              delay:0
//                            options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
//                         animations:^{
////                             self.cardADDRESSZip.frame = CGRectMake(kPKViewCardADDRESSZIPFieldX,
////                                                                     self.cardADDRESSZip.frame.origin.y,
////                                                                     self.cardADDRESSZip.frame.size.width,
////                                                                     self.cardADDRESSZip.frame.size.height);
////                             self.cardExpiryField.frame = CGRectMake(self.cardExpiryField.frame.origin.x,
////                                     self.cardExpiryField.frame.origin.y,
////                                     self.cardExpiryField.frame.size.width,
////                                     self.cardExpiryField.frame.size.height);
////                             self.cardCVCField.frame = CGRectMake(kPKViewCardCVCFieldStartX,
////                                     self.cardCVCField.frame.origin.y,
////                                     self.cardCVCField.frame.size.width,
////                                     self.cardCVCField.frame.size.height);
////                             self.cardNumberField.frame = CGRectMake(12,
////                                     self.cardNumberField.frame.origin.y,
////                                     self.cardNumberField.frame.size.width,
////                                     self.cardNumberField.frame.size.height);
//                         }
//                         completion:^(BOOL completed) {
////                             [self.cardExpiryField removeFromSuperview];
////                             [self.cardCVCField removeFromSuperview];
////                             [self.cardADDRESSZip removeFromSuperview];
//                         }];
    }

//    [self.cardNumberField becomeFirstResponder];
}

- (void)stateMeta
{
    _isInitialState = NO;

    CGSize cardNumberSize;
    CGSize lastGroupSize;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if ([self.cardNumber.formattedString respondsToSelector:@selector(sizeWithAttributes:)]) {
        NSDictionary *attributes = @{NSFontAttributeName: DefaultBoldFont};

        cardNumberSize = [self.cardNumber.formattedString sizeWithAttributes:attributes];
        lastGroupSize = [self.cardNumber.lastGroup sizeWithAttributes:attributes];
    } else {
        cardNumberSize = [self.cardNumber.formattedString sizeWithFont:DefaultBoldFont];
        lastGroupSize = [self.cardNumber.lastGroup sizeWithFont:DefaultBoldFont];
    }
#else
    NSDictionary *attributes = @{NSFontAttributeName: DefaultBoldFont};

    cardNumberSize = [self.cardNumber.formattedString sizeWithAttributes:attributes];
    lastGroupSize = [self.cardNumber.lastGroup sizeWithAttributes:attributes];
#endif

    CGFloat frameX = self.cardNumberField.frame.origin.x - (cardNumberSize.width - lastGroupSize.width);

    [UIView animateWithDuration:0.05 delay:0.35 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.opaqueOverGradientView.alpha = 1.0;
                     } completion:^(BOOL finished) {
    }];
    [UIView animateWithDuration:0.400 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        self.cardADDRESSZip.frame = CGRectMake(kPKViewCardADDRESSZIPFieldEndX,
//                                               self.cardADDRESSZip.frame.origin.y,
//                                               self.cardADDRESSZip.frame.size.width,
//                                               self.cardADDRESSZip.frame.size.height);
//
//        self.cardExpiryField.frame = CGRectMake(self.cardExpiryField.frame.origin.x,
//                self.cardExpiryField.frame.origin.y,
//                self.cardExpiryField.frame.size.width,
//                self.cardExpiryField.frame.size.height);
//        self.cardCVCField.frame = CGRectMake(kPKViewCardCVCFieldEndX,
//                self.cardCVCField.frame.origin.y,
//                self.cardCVCField.frame.size.width,
//                self.cardCVCField.frame.size.height);
//        self.cardNumberField.frame = CGRectMake(frameX,
//                self.cardNumberField.frame.origin.y,
//                self.cardNumberField.frame.size.width,
//                self.cardNumberField.frame.size.height);
    }                completion:nil];

    [self addSubview:self.placeholderView];
//    [self.innerView addSubview:self.cardExpiryField];
//    [self.innerView addSubview:self.cardCVCField];
//    [self.innerView addSubview:self.cardADDRESSZip];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"textFiledBecomeFirstREsponder" object:nil];
    
//    [self.cardExpiryField becomeFirstResponder];
}

- (void)stateCardCVC
{
    [self.cardCVCField becomeFirstResponder];
}

- (void)stateCardAddress
{
    [self.cardADDRESSZip becomeFirstResponder];
//    [UIView animateWithDuration:0.400
//                          delay:0
//                        options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
//                     animations:^{
////                         self.cardADDRESSZip.frame = CGRectMake(kPKViewCardCVCFieldEndX-30,
////                                                                self.cardADDRESSZip.frame.origin.y,
////                                                                self.cardADDRESSZip.frame.size.width,
////                                                                self.cardADDRESSZip.frame.size.height);
////                         self.cardExpiryField.frame = CGRectMake(self.cardExpiryField.frame.origin.x,
////                                                                 self.cardExpiryField.frame.origin.y,
////                                                                 self.cardExpiryField.frame.size.width,
////                                                                 self.cardExpiryField.frame.size.height);
////                         self.cardCVCField.frame = CGRectMake(kPKViewCardExpiryFieldEndX-20,
////                                                              self.cardCVCField.frame.origin.y,
////                                                              self.cardCVCField.frame.size.width,
////                                                              self.cardCVCField.frame.size.height);
////                          self.cardNumberField.frame = CGRectMake(-170,
////                                                                  self.cardNumberField.frame.origin.y,
////                                                                  self.cardNumberField.frame.size.width,
////                                                                  self.cardNumberField.frame.size.height);
//                     }
//                     completion:^(BOOL completed) {
//                         //                         [self.cardExpiryField removeFromSuperview];
//                         //                         [self.cardCVCField removeFromSuperview];
//                         //                         [self.cardADDRESSZip removeFromSuperview];
//                     }];
}

- (BOOL)isValid
{
    return [self.cardNumber isValid] && [self.cardExpiry isValid] &&
            [self.cardCVC isValidWithType:self.cardNumber.cardType] && [self.cardAddressZipCode isValid];
}

- (PKCard *)card
{
    PKCard *card = [[PKCard alloc] init];
    card.number = [self.cardNumber string];
    card.cvc = [self.cardCVC string];
    card.expMonth = [self.cardExpiry month];
    card.expYear = [self.cardExpiry year];
    card.addressZip = [self.cardAddressZipCode string];

    return card;
}

- (void)setPlaceholderViewImage:(UIImage *)image
{
    if (![self.placeholderView.image isEqual:image]) {
        __block __unsafe_unretained UIView *previousPlaceholderView = self.placeholderView;
        [UIView animateWithDuration:kPKViewPlaceholderViewAnimationDuration delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.placeholderView.layer.opacity = 0.0;
                             self.placeholderView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2);
                         } completion:^(BOOL finished) {
            [previousPlaceholderView removeFromSuperview];
        }];
        self.placeholderView = nil;

        [self setupPlaceholderView];
        self.placeholderView.image = image;
        self.placeholderView.layer.opacity = 0.0;
        self.placeholderView.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8);
        [self insertSubview:self.placeholderView belowSubview:previousPlaceholderView];
        [UIView animateWithDuration:kPKViewPlaceholderViewAnimationDuration delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.placeholderView.layer.opacity = 1.0;
                             self.placeholderView.layer.transform = CATransform3DIdentity;
                         } completion:^(BOOL finished) {
        }];
    }
}

- (void)setPlaceholderToCVC
{
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:self.cardNumberField.text];
    PKCardType cardType = [cardNumber cardType];

    if (cardType == PKCardTypeAmex) {
        [self setPlaceholderViewImage:[UIImage imageNamed:@"cvc-amex"]];
    } else {
        [self setPlaceholderViewImage:[UIImage imageNamed:@"cvc"]];
    }
}

- (void)setPlaceholderToCardType
{
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:self.cardNumberField.text];
    PKCardType cardType = [cardNumber cardType];
    NSString *cardTypeName = @"img_card";

    switch (cardType) {
        case PKCardTypeAmex:
            cardTypeName = @"amex";
            break;
        case PKCardTypeDinersClub:
            cardTypeName = @"diners";
            break;
        case PKCardTypeDiscover:
            cardTypeName = @"discover";
            break;
        case PKCardTypeJCB:
            cardTypeName = @"jcb";
            break;
        case PKCardTypeMasterCard:
            cardTypeName = @"mastercard";
            break;
        case PKCardTypeVisa:
            cardTypeName = @"visa";
            break;
        default:
            break;
    }

    [self setPlaceholderViewImage:[UIImage imageNamed:cardTypeName]];
}

#pragma mark - Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.cardCVCField]) {
        [self setPlaceholderToCVC];
    }
    else {
        [self setPlaceholderToCardType];
    }

    if ([textField isEqual:self.cardNumberField] && !_isInitialState) {
        [self stateCardNumber];
    }
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.cardCVCField]) {
        if (![textField.text length]) {
            textField.text = @"";
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.cardADDRESSZip]) {
        [self.cardADDRESSZip resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if ([textField isEqual:self.cardNumberField]) {
        return [self cardNumberFieldShouldChangeCharactersInRange:range replacementString:replacementString];
    }

    if ([textField isEqual:self.cardExpiryField]) {
        return [self cardExpiryShouldChangeCharactersInRange:range replacementString:replacementString];
    }

    if ([textField isEqual:self.cardCVCField]) {
        return [self cardCVCShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:self.cardADDRESSZip]) {
        return [self cardAddressZipShouldChangeCharactersInRange:range replacementString:replacementString];
    }

    return YES;
}

- (void)pkTextFieldDidBackSpaceWhileTextIsEmpty:(PKTextField *)textField
{
    if (textField == self.cardCVCField)
        [self.cardExpiryField becomeFirstResponder];
    else if (textField == self.cardExpiryField)
        [self stateCardNumber];
}

- (BOOL)cardNumberFieldShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardNumberField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [PKTextField textByRemovingUselessSpacesFromString:resultString];
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:resultString];

    if (![cardNumber isPartiallyValid])
        return NO;

    if (replacementString.length > 0) {
        self.cardNumberField.text = [cardNumber formattedStringWithTrail];
    } else {
        self.cardNumberField.text = [cardNumber formattedString];
    }

    [self setPlaceholderToCardType];

    if ([cardNumber isValid]) {
        [self textFieldIsValid:self.cardNumberField];
        [self stateMeta];

    } else if ([cardNumber isValidLength] && ![cardNumber isValidLuhn]) {
        [self textFieldIsInvalid:self.cardNumberField withErrors:YES];

    } else if (![cardNumber isValidLength]) {
        [self textFieldIsInvalid:self.cardNumberField withErrors:NO];
    }

    return NO;
}

- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardExpiryField.text stringByReplacingCharactersInRange:range withString:replacementString];
    CGFloat x = self.lblMMYY.frame.size.width/2 - 30;
    
    if (resultString.length>0)
    {
        self.cardExpiryField.frame = CGRectMake(0,  110, self.frame.size.width/2 - 29, 20);
    }
    else
    {
        self.cardExpiryField.frame = CGRectMake(x,  110, 60, 20);

    }
    
    resultString = [PKTextField textByRemovingUselessSpacesFromString:resultString];
    PKCardExpiry *cardExpiry = [PKCardExpiry cardExpiryWithString:resultString];

    if (![cardExpiry isPartiallyValid]) return NO;

    // Only support shorthand year
    if ([cardExpiry formattedString].length > 5) return NO;

    if (replacementString.length > 0) {
        self.cardExpiryField.text = [cardExpiry formattedStringWithTrail];
    } else {
        self.cardExpiryField.text = [cardExpiry formattedString];
    }

    if ([cardExpiry isValid]) {
        [self textFieldIsValid:self.cardExpiryField];
        [self stateCardCVC];

    } else if ([cardExpiry isValidLength] && ![cardExpiry isValidDate]) {
        [self textFieldIsInvalid:self.cardExpiryField withErrors:YES];
    } else if (![cardExpiry isValidLength]) {
        [self textFieldIsInvalid:self.cardExpiryField withErrors:NO];
    }

    return NO;
}

- (BOOL)cardCVCShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardCVCField.text stringByReplacingCharactersInRange:range withString:replacementString];
    
    CGFloat x = self.frame.size.width/2 + self.lblCVC.frame.size.width/2 - 30;
    if (resultString.length>0)
    {
        self.cardCVCField.frame = CGRectMake(self.frame.size.width/2 -2,  110, self.frame.size.width/2 - 29, 20);
    }
    else
    {
        self.cardCVCField.frame = CGRectMake(x,  110, 60, 20);
        
    }

    
    resultString = [PKTextField textByRemovingUselessSpacesFromString:resultString];
    PKCardCVC *cardCVC = [PKCardCVC cardCVCWithString:resultString];
    PKCardType cardType = [[PKCardNumber cardNumberWithString:self.cardNumberField.text] cardType];

    // Restrict length
    if (![cardCVC isPartiallyValidWithType:cardType]) return NO;

    // Strip non-digits
    self.cardCVCField.text = [cardCVC string];

    if ([cardCVC isValidWithType:cardType]) {
        [self textFieldIsValid:self.cardCVCField];
        [self stateCardAddress];
    } else {
        [self textFieldIsInvalid:self.cardCVCField withErrors:NO];
    }

    return NO;
}

- (BOOL)cardAddressZipShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
{
    NSString *resultString = [self.cardADDRESSZip.text stringByReplacingCharactersInRange:range withString:replacementString];
    CGFloat x = self.lblPostelCode.frame.size.width/2 - 50;
    
    if (resultString.length>0)
    {
        self.cardADDRESSZip.frame = CGRectMake(0,  158, self.frame.size.width/2 - 29, 20);
    }
    else
    {
        self.cardADDRESSZip.frame = CGRectMake(x,  158, 100, 20);
        
    }
    
    resultString = [PKTextField textByRemovingUselessSpacesFromString:resultString];
    PKAddressZip *cardAddress = [PKAddressZip addressZipWithString:resultString];
    
    self.cardADDRESSZip.text = [cardAddress string];
    if (![cardAddress isValid]) {
        [self textFieldIsInvalid:self.cardADDRESSZip withErrors:NO];
     return NO;
    }
    else{
        self.cardADDRESSZip.text = [cardAddress string];
       [self textFieldIsValid:self.cardADDRESSZip];
    }

    return NO;
}


#pragma mark - Validations

- (void)checkValid
{
    if ([self isValid]) {
        _isValidState = YES;

        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:isValid:)]) {
            [self.delegate paymentView:self withCard:self.card isValid:YES];
        }

    } else if (![self isValid] && _isValidState) {
        _isValidState = NO;

        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:isValid:)]) {
            [self.delegate paymentView:self withCard:self.card isValid:NO];
        }
    }
}

- (void)textFieldIsValid:(UITextField *)textField
{
    textField.textColor = DarkGreyColor;
    [self checkValid];
}

- (void)textFieldIsInvalid:(UITextField *)textField withErrors:(BOOL)errors
{
    if (errors) {
        textField.textColor = RedColor;
    } else {
        textField.textColor = DarkGreyColor;
    }

    [self checkValid];
}

#pragma mark -
#pragma mark UIResponder
- (UIResponder *)firstResponderField;
{
    NSArray *responders = @[self.cardNumberField, self.cardExpiryField, self.cardCVCField, self.cardADDRESSZip];
    for (UIResponder *responder in responders) {
        if (responder.isFirstResponder) {
            return responder;
        }
    }

    return nil;
}

- (PKTextField *)firstInvalidField;
{
    if (![[PKCardNumber cardNumberWithString:self.cardNumberField.text] isValid])
        return self.cardNumberField;
    else if (![[PKCardExpiry cardExpiryWithString:self.cardExpiryField.text] isValid])
        return self.cardExpiryField;
    else if (![[PKCardCVC cardCVCWithString:self.cardCVCField.text] isValid])
        return self.cardCVCField;

    else if (![[PKAddressZip addressZipWithString:self.cardADDRESSZip.text] isValid])
        return self.cardADDRESSZip;

    return nil;
}

- (PKTextField *)nextFirstResponder;
{
    if (self.firstInvalidField)
        return self.firstInvalidField;

    return self.cardCVCField;
}

- (BOOL)isFirstResponder;
{
    return self.firstResponderField.isFirstResponder;
}

- (BOOL)canBecomeFirstResponder;
{
    return self.nextFirstResponder.canBecomeFirstResponder;
}

- (BOOL)becomeFirstResponder;
{
    return [self.nextFirstResponder becomeFirstResponder];
}

- (BOOL)canResignFirstResponder;
{
    return self.firstResponderField.canResignFirstResponder;
}

- (BOOL)resignFirstResponder;
{
    return [self.firstResponderField resignFirstResponder];
}

@end
