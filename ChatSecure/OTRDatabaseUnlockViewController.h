//
//  OTRDatabaseUnlockViewController.h
//  Off the Record
//
//  Created by David Chiles on 5/5/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTRDatabaseUnlockViewController : UIViewController {
    NSString * newPinFirstAttempt;
    NSString * newPinSecondAttempt;
}

@property (nonatomic) BOOL isChangePin;

-(id)initChangePin;
-(id)initWithView:(UIViewController *)view;

@end
