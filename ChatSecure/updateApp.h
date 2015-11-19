//
//  updateApp.h
//  SafeJab
//
//  Created by Самсонов Александр on 18.02.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "OTRAppDelegate.h"


@interface updateApp : NSObject<NSURLConnectionDelegate, UIActionSheetDelegate>
{
    NSMutableData *_responseData;
}

@property NSString *aboutVersion;

@property (strong, nonatomic) UIView *view;

@property NSURLConnection  *curConnection;

@property (strong, nonatomic) NSString *dirWithFile;

- (void)initConnection:(UIView *)view;
-(void)show;


//-(void)beginUpdateApp;

@end
