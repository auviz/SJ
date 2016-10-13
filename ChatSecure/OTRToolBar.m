//
//  OTRToolBar.m
//  SafeJab
//
//  Created by Самсонов Александр on 26.08.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "OTRToolBar.h"


#import "OTRSettingsViewController.h"
#import "OTRAppDelegate.h"

static UINavigationController * settingsViewController_;
static UINavigationController * OTRComposeViewController_;
static id OTRConversationViewController_;

@implementation OTRToolBar


-(id)initWithState:(activeStateBar) state {
    
    self = [super init];
    
    
    if(self){
        
        
        if(state == left){
            
             self.leftButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"TabIconContacts_Highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target: nil action:nil];
            
            
            
        } else if(state == center){
            
    
        
            
            self.centerButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"TabIconMessages_Highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target: nil action:nil];
      
          
            
            
        } else if(state == right){
            
            self.rightButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"TabIconSettings_Highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target: nil action:nil];
            
        }
        
        
        if(!self.leftButton){
            
               self.leftButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"TabIconContacts"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonPressed)];
            
        }
        
        if(!self.centerButton){
            
               self.centerButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"TabIconMessages"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(centerButtonPressed)];
            
        }
        
        if(!self.rightButton){
            
               self.rightButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"TabIconSettings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonPressed)];
            
        }
    
       
    
        
        
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    
  self.barItems = [[NSMutableArray alloc] initWithObjects: self.leftButton , flex,  self.centerButton, flex, self.rightButton ,  nil];
    
        
        
        return self;
    }
    
 
    return nil;
}





-(void)addItemsToUINavigationController: (UINavigationController *)navigationController{
    
    
    [navigationController.toolbar  setItems:self.barItems];
}



-(void)leftButtonPressed{
  
    //[self.curVC dismissViewControllerAnimated:NO completion:nil];
    
   // if([self.curVC isKindOfClass:[OTRConversationViewController class]]){
    //<OTRComposeViewControllerDelegate>
    
 
    
    //if(!OTRComposeViewController_){
        
        //self.delegateVC = OTRConversationViewController_;
        
       // NSLog(@"frsfs %@", self.delegateVC);

    OTRComposeViewController * composeViewController = [[OTRComposeViewController alloc] init];
   UINavigationController * navComposeViewController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    //modalNavigationController.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    
  
    [OTRAppDelegate appDelegate].window.rootViewController = navComposeViewController;
    
 //  NSLog(@"leftButtonPressed");
}

-(void)centerButtonPressed{
    
     [[OTRAppDelegate appDelegate] showConversationViewController];
    
    
    //self.window.rootViewController =
    
   //  [self.curVC dismissViewControllerAnimated:NO completion:nil];
   
        //[(OTRComposeViewController *)self.curVC cancelButtonPressed:self];

    
    
  //  NSLog(@"centerButtonPressed");
}

-(void)rightButtonPressed{
   // NSLog(@"rightButtonPressed");
    
    
    
    if(!settingsViewController_){
     OTRSettingsViewController * settingsViewController = [[OTRSettingsViewController alloc] init];
    settingsViewController_ = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsViewController_.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    }
    
     [OTRAppDelegate appDelegate].window.rootViewController = settingsViewController_;
    
   // [self.curVC presentViewController:modalNavigationController animated:NO completion:nil];
    
   
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
