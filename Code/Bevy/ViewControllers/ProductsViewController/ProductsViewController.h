//
//  ProductsViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"
//#import "NPRImageView.h"
#import "MNPageViewController.h"

/**
 * This class is used to show the sub products of the selected item and user can also add the cart.
 */

@interface ProductsViewController : GAITrackedViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate,UITextFieldDelegate,MHFacebookImageViewerDatasource, ParseWSDelegate>

-(id)initWithMNPageViewController: (MNPageViewController *)controller withCategory:(NSDictionary *)category andSubCategoryIndex:(NSInteger)subCategoryIndex;

@property (nonatomic, retain) MNPageViewController *pageViewController;
@property (nonatomic, strong) IBOutlet SMPageControl *productPageControl;
@property (nonatomic, strong) IBOutlet SMPageControl *pageControl;

@property (nonatomic, strong) IBOutlet UITableView *tblProductsView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollDetails;
@property (nonatomic, strong) IBOutlet UIImageView *imgPaging;
@property (nonatomic, strong) IBOutlet UIView *viewStrip;
@property (nonatomic, strong) IBOutlet UIView *viewPanel;
@property (nonatomic, strong) IBOutlet UIView *viewScrollTop;
@property (nonatomic, strong) IBOutlet UIButton *btnProductCatgories;
@property (nonatomic, strong) IBOutlet UIButton *btnList;
@property (nonatomic, strong) IBOutlet UIButton *btnAddCartInPopUp;
@property (nonatomic, strong) IBOutlet UILabel *lblStoreStatus;
@property (nonatomic, strong) IBOutlet UILabel *lblSubCategoryName;
@property (nonatomic, strong) IBOutlet UIImageView *imageCategory;
@property (nonatomic, strong) IBOutlet UIImageView *imageProduct;
@property (nonatomic, strong) UITextField *txtSearchFiled;
//CollectionView
@property (nonatomic, strong) IBOutlet UICollectionView *itemsCollectionView;
@property (nonatomic, strong) IBOutlet UIButton *btnCart;
@property (nonatomic, strong) IBOutlet UIView *viewProductCatgories;

//ProductDetails
@property (nonatomic, strong) IBOutlet UIButton *btnClosePopup;
@property (nonatomic, retain) IBOutlet UIView *popupView;
@property (nonatomic, retain) IBOutlet UIView *innerPopupView;
@property (nonatomic, strong) IBOutlet UILabel *lblNumberOfQty;
@property (nonatomic, strong) IBOutlet UILabel *lblProductTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblProductSubTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblProductPrice;
@property (nonatomic, strong) IBOutlet UILabel *lblProductQuantity;
@property (nonatomic, strong) IBOutlet UITextView *textViewDescription;

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger categoryIndex;
@property (nonatomic, assign) NSInteger subCategoryIndex;
@property (nonatomic, strong) NSString *parentName;

@property (nonatomic, retain) NSMutableArray *arrayCategory;
@property (nonatomic, retain) NSDictionary *dictCategory;
@property (nonatomic, retain) NSDictionary *dictSubCategory;

@property (nonatomic, strong) NSMutableArray *arrayProducts;
@property (nonatomic, strong) NSMutableArray *arrDetailImages;
@property (nonatomic, strong) NSMutableArray *arrayDummy;
@property (nonatomic, strong) NSMutableArray *arrayOfOderViews;

@property (nonatomic, assign) BOOL isAddEnable;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSString *strProductName;
@property (nonatomic, retain) WS_Helper *objWSHelper;


/**
 *  btnProductCatgoriesClicked ,This method is called when user click on product categories button.
 *  @param btnProductCatgoriesClicked, it will show the product all categories in the grid view manner.
 */
-(IBAction)btnProductCatgoriesClicked:(id)sender;
/**
 *  btnProductsListClicked ,This method is called when user click on product list  button.
 *  @param btnProductsListClicked, it will show the product all categories in the list view manner.
 */
-(IBAction)btnProductsListClicked:(id)sender;
/**
 *  btnCartClicked ,This method is called when user click on cart  button.
 *  @param btnCartClicked, navigates to check out view controller.
 */
-(IBAction)btnCartClicked:(id)sender;
/**
 *  btnAddToCartClicked ,This method is called when user click on add to cart  button.
 *  @param btnAddToCartClicked, to add product to carts.
 */
-(IBAction)btnAddToCartClicked:(id)sender;
/**
 *  btnCancelEditing ,This method is called when user click on cancel  button.
 *  @param btnCancelEditing, to cancel the searching proiducts.
 */
-(void)btnCancelEditing:(UIButton *)sender;

@end
