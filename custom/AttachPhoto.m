//
//  AttachPhoto.m
//  SafeJab
//
//  Created by Самсонов Александр on 20.03.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
// Помимо фотографий мы добавляем и местоположение

#import "AttachPhoto.h"
#import "OTRLog.h"

@implementation AttachPhoto

@synthesize deleg;
@synthesize ViewController;
@synthesize linkToBuddy;

-(id)init{
    self = [super init];
    
    if(self){
        return self;
    }
    
    return nil;
}

- (id)delegate {
    return deleg;
}

- (void)setDelegate:(id)newDelegate {
    deleg = newDelegate;
}

-(id) initWithView: (UIViewController *)View{
    if(self = [super init]){
       // self.ViewController = View;
        
        self =[self initWithViewController:View];
        
        return self;
    }
}


- (UIButton *)AttachButton{
    UIButton *btn = [[UIButton alloc] init];
    
    
    UIImage *buttonImage = [UIImage imageNamed:@"Attach"];
    
    btn.frame = CGRectMake(0, 5, buttonImage.size.width, buttonImage.size.height);
 //   [btn addTarget:self action:@selector(pickButtonTap:)  forControlEvents: UIControlEventTouchUpInside];
    [btn setBackgroundImage:buttonImage forState:UIControlStateNormal];

    return btn;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [super actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex];
    
    if(buttonIndex == 2){
        
        
        DDLogInfo(@"actionSheetZigLocatin");
        [self.linkToBuddy initSendLocation];
    }
    
    
}



- (void)pickButtonTap:(id)sender {
    
    
    DDLogInfo(@"pickButtonTap");
    
    self.linkToBuddy = sender;
    
    
    
   
    
   // self.ViewController = self.linkToBuddy;
      self.delegate = self;
    
    
   // [photoActionSheet setLinkToBuddy:self.linkToBuddy];
    
    //[self setDeleg:photoActionSheet];
    
  
    
    [self showWithDestructiveButton:NO];
    
}

@end
