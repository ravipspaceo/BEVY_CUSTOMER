    //
//  UICustomPicker.m
//  pickerTest
//
//  Created by CompanyName on 19/09/11.
//  Copyright 2011 CompanyName. All rights reserved.
//

#import "UICustomPicker.h"

#define Separator @"--------------------"

@implementation UICustomPicker
@synthesize delegate;

-(void)initWithCustomPicker:(CGRect)rect inView:(id)AddView ContentSize:(CGSize)ContentSize pickerSize:(CGRect)pickerRect barStyle:(UIBarStyle)barStyle Recevier:(id)Receiver componentArray:(NSMutableArray *)componentArray  toolBartitle:(NSString*)toolBartitle textColor:(UIColor*)textColor needToSort:(BOOL)needToSort withDictKey:(NSString *) dictKey 
{
    self.needMultiSelection = NO;
    [self initWithCustomPicker:rect inView:AddView ContentSize:ContentSize pickerSize:pickerRect barStyle:barStyle Recevier:Receiver componentArray:componentArray toolBartitle:toolBartitle textColor:textColor needToSort:needToSort needMultiSelection:NO withDictKey:dictKey : @""];
}

-(void)initWithCustomPicker:(CGRect)rect inView:(id)AddView ContentSize:(CGSize)ContentSize pickerSize:(CGRect)pickerRect barStyle:(UIBarStyle)barStyle Recevier:(id)Receiver componentArray:(NSMutableArray *)componentArray toolBartitle:(NSString*)toolBartitle textColor:(UIColor*)textColor needToSort:(BOOL)needToSort needMultiSelection:(BOOL)needMultiSelection withDictKey:(NSString *) dictKey :(NSString*) prevSelcetedValues
{
    self.labelToolBarTitle = toolBartitle;
    rowDictKey=dictKey;
    self.arMultiRecords = [NSMutableArray arrayWithArray:componentArray];
    self.arPreMultiRecords = [NSMutableArray arrayWithArray:self.arMultiRecords];
    if ([prevSelcetedValues isEqualToString:@""]) {
        
        self.selectionString = @"";
//        self.selectionString = [NSString stringWithFormat:@",%@,",[self.arMultiRecords
//                                                                   componentsJoinedByString:@","]];
        
    } else{
//        prevSelcetedValues = [prevSelcetedValues stringByReplacingOccurrencesOfString:@", " withString:@","];
        self.selectionString = [NSString stringWithFormat:@"%@, ",prevSelcetedValues];
        
        self.selectionString = [self.selectionString stringByReplacingCharactersInRange:NSMakeRange(self.selectionString.length-2, 2) withString:@""];
    }
    
    self.preSelectionString = self.selectionString;
    self.needMultiSelection = needMultiSelection;
    target=AddView;
    
    if (![componentArray count]) 
    {
        return;
    }
    
	senders=Receiver;
	pickerValue=@"";
	if ([senders isKindOfClass:[UILabel class]])
    {
		tempLable=(UILabel *)senders;
        preValue=[[NSString alloc] initWithFormat:@"%@",tempLable.text];
	}
	else if ([senders isKindOfClass:[UITextField class]])
    {
		tempText=(UITextField*)senders;
		preValue=[[NSString alloc] initWithFormat:@"%@",tempText.text];
	}
	else if ([senders isKindOfClass:[UIButton class]])
	{
		button_Temp = (UIButton *)senders;
		preValue=[button_Temp titleForState:0];
	}
    if (needToSort)
    {
        keyArray = [[NSMutableArray alloc] initWithArray:[componentArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    else
    {
        keyArray = [[NSMutableArray alloc] initWithArray:[componentArray mutableCopy]];
        if(needMultiSelection && self.selectionString.length)
        {
            NSMutableArray *dummyArray = [NSMutableArray arrayWithArray:[self.selectionString componentsSeparatedByString:@", "]];
            
            NSMutableArray *finalArray = [[NSMutableArray alloc] init];
            NSMutableArray *finalArray1 = [[NSMutableArray alloc] init];
            for (NSMutableDictionary *dict in keyArray) {
                if ([dummyArray containsObject:[dict objectForKey:@"currency_code"]]) {
                    [finalArray addObject:dict];
                }
                else{
                    [finalArray1 addObject:dict];
                }
            }
            
            [keyArray removeAllObjects];
            [keyArray addObjectsFromArray:finalArray];
            [keyArray addObjectsFromArray:finalArray1];
            
//            NSString *strID = [[keyArray objectAtIndex:row] objectForKey:@"name"];
//            if (!strID)
//            {
//                strID = [[keyArray objectAtIndex:row] objectForKey:@"name"];
//            }
        }
    }
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		UIView *popoverView = [[UIView alloc] init];
		CGRect ToolRect=CGRectMake(0, 0,pickerRect.size.width, 44);
		popoverView.backgroundColor = [UIColor whiteColor];
		UIViewController* popoverContent = [[UIViewController alloc] init];	
		[popoverView addSubview:[self createToolBar:ToolRect BarStyle:barStyle toolBarTitle:toolBartitle textColor:textColor]];
        if (needMultiSelection){
            [popoverView addSubview:[self createMultiPicker:CGRectMake(0, 44, pickerRect.size.width,pickerRect.size.height)]];
        }
        else
            [popoverView addSubview:[self createPicker:CGRectMake(0, 44, pickerRect.size.width,pickerRect.size.height)]];
		popoverContent.view = popoverView;
	
		popoverView=nil;
		popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
		popoverController.delegate=self;
		
		popoverContent=nil;
		[popoverController setPopoverContentSize:ContentSize animated:NO];
		[popoverController presentPopoverFromRect:rect inView:AddView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
    else
    {
		CGRect ToolRect;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            UIView *masterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [GlobalManager getAppDelegateInstance].window.frame.size.width, 260)];
            ToolRect=CGRectMake(0,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 44);
            
            self.toolbar=[self createToolBar:ToolRect BarStyle:barStyle toolBarTitle:toolBartitle textColor:textColor];
            [masterView addSubview:self.toolbar];
            
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationPortraitUpsideDown)
            {
                [masterView addSubview:[self createPicker:CGRectMake(pickerRect.origin.x, 44, [GlobalManager getAppDelegateInstance].window.frame.size.width,216)]];
            }else
            {
                [masterView addSubview:[self createPicker:CGRectMake(pickerRect.origin.x, 32,[GlobalManager getAppDelegateInstance].window.frame.size.width,160)]];
            }
            
            
            self._actionSheetForIOS8 = [[SWActionSheet alloc] initWithView:masterView];
            
            [self presentActionSheet:self._actionSheetForIOS8];
        }
        else{
            self.actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            if ([AddView isKindOfClass:[UITabBarController class]])
            {
                UITabBarController *tabbarController=(UITabBarController*)AddView;
                [self.actionSheet showInView:tabbarController.tabBar];
                if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationPortraitUpsideDown)
                {
                    [self.actionSheet setFrame:CGRectMake(0,IS_IPHONE_5?310:222, [GlobalManager getAppDelegateInstance].window.frame.size.width,260)];
                    ToolRect=CGRectMake(0,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 44);
                }
                else
                {
                    [self.actionSheet setFrame:CGRectMake(rect.origin.x, 130, iPhoneType,350)];
                    ToolRect=CGRectMake(rect.origin.x,0,iPhoneType, 32);
                }
            }
            else
            {
                if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationPortraitUpsideDown)
                {
                    ToolRect=CGRectMake(0,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 44);
                    [self.actionSheet showInView:AddView];
                    [self.actionSheet setFrame:CGRectMake(0, [GlobalManager getAppDelegateInstance].window.frame.size.height-(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?needMultiSelection?256:240:256), [GlobalManager getAppDelegateInstance].window.frame.size.width,240)];
                }else
                {
                    ToolRect=CGRectMake(0,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 32);
                    [self.actionSheet showInView:AddView];
                    [self.actionSheet setFrame:CGRectMake(rect.origin.x, [AddView frame].size.height-190, [AddView frame].size.width,160)];
                }
            }
            self.actionSheet.backgroundColor=[UIColor whiteColor];
            self.toolbar=[self createToolBar:ToolRect BarStyle:barStyle toolBarTitle:toolBartitle textColor:textColor];
            [self.actionSheet addSubview:self.toolbar];
            
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationPortraitUpsideDown)
            {
                if(needMultiSelection)
                {
                    [self.actionSheet addSubview:[self createMultiPicker:CGRectMake(pickerRect.origin.x, ToolRect.size.height, pickerRect.size.width,pickerRect.size.height)]];
                }
                else
                {
                    [self.actionSheet addSubview:[self createPicker:CGRectMake(pickerRect.origin.x, 44, [GlobalManager getAppDelegateInstance].window.frame.size.width,216)]];
                }
                
            } else
            {
                [self.actionSheet addSubview:[self createPicker:CGRectMake(pickerRect.origin.x, 32,[GlobalManager getAppDelegateInstance].window.frame.size.width,160)]];
            }
        
        }

    
	}
}

- (void)presentActionSheet:(SWActionSheet *)actionSheet
{
    [actionSheet showInContainerView];
}
-(void)btnViewCustomClicked:(id)sender
{
    if ([(NSObject *)self.delegate respondsToSelector:@selector(btnViewCustomClicked:)])
    {
        [delegate btnViewCustomClicked:nil];
        [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(ALPickerView *)createMultiPicker:(CGRect)rect
{
    ALPickerView *multiPicker=[[ALPickerView alloc] initWithFrame:rect];
    multiPicker.allOptionTitle = nil;
    multiPicker.delegate  = self;
    return multiPicker;
}

-(UIPickerView*)createPicker:(CGRect)rect
{
	pickerView=[[UIPickerView alloc] initWithFrame:rect];
	pickerView.delegate  = self;
	pickerView.dataSource = self;
	NSInteger x=0;
	pickerView.showsSelectionIndicator = YES;
	if ([preValue length] > 0)
	{
        if ([[keyArray objectAtIndex:0] isKindOfClass:[NSString class]])
        {
            if ([keyArray  containsObject:preValue])
                x=[keyArray  indexOfObject:preValue];
            [pickerView selectRow:x inComponent:0 animated:YES];
        }
        else if([[keyArray objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
            
            preValue = [preValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"self.%@ = %@",@"mobile_code",preValue];
            NSMutableArray *array=[NSMutableArray arrayWithArray:[keyArray filteredArrayUsingPredicate:predicate]];
            if([array count])
            {
                if ([keyArray  containsObject:[array objectAtIndex:0]])
                    x=[keyArray  indexOfObject:[array objectAtIndex:0]];
                
            }
            
            [pickerView selectRow:x inComponent:0 animated:YES];
        }
	}
	return pickerView;
}          

-(UIToolbar*)createToolBar:(CGRect)rect BarStyle:(UIBarStyle)BarStyle toolBarTitle:(NSString*)toolBarTitle textColor:(UIColor*)textColor
{
	UIToolbar *Toolbar = [[UIToolbar alloc] initWithFrame:rect];
	Toolbar.barStyle = BarStyle;
    Toolbar.tintColor =  [UIColor whiteColor];
;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        Toolbar.barTintColor = [UIColor grayColor];
        Toolbar.tintColor = [UIColor whiteColor];
    }
	Toolbar.opaque=YES;
	Toolbar.translucent=NO;
	[Toolbar setItems:[self toolbarItem] animated:YES];	
	if ([toolBarTitle length]!=0)
    {
		[Toolbar addSubview:[self createTitleLabel:toolBarTitle labelTextColor:textColor width:(rect.size.width - 150)]];
	}
	return Toolbar ;
}

#pragma mark - ALPickerView delegate methods
- (NSInteger)numberOfRowsForPickerView:(ALPickerView *)pickerView
{
    return [keyArray count];
}

- (NSString *)pickerView:(ALPickerView *)pickerView textForRow:(NSInteger)row
{
    return [[keyArray objectAtIndex:row] objectForKey:@"currency_name"];
}

- (BOOL)pickerView:(ALPickerView *)pickerView selectionStateForRow:(NSInteger)row
{
    NSString *strID = [[keyArray objectAtIndex:row] objectForKey:@"currency_code"];
    if (!strID)
    {
        strID = [[keyArray objectAtIndex:row] objectForKey:@"currency_code"];
    }
    
    
    NSArray *arrTemp = [self.selectionString componentsSeparatedByString:@", "];
    if (![arrTemp containsObject:strID]) {
        return NO;
    }
    return ([self.selectionString rangeOfString:[NSString stringWithFormat:@"%@", strID]].location != NSNotFound);
}

- (void)pickerView:(ALPickerView *)pickerView didCheckRow:(NSInteger)row
{
    
    if (row == -1)
    {
        NSString *strID = [keyArray valueForKeyPath:@"currency_code"];
        if (!strID)
        {
            self.selectionString = [NSString stringWithFormat:@",%@", [[keyArray valueForKeyPath:@"currency_code"] componentsJoinedByString:@","]];
        }
        else
        {
            self.selectionString = [NSString stringWithFormat:@",%@", [[keyArray valueForKeyPath:@"currency_code"] componentsJoinedByString:@","]];
        }
        
        [self.arMultiRecords removeAllObjects];
        [self.arMultiRecords addObjectsFromArray:keyArray];
    }
    else
    {
        [self.arMultiRecords addObject:[keyArray objectAtIndex:row]];
        NSString *strID = [[keyArray objectAtIndex:row] objectForKey:@"currency_code"];
        if (!strID)
        {
            strID = [[keyArray objectAtIndex:row] objectForKey:@"currency_code"];
        }
        NSString *strsep = @"";
        self.selectionString = [self.selectionString stringByReplacingOccurrencesOfString:self.labelToolBarTitle withString:@""];
        if ([self.labelToolBarTitle isEqualToString:@"I HAVE"] || [self.labelToolBarTitle isEqualToString:@"I AM LOOKING FOR"]){
            self.selectionString = [self.selectionString stringByReplacingOccurrencesOfString:@"Pick minimum 1, maximum 4" withString:@""];
        }
        
        if (self.selectionString.length){
             strsep = [self.selectionString stringByReplacingCharactersInRange:NSMakeRange(0, self.selectionString.length-2) withString:@""];
        }
        
        if (self.selectionString.length && ![strsep isEqualToString:@", "]) {
            self.selectionString = [self.selectionString stringByAppendingFormat:@", "];
        }
        
        self.selectionString = [self.selectionString stringByAppendingFormat:@"%@, ", strID];
        self.selectionString = [self.selectionString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",,"] withString:@","];
    }
    if ([self.selectionString length] == 0)
    {
        [self callSenders:preValue];
    }
    else
    {
        [self callSenders:self.selectionString];
    }

}

- (void)pickerView:(ALPickerView *)pickerView didUncheckRow:(NSInteger)row
{
    // Check whether all rows are unchecked or only one
    if (row == -1)
    {
        self.selectionString = @",";
        [self.arMultiRecords removeAllObjects];
    }
    else
    {
        [self.arMultiRecords removeObject:[keyArray objectAtIndex:row]];
        NSString *strID = [[keyArray objectAtIndex:row] objectForKey:@"currency_code"];
        if (!strID)
        {
            strID = [[keyArray objectAtIndex:row] objectForKey:@"currency_code"];
        }
        self.selectionString = [self.selectionString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", strID] withString:@""];
        self.selectionString = [self.selectionString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",,"] withString:@","];
        self.selectionString = [self.selectionString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@", ,"] withString:@","];
        if ([self.selectionString rangeOfString:@","].location == 0) {
            self.selectionString = [self.selectionString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        if ([self.selectionString rangeOfString:@" "].location == 0) {
            self.selectionString = [self.selectionString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        if (self.selectionString.length==1) {
            self.selectionString = [self.selectionString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@","] withString:@""];
        }
        else if (self.selectionString.length==2) {
            self.selectionString = [self.selectionString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@", "] withString:@""];
        }
        

        
//        self.selectionString = [self.selectionString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",%@,", strID] withString:@","];
    }
    if ([self.selectionString length] == 0)
    {
//        preValue
        if ([self.labelToolBarTitle isEqualToString:@"I HAVE"] || [self.labelToolBarTitle isEqualToString:@"I AM LOOKING FOR"]){
            [self callSenders:@"Pick minimum 1, maximum 4"];
        }
        else
            [self callSenders:self.labelToolBarTitle];
    }
    else
    {
        [self callSenders:self.selectionString];
    }
}
#pragma mark - UIPickerView delegate methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{	
	if ([keyArray count] > 0)
	{
		if ([[keyArray objectAtIndex:0] isKindOfClass:[NSString class]])
		{
			return [keyArray count];
		}
        else{
            return [keyArray count];
        }
	}
	return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    int width = [[UIScreen mainScreen] bounds].size.width;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-20, 40)];
    label.text = [[keyArray objectAtIndex:row] valueForKey:@"countryNameAndId"];
    label.textAlignment = NSTextAlignmentCenter; //Changed to NS as UI is deprecated.
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.adjustsFontSizeToFitWidth = YES;
    return label;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if ([keyArray count] > 0)
	{
		if ([[keyArray objectAtIndex:0] isKindOfClass:[NSString class]])
		{
			return [keyArray objectAtIndex:row];
		}
        else{
//            if ([rowDictKey isEqualToString:@"Merchant"]) {
//                return [[keyArray  objectAtIndex:row] valueForKey:@"currency_name"];
//            }
//            else if ([rowDictKey isEqualToString:@"Location"]) {
//                return [[keyArray  objectAtIndex:row] valueForKey:@"addresss"];
//            }
//            else
                return [[keyArray  objectAtIndex:row] valueForKey:rowDictKey];
        }
	}
	return @"";
}

-(void) pickerView:(UIPickerView *)pickerVies didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSString  *pickerLocalValue=@"";
    if ([pickerView numberOfComponents]>1)
    {
        for(int i=0;i<[pickerView numberOfComponents];i++)
        {
            if ([[keyArray objectAtIndex:0] isKindOfClass:[NSString class]])
            {
                pickerLocalValue=[pickerLocalValue stringByAppendingFormat:@"%@",[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]]];
            }
            else{
                if ([rowDictKey isEqualToString:@"Merchant"]) {
                    pickerLocalValue=[pickerLocalValue stringByAppendingFormat:@"%@",[[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]] valueForKey:@"currency_name"]];
                }
                else if ([rowDictKey isEqualToString:@"currency_name"]) {
                    pickerLocalValue=[pickerLocalValue stringByAppendingFormat:@"%@",[[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]] valueForKey:@"currency_code"]];
                }
                else{
                pickerLocalValue=[pickerLocalValue stringByAppendingFormat:@"%@",[[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]] valueForKey:rowDictKey]];
                }
            }
        }
    }
    else {
        if ([[keyArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
            pickerLocalValue=[pickerLocalValue stringByAppendingFormat:@"%@",[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]]];
        }
        else{
             if ([rowDictKey isEqualToString:@"Merchant"]) {
                 pickerLocalValue=[pickerLocalValue stringByAppendingFormat:@"%@",[[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]] valueForKey:@"currency_name"]];

             }
             else if ([rowDictKey isEqualToString:@"currency_name"]) {
                 pickerLocalValue=[pickerLocalValue stringByAppendingFormat:@"%@",[[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]] valueForKey:@"currency_code"]];
             }
             else{
                 
                NSArray *ary = [[[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]] valueForKey:rowDictKey] componentsSeparatedByString:@")"];
                 NSString *name = [ary objectAtIndex:0];
                 NSString *countryCode = [name substringFromIndex:1];
                pickerLocalValue=[pickerLocalValue stringByAppendingFormat:@"%@",countryCode];
             }
        }
    }
	pickerValue = pickerLocalValue;
	[self callSenders:pickerValue];
}

-(IBAction)done_clicked:(id)sender
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self._actionSheetForIOS8 dismissWithClickedButtonIndex:0 animated:YES];
    }

    [self.arPreMultiRecords removeAllObjects];
    [self.arPreMultiRecords addObjectsFromArray:self.arMultiRecords];
    if ([pickerValue length] == 0)
    {
        if ([keyArray count] > 0)
        {
            if ([[keyArray objectAtIndex:0] isKindOfClass:[NSString class]])
            {
                pickerValue = [keyArray objectAtIndex:[pickerView selectedRowInComponent:0]];
            }
            else{
                if([rowDictKey isEqualToString:@"Merchant"])
                {
                    pickerValue=[[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]] valueForKey:@"currency_name"];

                }
                else if([rowDictKey isEqualToString:@"currency_name"]){
                    pickerValue=[[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]] valueForKey:@"currency_code"];
                }
                else{
                    
                    NSArray *ary = [[[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]] valueForKey:rowDictKey] componentsSeparatedByString:@")"];
                    NSString *name = [ary objectAtIndex:0];
                    NSString *countryCode = [name substringFromIndex:1];
                    pickerValue=[pickerValue stringByAppendingFormat:@"%@",countryCode];
                    
                    
//                    pickerValue=[[keyArray objectAtIndex:[pickerView selectedRowInComponent:0]] valueForKey:rowDictKey];
                }
            }
        }  
    }
    
    if ([(NSObject *)self.delegate respondsToSelector:@selector(pickerDoneClicked: withType: andSender:)])
    {
        
        pickerValue = [pickerValue stringByReplacingOccurrencesOfString:self.labelToolBarTitle withString:@""];
        
//        if ([self.labelToolBarTitle isEqualToString:@"I HAVE"] || [self.labelToolBarTitle isEqualToString:@"I AM LOOKING FOR"]){
//            pickerValue = [pickerValue stringByReplacingOccurrencesOfString:@"Pick minimum 1, maximum 4" withString:@""];
//        }
        
        [delegate pickerDoneClicked:pickerValue withType:rowDictKey andSender:(UIButton *)senders];
    }
    if ([(NSObject *)self.delegate respondsToSelector:@selector(picker:andDoneClicked:andIndex:)])
    {
        [self.delegate picker:self andDoneClicked:pickerValue andIndex:[pickerView selectedRowInComponent:0]];
    }
    if(!self.needMultiSelection)
    {
        [self callSenders:pickerValue];
    } else{
        NSString *newStr;
        
        
        if (self.selectionString.length>1) {
            NSString *strTest = [self.selectionString stringByReplacingCharactersInRange:NSMakeRange(0, self.selectionString.length-2) withString:@""];
            if ([strTest isEqualToString:@", "])
                newStr =[self.selectionString stringByReplacingCharactersInRange:NSMakeRange(self.selectionString.length-2, 2) withString:@""];
            else
                newStr =self.selectionString;
        }
        
        else{
            newStr =@"";
        }
        
        newStr = [newStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",,"] withString:@","];
        newStr = [newStr stringByReplacingOccurrencesOfString:self.labelToolBarTitle withString:@""];
        
        NSString *strDummy = self.labelToolBarTitle;
        if ([self.labelToolBarTitle isEqualToString:@"I HAVE"] || [self.labelToolBarTitle isEqualToString:@"I AM LOOKING FOR"]){
            newStr = [newStr stringByReplacingOccurrencesOfString:@"Pick minimum 1, maximum 4" withString:@""];
            strDummy = @"Pick minimum 1, maximum 4";
        }
        
        [self callSenders:(newStr.length == 0)?strDummy:newStr];
    }
    if ([(NSObject *)self.delegate respondsToSelector:@selector(adjustScrolling)])
    {
        [delegate adjustScrolling];
    }
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		[popoverController dismissPopoverAnimated:YES];
	}
    else
    {
		[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self callSenders:preValue];
}

-(UILabel*)createTitleLabel:(NSString*)labelTitle labelTextColor:(UIColor*)color width:(NSInteger)width
{
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ||
        [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationPortraitUpsideDown)
    {
        lheight = 36;
        lWidth = 4;
    }
    else
    {
        lWidth = 2;
        lheight = 28;
    }
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(80,lWidth,width,lheight)];
	self.label.textColor = color;
	self.label.backgroundColor = [UIColor clearColor];
	self.label.font = [UIFont fontWithName:@"Helvetica" size:17];
	self.label.text = labelTitle;
    self.label.numberOfLines=0;
    if(!self.PickerName)
    {
        self.PickerName = labelTitle;
    }
	self.label.textAlignment = NSTextAlignmentCenter;
	return self.label ;
}

-(void)callSenders:(NSString*)pickerString
{
    if ([senders isKindOfClass:[UILabel class]])
    {
		tempLable=(UILabel *)senders;
		tempLable.text=pickerString;
		//senders=(UILabel*)senders;
	}
	else if ([senders isKindOfClass:[UITextField class]]){
		tempText=(UITextField *)senders;
		tempText.text=pickerString;
		//senders=(UITextField*)senders;
	}
	else if ([senders isKindOfClass:[UIButton class]])
	{
		button_Temp = (UIButton *)senders;
		[button_Temp setTitle:pickerString forState:UIControlStateNormal];
        [button_Temp setTitleColor:[UIColor colorWithRed:34.0/255 green:34.0/255 blue:34.0/255 alpha:1.0] forState:0];
		//senders = (UIButton *)senders;
	}
    if ([(NSObject *)self.delegate respondsToSelector:@selector(CustomPickerValue:)])
    {
        [delegate CustomPickerValue:senders];
    }

}
-(IBAction)cancel_clicked:(id)sender
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self._actionSheetForIOS8 dismissWithClickedButtonIndex:0 animated:YES];
    }
    self.selectionString = self.preSelectionString;
    [self.arMultiRecords removeAllObjects];
    [self.arMultiRecords addObjectsFromArray:self.arPreMultiRecords];
	[self callSenders:preValue];
    if ([(NSObject *)self.delegate respondsToSelector:@selector(adjustScrolling)])
    {
        [delegate adjustScrolling];
    }
    if ([(NSObject *)self.delegate respondsToSelector:@selector(pickerCancelClicked: withType:andSender:)])
    {
        [self.delegate pickerCancelClicked:preValue withType:rowDictKey andSender:(UIButton *)senders];
    }
    if ([(NSObject *)self.delegate respondsToSelector:@selector(picker:andCancelClicked:)])
    {
        [self.delegate picker:self andCancelClicked:preValue];
    }

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		[popoverController dismissPopoverAnimated:YES];
	}
    else
    {
		[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	}
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
