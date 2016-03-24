//
//  BlurView.m
//  testView2
//
//  Created by Самсонов Александр on 29.02.16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "BlurView.h"

@implementation BlurView

-(id)initWithView:(UIView *)view{
    self = [super init];
    
    
    if(self){
        
        self.view = view;
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    self.bluredView = [[UIVisualEffectView alloc] initWithEffect:effect];
    
    self.bluredView.frame = self.view.bounds;
        
        
        self.bluredView.autoresizingMask = self.view.autoresizingMask;
    
        
        
        [UIView transitionWithView:self.view
                          duration:0.3
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                              [self.view addSubview:self.bluredView];
                        }
                        completion:nil];
        
 
        
        
        return self;
    }
    
    return nil;
}

-(void)setupWaitView{
    
    /*
    UILabel * test = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    
    test.text = @"test";
    test.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:test];
 */
    
    //Добавление индикатора
    
    self.waitView = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
     self.waitView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;

    
    self.waitView.center = self.view.center;
    
   // CGRect frame =  self.waitView.frame;
  //  frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
   // frame.origin.y = self.view.frame.size.height / 2 - frame.size.height / 2;
   // self.waitView.frame = frame;
    [self.waitView startAnimating];
    [self.view addSubview:self.waitView];
    
    
    /*
  
    self.waitView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    //CGRect bframe = self.bluredView.frame;
    
    
    
  //  self.waitView.frame = bframe;
    
    [self.waitView startAnimating];
    
    [self.view addSubview:self.waitView];
    
 
    
    
    
    
    //[self.bluredView]
     
     */
}

-(void)clearBlur{
    
    [UIView transitionWithView:self.view
                      duration:0.3
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if(self.bluredView) [self.bluredView removeFromSuperview];
                        if(self.waitView ) [self.waitView removeFromSuperview];
                    }
                    completion:nil];
    
    

}

@end
