//
//  BlurView.h
//  testView2
//
//  Created by Самсонов Александр on 29.02.16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BlurView : NSObject


@property (nonatomic, strong) UIVisualEffectView *bluredView;
@property (nonatomic, strong) UIActivityIndicatorView *waitView;
@property (nonatomic, strong) UIView *view;

-(id)initWithView:(UIView *)view;
-(void)setupWaitView;
-(void)clearBlur;

@end
