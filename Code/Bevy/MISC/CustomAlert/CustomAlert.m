//
//  CustomAlert.m
//  PhotoBud
//
//  Created by hidden brains on 03/04/14.
//  Copyright (c) 2014 hidden brains. All rights reserved.
//

#import "CustomAlert.h"

@interface CustomAlert ()

@end

@implementation CustomAlert

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lblSinglePopUpTitle.lineHeight = 15;
    
    self.lblInsufficientCredits.lineHeight = 15;
    
    self.lblInsufficientCredits.verticalAlignment = MSLabelVerticalAlignmentMiddle;
//    self.lblSinglePopUpTitle.verticalAlignment = MSLabelVerticalAlignmentMiddle;
    
    self.txtEmailForgotPassword.layer.borderWidth = self.viewInputAlert.layer.borderWidth = self.singleViewInternal.layer.borderWidth = self.btnOk.layer.borderWidth = self.viewConfirmationSmall.layer.borderWidth = self.viewPaymentAlertBox.layer.borderWidth = self.btnPaymentModeSubmit.layer.borderWidth = self.viewInnerInsufficientCredits.layer.borderWidth = 1.0f;
    self.viewInputAlert.layer.borderColor = self.txtEmailForgotPassword.layer.borderColor = self.singleViewInternal.layer.borderColor = self.btnOk.layer.borderColor  = self.viewConfirmationSmall.layer.borderColor = self.viewPaymentAlertBox.layer.borderColor = self.btnPaymentModeSubmit.layer.borderColor = self.viewInnerInsufficientCredits.layer.borderColor =  [NSGlobals getBorderColor].CGColor;
    
    self.viewPaymentAlert.frame =self.viewConfirmation.frame = self.viewSingle.frame = self.objScrl.frame = self.viewSingle.frame = self.objScrl.frame = self.viewInsufficientCredits.frame = CGRectMake(0, 0, [NSGlobals getAppDelegateInstance].window.frame.size.width, [NSGlobals getAppDelegateInstance].window.frame.size.height);
    
    [self addShadow:self.singleViewInternal];
    [self addShadow:self.viewInnerInsufficientCredits];
    [self addShadow:self.viewInputAlert];
    [self addShadow:self.viewPaymentAlertBox];
    [self addShadow:self.viewConfirmationSmall];
}

-(void)addShadow :(UIView*) vv {
    CALayer *layer = vv.layer;
    layer.shadowOffset = CGSizeMake(5, 10);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 4.0f;
    layer.shadowOpacity = 0.80f;
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
}

-(void)addSingleInputAler{
    self.objScrl.center = self.view.center;
    [self.view addSubview:self.objScrl];    
    [[NSGlobals getAppDelegateInstance].window addSubview:self.view];
}

-(void)addSingleButtonAlert :(NSString *)msg{
    [[NSGlobals getAppDelegateInstance].window endEditing:YES];
    [self.view addSubview:self.viewSingle];
    [[NSGlobals getAppDelegateInstance].window addSubview:self.view];
    self.lblSinglePopUpTitle.text = msg;
}


-(void)addInsufficientCredits:(NSString *)msg{
    [[NSGlobals getAppDelegateInstance].window endEditing:YES];
    [self.view addSubview:self.viewInsufficientCredits];
    [[NSGlobals getAppDelegateInstance].window addSubview:self.view];
}


-(void)addPaymentModeAlert
{
    self.btnInappPurchase.selected = self.btnPaypal.selected = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePopUpView)];
    tap.delegate = self;
    [tap setCancelsTouchesInView:YES];
    [self.viewPaymentAlert addGestureRecognizer:tap];

    [self.view addSubview:self.viewPaymentAlert];
    [[NSGlobals getAppDelegateInstance].window addSubview:self.view];
}
-(void)hidePopUpView
{
    [self.viewPaymentAlert removeFromSuperview];
    [self.view removeFromSuperview];
    self.btnPaypal.selected = NO;
    self.btnInappPurchase.selected = NO;
//    if ([self.alertDelegate respondsToSelector:@selector(btnCustomPaymentAlertClicked:)]) {
//        [self.alertDelegate btnCustomPaymentAlertClicked:self.paymentMode];
//    }

}


-(void)addConfirmationAlert :(NSString *)msg{
    [self.view addSubview:self.viewConfirmation];
    [[NSGlobals getAppDelegateInstance].window addSubview:self.view];
}

-(IBAction)btnCancelClicked:(id)sender{
    [self.txtEmailForgotPassword setText:@""];
    [self.objScrl removeFromSuperview];
    [self.view removeFromSuperview];
}

-(IBAction)btnOkClicked:(id)sender{
    [self.viewSingle removeFromSuperview];
    [self.view removeFromSuperview];
    if ([self.alertDelegate respondsToSelector:@selector(btnCustomAlertOKClicked:)]) {
        [self.alertDelegate btnCustomAlertOKClicked:self.alertTag];
    }
}

-(IBAction)btnSubmitClicked:(id)sender {
//    self.txtEmailForgotPassword.text = @"";
    [self.objScrl removeFromSuperview];
    [self.view removeFromSuperview];
    if ([self.alertDelegate respondsToSelector:@selector(btnCustomAlertSubmitClicked:)]) {
        [self.alertDelegate btnCustomAlertSubmitClicked:self.txtEmailForgotPassword.text];
    }
    self.txtEmailForgotPassword.text = @"";
}
-(IBAction)btnNOClicked:(id)sender{
//    [self.viewConfirmationSmall removeFromSuperview];
    [self.viewConfirmation removeFromSuperview];
    [self.view removeFromSuperview];
}

-(IBAction)btnYesClicked:(id)sender{
//    [self.viewConfirmationSmall removeFromSuperview];
    [self.viewConfirmation removeFromSuperview];
    [self.view removeFromSuperview];

    if ([self.alertDelegate respondsToSelector:@selector(btnCustomAlertYesClicked:)]) {
        [self.alertDelegate btnCustomAlertYesClicked:self.alertTag];
    }
}
-(IBAction)btnInsufficientCreditsYesClicked:(id)sender
{
    [self.viewInsufficientCredits removeFromSuperview];
    [self.view removeFromSuperview];
    
    if ([self.alertDelegate respondsToSelector:@selector(btnInsufficientCreditsAlertClicked:)]) {
        [self.alertDelegate btnInsufficientCreditsAlertClicked:1];
    }
}
-(IBAction)btnInsufficientCreditsNoClicked:(id)sender
{
    [self.viewInsufficientCredits removeFromSuperview];
    [self.view removeFromSuperview];
    
    if ([self.alertDelegate respondsToSelector:@selector(btnInsufficientCreditsAlertClicked:)]) {
        [self.alertDelegate btnInsufficientCreditsAlertClicked:0];
    }
}
-(IBAction)btnInAppPurClicked:(UIButton *)sender
{
    
    if (!sender.selected) {
        self.paymentMode = 0;
        sender.selected = YES;
        self.btnPaypal.selected = NO;
    }
    else{
        sender.selected = NO;
        self.paymentMode = 2;
    }
}
-(IBAction)btnPaypalClicked:(UIButton *)sender
{
    
    if (!sender.selected) {
        self.paymentMode = 1;
        sender.selected = YES;
        self.btnInappPurchase.selected = NO;
    }
    else{
        sender.selected = NO;
        self.paymentMode = 2;
    }
}
-(IBAction)btnPaymentOptionSelected:(id)sender
{
    
    [self.viewPaymentAlert removeFromSuperview];
    [self.view removeFromSuperview];
    
    if (self.btnInappPurchase.selected || self.btnPaypal.selected) {
        if ([self.alertDelegate respondsToSelector:@selector(btnCustomPaymentAlertClicked:)]) {
            if (self.btnInappPurchase.selected) {
                    [self.alertDelegate btnCustomPaymentAlertClicked:0];
            }
            else{
                [self.alertDelegate btnCustomPaymentAlertClicked:1];
            }
            
        }
    }
    

}
@end
