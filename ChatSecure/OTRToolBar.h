//
//  OTRToolBar.h
//  SafeJab
//
//  Created by Самсонов Александр on 26.08.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTRComposeViewController.h"
#import "OTRConversationViewController.h"

typedef NS_ENUM(NSUInteger, activeStateBar) {
    left,
    center,
    right
};

@interface OTRToolBar : UIToolbar


-(id)initWithState:(activeStateBar) state;
-(void)addItemsToUINavigationController: (UINavigationController *)navigationController;
-(void)leftButtonPressed;


@property UIBarButtonItem *leftButton;
@property UIBarButtonItem *centerButton;
@property UIBarButtonItem *rightButton;


@property  NSMutableArray *barItems;

@end
