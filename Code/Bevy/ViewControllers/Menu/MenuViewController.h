//
//  MenuViewController.h
//  Bevy
//
//  Created by CompanyName on 12/20/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class is used to select the screen from menu list.
 */
@interface MenuViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollContainer;
@property (nonatomic, strong) IBOutlet UIButton *btnHome;
@property (nonatomic, strong) IBOutlet UIButton *btnLocation;
@property (nonatomic, strong) IBOutlet UIButton *btnProfile;
@property (nonatomic, strong) IBOutlet UIButton *btnSupport;
@property (nonatomic, strong) IBOutlet UIButton *btnStatus;
@property (nonatomic, strong) IBOutlet UIButton *btnShare;

@property (nonatomic, assign) NSInteger panelIndex;
@property(nonatomic, retain) WS_Helper *objWSHelper;

@property (nonatomic, strong) IBOutlet UIImageView *imgArrow;

/**
 *  menuItemHomeClikced ,This method is called when user click on Home button.
 *  @param menuItemHomeClikced, to navigates to home screen.
 */
-(IBAction)menuItemHomeClikced:(id)sender;
/**
 *  menuItemLocationClicked ,This method is called when user click on Locarion button.
 *  @param menuItemLocationClicked, to navigates to location map screen.
 */
-(IBAction)menuItemLocationClicked:(id)sender;
/**
 *  menuItemProfileClicked ,This method is called when user click on Profile button.
 *  @param menuItemProfileClicked, to navigates to profile screen.
 */
-(IBAction)menuItemProfileClicked:(id)sender;
/**
 *  menuItemSupportClicked ,This method is called when user click on Support  button.
 *  @param menuItemSupportClicked, to navigates to Support screen.
 */
-(IBAction)menuItemSupportClicked:(id)sender;
/**
 *  menuItemStatusClicked ,This method is called when user click on Order  button.
 *  @param menuItemStatusClicked, to navigates to Order Status screen.
 */
-(IBAction)menuItemStatusClicked:(id)sender;
/**
 *  menuItemShareClicked ,This method is called when user click on Share  button.
 *  @param menuItemShareClicked, to navigates to Share slider view.
 */
-(IBAction)menuItemShareClicked:(id)sender;

/**
 *  @param chooseRightPanelIndex, to select the index in menu items.
 */
-(void)chooseRightPanelIndex:(NSInteger)index;

@end
