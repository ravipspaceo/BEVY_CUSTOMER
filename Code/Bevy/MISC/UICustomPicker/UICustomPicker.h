//
//  UICustomPicker.h
//  pickerTest
//
//  Created by CompanyName on 19/09/11.
//  Copyright 2011 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UICustomPicker;
#import "ALPickerView.h"
#import "SWActionSheet.h"


@protocol CustomPickerDelegate
@optional
-(void)CustomPickerValue:(id)retval;
-(void)adjustScrolling;
-(void)btnViewCustomClicked:(NSString*)doneValue;
-(void)pickerDoneClicked:(NSString*)doneValue withType:(NSString *)picker_type andSender:(UIButton *)sender;
-(void)pickerCancelClicked:(NSString*)doneValue withType:(NSString *)picker_type andSender:(UIButton *)sender;

-(void)picker:(UICustomPicker *)picker andDoneClicked:(NSString*)doneValue andIndex:(int)index;
-(void)picker:(UICustomPicker *)picker andCancelClicked:(NSString*)preValue;



@end

@interface UICustomPicker : UIViewController <UIPopoverControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate,ALPickerViewDelegate>
{
	UIPickerView *pickerView;
	UIPopoverController *popoverController;
	id senders;	
	NSString *preValue;
	UILabel *tempLable;
	UITextField *tempText;
	UIButton *button_Temp;
	NSString *pickerValue,*rowDictKey;
	NSDictionary *pickerDict;
	NSMutableArray *keyArray;
	int lWidth,lheight;
	id<CustomPickerDelegate>delegate;
    id target;     
 }
@property (nonatomic,strong) SWActionSheet *_actionSheetForIOS8;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) NSString *labelToolBarTitle;
@property (nonatomic,strong) UIActionSheet *actionSheet;
@property (nonatomic,readwrite) BOOL needMultiSelection;
@property (nonatomic,strong) NSString *preSelectionString;
@property (nonatomic,strong) NSString *selectionString;
@property (nonatomic,strong) NSMutableArray *arMultiRecords;
@property (nonatomic,strong) NSMutableArray *arPreMultiRecords;

@property(nonatomic,strong)id<CustomPickerDelegate>delegate;
@property(nonatomic,strong) NSString *PickerName;
@property(nonatomic,strong) UIButton *btnViewCustom;
@property(nonatomic,assign) BOOL needToShowCustomIcon;
@property(nonatomic,strong) UIToolbar *toolbar;

-(void)callSenders:(NSString*)pickerString;
-(NSMutableArray*)toolbarItem;
-(UIPickerView*)createPicker:(CGRect)rect;
-(UILabel*)createTitleLabel:(NSString*)labelTitle labelTextColor:(UIColor*)color width:(NSInteger)width;
-(void)initWithCustomPicker:(CGRect)rect inView:(id)AddView ContentSize:(CGSize)ContentSize pickerSize:(CGRect)pickerRect barStyle:(UIBarStyle)barStyle Recevier:(id)Receiver componentArray:(NSMutableArray *)componentArray  toolBartitle:(NSString*)toolBartitle textColor:(UIColor*)textColor needToSort:(BOOL)needToSort withDictKey:(NSString *) dictKey ;
-(void)initWithCustomPicker:(CGRect)rect inView:(id)AddView ContentSize:(CGSize)ContentSize pickerSize:(CGRect)pickerRect barStyle:(UIBarStyle)barStyle Recevier:(id)Receiver componentArray:(NSMutableArray *)componentArray toolBartitle:(NSString*)toolBartitle textColor:(UIColor*)textColor needToSort:(BOOL)needToSort needMultiSelection:(BOOL)needMultiSelection withDictKey:(NSString *) dictKey :(NSString*) prevSelcetedValues ;

-(UIToolbar*)createToolBar:(CGRect)rect BarStyle:(UIBarStyle)BarStyle toolBarTitle:(NSString*)toolBarTitle textColor:(UIColor*)textColor;
@end