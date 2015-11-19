//
//  OTRLocation.h
//  SafeJab
//
//  Created by Самсонов Александр on 11.09.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

struct locationXY{
    
    double latitude;
    double longitude;
    
};

@interface OTRLocation : NSObject<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property BOOL isNeedSend;

@property id view;

+(struct locationXY)sharedLocation;
+(void)showErrorGps:(id)view;
-(void)checkGps:(id)viewx;

-(void)startAndSend;
-(void)start;

+(struct locationXY)OTRMessageToLocation:(NSString *)OTRMessageText;

@end
