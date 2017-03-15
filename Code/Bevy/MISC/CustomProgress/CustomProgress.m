//
//  CustomProgress.m
//  PhotoShare
//
//  Created by CompanyName on 7/9/13.
//  Copyright (c) 2013 CompanyName. All rights reserved.
//

#import "CustomProgress.h"

#if __has_feature(objc_arc)
#define MB_AUTORELEASE(exp) exp
#define MB_RELEASE(exp) exp
#define MB_RETAIN(exp) exp
#else
#define MB_AUTORELEASE(exp) [exp autorelease]
#define MB_RELEASE(exp) [exp release]
#define MB_RETAIN(exp) [exp retain]
#endif


static const CGFloat kPadding = 4.f;
static const CGFloat kLabelFontSize = 16.f;
//static const CGFloat kDetailsLabelFontSize = 12.f;

@interface CustomProgress ()

- (void)registerForKVO;
- (void)unregisterFromKVO;
- (NSArray*)observableKeypaths;
- (void)registerForNotifications;
- (void)unregisterFromNotifications;
- (void)updateUIForKeypath:(NSString *)keyPath;
- (void)hideUsingAnimation:(BOOL)animated;
- (void)showUsingAnimation:(BOOL)animated;
- (void)done;
- (void)handleGraceTimer:(NSTimer *)theTimer;
- (void)handleMinShowTimer:(NSTimer *)theTimer;
- (void)setTransformForCurrentOrientation:(BOOL)animated;
- (void)cleanUp;
- (void)launchExecution;
- (void)deviceOrientationDidChange:(NSNotification *)notification;
- (void)hideDelayed:(NSNumber *)animated;

@property (MB_STRONG) UIView *indicator;
@property (MB_STRONG) NSTimer *graceTimer;
@property (MB_STRONG) NSTimer *minShowTimer;
@property (MB_STRONG) NSDate *showStarted;
@property (assign) CGSize size;

@end

@implementation CustomProgress
{
    UILabel *lblTracker;
    UIProgressView *objProgressView;
	BOOL useAnimation;
	SEL methodForExecution;
	id targetForExecution;
	id objectForExecution;
	BOOL isFinished;
	CGAffineTransform rotationTransform;
}

@synthesize animationType;
@synthesize delegate;
@synthesize opacity;
@synthesize labelFont;
@synthesize indicator;
@synthesize xOffset;
@synthesize yOffset;
@synthesize minSize;
@synthesize margin;
@synthesize dimBackground;
@synthesize graceTime;
@synthesize minShowTime;
@synthesize graceTimer;
@synthesize minShowTimer;
@synthesize taskInProgress;
@synthesize removeFromSuperViewOnHide;
@synthesize showStarted;
@synthesize labelText;
@synthesize progress;
@synthesize size;

- (void)dealloc
{
	[self unregisterFromNotifications];
	[self unregisterFromKVO];
#if !__has_feature(objc_arc)
	[labelText release];
	[graceTimer release];
	[minShowTimer release];
	[showStarted release];
	[super dealloc];
#endif
}

- (id)initWithWindow:(UIWindow *)window
{
	return [self initWithView:window];
}

- (id)initWithView:(UIView *)view
{
	NSAssert(view, @"View must not be nil.");
	id me = [self initWithFrame:view.bounds];
	// We need to take care of rotation ourselfs if we're adding the HUD to a window
	if ([view isKindOfClass:[UIWindow class]])
    {
		[self setTransformForCurrentOrientation:NO];
	}
	return me;
}

#pragma mark - Internal show & hide operations

- (void)showUsingAnimation:(BOOL)animated {
	self.alpha = 0.0f;
	if (animated && animationType == MBProgressHUDAnimationZoom) {
		self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
	}
	self.showStarted = [NSDate date];
	// Fade in
	if (animated)
    {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.30];
		self.alpha = 1.0f;
		if (animationType == MBProgressHUDAnimationZoom) {
			self.transform = rotationTransform;
		}
		[UIView commitAnimations];
	}
	else {
		self.alpha = 1.0f;
	}
}

- (void)hideUsingAnimation:(BOOL)animated {
	// Fade out
	if (animated && showStarted) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.30];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
		// 0.02 prevents the hud from passing through touches during the animation the hud will get completely hidden
		// in the done method
		if (animationType == MBProgressHUDAnimationZoom) {
			self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
		}
		self.alpha = 0.02f;
		[UIView commitAnimations];
	}
	else {
		self.alpha = 0.0f;
		[self done];
	}
	self.showStarted = nil;
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
	[self done];
}

- (void)done {
	isFinished = YES;
	self.alpha = 0.0f;
	if ([delegate respondsToSelector:@selector(hudWasHidden:)]) {
		[delegate performSelector:@selector(hudWasHidden:) withObject:self];
	}
	if (removeFromSuperViewOnHide) {
		[self removeFromSuperview];
	}
}

#pragma mark - Show & hide
- (void)show:(BOOL)animated
{
	useAnimation = animated;
	// If the grace time is set postpone the HUD display
	if (self.graceTime > 0.0)
    {
		self.graceTimer = [NSTimer scheduledTimerWithTimeInterval:self.graceTime target:self selector:@selector(handleGraceTimer:) userInfo:nil repeats:NO];
	}
	// ... otherwise show the HUD imediately
	else
    {
		[self setNeedsDisplay];
		[self showUsingAnimation:useAnimation];
	}
}

- (void)hide:(BOOL)animated
{
	useAnimation = animated;
	// If the minShow time is set, calculate how long the hud was shown,
	// and pospone the hiding operation if necessary
	if (self.minShowTime > 0.0 && showStarted)
    {
		NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:showStarted];
		if (interv < self.minShowTime)
        {
			self.minShowTimer = [NSTimer scheduledTimerWithTimeInterval:(self.minShowTime - interv) target:self selector:@selector(handleMinShowTimer:) userInfo:nil repeats:NO];
			return;
		}
	}
	// ... otherwise hide the HUD immediately
	[self hideUsingAnimation:useAnimation];
}

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay
{
	[self performSelector:@selector(hideDelayed:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay];
}

- (void)hideDelayed:(NSNumber *)animated
{
	[self hide:[animated boolValue]];
}

#pragma mark BG Drawing

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (dimBackground) {
		//Gradient colours
		size_t gradLocationsNum = 2;
		CGFloat gradLocations[2] = {0.0f, 1.0f};
		CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
		CGColorSpaceRelease(colorSpace);
		//Gradient center
		CGPoint gradCenter= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		//Gradient radius
		float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
		//Gradient draw
		CGContextDrawRadialGradient (context, gradient, gradCenter,
									 0, gradCenter, gradRadius,
									 kCGGradientDrawsAfterEndLocation);
		CGGradientRelease(gradient);
	}
	
	// Center HUD
	CGRect allRect = self.bounds;
	// Draw rounded HUD bacgroud rect
	CGRect boxRect = CGRectMake(roundf((allRect.size.width - size.width) / 2) + self.xOffset,
								roundf((allRect.size.height - size.height) / 2) + self.yOffset, size.width, size.height);
	float radius = 10.0f;
	CGContextBeginPath(context);
	CGContextSetGrayFillColor(context, 0.0f, self.opacity);
	CGContextMoveToPoint(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect));
	CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
	CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
	CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
	CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
	CGContextClosePath(context);
	CGContextFillPath(context);
}

#pragma mark - Layout
- (void)layoutSubviews
{
	// Entirely cover the parent view
	UIView *parent = self.superview;
	if (parent)
    {
		self.frame = parent.bounds;
	}
	CGRect bounds = self.bounds;
	
	// Determine the total widt and height needed
	CGFloat maxWidth = bounds.size.width - 4 * margin;
	CGSize totalSize = CGSizeZero;
	
	CGRect indicatorF = indicator.bounds;
	indicatorF.size.width = MIN(indicatorF.size.width, maxWidth);
	totalSize.width = MAX(totalSize.width, indicatorF.size.width);
	totalSize.height += indicatorF.size.height;
	
	CGSize labelSize = [lblTracker.text sizeWithFont:lblTracker.font];
	labelSize.width = MIN(labelSize.width, maxWidth);
	totalSize.width = MAX(totalSize.width, labelSize.width);
	totalSize.height += labelSize.height;
    labelSize.height = 40.0;
	if (labelSize.height > 0.f && indicatorF.size.height > 0.f) {
		totalSize.height += kPadding;
	}
    
    CGSize progressViewSize = CGSizeMake(252, 12);
	totalSize.width = MAX(totalSize.width, progressViewSize.width);
	totalSize.height += progressViewSize.height;
    totalSize.width = totalSize.width;
    if (progressViewSize.height > 0.f && labelSize.height > 0.f)
    {
		totalSize.height += kPadding;
	}
	
	totalSize.width += 2 * margin;
    totalSize.width = MIN(270, totalSize.width);
	totalSize.height += 2 * margin;
    totalSize.height = MAX(100, totalSize.height);
	
	// Position elements
	CGFloat yPos = roundf(((bounds.size.height - totalSize.height) / 2)) + margin + yOffset;
	CGFloat xPos = xOffset;
	CGRect labelF;
	labelF.origin.y = yPos;
	labelF.origin.x = roundf((bounds.size.width - labelSize.width) / 2) + xPos;
	labelF.size = labelSize;
	lblTracker.frame = labelF;
	yPos += labelF.size.height;
	
    if (progressViewSize.height > 0.f && labelSize.height > 0.f)
    {
		yPos += kPadding;
	}
    
    CGRect progressViewF;
	progressViewF.origin.y = yPos;
	progressViewF.origin.x = roundf((bounds.size.width - progressViewSize.width) / 2) + xPos;
	progressViewF.size = progressViewSize;
	objProgressView.frame = progressViewF;
	self.size = totalSize;
}

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
    {
		// Set default values for properties
		self.labelText = nil;
		self.opacity = 0.8f;
		self.labelFont = [UIFont boldSystemFontOfSize:kLabelFontSize];
		self.xOffset = 0.0f;
		self.yOffset = 0.0f;
		self.dimBackground = NO;
		self.margin = 20.0f;
		self.graceTime = 0.0f;
		self.minShowTime = 0.0f;
		self.removeFromSuperViewOnHide = NO;
		self.minSize = CGSizeZero;
		self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
		// Transparent background
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		// Make it invisible for now
		self.alpha = 0.0f;
		
		taskInProgress = NO;
		rotationTransform = CGAffineTransformIdentity;
		
        lblTracker = [[UILabel alloc] initWithFrame:self.bounds];
//        lblTracker.adjustsFontSizeToFitWidth = YES;
        
        lblTracker.textAlignment = NSTextAlignmentCenter;
        lblTracker.opaque = NO;
        lblTracker.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:kLabelFontSize];
        lblTracker.backgroundColor = [UIColor clearColor];
        lblTracker.textColor = [UIColor lightGrayColor];
        lblTracker.text = self.labelText;
        lblTracker.numberOfLines = 0;
        [lblTracker sizeToFit];
        [self addSubview:lblTracker];
        
        objProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        objProgressView.progress = 0.0;
        UIImage *track = [[UIImage imageNamed:@"loading_tab.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [objProgressView setTrackImage:track];
        UIImage *progressImg = [[UIImage imageNamed:@"loading_tab_1.png"] resizableImageWithCapInsets:(const UIEdgeInsets){4.0f, 4.0f, 4.0f, 4.0f}];
        [objProgressView setProgressImage:progressImg];
        [self addSubview:objProgressView];

		[self registerForKVO];
		[self registerForNotifications];
	}
	return self;
}

#pragma mark - KVO
- (void)registerForKVO
{
	for (NSString *keyPath in [self observableKeypaths])
    {
		[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)unregisterFromKVO
{
	for (NSString *keyPath in [self observableKeypaths])
    {
		[self removeObserver:self forKeyPath:keyPath];
	}
}

- (NSArray *)observableKeypaths
{
	return [NSArray arrayWithObjects:@"labelText", @"labelFont", @"progress", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (![NSThread isMainThread])
    {
		[self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
	}
    else
    {
		[self updateUIForKeypath:keyPath];
	}
}

- (void)updateUIForKeypath:(NSString *)keyPath
{
    if ([keyPath isEqualToString:@"labelText"])
    {
		lblTracker.text = self.labelText;
        
        lblTracker.numberOfLines = 0;
        [lblTracker sizeToFit];
	}
    else if ([keyPath isEqualToString:@"labelFont"])
    {
		lblTracker.font = self.labelFont;
	}
    else if ([keyPath isEqualToString:@"progress"])
    {
		if ([objProgressView respondsToSelector:@selector(setProgress:animated:)])
        {
			[(id)objProgressView setProgress:self.progress animated:TRUE];
		}
		return;
	}
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

#pragma mark - Notifications
- (void)registerForNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unregisterFromNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
	UIView *superview = self.superview;
	if (!superview)
    {
		return;
	}
    else if ([superview isKindOfClass:[UIWindow class]])
    {
		[self setTransformForCurrentOrientation:YES];
	}
    else
    {
		self.bounds = self.superview.bounds;
		[self setNeedsDisplay];
	}
}

- (void)setTransformForCurrentOrientation:(BOOL)animated
{
	// Stay in sync with the superview
	if (self.superview) {
		self.bounds = self.superview.bounds;
		[self setNeedsDisplay];
	}
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	float radians = 0;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -M_PI_2; }
		else { radians = M_PI_2; }
		// Window coordinates differ!
		self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
	} else {
		if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = M_PI; }
		else { radians = 0; }
	}
	rotationTransform = CGAffineTransformMakeRotation(radians);
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
	}
	[self setTransform:rotationTransform];
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark - Timer callbacks
- (void)handleGraceTimer:(NSTimer *)theTimer
{
	// Show the HUD only if the task is still running
	if (taskInProgress) {
		[self setNeedsDisplay];
		[self showUsingAnimation:useAnimation];
	}
}

- (void)handleMinShowTimer:(NSTimer *)theTimer {
	[self hideUsingAnimation:useAnimation];
}

#pragma mark - Threading

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated {
	methodForExecution = method;
	targetForExecution = MB_RETAIN(target);
	objectForExecution = MB_RETAIN(object);
	// Launch execution in new thread
	self.taskInProgress = YES;
	[NSThread detachNewThreadSelector:@selector(launchExecution) toTarget:self withObject:nil];
	// Show HUD view
	[self show:animated];
}

- (void)launchExecution {
	@autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		// Start executing the requested task
		[targetForExecution performSelector:methodForExecution withObject:objectForExecution];
#pragma clang diagnostic pop
		// Task completed, update view in main thread (note: view operations should
		// be done only in the main thread)
		[self performSelectorOnMainThread:@selector(cleanUp) withObject:nil waitUntilDone:NO];
	}
}

- (void)cleanUp
{
	taskInProgress = NO;
	self.indicator = nil;
#if !__has_feature(objc_arc)
	[targetForExecution release];
	[objectForExecution release];
#endif
	[self hide:useAnimation];
}

@end
