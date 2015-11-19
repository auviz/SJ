//
//  OTRMapViewController.m
//  SafeJab
//
//  Created by Самсонов Александр on 12.10.15.
//  Copyright © 2015 Leader Consult. All rights reserved.
//

#import "OTRMapViewController.h"


@interface OTRMapViewController ()



@end

@implementation OTRMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMapView];
    // Do any additional setup after loading the view.
}

-(id)initWithBigLocation:(struct locationXY)loc{
    
    self = [super init];
    
    
    if(self){
    _latitude = loc.latitude;
    _longitude = loc.longitude;
        return self;
    }
    
    return nil;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) customUpdateView{
    
    float width = [[self view] bounds].size.width;
    float height = [[self view] bounds].size.height;
    
    self.mapView.frame = CGRectMake(0, 0, width, height);
    
    
}



-(void)setupMapView {
    
    // float width = [[self view] bounds].size.width;
    //  float height = [[self view] bounds].size.height;
    
    self.mapView = [[MKMapView alloc] init];
    
    // start off by default in San Francisco
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = _latitude;
    newRegion.center.longitude = _longitude;
    newRegion.span.latitudeDelta = 0.05;
    newRegion.span.longitudeDelta = 0.05;
    
    
    
  

 
    
    
    [self.view addSubview:self.mapView];
    
    
    [self.mapView setRegion:newRegion animated:YES];
    
    
    
    MKPointAnnotation*    annotation = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D myCoordinate;
    myCoordinate.latitude=_latitude;
    myCoordinate.longitude=_longitude;
    annotation.coordinate = myCoordinate;
      [self.mapView addAnnotation:annotation];
}

-(void)viewWillLayoutSubviews {
    // NSLog(@"viewWillLayoutSubviews");
    [super viewWillLayoutSubviews];
    [self customUpdateView];
    
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
