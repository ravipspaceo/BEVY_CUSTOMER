//
//  TrackOrderViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "TrackOrderViewController.h"
#import "CustomMap.h"

//#define SECONDS 40.0

#define SECONDS [[[[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS] valueForKey:@"customer_driver_location_refresh"] intValue]

@interface TrackOrderViewController ()

@end

@implementation TrackOrderViewController

@synthesize coordinate;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    [self setUpLayout];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.isFirstTime = YES;
    [GlobalUtilityClass googleAnalyticsScreenTrack:@"Order Track Screen"];
    [self callOrderOnMapWS];
}

-(void)viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       //Background;
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          //main thread;
                                          self.timer = [NSTimer scheduledTimerWithTimeInterval:SECONDS target:self selector:@selector(callOrderOnMapWS) userInfo:nil repeats:YES];
                                          [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
                                      });
                   });

}

-(void)viewWillDisappear:(BOOL)animated
{
    if(self.timer != nil)
    {
        [self.timer invalidate];
    }
}

#pragma mark - Instance Methods

-(void)setUpLayout
{
    [self.navigationItem setRightBarButtonItem:[GlobalManager getnavigationRightButtonWithTarget:self :@"menu"]] ;
    self.navigationItem.title = @"Order Track";
    [self setBackButton];
    self.mapView.delegate = self;
}

-(void)setCurrentLocation
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setTitle:@""];
    [annotation setCoordinate:self.driverLocation.coordinate];
    
    if(self.mapView.annotations.count)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeAnnotation:annotation];
        
    }
    
    
    if (self.isFirstTime) {
        self.isFirstTime = NO;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.driverLocation.coordinate, 500.0, 500.0);
        [self.mapView setRegion:region animated:YES];

    }
}

-(void)setAnnotationForMap :(NSArray*)arrLocations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    if(arrLocations.count)
    {
        for (NSDictionary *dict in arrLocations)
        {
            BasicMapAnnotation *ann =[[BasicMapAnnotation alloc] initWithLatitude:[[dict valueForKey:@"latitude"] doubleValue] andLongitude:[[dict valueForKey:@"longitude"] doubleValue]];
            ann.selectedDict =  [NSMutableDictionary dictionaryWithDictionary:dict];
            [self.mapView addAnnotation:ann];
            [[self.mapView viewForAnnotation:ann] setTag:1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isFirstTime) {
                self.isFirstTime = NO;
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.driverLocation.coordinate, 500.0, 500.0);
                [self.mapView setRegion:region animated:YES];
                
            }
        });
    }
}

-(void)btnMenuClicked
{
    [self.view endEditing:YES];
    [[GlobalManager getAppDelegateInstance].objSidePanelviewController showRightPanelAnimated:YES];
}

#pragma mark - MapAnotation Method

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    BasicMapAnnotation *ann = (BasicMapAnnotation *)annotation;
    
    NSString* AnnotationIdentifier = [NSString stringWithFormat:@"com.identifier.%@",[ann.selectedDict valueForKey:@"location_type"]];
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                    reuseIdentifier:AnnotationIdentifier];
    
    annotationView.draggable = NO;

    
    NSString *strLocationType = [ann.selectedDict valueForKey:@"location_type"];


    if ([strLocationType isEqualToString:@"DRIVER"]) {
        annotationView.image = [UIImage imageNamed:@"deliverytruckpin"];
    }
    else{
        annotationView.image = [UIImage imageNamed:@"map_pin"];
    }
    
//    if([annotation isKindOfClass:[MKUserLocation class]])
//        return nil;
//    else
//    {
//        MKAnnotationView *pinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];;
//        if(pinView)
//            pinView.annotation = annotation;
//        else
//        {
//            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
//            pinView.centerOffset = CGPointMake(0, -15);
//            pinView.image = [UIImage imageNamed:@"deliverytruckpin"];
//        }
         return annotationView;
//    }
}

#pragma mark - WS calling methods

-(void)callOrderOnMapWS
{
    if(!self.isTimerStarted)
        [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];

    self.isTimerStarted = YES;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] forKey:@"user_id"];
    [params setObject:[self.dictDetails objectForKey:@"order_id"] forKey:@"order_id"];
     [params setObject:[self.dictDetails objectForKey:@"driver_id"] forKey:@"driver_id"];
    
    [self.objWSHelper sendRequestWithURL:[WS_Urls getOrderOnMapURL:params]];
}

#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if (!response)
    {
        return;
    }
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
    {
        NSString *latitude = [[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"lat"];
        NSString *longitude = [[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"long"];
        
        
        self.driverLocation = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        
        NSString *deliveryLat = [[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"delivery_latitude"];
        NSString *deliveryLong = [[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"delivery_longitude"];
        
        
        self.deliveryLocation = [[CLLocation alloc] initWithLatitude:[deliveryLat floatValue] longitude:[deliveryLong floatValue]];

        NSMutableArray *arrayPins = [[NSMutableArray alloc] init];
        NSMutableDictionary *dictLocation = [[NSMutableDictionary alloc] init];
        
        [dictLocation setObject:latitude forKey:@"latitude"];
        [dictLocation setObject:longitude forKey:@"longitude"];
        [dictLocation setObject:@"DRIVER" forKey:@"location_type"];
        [arrayPins addObject:dictLocation];
        dictLocation = nil;
        dictLocation = [[NSMutableDictionary alloc] init];
        
        [dictLocation setObject:deliveryLat forKey:@"latitude"];
        [dictLocation setObject:deliveryLong forKey:@"longitude"];
        [dictLocation setObject:@"CUSTOMER" forKey:@"location_type"];
        [arrayPins addObject:dictLocation];
        
        [self setAnnotationForMap:arrayPins];

        dispatch_async(dispatch_get_main_queue(), ^{
        
//            [self setCurrentLocation];
        });
    }
    else
    {
        NSLog(@"LOCATION NOT FOUND: %@", [[dictResults objectForKey:@"settings"] objectForKey:@"message"]);
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end
