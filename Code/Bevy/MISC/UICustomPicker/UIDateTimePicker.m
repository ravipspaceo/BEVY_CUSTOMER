//
//  UIDateTimePicker.m
//  pickerTest
//
//  Created by CompanyName on 20/09/11.
//  Copyright 2011 CompanyName. All rights reserved.
//

#import "UIDateTimePicker.h"
#import "AppDelegate.h"
#define intrval 1

@implementation UIDateTimePicker
@synthesize delegate;

-(void)initWithDatePicker:(CGRect)rect inView:(id)AddView ContentSize:(CGSize)ContentSize pickerSize:(CGRect)pickerRect  pickerMode:(UIDatePickerMode)datePickerMode dateFormat:(NSString*)dateFormat minimumDate:(NSDate*)minimumDate maxDate:(NSDate*)maxDate setCurrentDate:(NSDate*)setCurrentDate Recevier:(id)Receiver barStyle:(UIBarStyle)barStyle toolBartitle:(NSString*)toolBartitle textColor:(UIColor*)textColor
{
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"language"] isEqualToString:@"DA"])
    {
        self.localIdentifier=@"da";
    }else
    {
        self.localIdentifier=@"en_US";
    }
	formatString=[[NSString alloc] initWithString:dateFormat];
	senders=Receiver;
	if ([senders isKindOfClass:[UILabel class]])
	{
		tempLable=(UILabel *)senders;
		pickerDate=tempLable.text ;
	}
	else if ([senders isKindOfClass:[UITextField class]])
	{
		tempText=(UITextField *)senders;
		pickerDate=tempText.text;
	}
	else if ([senders isKindOfClass:[UIButton class]])
	{
		button_Temp = (UIButton *)senders;
		pickerDate=button_Temp.titleLabel.text ;
	}
    

    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		UIView *popoverView = [[UIView alloc] init];
		CGRect ToolRect=CGRectMake(0, 0,pickerRect.size.width, 44);
		popoverView.backgroundColor = [UIColor blackColor];
		UIViewController* popoverContent = [[UIViewController alloc] init];
		[popoverView addSubview:[self createToolBar:ToolRect BarStyle:barStyle toolBarTitle:toolBartitle textColor:textColor]];
		[popoverView addSubview:[self createDatePicker:minimumDate maxDate:maxDate datePickerMode:datePickerMode setCurrentDate:setCurrentDate frame:CGRectMake(pickerRect.origin.x, ToolRect.size.height, pickerRect.size.width,pickerRect.size.height) dateFormat:dateFormat]];
		popoverContent.view = popoverView;
        popoverView.backgroundColor = [UIColor clearColor];
        
		popoverView=nil;
		popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
		popoverController.delegate=self;
		
		popoverContent=nil;
		[popoverController setPopoverContentSize:ContentSize animated:NO];
		[popoverController presentPopoverFromRect:rect inView:AddView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [actionSheet removeFromSuperview];
	}
    else
    {
        CGRect ToolRect;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            UIView *masterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [GlobalManager getAppDelegateInstance].window.frame.size.width, 260)];
            ToolRect=CGRectMake(rect.origin.x,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 44);
            
            [masterView addSubview:[self createToolBar:ToolRect BarStyle:barStyle toolBarTitle:toolBartitle textColor:textColor]];
            
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationPortraitUpsideDown)
            {
                [masterView addSubview:[self createDatePicker:minimumDate maxDate:maxDate datePickerMode:datePickerMode setCurrentDate:setCurrentDate frame:CGRectMake(pickerRect.origin.x, ToolRect.size.height, pickerRect.size.width,pickerRect.size.height) dateFormat:dateFormat]];
            }else
            {
                ToolRect=CGRectMake(rect.origin.x,0,[AddView frame].size.width, 32);
                
                [masterView addSubview:[self createDatePicker:minimumDate maxDate:maxDate datePickerMode:datePickerMode setCurrentDate:setCurrentDate frame:CGRectMake(pickerRect.origin.x, ToolRect.size.height, pickerRect.size.width,pickerRect.size.height) dateFormat:dateFormat]];
            }
            
            
            self._actionSheetForIOS8 = [[SWActionSheet alloc] initWithView:masterView];
            
            [self presentActionSheet:self._actionSheetForIOS8];
        }else
        {
            
            actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            actionSheet.backgroundColor=[UIColor whiteColor];
            if ([AddView isKindOfClass:[UITabBarController class]])
            {
                UITabBarController *tabbarController=(UITabBarController*)AddView;
                [actionSheet showInView:tabbarController.tabBar];
                if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationPortraitUpsideDown)
                {
                    [actionSheet setFrame:CGRectMake(rect.origin.x,222, rect.size.width,260)];
                    ToolRect=CGRectMake(rect.origin.x,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 44);
                }
                else
                {
                    [actionSheet setFrame:CGRectMake(rect.origin.x, 130, 480,350)];
                    ToolRect=CGRectMake(rect.origin.x,0,480, 32);
                }
            }
            else
            {
                if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationPortraitUpsideDown)
                {
                    ToolRect=CGRectMake(rect.origin.x,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 44);
                    //            if (!IS_iPAD)
                    [actionSheet showInView:AddView];
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                        [actionSheet setFrame:CGRectMake(rect.origin.x, [AddView frame].size.height-(256-24), [GlobalManager getAppDelegateInstance].window.frame.size.width,240)];
                    }
                    else{
                        [actionSheet setFrame:CGRectMake(rect.origin.x, [AddView frame].size.height-(256), [GlobalManager getAppDelegateInstance].window.frame.size.width,240)];
                    }
                }else
                {
                    ToolRect=CGRectMake(rect.origin.x,0,[AddView frame].size.width, 32);
                    //            if (!IS_iPAD) {
                    [actionSheet showInView:AddView];
                    //            }
                    
                    [actionSheet setFrame:CGRectMake(rect.origin.x, [AddView frame].size.height-190, [AddView frame].size.width,160)];
                }
            }
            [actionSheet addSubview:[self createToolBar:ToolRect BarStyle:barStyle toolBarTitle:toolBartitle textColor:textColor]];
            [actionSheet addSubview:[self createDatePicker:minimumDate maxDate:maxDate datePickerMode:datePickerMode setCurrentDate:setCurrentDate frame:CGRectMake(pickerRect.origin.x, ToolRect.size.height, pickerRect.size.width,pickerRect.size.height) dateFormat:dateFormat]];
        }

        }
        
        
}
- (void)presentActionSheet:(SWActionSheet *)actionSheetObj
{
    [actionSheetObj showInContainerView];
}
-(UIToolbar*)createToolBar:(CGRect)rect BarStyle:(UIBarStyle)BarStyle toolBarTitle:(NSString*)toolBarTitle textColor:(UIColor*)textColor
{
    if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        rect=CGRectMake(0, 0, [GlobalManager getAppDelegateInstance].window.frame.size.width, 44);
    }else
    {
        rect=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 32);
    }
    UIToolbar *pickerToolbar=[[UIToolbar alloc] initWithFrame:rect];
	pickerToolbar.barStyle = BarStyle;
//   pickerToolbar.tintColor = [UIColor whiteColor];
    pickerToolbar.tintColor = [UIColor grayColor];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        pickerToolbar.barTintColor   = [UIColor grayColor];
        [pickerToolbar setTintColor:[UIColor whiteColor]];
    }
	pickerToolbar.opaque=YES;
	pickerToolbar.translucent=NO;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [pickerToolbar setItems:[self toolbarItem] animated:YES];
    }else{
        [pickerToolbar setItems:[self toolbarItemForPriorToiOS7] animated:YES];
    }
	if ([toolBarTitle length]!=0)
	{
		[pickerToolbar addSubview:[self createTitleLabel:toolBarTitle labelTextColor:textColor width:(rect.size.width-150)]];
	}
	return pickerToolbar;
}

-(UIDatePicker*)createDatePicker:(NSDate*)minDate maxDate:(NSDate*)maxDate datePickerMode:(UIDatePickerMode)datePickerMode setCurrentDate:(NSDate*)setCurrentDate frame:(CGRect)rect dateFormat:(NSString *)dateFormat
{
    if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        rect=CGRectMake(0, 42, [GlobalManager getAppDelegateInstance].window.frame.size.width, 218);
    }else
    {
        rect=CGRectMake(0, 32, [UIScreen mainScreen].bounds.size.height, 152);
    }
    
	dateFormatter=[[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:[NSString stringWithFormat:@"%@",dateFormat]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:self.localIdentifier]];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:self.localIdentifier]];
    datePicker=[[UIDatePicker alloc] initWithFrame:rect];
	datePicker.datePickerMode = datePickerMode;
	[datePicker setMinuteInterval:intrval];
    [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:self.localIdentifier]];
    [datePicker setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:self.localIdentifier]];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        datePicker.tintColor =[UIColor whiteColor];
    }
	if ([dateFormatter dateFromString:pickerDate])
	{
		[datePicker setDate:[dateFormatter dateFromString:pickerDate]];
	}
	else
    {
		[datePicker setDate:setCurrentDate];
	}
    if (maxDate) {
        [datePicker setMaximumDate:maxDate];
    }
    if (minDate) {
        [datePicker setMinimumDate:minDate];
    }
	[datePicker addTarget:self action:@selector(Result) forControlEvents:UIControlEventValueChanged];
	return datePicker;
}

-(void)Result
{
	dateFormatter=[[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:[NSString stringWithFormat:@"%@",formatString]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:self.localIdentifier]];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:self.localIdentifier]];
	pickerValue= [dateFormatter stringFromDate:[datePicker date]];
	dateFormatter=nil;
	[self callSenders:pickerValue];
}

-(IBAction)done_clicked:(id)sender
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self._actionSheetForIOS8 dismissWithClickedButtonIndex:0 animated:YES];
    }
	dateFormatter=[[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:[NSString stringWithFormat:@"%@",formatString]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:@"en_US"]];
    
	pickerValue= [dateFormatter stringFromDate:[datePicker date]];
     if ([(NSObject *)self.delegate respondsToSelector:@selector(adjustScrolling)])
         [delegate adjustScrolling];
	[self callSenders:pickerValue];
    if ([(NSObject *)self.delegate respondsToSelector:@selector(pickerDoneWithDate:)]) {
            [delegate pickerDoneWithDate:[dateFormatter dateFromString:pickerValue]];
    }

    dateFormatter=nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		[popoverController dismissPopoverAnimated:YES];
	}
	else
	{
		[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	}
}

-(UILabel*)createTitleLabel:(NSString*)labelTitle labelTextColor:(UIColor*)color width:(NSInteger)width
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		lWidth=4;
		lheight=36;
	}
	else
	{
		if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationPortraitUpsideDown)
		{
			lheight=36;    
			lWidth=4;
		}
		else
		{
			lWidth=2;
			lheight=28;
		}
	}
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70,lWidth,width,lheight)];
	label.textColor = color;
	label.backgroundColor = [UIColor clearColor];
	label.font = [GlobalManager FontMediumForSize:15.0];
	label.text = labelTitle;
    label.numberOfLines=0;
	label.textAlignment=NSTextAlignmentCenter;
	return label ;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self callSenders:pickerDate];
}

-(void)callSenders:(NSString*)pickerString
{
    if ([senders isKindOfClass:[UILabel class]])
    {
        tempLable=(UILabel *)senders;
        tempLable.text=pickerString;
        //senders=(UILabel*)senders;
    }
    else if ([senders isKindOfClass:[UITextField class]])
    {
        tempText=(UITextField *)senders;
        tempText.text=pickerString;
        //senders=(UITextField*)senders;
    }
    else if ([senders isKindOfClass:[UIButton class]])
    {
        button_Temp = (UIButton *)senders;
        [button_Temp setTitle:pickerString forState:UIControlStateNormal];
        [button_Temp setTitle:pickerString forState:UIControlStateSelected];
        //senders = (UIButton *)senders;
    }
    if ([(NSObject *)self.delegate respondsToSelector:@selector(DateTimePickerValue:)])
        [delegate DateTimePickerValue:senders];
}


-(IBAction)cancel_clicked:(id)sender
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self._actionSheetForIOS8 dismissWithClickedButtonIndex:0 animated:YES];
    }
     if ([(NSObject *)self.delegate respondsToSelector:@selector(adjustScrolling)])
         [delegate adjustScrolling];
    
	[self callSenders:pickerDate];
    
    if ([(NSObject *)self.delegate respondsToSelector:@selector(cancel_clicked:)])
        [delegate cancel_clicked:nil];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		[popoverController dismissPopoverAnimated:YES];
	}
    else
    {
		[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	}
}

-(NSMutableArray*)toolbarItemForPriorToiOS7
{
	NSMutableArray *barItems = [[NSMutableArray alloc] init];
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel_clicked:)];
    
	[barItems addObject:cancelBtn];
	
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[barItems addObject:flexSpace];
	
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done_clicked:)];
	[barItems addObject:doneBtn];
	return barItems ;
}


-(NSMutableArray*)toolbarItem
{
	NSMutableArray *barItems = [[NSMutableArray alloc] init];
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel_clicked:)];
	[barItems addObject:cancelBtn];
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[barItems addObject:flexSpace];
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done_clicked:)];
	[barItems addObject:doneBtn];
    
	return barItems ;
}
@end
