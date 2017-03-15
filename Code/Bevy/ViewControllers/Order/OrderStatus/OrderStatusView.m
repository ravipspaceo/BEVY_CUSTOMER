//
//  OrderStatusView.m
//  Bevy
//
//  Created by CompanyName on 1/23/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "OrderStatusView.h"

@implementation OrderStatusView


-(IBAction)btnPlaceNewOrderPressed:(id)sender
{
    [self.statusDelegate OrderStatusView:self placeNewOrderPressed:sender];
}

-(IBAction)btnOrderDetailsClicked:(id)sender
{
    [self.statusDelegate OrderStatusView:self orderDetailPressed:sender];
}

-(IBAction)btnMapPressed:(id)sender
{
    [self.statusDelegate OrderStatusView:self gpsTrackPressed:sender];
}

-(IBAction)btnRateDriverPressed:(id)sender
{
    [self.statusDelegate OrderStatusView:self rateDriverPressed:sender];
}

@end
