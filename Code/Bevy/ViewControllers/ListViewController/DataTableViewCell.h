//
//  DataTableViewCell.h
//  TableCellAnimationDemo
//
//  Created by CompanyName on 12/23/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataTableViewCell;

/**
 * This class is used to create a cell for data table view.
 */
@protocol CustomCollectionDelegate <NSObject>

@required
-(void)dataTableViewCell:(DataTableViewCell *)dataCell didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface DataTableViewCell : UITableViewCell<UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, retain) IBOutlet UICollectionView *itemsCollectionView;
@property(nonatomic, strong) NSMutableArray *arrItems;

@property(nonatomic, retain) id<CustomCollectionDelegate>collectionDelegate;

@end
