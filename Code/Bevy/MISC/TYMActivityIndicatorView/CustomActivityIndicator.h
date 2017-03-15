//
//  CustomActivityIndicator.h
//  Moxiee
//
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYMActivityIndicatorView.h"

//@protocol  CustomActivityIndicatorDelegate<NSObject>
//
//@end


@interface CustomActivityIndicator : UIView


-(id)initWithFrame:(CGRect)frame;

@property (nonatomic, strong) TYMActivityIndicatorView *activityIndicator;


+ (CustomActivityIndicator*) getCustomIndicatorInstance;
- (void)addedIndicatorToView:(CGRect)frame setViewController :(UIViewController*)currentController;
- (void)hideIndicatorForView:(UIViewController*)currentController;
-(void)hudShouldbeNil;

@end
