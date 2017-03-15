//
//  HomeViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "JASidePanelController.h"
#import "SPGooglePlacesPlaceDetailQuery.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "WS_Helper.h"
#import <Google/Analytics.h>

/**
 * This class is used to set the user current location and user can change delivery address .
 */
@interface HomeViewController : GAITrackedViewController<UITextFieldDelegate,MKMapViewDelegate,CLLocationManagerDelegate,MKOverlay,MKAnnotation>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIImageView *imagePinView;
@property (nonatomic, strong) IBOutlet UITableView *tblLocations;
@property (nonatomic, strong) IBOutlet UIView *viewLocations;
@property (nonatomic, strong) IBOutlet UIView *viewStore;
@property(nonatomic, retain) IBOutlet UILabel *lblStoreAvailable;
@property(nonatomic, retain) IBOutlet UIButton *btnChangeLocation;

@property (nonatomic, strong) IBOutlet UIButton *btnLocationTitle,*btnShopNow,*btnCurrentLocation;
@property (strong, nonatomic) MKPolyline *objPolyline;
@property (strong, nonatomic) MKPointAnnotation *origin,*destination;
@property (nonatomic, strong) WS_Helper *objWSHelper;
@property (nonatomic, retain) SPGooglePlacesAutocompleteQuery *searchQuery;

@property (nonatomic, retain) CLLocation *changeLocation;

@property (nonatomic, retain) CLLocation *locationDeleivery;

@property (nonatomic, retain) NSString *storeId;
@property (nonatomic, assign) BOOL isChangingLocation,isFromTableSelection;
@property (nonatomic, strong) NSMutableArray *arrLocations;
@property (nonatomic, strong) UITextField *txtSearchFiled;

@property (nonatomic, assign) BOOL is_FromLogin;

/**
 *  btnShopNowClicked ,This method is called when user click on Shop now button.
 *  @param btnShopNowClicked, navigates to list view controller.
 */
-(IBAction)btnShopNowClicked:(id)sender;
/**
 *  btnChangeLocationPressed ,This method is called when user click on save button.
 *  @param btnChangeLocationPressed, to change the location.
 */
-(IBAction)btnChangeLocationPressed:(id)sender;
/**
 *  btnCurrentlocationClicked ,This method is called when user click on current location button.
 *  @param btnCurrentlocationClicked, to set the user current location as delivery location.
 */
-(IBAction)btnCurrentlocationClicked:(id)sender;

@end
