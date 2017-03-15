//
//  ListViewController.h
//  TableCellAnimationDemo
//
//  Created by CompanyName on 12/23/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataTableViewCell.h"

/**
 * This class is used to select the item in the list of items available for the location searched.
 */
@interface ListViewController : GAITrackedViewController<UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate,CustomCollectionDelegate>

@property(nonatomic, retain) IBOutlet UITableView *tblListView;
@property(nonatomic, retain) IBOutlet UIButton *btnCart;

@property(nonatomic, retain) WS_Helper *objWSHelper;
@property(nonatomic, strong) NSIndexPath *indexPathToClose;
@property(nonatomic, retain) NSMutableArray *dataArray;
@property(nonatomic, retain) NSMutableArray *arraySubCategories;
@property(nonatomic, retain) NSDictionary *dictCategory;

/**
 *  btnCartClicked ,This method is called when user click on cart  button.
 *  @param btnCartClicked, navigates to check out view controller.
 */
-(IBAction)btnCartClicked:(id)sender;

@end
