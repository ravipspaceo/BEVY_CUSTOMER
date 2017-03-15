//
//  CustomAlert.h
//  PhotoBud
//
//  Created by hidden brains on 03/04/14.
//  Copyright (c) 2014 hidden brains. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSLabel.h"

@protocol CustomAlertDelegate <NSObject>

-(void)btnCustomAlertSubmitClicked:(NSString*)input;
-(void)btnCustomAlertOKClicked:(int)tag;
-(void)btnCustomAlertYesClicked:(int)tag;
-(void)btnCustomPaymentAlertClicked:(int)tag;

-(void)btnInsufficientCreditsAlertClicked:(int)tag;

@end

@interface CustomAlert : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic,strong) id <CustomAlertDelegate> alertDelegate;

@property (nonatomic,strong) IBOutlet UIView *viewInputAlert,*viewSingle,*singleViewInternal,*viewConfirmation,*viewConfirmationSmall,*viewPaymentAlert,*viewPaymentAlertBox,*viewInsufficientCredits,*viewInnerInsufficientCredits;
//@property (nonatomic,strong) IBOutlet UILabel *lblSinglePopUpTitle;
@property(nonatomic,strong) IBOutlet MSLabel *lblSinglePopUpTitle,*lblInsufficientCredits;
@property (nonatomic,strong) IBOutlet UIScrollView *objScrl;
@property(nonatomic,strong) IBOutlet CustomTextField *txtEmailForgotPassword;
@property(nonatomic,strong) IBOutlet UIButton *btnCancel,*btnSubmit,*btnOk;
@property(nonatomic,assign) int alertTag,paymentMode;
@property(nonatomic,strong) IBOutlet UIButton *btnInappPurchase,*btnPaypal,*btnPaymentModeSubmit;

-(void)addSingleInputAler;
-(void)addSingleButtonAlert :(NSString *)msg;
-(void)addConfirmationAlert :(NSString *)msg;
-(void)addPaymentModeAlert;

-(IBAction)btnCancelClicked:(id)sender;
-(IBAction)btnOkClicked:(id)sender;
-(IBAction)btnSubmitClicked:(id)sender;
-(IBAction)btnYesClicked:(id)sender;

-(IBAction)btnInAppPurClicked:(UIButton *)sender;
-(IBAction)btnPaypalClicked:(UIButton *)sender;
-(IBAction)btnPaymentOptionSelected:(id)sender;



-(void)addInsufficientCredits:(NSString *)msg;

-(IBAction)btnInsufficientCreditsYesClicked:(id)sender;
-(IBAction)btnInsufficientCreditsNoClicked:(id)sender;

@end
