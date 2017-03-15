//
//  CustomProgress.h
//  PhotoShare
//
//  Created by CompanyName on 7/9/13.
//  Copyright (c) 2013 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomProgressDelegate <NSObject>

@optional

/**
 * Called after the HUD was fully hidden from the screen.
 */
//- (void)hudWasHidden:(CustomProgress*)tracker;

#ifndef MB_STRONG
#if __has_feature(objc_arc)
#define MB_STRONG strong
#else
#define MB_STRONG retain
#endif
#endif

#ifndef MB_WEAK
#if __has_feature(objc_arc_weak)
#define MB_WEAK weak
#elif __has_feature(objc_arc)
#define MB_WEAK unsafe_unretained
#else
#define MB_WEAK assign
#endif
#endif

@end

//typedef enum {
//	/** Opacity animation */
//	MBProgressHUDAnimationFade,
//	/** Opacity + scale animation */
//	MBProgressHUDAnimationZoom
//} MBProgressHUDAnimation;

@interface CustomProgress : UIView

/**
 * Display the HUD. You need to make sure that the main thread completes its run loop soon after this method call so
 * the user interface can be updated. Call this method when your task is already set-up to be executed in a new thread
 * (e.g., when using something like NSOperation or calling an asynchronous call like NSURLRequest).
 *
 * @param animated If set to YES the HUD will appear using the current animationType. If set to NO the HUD will not use
 * animations while appearing.
 *
 * @see animationType
 */
- (void)show:(BOOL)animated;

/**
 * Hide the HUD. This still calls the hudWasHidden: delegate. This is the counterpart of the show: method. Use it to
 * hide the HUD when your task completes.
 *
 * @param animated If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use
 * animations while disappearing.
 *
 * @see animationType
 */
- (void)hide:(BOOL)animated;

/**
 * Initializes the HUD with the window's bounds. Calls the designated constructor with
 * window.bounds as the parameter.
 *
 * @param window The window instance that will provide the bounds for the HUD. Should be the same instance as
 * the HUD's superview (i.e., the window that the HUD will be added to).
 */
- (id)initWithWindow:(UIWindow *)window;

/**
 * The animation type that should be used when the HUD is shown and hidden.
 *
 * @see MBProgressHUDAnimation
 */
@property (assign) MBProgressHUDAnimation animationType;

/**
 * The HUD delegate object.
 *
 * @see CustomProgressDelegate
 */
@property (MB_WEAK) id<CustomProgressDelegate> delegate;

/**
 * An optional short message to be displayed below the activity indicator. The HUD is automatically resized to fit
 * the entire text. If the text is too long it will get clipped by displaying "..." at the end. If left unchanged or
 * set to @"", then no message is displayed.
 */
@property (copy) NSString *labelText;

/**
 * The opacity of the HUD window. Defaults to 0.9 (90% opacity).
 */
@property (assign) float opacity;

/**
 * The x-axis offset of the HUD relative to the centre of the superview.
 */
@property (assign) float xOffset;

/**
 * The y-ayis offset of the HUD relative to the centre of the superview.
 */
@property (assign) float yOffset;

/**
 * The amounth of space between the HUD edge and the HUD elements (labels, indicators or custom views).
 * Defaults to 20.0
 */
@property (assign) float margin;

/**
 * Cover the HUD background view with a radial gradient.
 */
@property (assign) BOOL dimBackground;

/*
 * Grace period is the time (in seconds) that the invoked method may be run without
 * showing the HUD. If the task finishes before the grace time runs out, the HUD will
 * not be shown at all.
 * This may be used to prevent HUD display for very short tasks.
 * Defaults to 0 (no grace time).
 * Grace time functionality is only supported when the task status is known!
 * @see taskInProgress
 */
@property (assign) float graceTime;

/**
 * The minimum time (in seconds) that the HUD is shown.
 * This avoids the problem of the HUD being shown and than instantly hidden.
 * Defaults to 0 (no minimum show time).
 */
@property (assign) float minShowTime;

/**
 * Indicates that the executed operation is in progress. Needed for correct graceTime operation.
 * If you don't set a graceTime (different than 0.0) this does nothing.
 * This property is automatically set when using showWhileExecuting:onTarget:withObject:animated:.
 * When threading is done outside of the HUD (i.e., when the show: and hide: methods are used directly),
 * you need to set this property when your task starts and completes in order to have normal graceTime
 * functionality.
 */
@property (assign) BOOL taskInProgress;

/**
 * Removes the HUD from its parent view when hidden.
 * Defaults to NO.
 */
@property (assign) BOOL removeFromSuperViewOnHide;

/**
 * Font to be used for the main label. Set this property if the default is not adequate.
 */
@property (MB_STRONG) UIFont* labelFont;

/**
 * The progress of the progress indicator, from 0.0 to 1.0. Defaults to 0.0.
 */
@property (assign) float progress;

/**
 * The minimum size of the HUD bezel. Defaults to CGSizeZero (no minimum size).
 */
@property (assign) CGSize minSize;

@end
