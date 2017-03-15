//
//  TrackOrderViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BasicMapAnnotation.h"

/**
 * This class is used to show the map screen for tracking the order.
 */

@interface TrackOrderViewController : GAITrackedViewController<MKMapViewDelegate,MKAnnotation>//,CLLocationManagerDelegate,MKAnnotation>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property(nonatomic, retain) WS_Helper *objWSHelper;
@property(nonatomic, retain) CLLocation *driverLocation;

@property(nonatomic, retain) CLLocation *deliveryLocation;

@property(nonatomic, retain) NSDictionary *dictDetails;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic,strong) BasicMapAnnotation *annCurrent;
@property (nonatomic, assign) BOOL isTimerStarted,isFirstTime;

@end
