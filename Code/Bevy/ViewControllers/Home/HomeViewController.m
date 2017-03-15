//
//  HomeViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "HomeViewController.h"
#import "LocationTableViewCell.h"
#import "UIView+Genie.h"
#import "ListViewController.h"
#import "CustomMap.h"
#import "MenuViewController.h"
#import "CheckOutViewController.h"
#import "DeliveryAddressViewController.h"

#define CLCOORDINATES_EQUAL( coord1, coord2 ) (coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude)

@interface HomeViewController ()<UIGestureRecognizerDelegate>
{
    BOOL isSettingUpMap;
    BOOL isStoreFound;
    NSInteger webserviceCall;
    
    BOOL lastTime;
    CLLocation *locationForAlert;
    NSInteger previousValue;
    NSInteger presentValue;
    
    NSString *strMessage;
    NSString *strTitle;
    NSString *strStatus;
    BOOL is_first ;
}
@end

@implementation HomeViewController

@synthesize boundingMapRect,coordinate;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        isSettingUpMap =YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isStoreFound = NO;
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [self setUpUI];
}

-(void)setUpUI
{
    [self.navigationItem setRightBarButtonItems:[GlobalManager getnavigationRightButtonsWithTarget:self withImageOne:@"menu.png" andTarget2:self andImageTwo:@"search_icon"]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor lightGrayColor]];
    [titleLabel setFont:[GlobalManager fontMuseoSans300:13.0f]];
    [titleLabel setText:@"Enter Delivery Address"];
    titleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textClicked)];
    [titleLabel addGestureRecognizer:tapGes];
    
    
//    [self.navigationItem setTitleView:titleLabel];
    
    [self.tblLocations registerNib:[UINib nibWithNibName:@"LocationTableViewCell" bundle:nil] forCellReuseIdentifier:@"LocationTableViewCell"];
    
    self.searchQuery =[[SPGooglePlacesAutocompleteQuery alloc]init];
    self.searchQuery.radius = 1000.0;
    
    if (IS_IPHONE_6 || IS_IPHONE_6_PLUS)
    {
        [self.btnShopNow setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, (IS_IPHONE_6 ? -360 : -400))];
    }
    
    CGRect mapFrame = self.mapView.frame;
    [self.imagePinView setFrame:CGRectMake(self.imagePinView.frame.origin.x-7, mapFrame.origin.y + (mapFrame.size.height/2-self.imagePinView.frame.size.height)+((IS_IPHONE_6 || IS_IPHONE_6_PLUS)?6:3), self.imagePinView.frame.size.width, self.imagePinView.frame.size.height)];
    self.isFromTableSelection = NO;
    
    
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];

}

-(void)viewWillAppear:(BOOL)animated
{
    is_first = NO;
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Location Screen"];
    NSLog(@"%@",self.navigationController.viewControllers);
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:RUNNING_FIRST];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.txtSearchFiled.text = @"";

    if (self.isChangingLocation)
    {
        if(![GlobalManager getAppDelegateInstance].isFromHomeTab)
            [self setBackButton];
        else
        {
//           [self setLeftButton];
        }
        
        [self.btnShopNow setHidden:YES];
        [self.btnCurrentLocation setHidden:NO];
        [self.btnChangeLocation setHidden:NO];
    }
    else
    {
//        [self setLeftButton];
        if([self.btnShopNow isHidden])
        {
            [self.btnChangeLocation setHidden:YES];
            [self.btnShopNow setHidden:NO];
            [self.btnCurrentLocation setHidden:NO];
        }
    }
    NSInteger productCount = [[[NSUserDefaults standardUserDefaults] objectForKey:PRODUCT_COUNT] integerValue];
    if (productCount <= 0) {
        [self performSelector:@selector(showCurrentCoordinate:) withObject:[GlobalManager getAppDelegateInstance].currentLocation afterDelay:0.1];
        locationForAlert = [GlobalManager getAppDelegateInstance].currentLocation;
        [self callGetNearStoreWS:locationForAlert.coordinate];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:STORE_ID] == nil)
    {
        [self performSelector:@selector(showCurrentCoordinate:) withObject:[GlobalManager getAppDelegateInstance].currentLocation afterDelay:0.1];
        locationForAlert = [GlobalManager getAppDelegateInstance].currentLocation;

        [self callGetNearStoreWS:locationForAlert.coordinate];


    }
    else
    {
        if(isSettingUpMap || ![self.btnLocationTitle.titleLabel.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LOCATION_NAME]])
        {
            isSettingUpMap = NO;
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LATITUDE] floatValue], [[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LONGITUDE] floatValue]);
            [GlobalManager getAppDelegateInstance].recentStoreLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
            if (productCount > 0) {
                [self performSelector:@selector(showCurrentCoordinate:) withObject:[GlobalManager getAppDelegateInstance].recentStoreLocation afterDelay:0.1];
                locationForAlert = [GlobalManager getAppDelegateInstance].currentLocation;
                [self callGetNearStoreWS:locationForAlert.coordinate];
            }
        }
        else
        {
            [self.btnLocationTitle setTitle:[[NSUserDefaults standardUserDefaults] objectForKey:REQUIRED_LOCATION_NAME] forState:UIControlStateNormal];
        }
    }
    [self btnSearchClicked];
    self.txtSearchFiled.text = @"";
    lastTime = NO;

}

#pragma mark - Instance Methods

-(void)showCurrentCoordinate:(CLLocation *)location
{
    CLLocationCoordinate2D coord=location.coordinate;
    MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(coord, 1.0, 1.0);
    [self.mapView setRegion:region animated:YES];//MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.05, 0.05))
}

-(void)showSelectedCoordinate:(CLLocation *)location
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void)
                   {
                       NSString *address = [self getAddressFromLatLong:[NSString stringWithFormat:@"%f,%f",location.coordinate.latitude, location.coordinate.longitude]];
                       dispatch_async(dispatch_get_main_queue(), ^(void)
                                      {
                                          if(address != nil)
                                          {
                                              if (self.isFromTableSelection) {
                                                  self.isFromTableSelection = NO;
                                              }
                                              else
                                                  [self.btnLocationTitle setTitle:address forState:UIControlStateNormal];
                                              if(!self.isChangingLocation)
                                              {
                                                  [[NSUserDefaults standardUserDefaults] setObject:address forKey:REQUIRED_LOCATION_NAME];
                                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                              }
                                          }
                                      });
                   });
    if (is_first)
    {
//        [self callGetNearStoreWS:location.coordinate];
        [self performSelector:@selector(callWSToAvoidAlerts:) withObject:location afterDelay:0.1];
        
    }
}

#pragma mark - Calling this method to stop Multiple Alerts at a time
-(void)callWSToAvoidAlerts:(CLLocation *)location
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSLog(@"***** WS Call *****");
    [self callGetNearStoreWS:location.coordinate];
}



-(void)getAddressFromLocation:(CLLocation *)location
{
    CLGeocoder *gc = [[CLGeocoder alloc] init];
    [gc reverseGeocodeLocation:location completionHandler:^(NSArray *placemark, NSError *error)
     {
         CLPlacemark *pm = [placemark objectAtIndex:0];
         NSDictionary *address = pm.addressDictionary;
         NSLog(@"ADDRESS: %@", address);
     }];
}

-(NSString*)getAddressFromLatLong:(NSString *)latLng
{
    NSString *esc_addr =  [latLng stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    NSMutableDictionary *data;
    if(result)
    {
        data = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]options:NSJSONReadingMutableContainers error:nil];
    }
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        
        is_first = YES;
        
    }
}

#pragma mark - MKMapViewDelegate methods


- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if(self.isChangingLocation)
        [self.btnChangeLocation setEnabled:NO];
    else
        [self.btnShopNow setEnabled:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CGPoint center = self.mapView.center;
    CLLocationCoordinate2D coord = [self.mapView convertPoint:center toCoordinateFromView:self.mapView];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    if (self.isFromTableSelection )
    {
        coord.latitude   = [[[NSUserDefaults standardUserDefaults] valueForKey:REQUIRED_LATITUDE] floatValue];
        coord.longitude  = [[[NSUserDefaults standardUserDefaults] valueForKey:REQUIRED_LONGITUDE] floatValue];
        location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    }
    
    //22-Mar-2016 changes

    
    CLLocationDistance distanceThreshold = 15.0; // in meters
    if ([locationForAlert distanceFromLocation:location] < distanceThreshold && locationForAlert != nil)
    {
         [self performSelector:@selector(setLastTime) withObject:nil afterDelay:0.1];
    }
    
    
    if(!isSettingUpMap)
    {
        if(self.isChangingLocation)
        {
            self.changeLocation = location;
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",coord.latitude] forKey:REQUIRED_LATITUDE];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",coord.longitude] forKey:REQUIRED_LONGITUDE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[GlobalManager getAppDelegateInstance] setRecentStoreLocation:location];
        }
    }
    isStoreFound = NO;
    [self showSelectedCoordinate:location];
}



-(void)setLastTime
{
    lastTime = YES;
}




#pragma mark - IBAction Methods

-(IBAction)btnChangeLocationPressed:(id)sender
{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:STORE_OPEN_STATUS] isEqualToString:STORE_CLOSE]) {
        [UIAlertView showWithTitle:[[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE_TITLE] message:[[NSUserDefaults standardUserDefaults] valueForKey:STORE_STATUS_MESSAGE] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        return;
    }
    [self callChangeCartAddressWS];
    return;
}

-(IBAction)btnCurrentlocationClicked:(id)sender
{
    is_first = YES;
    self.txtSearchFiled.text = @"";
    self.isFromTableSelection = NO;
    [self showCurrentCoordinate:[GlobalManager getAppDelegateInstance].currentLocation];
}

-(IBAction)btnShopNowClicked:(id)sender
{
    [self navigateToDeliveryAddressScreen];
    //    [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
    //    MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
    //    [menuViewcontroller chooseRightPanelIndex:0];
    //    [menuViewcontroller menuItemHomeClikced:nil];
}

-(void)navigateToDeliveryAddressScreen
{
    DeliveryAddressViewController *objDeliveryVC = [[DeliveryAddressViewController alloc] init];
    objDeliveryVC.locationLatLon = self.locationDeleivery;
    objDeliveryVC.isFromLocationChange = NO;
    objDeliveryVC.isPopToCheckOutScreen = NO;
    objDeliveryVC.strAddress = self.btnLocationTitle.titleLabel.text;
    [self.navigationController pushViewController:objDeliveryVC animated:YES];
}


-(void)btnMenuClicked
{
    if(![self.viewLocations isHidden])
        [self btnCancelEditing:nil];
    
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

-(IBAction)btnAddressPressed:(id)sender
{
    [self btnSearchClicked];
    return;
}

-(void)textClicked
{
    [self btnSearchClicked];
}

-(void)btnSearchClicked
{
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"menu.png"];
    
    CGFloat textWidth = 280;
    if (IS_IPHONE_6)
    {
        textWidth = 335;
    }
    else if (IS_IPHONE_6_PLUS)
    {
        textWidth = 374;
    }
    
    self.txtSearchFiled = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, textWidth, 35)];
    self.txtSearchFiled.delegate = self;
    [self.txtSearchFiled setAutocorrectionType:UITextAutocorrectionTypeNo];
    self.txtSearchFiled.returnKeyType = UIReturnKeySearch;
    [self.txtSearchFiled setPlaceholder:@"Enter Delivery Address..."];
    if(![@"SEARCHING" isEqualToString:self.btnLocationTitle.titleLabel.text])
        [self.txtSearchFiled setText:self.btnLocationTitle.titleLabel.text];
    
    self.txtSearchFiled.keyboardAppearance = UIKeyboardAppearanceDark;
    [[UITextField appearance] setTintColor:[UIColor lightGrayColor]];
    [self.txtSearchFiled setBackgroundColor:[UIColor whiteColor]];
    [self.txtSearchFiled textRectForBounds:CGRectMake(20, self.txtSearchFiled.frame.origin.y, self.txtSearchFiled.frame.size.width-47, self.txtSearchFiled.frame.size.height)];
    self.txtSearchFiled.tag = 502;
    [self.txtSearchFiled awakeFromNib];

//    [self.txtSearchFiled becomeFirstResponder];
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
    [rightView setImage:[UIImage imageNamed:@"search_icon"]];
    rightView.contentMode = UIViewContentModeLeft;
    self.txtSearchFiled.rightView = rightView;
    self.txtSearchFiled.rightViewMode = UITextFieldViewModeAlways;
    
    [self.txtSearchFiled setFont:[GlobalManager fontMuseoSans100:15.0]];
    
    UIButton *buttonClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonClear setFrame:CGRectMake(0, 0, 20, 20)];
    [buttonClear setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [buttonClear addTarget:self action:@selector(btnClearEditing:) forControlEvents:UIControlEventTouchUpInside];
//    self.txtSearchFiled.rightView = buttonClear;
    self.txtSearchFiled.rightViewMode = UITextFieldViewModeAlways;
    
    self.navigationItem.titleView = self.txtSearchFiled;
//    self.navigationItem.titleView.frame = CGRectMake(280, 0, 0, 25);
//    [UIView animateWithDuration:0.5 animations:^
//     {
         self.navigationItem.titleView.frame = CGRectMake(0, 0, 280, 35);
//     }
//                     completion:^(BOOL finished)
//     {}];
}

-(void)btnClearEditing:(UIButton *)sender
{
    if ([self.txtSearchFiled.text isEqualToString:@""])
        [self btnCancelEditing:nil];
    else
        self.txtSearchFiled.text = @"";
}

-(void)btnCancelEditing:(UIButton *)sender
{
    if ([self.txtSearchFiled.text length]) {
        return;
    }
//    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    leftView.contentMode = UIViewContentModeCenter;
//    [leftView setImage:[UIImage imageNamed:@"search_icon"]];
//    [self.txtSearchFiled setText:@""];
//    self.txtSearchFiled.rightView = leftView;
//    self.txtSearchFiled.rightViewMode = UITextFieldViewModeAlways;
//    self.txtSearchFiled.leftViewMode = UITextFieldViewModeNever;
//    [self.txtSearchFiled resignFirstResponder];
        self.viewLocations.hidden = YES;
//    
//    self.navigationItem.titleView.frame = CGRectMake(0, 0, 280, 40);
//    [UIView animateWithDuration:0.5 animations:^
//     {
//         self.navigationItem.titleView.frame = CGRectMake(280, 0, 0, 40);
//         if (sender)
//         {
//             CGRect rectTemp = sender.frame;
//             rectTemp.origin.y -= 10;
//             rectTemp.origin.x += 10;
//         }
//     }
//                     completion:^(BOOL finished)
//     {
//         [self.txtSearchFiled removeFromSuperview];
//         
//         UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
//         [titleLabel setBackgroundColor:[UIColor clearColor]];
//         [titleLabel setTextColor:[UIColor lightGrayColor]];
//         [titleLabel setFont:[GlobalManager fontMuseoSans300:13.0f]];
//         [titleLabel setText:@"Enter Delivery Address"];
//         titleLabel.userInteractionEnabled = YES;
//         UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textClicked)];
//         [titleLabel addGestureRecognizer:tapGes];
//         [self.navigationItem setTitleView:titleLabel];
//         
//         [self.navigationItem setRightBarButtonItems:[GlobalManager getnavigationRightButtonsWithTarget:self withImageOne:@"menu" andTarget2:self andImageTwo:@"search_icon"]];
    
//         if (self.isChangingLocation && ![GlobalManager getAppDelegateInstance].isFromHomeTab)
//         {
//             [self setBackButton];
//         }
//         else
//         {
//             [self setLeftButton];
//         }
//     }];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        [self btnCancelEditing:nil];
        return NO;
    }
    NSString *str = textField.text;
    str = [str stringByReplacingCharactersInRange:range withString:string];
    if (str.length>0)
    {
        [self handleSearchForSearchString:str];
    }
    else
    {
        [self.viewLocations setHidden:YES];
        
        [self.tblLocations setHidden:YES];
        [self.arrLocations removeAllObjects];
        [self.tblLocations reloadData];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.tblLocations.hidden  = YES;
    self.viewLocations.hidden = YES;
    return YES;
}

#pragma mark - UITableViewDelegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrLocations count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LocationTableViewCell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[self placeAtIndexPath:indexPath].name componentsSeparatedByString:@","]];
    if (array.count)
    {
        cell.lblLocationName.text =[[array objectAtIndex:array.count - 1] uppercaseString];
        [array removeLastObject];
        cell.lblLocationAddress.text = [array componentsJoinedByString:@", "];
    }
    else
    {
        cell.lblLocationName.text =[self placeAtIndexPath:indexPath].name;
        cell.lblLocationAddress.text =[self placeAtIndexPath:indexPath].name;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    is_first = YES;
    self.viewLocations.hidden = YES;
    [self.view endEditing:YES];
    [self.txtSearchFiled resignFirstResponder];
    
    [self btnCancelEditing:nil];
    self.isFromTableSelection = YES;
    [self performSelector:@selector(showSPGooglePlacesPlaceAddress:) withObject:indexPath afterDelay:0.1];
}

-(void)showSPGooglePlacesPlaceAddress:(NSIndexPath *)indexPath
{
    SPGooglePlacesPlaceDetailQuery *query = [[SPGooglePlacesPlaceDetailQuery alloc] init];
    SPGooglePlacesAutocompletePlace *place =[self.arrLocations objectAtIndex:indexPath.row];
    [query setPlaceid:place.placeid];
    [query fetchPlaceDetail:^(NSDictionary *placeDictionary, NSError *error)
     {
         NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[[placeDictionary valueForKey:@"geometry"]valueForKey:@"location"]];
         CLLocationCoordinate2D coord;
         coord.latitude   = [[dict valueForKey:@"lat"] floatValue];
         coord.longitude  = [[dict valueForKey:@"lng"] floatValue];
         if(self.isChangingLocation)
         {
             self.changeLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
             [self showSelectedCoordinate:self.changeLocation];
         }
         else
         {
             [[NSUserDefaults standardUserDefaults] setObject:[dict valueForKey:@"lat"] forKey:REQUIRED_LATITUDE];
             [[NSUserDefaults standardUserDefaults] setObject:[dict valueForKey:@"lng"] forKey:REQUIRED_LONGITUDE];
             [[NSUserDefaults standardUserDefaults] synchronize];
             [[GlobalManager getAppDelegateInstance] setRecentStoreLocation:[[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude]];
         }
         MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(coord, 1.0, 1.0);
         [self.mapView setRegion:region animated:YES];//MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.05, 0.05))
     }];
    
    NSString *placeName =[self placeAtIndexPath:indexPath].name;
    if(placeName != nil)
    {
        [self.btnLocationTitle setTitle:placeName forState:UIControlStateNormal];
        if(!self.isChangingLocation)
        {
            [[NSUserDefaults standardUserDefaults] setObject:placeName forKey:REQUIRED_LOCATION_NAME];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.arrLocations.count) {
        return nil;
    }
    return [self.arrLocations objectAtIndex:indexPath.row];
}

- (void)handleSearchForSearchString:(NSString *)searchString
{
    if (searchString.length == 0)
    {
        searchString = self.txtSearchFiled.text;
    }
    self.searchQuery.location = [GlobalManager getAppDelegateInstance].currentLocation.coordinate;

    self.searchQuery.input = searchString;
    [self.searchQuery fetchPlaces:^(NSArray *places, NSError *error)
     {
         if (error)
         {
             SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
             self.tblLocations.hidden = YES;
             self.viewLocations.hidden = YES;
         }
         else
         {
             self.arrLocations = [NSMutableArray arrayWithArray:places];
             if (self.arrLocations.count>0)
             {
                 self.tblLocations.hidden = NO;
                 self.viewLocations.hidden = NO;
                 [self.tblLocations reloadData];
             }
             else{
                 self.tblLocations.hidden = YES;
                 self.viewLocations.hidden = YES;
                 [self.tblLocations reloadData];
             }
         }
     }];
}

#pragma mark - Webservices Methods

-(void)callGetNearStoreWS:(CLLocationCoordinate2D)coord
{
 
    self.locationDeleivery = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    
    
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    NSDictionary *params = @{@"user_lat" : [NSString stringWithFormat:@"%f", coord.latitude], @"user_long" : [NSString stringWithFormat:@"%f", coord.longitude]};
    [self.objWSHelper setServiceName:@"GET_NEAR_STORES"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getNearByStoreURL:params]];
    
    
    
}

-(void)callChangeCartAddressWS
{
    [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
    self.locationDeleivery = [[CLLocation alloc] initWithLatitude:self.changeLocation.coordinate.latitude longitude:self.changeLocation.coordinate.longitude];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:CART_ID] forKey:@"cart_id"];
    [params setObject:self.btnLocationTitle.titleLabel.text forKey:@"delivery_address"];
    [params setObject:[NSString stringWithFormat:@"%f",self.changeLocation.coordinate.latitude] forKey:@"delivery_lat"];
    [params setObject:[NSString stringWithFormat:@"%f",self.changeLocation.coordinate.longitude] forKey:@"delivery_long"];
    [params setObject:self.storeId forKey:@"store_id"];
    
    [self.objWSHelper setServiceName:@"CHANGE_CART_ADDRESS"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getChangeCartAddress:params]];
}

#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    
    
    NSLog(@"response --- %@", response);
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if(!response)
        return;
    NSDictionary *dictResults = (NSMutableDictionary *)response;
    
    if([helper.serviceName isEqualToString:@"CHANGE_CART_ADDRESS"])
    {
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
//            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
//             {
                 [[NSUserDefaults standardUserDefaults] setObject:self.storeId forKey:STORE_ID];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",self.changeLocation.coordinate.latitude] forKey:REQUIRED_LATITUDE];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",self.changeLocation.coordinate.longitude] forKey:REQUIRED_LONGITUDE];
                 [[NSUserDefaults standardUserDefaults] setObject:self.btnLocationTitle.titleLabel.text forKey:REQUIRED_LOCATION_NAME];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 if(![GlobalManager getAppDelegateInstance].isFromHomeTab)
                 {
                     DeliveryAddressViewController *objDeliveryVC = [[DeliveryAddressViewController alloc] init];
                     objDeliveryVC.locationLatLon = self.locationDeleivery;
                     objDeliveryVC.isFromLocationChange = YES;
                     objDeliveryVC.strAddress = self.btnLocationTitle.titleLabel.text;
                     objDeliveryVC.isPopToCheckOutScreen = YES;
                     [self.navigationController pushViewController:objDeliveryVC animated:YES];
                     //                     [self popToCheckOutScreen];


                 }
                 else
                 {
                     [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
                     
                     DeliveryAddressViewController *objDeliveryVC = [[DeliveryAddressViewController alloc] init];
                     objDeliveryVC.locationLatLon = self.locationDeleivery;
                     objDeliveryVC.strAddress = self.btnLocationTitle.titleLabel.text;
                     objDeliveryVC.isFromLocationChange = YES;
                     objDeliveryVC.isPopToCheckOutScreen = NO;
                     
                     [self.navigationController pushViewController:objDeliveryVC animated:YES];

//                     [self navigateToDeliveryAddressScreen];
//                     MenuViewController *menuViewcontroller = (MenuViewController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.rightPanel;
//                     [menuViewcontroller chooseRightPanelIndex:0];
//                     [menuViewcontroller menuItemHomeClikced:nil];
                 }
//             }];
        }
        else
        {
            if(![GlobalManager getAppDelegateInstance].isFromHomeTab)
                [self popToCheckOutScreen];
            else
                [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
        }
    }
    else
    {
        
        webserviceCall ++;
      
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            isStoreFound=YES;
            [[NSUserDefaults standardUserDefaults] setObject:STORE_OPEN forKey:STORE_OPEN_STATUS];
            self.storeId = [[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"store_id"];
            NSLog(@"STORE ID FOUND: %@", self.storeId);
            if(self.isChangingLocation)
            {
                [self.btnChangeLocation setEnabled:YES];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:self.storeId forKey:STORE_ID];
                [self.btnShopNow setEnabled:YES];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.lblStoreAvailable setText:@"STORE IS OPEN"];
            [[NSUserDefaults standardUserDefaults] setObject:@"STORE IS OPEN" forKey:STORE_OPEN_CLOSE_MESSAGE];
            
//            [self.lblStoreAvailable setTextColor:BasicAppThemeColor];
            self.lblStoreAvailable.textColor = BasicAppThemeColor;
            
            [self.imagePinView setImage:[UIImage imageNamed:@"map_pin"]];
            webserviceCall = 3;


        }
        else if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"2"])
        {
            isStoreFound=YES;
            self.storeId = [[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"store_id"];
            [[NSUserDefaults standardUserDefaults] setObject:STORE_CLOSE forKey:STORE_OPEN_STATUS];
            
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] valueForKey:@"message_desc"] objectAtIndex:0] forKey:STORE_STATUS_MESSAGE];
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] valueForKey:@"message_title"] objectAtIndex:0] forKey:STORE_STATUS_MESSAGE_TITLE];
            
            NSLog(@"STORE ID FOUND: %@", self.storeId);
            if(self.isChangingLocation)
            {
                [self.btnChangeLocation setEnabled:YES];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:self.storeId forKey:STORE_ID];
                [self.btnShopNow setEnabled:YES];
            }
            [[NSUserDefaults standardUserDefaults] setObject:@"STORE IS CLOSED" forKey:STORE_OPEN_CLOSE_MESSAGE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.lblStoreAvailable setText:@"STORE IS CLOSED"];
            [self.lblStoreAvailable setTextColor:[UIColor redColor]];
            [self.imagePinView setImage:[UIImage imageNamed:@"red_pin"]];
            
            //22-Mar-2016 changes

            if (![[NSUserDefaults standardUserDefaults] boolForKey:STORE_DONT_SHOW_CLOSE])
            {
                strMessage = [[[dictResults objectForKey:@"data"] valueForKey:@"message_desc"] objectAtIndex:0] ;
                
                strTitle = [[[dictResults objectForKey:@"data"] valueForKey:@"message_title"] objectAtIndex:0];
                
                
                
                for (UIWindow* window in [UIApplication sharedApplication].windows) {
                    NSArray* subviews = window.subviews;
                    if ([subviews count] > 0)
                        if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]]){
                            return;
                        }
                }
                
                [UIAlertView showWithTitle:strTitle message:strMessage handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                }];
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STORE_DONT_SHOW_CLOSE];
                
            }
        }
        else
        {
            isStoreFound=YES;
            
            
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] valueForKey:@"message_desc"] objectAtIndex:0] forKey:STORE_STATUS_MESSAGE];
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] valueForKey:@"message_title"] objectAtIndex:0] forKey:STORE_STATUS_MESSAGE_TITLE];

            
            
            [[NSUserDefaults standardUserDefaults] setObject:STORE_CLOSE forKey:STORE_OPEN_STATUS];
            if(self.isChangingLocation)
            {
                [self.btnChangeLocation setEnabled:YES];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:STORE_ID];
                NSLog(@"%@",[[dictResults objectForKey:@"settings"] valueForKey:@"message"]);
                [self.btnShopNow setEnabled:YES];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSUserDefaults standardUserDefaults] setObject:@"OUTSIDE DELIVERY ZONE" forKey:STORE_OPEN_CLOSE_MESSAGE];
            [self.lblStoreAvailable setText:@"OUTSIDE DELIVERY ZONE"];
            [self.lblStoreAvailable setTextColor:[UIColor redColor]];
            [self.imagePinView setImage:[UIImage imageNamed:@"red_pin"]];
            
            //22-Mar-2016 changes
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:STORE_DONT_SHOW_OUTSIDE_ZONE])
            {
                strMessage = [[[dictResults objectForKey:@"data"] valueForKey:@"message_desc"] objectAtIndex:0] ;

                 strTitle = [[[dictResults objectForKey:@"data"] valueForKey:@"message_title"] objectAtIndex:0];
                
               

                [UIAlertView showWithTitle:strTitle message:strMessage handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                }];

//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STORE_DONT_SHOW_OUTSIDE_ZONE];

            }
          
        }
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [GlobalManager getAppDelegateInstance].isFromHomeTab = NO;
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

-(void)popToCheckOutScreen
{
    UINavigationController *navController = (UINavigationController *)[GlobalManager getAppDelegateInstance].objSidePanelviewController.centerPanel;
    
    for(UIViewController *viewController in [navController viewControllers])
    {
        if([viewController isKindOfClass:[CheckOutViewController class]])
        {
            [navController popToViewController:viewController animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)showAlert
{
        if (![[NSUserDefaults standardUserDefaults] boolForKey:STORE_DONT_SHOW_CLOSE] && [strStatus isEqualToString:@"STORE IS CLOSED"])
        {

            [UIAlertView showWithTitle:strTitle message:strMessage handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            }];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STORE_DONT_SHOW_CLOSE];

        }
        else if (![[NSUserDefaults standardUserDefaults] boolForKey:STORE_DONT_SHOW_OUTSIDE_ZONE] && [strStatus isEqualToString:@"OUTSIDE DELIVERY ZONE"])
        {

            [UIAlertView showWithTitle:strTitle message:strMessage handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            }];

            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STORE_DONT_SHOW_OUTSIDE_ZONE];
        }

}

@end
