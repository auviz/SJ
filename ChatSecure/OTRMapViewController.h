//
//  OTRMapViewController.h
//  SafeJab
//
//  Created by Самсонов Александр on 12.10.15.
//  Copyright © 2015 Leader Consult. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OTRLocation.h"

@interface OTRMapViewController : UIViewController {
    
    double _latitude;
    double _longitude;
    
}

@property (strong, nonatomic) MKMapView *mapView;

-(id)initWithBigLocation:(struct locationXY)loc;

@end
