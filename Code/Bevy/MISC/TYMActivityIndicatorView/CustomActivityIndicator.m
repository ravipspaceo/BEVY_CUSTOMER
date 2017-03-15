//
//  CustomActivityIndicator.m
//  Moxiee
//
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "CustomActivityIndicator.h"


@implementation CustomActivityIndicator

static CustomActivityIndicator *singletonObject = nil;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

+ (CustomActivityIndicator*) getCustomIndicatorInstance
{
    if (singletonObject == nil)
    {
        singletonObject = [[CustomActivityIndicator alloc] initWithFrame:[GlobalManager getAppDelegateInstance].window.frame];
    }
    return singletonObject;
}


- (void)addedIndicatorToView:(CGRect)frame setViewController :(UIViewController*)currentController
{
    if (!self.activityIndicator)
    {
        self.activityIndicator = [[TYMActivityIndicatorView alloc] initWithActivityIndicatorStyle:TYMActivityIndicatorViewStyleNormal];
        self.activityIndicator.hidesWhenStopped = NO;
    }
    self.activityIndicator.frame = frame;
    [self addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    self.backgroundColor = [UIColor clearColor];
//    self.frame = CGRectMake(0, 0, [GlobalManager getAppDelegateInstance].window.frame.size.width, 64);
    [currentController.view addSubview:self];
}

- (void)hideIndicatorForView:(UIViewController*)currentController
{
    [self.activityIndicator stopAnimating];
//    self.backgroundColor = [UIColor redColor];
    [self.activityIndicator removeFromSuperview];
    [self removeFromSuperview];
}
-(void)hudShouldbeNil
{
    self.activityIndicator = nil;
}

@end
