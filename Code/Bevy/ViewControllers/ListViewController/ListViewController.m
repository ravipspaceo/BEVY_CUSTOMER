//
//  ListViewController.m
//  TableCellAnimationDemo
//
//  Created by CompanyName on 12/23/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "ListViewController.h"
#import "ListTableViewCell.h"
#import "ProductsViewController.h"
#import "OrderStatusViewController.h"
#import "CheckOutViewController.h"
#import "UIView+Genie.h"
#import "MNPageViewController.h"
#import "MenuViewController.h"

#define CELL_HEIGHT 400  // Need to change inner cell height

@interface ListViewController ()<MNPageViewControllerDataSource, MNPageViewControllerDelegate>

@property(nonatomic, assign) BOOL hasInlineCell;
@property(nonatomic, retain) NSMutableIndexSet *indexSet;

@end

@implementation ListViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpLayout];
}

-(void)viewDidAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Home Screen"];
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Home Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:ORDER_TRACE])
    {
        [self.btnCart setImage:[UIImage imageNamed:@"Delivery-Truck"] forState:UIControlStateNormal];
        self.btnCart.badgeValue = @"";
        [self.btnCart setHidden:NO];
    }
    else
    {
        [self.btnCart setImage:[UIImage imageNamed:@"shoppingcart"] forState:UIControlStateNormal];
        self.btnCart.badgeValue = [[NSUserDefaults standardUserDefaults] objectForKey:PRODUCT_COUNT];
        [self.btnCart setHidden:!([self.btnCart.badgeValue integerValue])];
    }
    
    if (self.indexPathToClose)
    {
        [self.dataArray removeObjectAtIndex:self.indexPathToClose.row];
        [self.indexSet removeIndex:self.indexPathToClose.row];
        [self.tblListView beginUpdates];
        [self.tblListView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.indexPathToClose.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tblListView endUpdates];
        self.indexPathToClose = nil;
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID])
    {
        [self callCategoryList];
    }
    return;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Instance Methods

-(void)setUpLayout
{
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:RUNNING_FIRST];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setRightBarButtonItem:[GlobalManager getnavigationRightButtonWithTarget:self :@"menu"]];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    
    self.indexSet = [[NSMutableIndexSet alloc] init];
    [self.tblListView registerNib:[UINib nibWithNibName:@"ListTableViewCell" bundle:nil] forCellReuseIdentifier:@"ListCell"];
    [self.tblListView registerNib:[UINib nibWithNibName:@"DataTableViewCell" bundle:nil] forCellReuseIdentifier:@"DataCell"];
}

#pragma mark - IBAction Methods

-(IBAction)btnCartClicked:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:ORDER_TRACE])
    {
        MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
        [menuViewcontroller viewDidLoad];
        [menuViewcontroller chooseRightPanelIndex:2];
        [menuViewcontroller menuItemStatusClicked:nil];
    }
    else
    {
        if(![[[NSUserDefaults standardUserDefaults] objectForKey:PRODUCT_COUNT] isEqualToString:@"0"])
        {
            CheckOutViewController *objChkoutVC = [[CheckOutViewController alloc] initWithNibName:@"CheckOutViewController" bundle:nil];
            objChkoutVC.isFromMenu = NO;
            objChkoutVC.isProductAvailble = NO;
            [self.navigationController pushViewController:objChkoutVC animated:YES];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:@"Cart is empty" handler:nil];
            return;
        }
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.indexSet containsIndex:indexPath.row])
    {
        DataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DataCell"];
        [cell setArrItems:[NSMutableArray arrayWithArray:[[self.dataArray objectAtIndex:indexPath.row-1] objectForKey:@"sub_category"]]];
        [cell setCollectionDelegate:self];
        [cell.itemsCollectionView reloadData];
        [cell.itemsCollectionView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0.05];
        return cell;
    }
    else
    {
        ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell"];
        NSMutableDictionary *dict = [self.dataArray objectAtIndex:indexPath.row];
        
        NSString *text = [dict valueForKey:@"category_name"];
        CGRect labelRect = [text
                            boundingRectWithSize:cell.lblText.frame.size
                            options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{
                                         NSFontAttributeName : cell.lblText.font
                                         }
                            context:nil];

        int width = [GlobalManager getAppDelegateInstance].window.frame.size.width;
        int xPostion = (width/2)-(labelRect.size.width/2);
        cell.lblLine.frame = CGRectMake(xPostion, cell.lblLine.frame.origin.y, labelRect.size.width, 2.0);
        cell.lblLine.alpha = 0.9;
        
//        NSMutableAttributedString* string = [[NSMutableAttributedString alloc]initWithString:[dict valueForKey:@"category_name"]];
//        [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleThick] range:NSMakeRange(0, string.length)];
//        [string addAttribute:NSUnderlineColorAttributeName value:BasicAppThemeColor range:NSMakeRange(0, string.length)];
//        cell.lblText. attributedText = string;
        
        cell.lblText.text =[dict valueForKey:@"category_name"];
        
        [cell.imageCategory sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"banner_image"]] placeholderImage:[UIImage imageNamed:@"large_placeholder"]];
        CGRect rect = cell.imageCategory.frame;

        if (indexPath.row == (self.dataArray.count-1)) {
            rect.size.height = cell.frame.size.height;
            cell.imageCategory.frame = rect;
        }
        else{
            rect.size.height = cell.frame.size.height-0.5;
           cell.imageCategory.frame = rect;
        }
        return cell;
    }
}


#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.hasInlineCell && ([self.indexSet containsIndex:indexPath.row]))
    {
        NSArray *subCategory = [[self.dataArray objectAtIndex:(indexPath.row)-1] objectForKey:@"sub_category"];
            CGFloat noOFRows = (subCategory.count)/3;
            CGFloat noOFItems = subCategory.count%3;
            if (noOFItems>0) {
                return MIN(CELL_HEIGHT, (100*noOFRows)+100); //(100*noOFRows)+100;
            }
            else{
                return MIN(CELL_HEIGHT, 100*noOFRows); //100*noOFRows;
            }
//        return CELL_HEIGHT;
    }
    else
    {
        return self.tblListView.rowHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //If there is no sub-category
    if(![[[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"sub_category"] count])
    {
        NSInteger categoryIndex = indexPath.row;
        self.dictCategory = [NSDictionary dictionaryWithDictionary:[self.dataArray objectAtIndex:categoryIndex]];// Here category detail
//        [Flurry logEvent:[self.dictCategory valueForKey:@"category_name"]];
        [GlobalUtilityClass googleAnalyticsScreenTrack:[self.dictCategory valueForKey:@"category_name"]];
        self.arraySubCategories = [NSMutableArray arrayWithArray:@[[self.dataArray objectAtIndex:categoryIndex]]];// Here also category detail
        MNPageViewController *controller = [[MNPageViewController alloc] init];
        ProductsViewController *objProduct = [[ProductsViewController alloc] initWithMNPageViewController:controller withCategory:self.dictCategory andSubCategoryIndex:indexPath.row];
        //below line is important; Need to set the main category is subcategory because there are no sub categories are there.
        objProduct.dictSubCategory = [NSDictionary dictionaryWithDictionary:[self.dataArray objectAtIndex:categoryIndex]];
        
        [controller setViewController:objProduct];
        [controller setDataSource:self];
        [controller setDelegate:self];
        
        UINavigationController *navController = (UINavigationController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.centerPanel;
        [navController.navigationBar setTranslucent:NO];
        [navController setNavigationBarHidden:NO];
        [navController pushViewController:controller animated:YES];
    }
    else
    {
        if([self.indexSet containsIndex:indexPath.row])
        {
            NSLog(@"INNER CELL CLICKED");
            return;
        }
        else
        {
            [self toggleIndexPathCell:indexPath];
        }
    }
}

#pragma mark - Instance methods

-(void)btnMenuClicked
{
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

-(void)callCategoryList
{
    if (!self.dataArray.count) {
        [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    }
    
    NSDictionary *params = @{@"user_id" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID], @"store_id" :[[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID]};
    [self.objWSHelper sendRequestWithURL:[WS_Urls getCategoryListURL:params]];
}

-(void)toggleIndexPathCell:(NSIndexPath *)indexPath
{
    /*Get the previous index and removing it from 'indexSet'*/
    __block NSIndexPath *previousIndexPath = nil;
    [self.indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
     {
         previousIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
     }];
    
    [self.indexSet removeIndex:previousIndexPath.row];
    
    /*Clicked on Previous cell*/
    if(previousIndexPath != nil && previousIndexPath.row-1 == indexPath.row)
    {
        self.hasInlineCell = NO;
        [self.dataArray removeObjectAtIndex:previousIndexPath.row];
        [self.tblListView beginUpdates];
        self.indexPathToClose = nil;
        [self.tblListView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:previousIndexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tblListView endUpdates];
    }
    else/*Clicked on Other cell*/
    {
        if(previousIndexPath ==nil)
        {
            [self.tblListView beginUpdates];
            self.hasInlineCell = YES;
            [self.dataArray insertObject:@"NEW OBJECT" atIndex:(indexPath.row + 1)];
            [self.indexSet addIndex:indexPath.row+1];
            self.indexPathToClose = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
            [self.tblListView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tblListView endUpdates];
            [self.tblListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        else
        {
            [self.tblListView beginUpdates];
            [self.dataArray removeObjectAtIndex:previousIndexPath.row];
            [self.tblListView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:previousIndexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            NSIndexPath *insertIndexPath = (previousIndexPath.row > indexPath.row) ? [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0] : [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            self.hasInlineCell = YES;
            [self.dataArray insertObject:@"NEW OBJECT" atIndex:insertIndexPath.row];
            [self.indexSet addIndex:insertIndexPath.row];
            self.indexPathToClose = [NSIndexPath indexPathForRow:insertIndexPath.row inSection:insertIndexPath.section];
            [self.tblListView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tblListView endUpdates];
            [self.tblListView scrollToRowAtIndexPath:insertIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

#pragma mark - CustomCollectionDelegate Methods

-(void)dataTableViewCell:(DataTableViewCell *)dataCell didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"ITEM CLICKED at TableCell: %li on ITEM index: %li", (long)[self.tblListView indexPathForCell:dataCell].row, (long)indexPath.row);
    NSInteger categoryIndex = ([self.tblListView indexPathForCell:dataCell].row-1);
    self.dictCategory = [NSDictionary dictionaryWithDictionary:[self.dataArray objectAtIndex:categoryIndex]];
    
    self.arraySubCategories = [NSMutableArray arrayWithArray:[self.dictCategory objectForKey:@"sub_category"]];
    MNPageViewController *controller = [[MNPageViewController alloc] init];
    ProductsViewController *objProduct = [[ProductsViewController alloc] initWithMNPageViewController:controller withCategory:self.dictCategory andSubCategoryIndex:indexPath.row];
    
    NSString *strCategoryName = [[self.arraySubCategories objectAtIndex:indexPath.row] valueForKey:@"category_name"];
//    [Flurry logEvent:strCategoryName];
    
    [GlobalUtilityClass googleAnalyticsScreenTrack:strCategoryName];
    [controller setViewController:objProduct];
    [controller setDataSource:self];
    [controller setDelegate:self];
    
    UINavigationController *navController = (UINavigationController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.centerPanel;
    [navController.navigationBar setTranslucent:NO];
    [navController setNavigationBarHidden:NO];
    [navController pushViewController:controller animated:YES];
}


#pragma mark - MNPageViewControllerDataSource

- (UIViewController *)mn_pageViewController:(MNPageViewController *)pageViewController viewControllerBeforeViewController:(ProductsViewController *)viewController
{
    NSUInteger index = [self.arraySubCategories indexOfObject:viewController.dictSubCategory];
    if (index == NSNotFound || index == 0)
    {
        return nil;
    }
    return [[ProductsViewController alloc] initWithMNPageViewController:pageViewController withCategory:self.dictCategory andSubCategoryIndex:(index-1)];
}

- (UIViewController *)mn_pageViewController:(MNPageViewController *)pageViewController viewControllerAfterViewController:(ProductsViewController *)viewController
{
    NSUInteger index = [self.arraySubCategories indexOfObject:viewController.dictSubCategory];
    if (index == NSNotFound || index == (self.arraySubCategories.count - 1))
    {
        return nil;
    }
    return [[ProductsViewController alloc] initWithMNPageViewController:pageViewController withCategory:self.dictCategory andSubCategoryIndex:(index + 1)];
}

#pragma mark - MNPageViewControllerDelegate methods

- (void)mn_pageViewController:(MNPageViewController *)pageViewController willBeginPageToViewController:(UIViewController *)viewController
{
    NSLog(@"willBeginPageToViewController");
    ProductsViewController *productVC = (ProductsViewController *)viewController;
    productVC.txtSearchFiled.text = @"";
    productVC.txtSearchFiled.hidden = YES;
    [productVC btnCancelEditing:nil];
}

- (void)mn_pageViewController:(MNPageViewController *)pageViewController didPageToViewController:(UIViewController *)viewController
{
    [pageViewController.viewController viewWillAppear:YES];
}

#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if(!response)
        return;
    NSMutableDictionary *resultDictionary = (NSMutableDictionary *)response;
    if([[[resultDictionary objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
    {
        if([[resultDictionary objectForKey:@"data"] count])
        {
            self.dataArray = [NSMutableArray arrayWithArray:[[resultDictionary objectForKey:@"data"] objectForKey:@"category_list"]];
            
            if([[[resultDictionary objectForKey:@"data"] objectForKey:@"remaining_orders"] isEqualToString:@"0"])
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ORDER_TRACE];
            else
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ORDER_TRACE];
            
            [[NSUserDefaults standardUserDefaults] setObject:[[[resultDictionary objectForKey:@"data"] objectForKey:@"product_in_cart"] objectForKey:@"iCartId"] forKey:CART_ID];
            [[NSUserDefaults standardUserDefaults] setObject:[[[resultDictionary objectForKey:@"data"] objectForKey:@"product_in_cart"] objectForKey:@"iTotalProduct"] forKey:PRODUCT_COUNT];
            [[NSUserDefaults standardUserDefaults] setObject:[[resultDictionary objectForKey:@"data"] objectForKey:@"remaining_orders"] forKey:REMAINING_ORDERS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:ORDER_TRACE])
        {
            [self.btnCart setImage:[UIImage imageNamed:@"Delivery-Truck"] forState:UIControlStateNormal];
            self.btnCart.badgeValue = @"";
            [self.btnCart setHidden:NO];
        }
        else
        {
            [self.btnCart setImage:[UIImage imageNamed:@"shoppingcart"] forState:UIControlStateNormal];
            self.btnCart.badgeValue = [[NSUserDefaults standardUserDefaults] objectForKey:PRODUCT_COUNT];
            if ([self.btnCart.badgeValue integerValue]) {
                [self.btnCart setHidden:NO];
            }
            else
            {
                [self.btnCart setHidden:YES];
            }
        }
        [self.tblListView reloadData];
    }
    else
    {
        if([[resultDictionary objectForKey:@"data"] count])
        {
            if([[[resultDictionary objectForKey:@"data"] objectForKey:@"remaining_orders"] isEqualToString:@"0"])
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ORDER_TRACE];
            else
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ORDER_TRACE];
            
            [[NSUserDefaults standardUserDefaults] setObject:[[[resultDictionary objectForKey:@"data"] objectForKey:@"product_in_cart"] objectForKey:@"iCartId"] forKey:CART_ID];
            [[NSUserDefaults standardUserDefaults] setObject:[[[resultDictionary objectForKey:@"data"] objectForKey:@"product_in_cart"] objectForKey:@"iTotalProduct"] forKey:PRODUCT_COUNT];
            [[NSUserDefaults standardUserDefaults] setObject:[[resultDictionary objectForKey:@"data"] objectForKey:@"remaining_orders"] forKey:REMAINING_ORDERS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:ORDER_TRACE])
        {
            [self.btnCart setImage:[UIImage imageNamed:@"Delivery-Truck"] forState:UIControlStateNormal];
            self.btnCart.badgeValue = @"";
            [self.btnCart setHidden:NO];
        }
        else
        {
            [self.btnCart setImage:[UIImage imageNamed:@"shoppingcart"] forState:UIControlStateNormal];
            self.btnCart.badgeValue = [[NSUserDefaults standardUserDefaults] objectForKey:PRODUCT_COUNT];
            [self.btnCart setHidden:!([self.btnCart.badgeValue integerValue])];
        }
        
        [UIAlertView showWithTitle:APPNAME message:[[resultDictionary objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
         }];
        return;
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end
