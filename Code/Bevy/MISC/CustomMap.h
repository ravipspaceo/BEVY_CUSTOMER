//
//  CustomMap.h
//  SampleMap
//
//  Created by CompanyName on 04/09/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface CustomMap : NSObject <MKAnnotation>

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic,copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id)initWithTitle:(NSString *)newTitle andCoordinate:(CLLocationCoordinate2D)coord;
-(MKAnnotationView*)annotationView;

@end
