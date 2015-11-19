//
//  tabBar.h
//  tabBar
//
//  Created by Самсонов Александр on 01.09.15.
//  Copyright (c) 2015 LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OTRComposeViewController.h"
#import "OTRConversationViewController.h"
#import "OTRSettingsViewController.h"
#import "OTRAppDelegate.h"

typedef NS_ENUM(NSUInteger, activeStateBar) {
    left,
    center,
    right
};

@interface OTRTabBar : NSObject<UITabBarDelegate>



-(void)addTabBar:(UIView *)view;
-(void)setTBFrame:(CGRect)frame;
+(void)setState:(activeStateBar)state;
+(void)setBadgeChats:(NSInteger *)count;
+(void)showConversationViewControllerWithAnimation:(UIView *)view;

@end
