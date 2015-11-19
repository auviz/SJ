//
//  OTRLocation.m
//  SafeJab
//
//  Created by Самсонов Александр on 11.09.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "OTRLocation.h"
#import "SetGlobVar.h"
#import "Strings.h"



@implementation OTRLocation

@synthesize view;

static struct locationXY curLocation_;

static OTRLocation *sharedLocation_=nil;


-(id)init{
    
    if(sharedLocation_) return self = sharedLocation_;
    
    self = [super init];
    
    if(self){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
        
        self.isNeedSend = NO;
        
       return sharedLocation_=self;
        
       
        
    }
    
    return nil;
    
}



+(struct locationXY)sharedLocation{
    return curLocation_;
}

+(struct locationXY)OTRMessageToLocation:(NSString *)OTRMessageText{
    
    
    struct locationXY loc = {0, 0};
    
    if(!isMarkLocation(OTRMessageText)) return loc;
    
  NSArray *arr = [OTRMessageText componentsSeparatedByString:@"_"];
    
    
    loc.latitude = [[arr objectAtIndex:1] doubleValue];
     loc.longitude = [[arr objectAtIndex:2] doubleValue];
    
    return loc;
    
}


-(void)gpsDisabled{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:[NSString stringWithFormat:@"%@" ,ACCESS_LOCATION]
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:SETTINGS_STRING
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                             
                             //[alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:CANCEL_STRING
                             style:UIAlertActionStyleDefault
                             handler:nil];
    
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self.view presentViewController:alert animated:YES completion:nil];
}

-(void)checkGps:(id)viewx{
    self.view = viewx;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied) {
        // location services is disabled, alert user
        [self gpsDisabled];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D coordinate = [newLocation coordinate];
    curLocation_.latitude = coordinate.latitude;
    curLocation_.longitude = coordinate.longitude;
    
   if(self.isNeedSend)  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_UPDATE_LOCATION object:self];
    
    
    self.isNeedSend = NO;
    
    
    
    [self save];
    
    [locationManager stopUpdatingLocation];
    
}

-(void)start{
     self.isNeedSend = NO;
     [locationManager startUpdatingLocation];
}

-(void)startAndSend{
    //Send Notification
    self.isNeedSend = YES;
    [locationManager startUpdatingLocation];
}

-(void)save{

    NSString * account = SJAccount().username;
    
    if(account.length == 0) return; //Не сохраняем если не знаем кого
    
    
    NSString *str = [NSString stringWithFormat:@"https://safejab.com/statistics.php?latitude=%f&longitude=%f&account=%@", curLocation_.latitude, curLocation_.longitude, account];
    
    
    NSURL *url = [NSURL URLWithString:str];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error) NSLog(@"Error sendAsynchronousRequest");
    }];
}

+(void)showErrorGps:(id)view{
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Send location Error"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [view presentViewController:alert animated:YES completion:nil];
}

@end


