//
//  tabBar.m
//  tabBar
//
//  Created by Самсонов Александр on 01.09.15.
//  Copyright (c) 2015 LC. All rights reserved.
//

#import "OTRTabBar.h"
#import "Strings.h"


@implementation OTRTabBar

//static OTRComposeViewController * composeViewController_;

static OTRTabBar *zigTB;


static activeStateBar curState;

/*
-(void)addTabBar:(UIView *)view{
    [self tabBarr];
    
    
    [view addSubview:zigTB];
}
 */


+(OTRTabBar *)getTabBar{
    
    if(zigTB) return zigTB;
    
    
    
    OTRTabBar * tabBar = [[OTRTabBar alloc] init];
    
    [tabBar tabBarr];
    
    return zigTB;
    
}

- (void)tabBarr
{
    
    
    if(!zigTB){
        
       // UITabBar *myTabBar = [[UITabBar alloc] init];
        self.delegate=self;   //here you need import the protocol <UITabBarDelegate>
        //[view addSubview:myTabBar];
        
        NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
        
        UITabBarItem *leftButton= [[UITabBarItem alloc] initWithTitle:COMPOSE_STRING image:[UIImage imageNamed:@"TabIconContacts"]  selectedImage:[UIImage imageNamed:@"TabIconContacts_Highlighted"]];
        leftButton.tag = 0;
        
        
        UITabBarItem *centerButton = [[UITabBarItem alloc] initWithTitle:CHATS_STRING image:[UIImage imageNamed:@"TabIconMessages"]  selectedImage:[UIImage imageNamed:@"TabIconMessages_Highlighted"]];
         centerButton.tag = 1;
        
        
        UITabBarItem *rightButton = [[UITabBarItem alloc] initWithTitle:SETTINGS_STRING image:[UIImage imageNamed:@"TabIconSettings"]  selectedImage:[UIImage imageNamed:@"TabIconSettings_Highlighted"]];
       rightButton.tag = 2;
        
        
        [tabBarItems addObject:leftButton];
        [tabBarItems addObject:centerButton];
        [tabBarItems addObject:rightButton];
        
        self.items = tabBarItems;
        self.selectedItem = [tabBarItems objectAtIndex:1];
        curState = center;
        
        
        zigTB = self;
    }
    
    
}

+(void)setState:(activeStateBar)state{
   curState = state;
    zigTB.selectedItem = [zigTB.items objectAtIndex:state];
}

-(void)setTBFrame:(CGRect)frame{
    zigTB.frame = frame;
}

+(void)setBadgeChats:(NSInteger *)count{
    
    NSString *strCount;
    
    if(count >0){
         strCount =[NSString stringWithFormat:@"%d", (int)count];
    } else {
        strCount = nil;
    }
   
    
   UITabBarItem * item=  [zigTB.items objectAtIndex:1];
    item.badgeValue = strCount;
   
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    
    activeStateBar selectedTag = tabBar.selectedItem.tag;

    
    
    
    if (selectedTag == left) {
        
           if(curState== left) return;
             curState=left;
  
        
      //  if(!composeViewController_){
        
        //OTRComposeViewController * composeViewController = [[OTRComposeViewController alloc] init];
            
        //    composeViewController_ = [[OTRComposeViewController alloc] init];
       // }
        
        UINavigationController * navComposeViewController = [[UINavigationController alloc] initWithRootViewController:[OTRAppDelegate appDelegate].composeViewController];
        //modalNavigationController.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
        
        
        [OTRAppDelegate appDelegate].window.rootViewController = navComposeViewController;
       
   
        
        
    } else if(selectedTag == center) {
        if(curState == center) return;
        curState=center;
        
     
        [[OTRAppDelegate appDelegate] showConversationViewController];
        
        
        
    } else if(selectedTag == right){
        
        if(curState == right) return;
        curState = right;

        
        //[OTRAppDelegate appDelegate].settingsViewController.tabBar = self;
        
            //OTRSettingsViewController * settingsViewController = [[OTRSettingsViewController alloc] init];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[OTRAppDelegate appDelegate].settingsViewController];
            nc.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
       
        
        [OTRAppDelegate appDelegate].window.rootViewController = nc;
        
        
    }
}

+(void)showConversationViewControllerWithAnimation:(UIView *)view{
    
    
    [UIView transitionWithView:view.window
                      duration:1.0
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [OTRTabBar setState:center];
                        [[OTRAppDelegate appDelegate] showConversationViewController];
                    }
                    completion:nil];
    
    
  
}

/*
 //
 //  OTRTabBar.m
 //  SafeJab
 //
 //  Created by Самсонов Александр on 28.08.15.
 //  Copyright (c) 2015 Leader Consult. All rights reserved.
 //
 
 #import "OTRTabBar.h"
 #import "Strings.h"
 
 @implementation OTRTabBar
 
 static OTRTabBar * staticTabBar_;
 
 
 -(id)init{
 
 
 self = [super init];
 
 if(self){
 
 UITabBar *myTabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 100, 320, 50)];
 //myTabBar.delegate=self;   //here you need import the protocol <UITabBarDelegate>
 
 
 
 NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
 
 UITabBarItem *leftButton= [[UITabBarItem alloc] initWithTitle:COMPOSE_STRING image:[UIImage imageNamed:@"TabIconContacts"]  selectedImage:[UIImage imageNamed:@"TabIconContacts_Highlighted"]];
 
 UITabBarItem *centerButton = [[UITabBarItem alloc] initWithTitle:CHATS_STRING image:[UIImage imageNamed:@"TabIconMessages"]  selectedImage:[UIImage imageNamed:@"TabIconMessages_Highlighted"]];
 
 UITabBarItem *rightButton = [[UITabBarItem alloc] initWithTitle:SETTINGS_STRING image:[UIImage imageNamed:@"TabIconSettings"]  selectedImage:[UIImage imageNamed:@"TabIconSettings_Highlighted"]];
 
 [tabBarItems addObject:leftButton];
 [tabBarItems addObject:centerButton];
 [tabBarItems addObject:rightButton];
 
 myTabBar.items = tabBarItems;
 myTabBar.selectedItem = [tabBarItems objectAtIndex:1];
 
 self = (OTRTabBar *)myTabBar;
 
 self.delegate = self;
 
 return self;
 
 }
 return nil;
 }
 
 
 
 
 +(OTRTabBar *)getTabBar{
 
 if(!staticTabBar_){
 staticTabBar_ = [[OTRTabBar alloc] init];
 }
 
 return staticTabBar_;
 
 }
 
 - (void)tabBar:(OTRTabBar *)tabBar didSelectItem:(UITabBarItem *)item {
 NSLog(@"rwewef");
 }
 
 
 
 
 


@end

 */


@end
