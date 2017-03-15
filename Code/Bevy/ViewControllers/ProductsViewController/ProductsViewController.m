//
//  ProductsViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "ProductsViewController.h"
#import "ProductsCell.h"
#import "SMPageControl.h"
#import "OrderStatusViewController.h"
#import "GlobalManager.h"
#import "ProductCatgoriesCell.h"
#import "GlobalManager.h"
#import "CheckOutViewController.h"
#import "UIView+Genie.h"
#import "UIAlertView+Blocks.h"
#import "MenuViewController.h"

@interface ProductsViewController ()
{
    BOOL isHeaderHide,is_keyboard;
    UIButton *dummyButton;
}

@end

@implementation ProductsViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.categoryIndex = 0;
        self.subCategoryIndex = 0;
    }
    return self;
}

-(id)initWithMNPageViewController: (MNPageViewController *)controller withCategory:(NSDictionary *)category andSubCategoryIndex:(NSInteger)subCategoryIndex
{
    self = [self initWithNibName:@"ProductsViewController" bundle:nil];
    if(self)
    {
        self.pageViewController = controller;
        self.dictCategory = category;
        self.subCategoryIndex = subCategoryIndex;
        if([[category objectForKey:@"sub_category"] count])
        {
            self.dictSubCategory = [NSDictionary dictionaryWithDictionary:[[category objectForKey:@"sub_category"] objectAtIndex:subCategoryIndex]];
        }

    }
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
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:RUNNING_FIRST];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setUpLayout];
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Products Listing Screen"];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:STORE_OPEN_STATUS] isEqualToString:STORE_CLOSE]) {
        self.lblStoreStatus.textColor = [UIColor redColor];
        self.lblStoreStatus.text = [[NSUserDefaults standardUserDefaults] valueForKey:STORE_OPEN_CLOSE_MESSAGE];
    }
    else
    {
        self.lblStoreStatus.text = @"STORE IS OPEN";
    }
    
    self.parentName = [self.dictCategory valueForKey:@"category_name"];
    [self.pageViewController setLeftBarButtonWithTitle:self.parentName];
    
    if ([[self.dictCategory objectForKey:@"sub_category"] count])
    {
         [self.imageCategory sd_setImageWithURL:[NSURL URLWithString:[self.dictSubCategory valueForKey:@"banner_image"]] placeholderImage:[UIImage imageNamed:@"large_placeholder"]];
    }
    else
    {
        if ([[self.dictSubCategory valueForKey:@"promo_banner"] length])
        {
            [self.imageCategory sd_setImageWithURL:[NSURL URLWithString:[self.dictSubCategory valueForKey:@"promo_banner"]] placeholderImage:[UIImage imageNamed:@"large_placeholder"]];
        }
        else{
            [self.imageCategory sd_setImageWithURL:[NSURL URLWithString:[self.dictSubCategory valueForKey:@"banner_image"]] placeholderImage:[UIImage imageNamed:@"large_placeholder"]];
        }
        
    }
   
    
    self.productPageControl.pageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"de_dot.png"]];
    self.productPageControl.currentPageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"act_dot.png"]];
    
    [self.productPageControl setNumberOfPages:[[self.dictCategory objectForKey:@"sub_category"] count]];
    [self.productPageControl setAlignment:SMPageControlAlignmentRight];
    [self.productPageControl setCurrentPage:self.subCategoryIndex];
    [self.productPageControl setTag:200];
    
    NSLog(@"Page --> %li",(long)self.subCategoryIndex);
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"de_dot.png"]];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"act_dot.png"]];
    
    // New Change un comment if image large view needed
    //    [self.imageCategory setupImageViewer];
    [self.lblSubCategoryName setText:[self.dictSubCategory objectForKey:@"category_name"]];
    if([[self.dictSubCategory objectForKey:@"parent_id"] isEqualToString:@"0"])
    {
        [self callProductsList:[self.dictSubCategory objectForKey:@"parent_id"] andParentId:[self.dictSubCategory objectForKey:@"category_id"]];
    }
    else
    {
//        NSString *strProductName = [self.dictSubCategory objectForKey:@"category_name"];
//        [Flurry logEvent:strProductName];
//        [GlobalUtilityClass googleAnalyticsScreenTrack:strProductName];
        [self callProductsList:[self.dictSubCategory objectForKey:@"category_id"] andParentId:[self.dictSubCategory objectForKey:@"parent_id"]];
    }
    
    //    [self showProducts];
    [self btnCancelEditing:nil];
}


#pragma mark - Instance Methods

-(void)setUpLayout
{
    [self.pageViewController.navigationItem setLeftBarButtonItem:nil];
    [self.pageViewController.navigationItem setHidesBackButton:YES];
    self.pageViewController.navigationItem.rightBarButtonItems = [GlobalManager getnavigationRightButtonsWithTarget:self withImageOne:@"menu" andTarget2:self andImageTwo:@"search_iconblack"];
    [self.tblProductsView registerNib:[UINib nibWithNibName:@"ProductsCell" bundle:nil] forCellReuseIdentifier:@"ProductsCell"];
    [self.itemsCollectionView registerNib:[UINib  nibWithNibName:@"ProductCatgoriesCell" bundle:nil] forCellWithReuseIdentifier:@"ProductCatgoriesCell"];
    [self.itemsCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    
    // New Change
    UITapGestureRecognizer *tapOutsidePopUp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClosePopupClicked:)];
    [self.popupView addGestureRecognizer:tapOutsidePopUp];
    
    UITapGestureRecognizer *tapOutsidePopUpInner = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(innerPopUptapped)];
    [self.innerPopupView addGestureRecognizer:tapOutsidePopUpInner];
}


-(void)showProducts
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:ORDER_TRACE])
    {
        self.isAddEnable = NO;
        [self.btnCart setImage:[UIImage imageNamed:@"Delivery-Truck"] forState:UIControlStateNormal];
        self.btnCart.badgeValue = @"";
    }
    else
    {
        self.isAddEnable = YES;
        [self.btnCart setImage:[UIImage imageNamed:@"shoppingcart"] forState:UIControlStateNormal];
        self.btnCart.badgeValue = [[NSUserDefaults standardUserDefaults] objectForKey:PRODUCT_COUNT];
    }
    
    self.arrayDummy = [NSMutableArray arrayWithArray:self.arrayProducts];
    [self.scrollDetails setScrollsToTop:NO];
    [self.scrollDetails setDelegate:self];
    
    //     New Change
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LISTVIEW]) {
        [self btnProductsListClicked:nil];
    }
    else
    {
        [self btnProductCatgoriesClicked:nil];
    }
    [self showHeader:YES animated:YES];
}

-(void)btnSearchClicked
{
    ProductsViewController *objVc = (ProductsViewController *)self.pageViewController.viewController;
    self.pageViewController.navigationItem.leftBarButtonItems = nil;
    self.pageViewController.navigationItem.rightBarButtonItems = nil;
    self.pageViewController.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"menu"];
    
    CGFloat textWidth = 280;
    if (IS_IPHONE_6)
    {
        textWidth = 335;
    }
    else if (IS_IPHONE_6_PLUS)
    {
        textWidth = 374;
    }
    
    objVc.txtSearchFiled = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, textWidth, 25)];
    objVc.txtSearchFiled.delegate = objVc;
    objVc.txtSearchFiled.keyboardAppearance = UIKeyboardAppearanceDark;
    [objVc.txtSearchFiled setReturnKeyType:UIReturnKeySearch];
    
    [[UITextField appearance] setTintColor:[UIColor lightGrayColor]];
    
    [objVc.txtSearchFiled setBackgroundColor:[UIColor whiteColor]];
    objVc.txtSearchFiled.tag = 501;
    
    //    objVc.txtSearchFiled.layer.cornerRadius = 3;
    
    [objVc.txtSearchFiled becomeFirstResponder];
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
    [leftView setImage:[UIImage imageNamed:@"search_icon"]];
    leftView.contentMode = UIViewContentModeCenter;
    objVc.txtSearchFiled.leftView = leftView;
    objVc.txtSearchFiled.leftViewMode = UITextFieldViewModeAlways;
    
    UIButton *buttonClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonClear setFrame:CGRectMake(30, 0, 16, 16)];
    [buttonClear setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    buttonClear.tag=1;
    [buttonClear addTarget:self action:@selector(btnCancelEditing:) forControlEvents:UIControlEventTouchUpInside];
    
    objVc.txtSearchFiled.rightView = buttonClear;
    objVc.txtSearchFiled.rightViewMode = UITextFieldViewModeAlways;
    objVc.txtSearchFiled.font = [GlobalManager fontMuseoSans100:13.0];
    
    self.pageViewController.navigationItem.titleView = objVc.txtSearchFiled;
    
    self.pageViewController.navigationItem.titleView.frame = CGRectMake(textWidth, 0, 0, 25);
    [UIView animateWithDuration:0.5 animations:^
     {
         self.pageViewController.navigationItem.titleView.frame = CGRectMake(0, 0, textWidth, 25);
         [objVc showHeader:NO animated:YES];
     }
                     completion:^(BOOL finished)
     {}];
}

-(void)btnCancelEditing:(UIButton *)sender
{
    ProductsViewController *objVc = (ProductsViewController *)self.pageViewController.viewController;
    if(objVc.txtSearchFiled != nil && ![objVc.txtSearchFiled.text isEqualToString:@""])
    {
        objVc.txtSearchFiled.text = @"";
        objVc.arrayProducts = [NSMutableArray arrayWithArray:objVc.arrayDummy];
        [objVc showHeader:NO animated:YES];
        return;
    }
    
    CGFloat textWidth = 280;
    if (IS_IPHONE_6)
    {
        textWidth = 335;
    }
    else if (IS_IPHONE_6_PLUS)
    {
        textWidth = 374;
    }
    
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0,9, 30, 30)];
    leftView.contentMode = UIViewContentModeCenter;
    [leftView setImage:[UIImage imageNamed:@"search_iconblack"]];
    objVc.txtSearchFiled.rightView = leftView;
    objVc.txtSearchFiled.rightViewMode = UITextFieldViewModeAlways;
    objVc.txtSearchFiled.leftViewMode = UITextFieldViewModeNever;
    [objVc.txtSearchFiled resignFirstResponder];
    
    objVc.arrayProducts = [NSMutableArray arrayWithArray:objVc.arrayDummy];
    if([objVc.tblProductsView isHidden])
        [objVc.itemsCollectionView reloadData];
    else
        [objVc.tblProductsView reloadData];
    
    objVc.pageViewController.navigationItem.titleView.frame = CGRectMake(0, 0, textWidth, 25);
    
    [UIView animateWithDuration:0.3 animations:^{
        objVc.pageViewController.navigationItem.titleView.frame = CGRectMake(textWidth, 0, 0, 25);
        [objVc showHeader:YES animated:YES];
    }
                     completion:^(BOOL finished)
     {
         [objVc.txtSearchFiled removeFromSuperview];
         [self.pageViewController setLeftBarButtonWithTitle:objVc.parentName];
         self.pageViewController.navigationItem.rightBarButtonItems = [GlobalManager getnavigationRightButtonsWithTarget:self withImageOne:@"menu" andTarget2:self andImageTwo:@"search_iconblack"];
     }];
}

-(void)btnMenuClicked
{
    self.txtSearchFiled.text = @"";
    self.txtSearchFiled.hidden = YES;
    [self btnCancelEditing:nil];
    [self.txtSearchFiled endEditing:YES];
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer*) imageViewer
{
    return self.arrDetailImages.count;
}

- (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    return [NSURL URLWithString:[self.arrDetailImages objectAtIndex:index]];
}

//when image select that will appear in super view
- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.arrDetailImages objectAtIndex:index]]]];
}

#pragma mark - Scroll the PageViewController

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x  / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
    //    float fractionalPage = self.scrollContainer.contentOffset.x / pageWidth;
}


#pragma mark - IBAction Methods

-(IBAction)btnProductCatgoriesClicked:(id)sender
{
    if(!self.btnProductCatgories.selected)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LISTVIEW];
        self.btnProductCatgories.selected=!self.btnProductCatgories.selected;
        self.btnList.selected = NO;
        [self.btnProductCatgories setImage:[UIImage imageNamed:@"thumbe_act.png"] forState:UIControlStateNormal];
        [self.btnList setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
        self.tblProductsView.hidden=YES;
        self.viewProductCatgories.hidden=NO;
        
        [UIView transitionWithView:self.viewPanel duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve+UIViewAnimationOptionCurveEaseInOut animations:^{
            self.tblProductsView.hidden=YES;
            self.viewProductCatgories.hidden=NO;
            [self showHeader:YES animated:YES];
        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
        return;
}

-(IBAction)btnProductsListClicked:(id)sender
{
    if (!self.btnList.selected)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LISTVIEW];
        self.btnList.selected = YES;
        self.btnProductCatgories.selected = NO;
        [self.btnProductCatgories setImage:[UIImage imageNamed:@"thumbe.png"] forState:UIControlStateNormal];
        [self.btnList setImage:[UIImage imageNamed:@"list_act.png"] forState:UIControlStateNormal];
        self.tblProductsView.hidden=NO;
        self.viewProductCatgories.hidden=YES;
        
        [UIView transitionWithView:self.viewPanel duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve+UIViewAnimationOptionCurveEaseInOut animations:^{
            self.tblProductsView.hidden=NO;
            self.viewProductCatgories.hidden=YES;
            [self showHeader:YES animated:YES];
        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
        return;
}

-(IBAction)btnClosePopupClicked:(id)sender
{
    self.innerPopupView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         self.innerPopupView.transform = CGAffineTransformMakeScale(0.01, 0.01);
     }
                     completion:^(BOOL finished)
     {
         self.popupView.hidden = YES;
         self.innerPopupView.transform = CGAffineTransformIdentity;
     }];
}

#pragma mark - Tap Gesture Recognizer
-(void)innerPopUptapped
{
    
}

-(IBAction)changePage:(UIPageControl *)sender
{
    [self.scrollDetails setContentOffset:CGPointMake(self.scrollDetails.frame.size.width*sender.currentPage, 0) animated:YES];
}

-(IBAction)clickedOnQtyIncrease:(UIButton *)sender
{
    NSInteger noOfQty =[self.lblNumberOfQty.text integerValue];
    if (noOfQty>=0)
    {
        noOfQty++;
    }
    [self.lblNumberOfQty setText:[NSString stringWithFormat:@"%li",(long)noOfQty]];
}

-(IBAction)clickedOnQtyDecrease:(UIButton *)sender
{
    NSInteger noOfQty =[self.lblNumberOfQty.text integerValue];
    if (noOfQty>1)
    {
        noOfQty=noOfQty-1;
    }
    [self.lblNumberOfQty setText:[NSString stringWithFormat:@"%li",(long)noOfQty]];
}

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
            [self.pageViewController.navigationController pushViewController:objChkoutVC animated:YES];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:@"Cart is empty" handler:nil];
            return;
        }
    }
}

-(IBAction)btnAddToCartClicked:(UIButton *)sender
{
#pragma mark - New Change
    // New Change.
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:STORE_OPEN_STATUS] isEqualToString:STORE_CLOSE]) {
        
        NSString *strTitle = APPNAME;
        NSString *strMessage = [[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE];
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE] rangeOfString:@"Outside Delivery"].location != NSNotFound)
        {
            strTitle = @"Outside Delivery Zone";
            
            strMessage = [strMessage stringByReplacingOccurrencesOfString:@"Outside Delivery Zone" withString:@""];
        }
        else{
            strTitle = @"Apologies, we're closed";
            //            strMessage = [strMessage stringByReplacingOccurrencesOfString:@"Open soon!" withString:@""];
        }
        
//        [UIAlertView showWithTitle:strTitle message:strMessage handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//        }];
        
        [UIAlertView showWithTitle:[[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE_TITLE] message:[[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        
        return;
    }
#pragma mark -
    
    NSMutableDictionary *dictProduct = [NSMutableDictionary dictionaryWithDictionary:[self.arrayProducts objectAtIndex:[sender tag]]];
    [dictProduct setObject:self.lblNumberOfQty.text forKey:@"vNumOfQuantity"];
    [self callAddProductToCartWS:dictProduct];
}

-(void)reloadListView:(BOOL)isShownHeader
{
    if([self.tblProductsView isHidden])
    {
        [self.itemsCollectionView reloadData];
    }
    else
    {
        [self showHeader:isShownHeader animated:YES];
    }
}

#pragma mark - UITableViewDataSource Methods

- (void) showHeader:(BOOL)show animated:(BOOL)animated
{
    if(![self.tblProductsView isHidden])
    {
        if(animated)
        {
            [UIView animateWithDuration:.5f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
             {
                 [self.tblProductsView setTableHeaderView:(show ? self.viewScrollTop : [UIView new])];
             }
                             completion:^(BOOL finished){}];
        }
        [self.tblProductsView reloadData];
    }
    else
    {
        [self.tblProductsView setTableHeaderView:[UIView new]];
        isHeaderHide = !show;
        [self.itemsCollectionView reloadData];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayProducts count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductsCell *cell=[self.tblProductsView dequeueReusableCellWithIdentifier:@"ProductsCell"];
    NSMutableDictionary *dict = [self.arrayProducts objectAtIndex:indexPath.row];
    [cell.lblProductTitle setText:[dict objectForKey:@"product_name"]];
    [cell.lblProductSubtitle setText:[dict objectForKey:@"product_sub_title"]];
    [cell.lblPrice setText:[NSString stringWithFormat:@"£%@", [dict objectForKey:@"product_price"]]];
    [cell.lblQuantity setText:[dict objectForKey:@"product_tag"]];
    [cell.btnAdd setEnabled:self.isAddEnable];
    
    
    [cell.imgProduct sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"product_image"]] placeholderImage:[UIImage imageNamed:@"listview_placeholder"]];
    [cell.btnAdd setTag:indexPath.row];
    [cell.btnAdd addTarget:self action:@selector(btnAddToCartSmallClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.isAddEnable)
        [self popUpForProduct:indexPath.row];
}

-(void)btnAddToCartSmallClicked:(UIButton *)sender
{
#pragma mark - New Change
    // New Change.
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:STORE_OPEN_STATUS] isEqualToString:STORE_CLOSE]) {
        NSString *strTitle = APPNAME;
        
        NSString *strMessage = [[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE];
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE] rangeOfString:@"Outside Delivery"].location != NSNotFound) {
            strTitle = @"Outside Delivery Zone";
            
            strMessage = [strMessage stringByReplacingOccurrencesOfString:@"Outside Delivery Zone" withString:@""];
        }
        else{
            strTitle = @"Apologies, we're closed";
            //            strMessage = [strMessage stringByReplacingOccurrencesOfString:@"Open soon!" withString:@""];
        }
        
//        [UIAlertView showWithTitle:strTitle message:strMessage handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//        }];
        
        [UIAlertView showWithTitle:[[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE_TITLE] message:[[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        return;
    }
#pragma mark -
    dummyButton = sender;
    NSMutableDictionary *dictProduct = [NSMutableDictionary dictionaryWithDictionary:[self.arrayProducts objectAtIndex:[sender tag]]];
    [dictProduct setObject:@"1" forKey:@"vNumOfQuantity"];
    [self callAddProductToCartWS:dictProduct];
}

-(void)addButtonToCart
{
    UIButton *shopCarBt = self.btnCart;
    CALayer *transitionLayer = [[CALayer alloc] init];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    transitionLayer.opacity = 1.0;
    transitionLayer.contents = (id)[UIImage imageNamed:@"gift"].CGImage;
    transitionLayer.backgroundColor = [[UIColor clearColor] CGColor];
    
    CGRect recttemp = dummyButton.bounds;
    recttemp.size.width = 20;
    recttemp.size.height = 20;
    
    transitionLayer.frame = [[UIApplication sharedApplication].keyWindow convertRect:recttemp fromView:dummyButton];
    transitionLayer.cornerRadius = transitionLayer.frame.size.width/2.0;
    [[UIApplication sharedApplication].keyWindow.layer addSublayer:transitionLayer];
    [CATransaction commit];
    
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:transitionLayer.position];
    CGPoint toPoint = CGPointMake(shopCarBt.center.x, shopCarBt.center.y+60);
    [movePath addQuadCurveToPoint:toPoint
                     controlPoint:CGPointMake(shopCarBt.center.x,transitionLayer.position.y-120)];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = movePath.CGPath;
    positionAnimation.removedOnCompletion = YES;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.beginTime = CACurrentMediaTime();
    group.duration = 0.7;
    group.animations = [NSArray arrayWithObjects:positionAnimation,nil];
    group.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    group.delegate = self;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.autoreverses= NO;
    
    [transitionLayer addAnimation:group forKey:@"opacity"];
    [self performSelector:@selector(addShopFinished:) withObject:transitionLayer afterDelay:0.8f];
}

- (void)addShopFinished:(CALayer*)transitionLayer
{
    transitionLayer.opacity = 0;
    NSInteger numOfProductsOnCart =[self.btnCart.badge.text integerValue];
    numOfProductsOnCart++;
    self.btnCart.badgeValue = [NSString stringWithFormat:@"%li",(long)numOfProductsOnCart];
    [[NSUserDefaults standardUserDefaults] setValue:self.btnCart.badgeValue forKey:PRODUCT_COUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UICollectionView methods

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    if (sectionHeader==nil)
    {
        sectionHeader=[[UICollectionReusableView alloc] initWithFrame:(isHeaderHide ? CGRectZero : self.viewScrollTop.frame)];
    }
    self.viewScrollTop.frame = CGRectMake(0, 0,self.view.frame.size.width,self.viewScrollTop.frame.size.height);
    [sectionHeader setFrame:(isHeaderHide ? CGRectZero : self.viewScrollTop.frame)];
    [sectionHeader addSubview:(isHeaderHide ? [UIView new] : self.viewScrollTop)];
    
    return sectionHeader;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize headerSize = (isHeaderHide ? CGSizeZero : self.viewScrollTop.frame.size);
    return headerSize;
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (IS_IPHONE_6_PLUS || IS_IPHONE_6)
    {
        return UIEdgeInsetsMake(0, 10, 0, 10);// top, left, bottom, right
    }
    return UIEdgeInsetsMake(0, 4, 0, 4);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = 153;
    if (IS_IPHONE_6_PLUS)
    {
        width = 192;//185
    }
    else if (IS_IPHONE_6)
    {
        width = 172;//170
    }
    else
        width = 154;
    
    CGSize mElementSize = CGSizeMake(width, 220);
    return mElementSize;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    int spacing = 5.0;
    if (IS_IPHONE_6_PLUS)
    {
        spacing = 10;
    }
    else if (IS_IPHONE_6)
    {
        spacing = 10;
    }
    else
        spacing = 4;
    return spacing;
}


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayProducts.count;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCatgoriesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCatgoriesCell" forIndexPath:indexPath];
    NSMutableDictionary *dict = [self.arrayProducts objectAtIndex:indexPath.row];
    [cell.lblProductTitle setText:[dict objectForKey:@"product_name"]];
    [cell.lblProductSubtitle setText:[dict objectForKey:@"product_sub_title"]];
    [cell.lblPrice setText:[NSString stringWithFormat:@"£%@", [dict objectForKey:@"product_price"]]];
    [cell.lblQuantity setText:[dict objectForKey:@"product_tag"]];
    
    [cell.imgProduct sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"product_image"]] placeholderImage:[UIImage imageNamed:@"thumb_placeholder"]];
    [cell.btnAdd setEnabled:self.isAddEnable];
    [cell.btnAdd addTarget:self action:@selector(btnAddToCartSmallClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnAdd setTag:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    if(self.isAddEnable)
        [self popUpForProduct:indexPath.row];
}

-(void)popUpForProduct:(NSInteger)index
{
    [self.view endEditing:YES];
    self.lblNumberOfQty.text = @"1";
    [self.btnAddCartInPopUp setTag:index];
    self.popupView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.popupView.frame = CGRectMake(0, 0, [GlobalManager getAppDelegateInstance].window.frame.size.width, [GlobalManager getAppDelegateInstance].window.frame.size.height);
    
    [[[GlobalManager getAppDelegateInstance] window] addSubview:self.popupView];
    self.popupView.hidden=NO;
    
    self.innerPopupView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         self.innerPopupView.transform = CGAffineTransformIdentity;
     }
                     completion:^(BOOL finished)
     {
         self.innerPopupView.transform = CGAffineTransformIdentity;
         // do something once the animation finishes, put it here
     }];
    
    self.arrDetailImages = [[NSMutableArray alloc] init];
    [self.arrDetailImages addObject:[[self.arrayProducts objectAtIndex:index] objectForKey:@"product_image"]];
    
    [self.lblProductTitle setText:[[self.arrayProducts objectAtIndex:index] objectForKey:@"product_name"]];
    NSString *strProductName = [[self.arrayProducts objectAtIndex:index] objectForKey:@"product_name"];
//    [Flurry logEvent:strProductName];
    [GlobalUtilityClass googleAnalyticsScreenTrack:strProductName];
    [self.lblProductSubTitle setText:[[self.arrayProducts objectAtIndex:index] objectForKey:@"product_sub_title"]];
    [self.lblProductPrice setText:[NSString stringWithFormat:@"£%@",[[self.arrayProducts objectAtIndex:index] objectForKey:@"product_price"]]];
    [self.lblProductQuantity setText:[[self.arrayProducts objectAtIndex:index] objectForKey:@"product_tag"]];
    [self.textViewDescription setText:[[self.arrayProducts objectAtIndex:index] objectForKey:@"product_desc"]];
    
    [self.pageControl setNumberOfPages:[self.arrDetailImages count]];
    [self.pageControl setAlignment:SMPageControlAlignmentCenter];
    [self.pageControl setCurrentPage:0];
    [self.pageControl setTag:100];
    
    CGFloat xPosition = 0;
    int iCount = 0;
    
    for(UIView *view in [self.scrollDetails subviews])
    {
        [view removeFromSuperview];
    }
    
    for (NSString *str in self.arrDetailImages)
    {
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(xPosition, 0, self.scrollDetails.frame.size.width, self.scrollDetails.frame.size.height-15)];
        [imageview setContentMode:UIViewContentModeScaleAspectFit];
        [imageview sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"large_placeholder"]];
        // New Change un comment if image large view needed
        //        [imageview setupImageViewerWithDatasource:self initialIndex:iCount onOpen:nil onClose:nil];
        [self.scrollDetails addSubview:imageview];
        xPosition +=self.scrollDetails.frame.size.width;
        iCount++;
    }
    self.scrollDetails.contentSize = CGSizeMake(self.scrollDetails.frame.size.width*self.arrDetailImages.count, self.scrollDetails.frame.size.height);
}

- (void)genieToRect:(CGRect)rect edge:(BCRectEdge)edge andSender:(UIButton *)sender
{
    NSTimeInterval duration = 0.5;
    CGRect endRect = CGRectInset(rect, 5.0, 5.0);
    [self.innerPopupView genieInTransitionWithDuration:duration destinationRect:endRect destinationEdge:edge completion:
     ^{
         self.innerPopupView.transform = CGAffineTransformIdentity;
         [self.popupView removeFromSuperview];
         [self.popupView setHidden:YES];
     }];
    
    NSInteger numOfProductsOnCart =[self.btnCart.badge.text integerValue];
    NSInteger noOfPopUpQty = [self.lblNumberOfQty.text integerValue];
    numOfProductsOnCart = numOfProductsOnCart + noOfPopUpQty;
    self.btnCart.badgeValue = [NSString stringWithFormat:@"%li",(long)numOfProductsOnCart];
    [[NSUserDefaults standardUserDefaults] setValue:self.btnCart.badgeValue forKey:PRODUCT_COUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UITextField Delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        if ([self.txtSearchFiled.text isEqualToString:@""])
            [self btnCancelEditing:nil];
        return NO;
    }
    NSString *str = textField.text;
    str = [str stringByReplacingCharactersInRange:range withString:string];
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (str.length>0)
    {
        [self handleSearchForSearchString:str];
    }
    else
    {
        self.arrayProducts = [NSMutableArray arrayWithArray:self.arrayDummy];
        [self reloadListView:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.arrayProducts = [NSMutableArray arrayWithArray:self.arrayDummy];
    [self reloadListView:YES];
    
    return YES;
}
- (void)handleSearchForSearchString:(NSString *)searchString
{
    if (searchString.length == 0)
    {
        self.arrayProducts = [NSMutableArray arrayWithArray:self.arrayDummy];
        [self reloadListView:YES];
        return;
    }
    
    [self.arrayProducts removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.product_name CONTAINS[c] %@",searchString];
    self.arrayProducts = [NSMutableArray arrayWithArray:[self.arrayDummy filteredArrayUsingPredicate:predicate]];
    [self reloadListView:NO];
}

-(void)searchViewAnimationUP
{
    [UIView animateWithDuration:0.5 animations:^{
        self.viewPanel.frame = CGRectMake(self.viewPanel.frame.origin.x, 1, self.viewPanel.frame.size.width, self.viewPanel.frame.size.height);
        self.viewScrollTop.frame = CGRectMake(self.viewScrollTop.frame.origin.x, - 170, self.view.frame.size.width, self.viewScrollTop.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)searchAnimationDown
{
    [UIView animateWithDuration:0.3 animations:^{
        self.viewPanel.frame = CGRectMake(self.viewPanel.frame.origin.x, 171, self.viewPanel.frame.size.width, self.viewPanel.frame.size.height);
        self.viewScrollTop.frame = CGRectMake(self.viewScrollTop.frame.origin.x, 1, self.view.frame.size.width, self.viewScrollTop.frame.size.height);
    } completion:^(BOOL finished)
     {
     }];
}

#pragma mark - Webservice Methods

-(void)callAddProductToCartWS:(NSDictionary *)dictProduct
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LOCATION_NAME] == nil)
    {
        NSString *address = [self getADdressFromLocation:[NSString stringWithFormat:@"%@,%@",[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LATITUDE], [[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LONGITUDE]]];
        NSLog(@"CURRENT ADDRESS: %@", address);
        if(address)
        {
            [[NSUserDefaults standardUserDefaults] setObject:address forKey:REQUIRED_LOCATION_NAME];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:REQUIRED_LOCATION_NAME];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID] forKey:@"store_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LOCATION_NAME] forKey:@"delivery_address"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LATITUDE] forKey:@"delivery_lat"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LONGITUDE] forKey:@"delivery_long"];
    
    NSString *strPostCode = [[GlobalManager getAppDelegateInstance].dictAddress valueForKey:@"POST_CODE"];
    
    [params setObject:([strPostCode length])?strPostCode:@"" forKey:@"delivery_postcode"];
    [params setObject:[dictProduct objectForKey:@"product_id"] forKey:@"product_id"];
    [params setObject:[dictProduct objectForKey:@"vNumOfQuantity"] forKey:@"qty"];
    [params setObject:([[NSUserDefaults standardUserDefaults] objectForKey:CART_ID] == nil ? @"0" : [[NSUserDefaults standardUserDefaults] objectForKey:CART_ID]) forKey:@"cart_id"];
    
    [self.objWSHelper setServiceName:@"ADD_PRODUCT_TO_CART"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getAddProductToCartURL:params]];
}

-(void)callProductsList:(NSString *)categoryId andParentId:(NSString *)parentId
{
    //    new change
    //    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@""];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:categoryId forKey:@"sub_cat_id"];
    [params setObject:parentId forKey:@"par_cat_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID] forKey:@"store_id"];
    
    [self.objWSHelper setServiceName:@"PRODUCT_LIST"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getProductListURL:params]];
}

#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if(!response)
        return;
    
    NSMutableDictionary *resultDictionary = (NSMutableDictionary *)response;
    if([helper.serviceName isEqualToString:@"PRODUCT_LIST"])
    {
        if([[[resultDictionary objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:STORE_ID] integerValue] > 0) {
                self.arrayProducts = [NSMutableArray arrayWithArray:[[resultDictionary objectForKey:@"data"] objectForKey:@"fetch_product_id"]];
            }
            else
            {
                self.arrayProducts = [NSMutableArray arrayWithArray:[[resultDictionary objectForKey:@"data"] objectForKey:@"fetch_product_id_v1"]];
            }
            NSString *remainingOrders = [[[[resultDictionary objectForKey:@"data"] objectForKey:@"remaining_orders"] objectAtIndex:0] objectForKey:@"remaining_orders"];
            
            if([remainingOrders isEqualToString:@"0"])
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ORDER_TRACE];
            else
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ORDER_TRACE];
            [[NSUserDefaults standardUserDefaults] setObject:remainingOrders forKey:REMAINING_ORDERS];
            
            if([[[resultDictionary objectForKey:@"data"] objectForKey:@"product_in_cart"] count])
            {
                [[NSUserDefaults standardUserDefaults] setObject:[[[[resultDictionary objectForKey:@"data"] objectForKey:@"product_in_cart"] objectAtIndex:0] objectForKey:@"iCartId"] forKey:CART_ID];
                [[NSUserDefaults standardUserDefaults] setObject:[[[[resultDictionary objectForKey:@"data"] objectForKey:@"product_in_cart"] objectAtIndex:0] objectForKey:@"iTotalProduct"] forKey:PRODUCT_COUNT];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                NSString *remainingOrders = [[[[resultDictionary objectForKey:@"data"] objectForKey:@"remaining_orders"] objectAtIndex:0] objectForKey:@"remaining_orders"];
                if([remainingOrders isEqualToString:@"0"])
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ORDER_TRACE];
                else
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ORDER_TRACE];
                [[NSUserDefaults standardUserDefaults] setObject:remainingOrders forKey:REMAINING_ORDERS];
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:CART_ID];
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:PRODUCT_COUNT];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [self showProducts];
        }
        else
        {
            NSString *remainingOrders = [[[resultDictionary objectForKey:@"data"] objectAtIndex:0] objectForKey:@"remaining_orders"];
            if([remainingOrders isEqualToString:@"0"])
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ORDER_TRACE];
            else
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ORDER_TRACE];
            
            [[NSUserDefaults standardUserDefaults] setObject:remainingOrders forKey:REMAINING_ORDERS];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:CART_ID];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:PRODUCT_COUNT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            ProductsViewController *objVc = (ProductsViewController *)self.pageViewController.viewController;
            if(objVc.subCategoryIndex == self.subCategoryIndex)
            {
                [UIAlertView showWithTitle:APPNAME message:[[resultDictionary objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
                return;
            }
        }
    }
    else if([helper.serviceName isEqualToString:@"ADD_PRODUCT_TO_CART"])
    {
        if([[[resultDictionary objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            
            @try {
                [[NSUserDefaults standardUserDefaults] setObject:[[[resultDictionary objectForKey:@"data"] objectAtIndex:0] objectForKey:@"cart_id"] forKey:CART_ID];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if([self.popupView isHidden])
                {
                    [self addButtonToCart];
                    return;
                }
                else
                {
                    CGRect rectTemp = self.btnCart.frame;
                    rectTemp.origin.y += 94;
                    rectTemp.origin.x += 30;
                    rectTemp.size.width = 10;
                    rectTemp.size.height = 10;
                    [self genieToRect:rectTemp edge:BCRectEdgeTop andSender:self.btnAddCartInPopUp];
                }
                
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[resultDictionary objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else
    {
        [UIAlertView showWithTitle:APPNAME message:[[resultDictionary objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
        return;
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

-(NSString*)getADdressFromLocation:(NSString *)latAndLong
{
    NSString *esc_addr =  [latAndLong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    NSMutableDictionary *data = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray *dataArray = (NSMutableArray *)[data valueForKey:@"results"];
    if (dataArray.count == 0)
    {
        NSLog(@"INVALID ADDRESS");
    }
    else
    {
        for (id firstTime in dataArray)
        {
            NSString *jsonStr1 = [firstTime valueForKey:@"formatted_address"];
            return jsonStr1;
        }
    }
    return nil;
}

@end
