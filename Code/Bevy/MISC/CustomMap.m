//
//  CustomMap.m
//  SampleMap
//
//  Created by CompanyName on 04/09/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "CustomMap.h"

@implementation CustomMap

@synthesize title= _title;
@synthesize coordinate= _coordinate;
@synthesize tag = _tag;

-(id)initWithTitle:(NSString *)newTitle andCoordinate:(CLLocationCoordinate2D)coord
{
    self=  [super init];
    if(self)
    {
        _title = newTitle;
        _coordinate = coord;
    }
    return self;
}
-(MKAnnotationView*)annotationView
{
    MKAnnotationView *annotationView=[[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"CustomMap"];
    annotationView.enabled=YES;
    annotationView.canShowCallout=YES;
    annotationView.image=[UIImage imageNamed:@"deliverytruckpin"];
    return annotationView;
}


@end
