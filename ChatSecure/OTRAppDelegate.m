//
//  OTRAppDelegate.m
//  Off the Record
//
//  Created by Chris Ballinger on 8/11/11.
//  Copyright (c) 2011 Chris Ballinger. All rights reserved.
//
//  This file is part of ChatSecure.
//
//  ChatSecure is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ChatSecure is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ChatSecure.  If not, see <http://www.gnu.org/licenses/>.

#import "OTRAppDelegate.h"

#import "OTRConversationViewController.h"

#import "OTRMessagesViewController.h"
#import "Strings.h"
#import "OTRSettingsViewController.h"
#import "OTRSettingsManager.h"

//#import "Appirater.h"
#import "OTRConstants.h"
#import "OTRLanguageManager.h"
#import "OTRUtilities.h"
#import "OTRAccountsManager.h"
#import "FacebookSDK.h"
//#import "OTRAppVersionManager.h"
#import "OTRSettingsManager.h"
#import "OTRSecrets.h"
#import "OTRDatabaseManager.h"
#import "SSKeychain.h"

#import "OTRLog.h"
#import "DDTTYLogger.h"
#import "OTRAccount.h"
#import "OTRBuddy.h"
#import "YAPDatabaseTransaction.h"
#import "YapDatabaseConnection.h"
#import "OTRCertificatePinning.h"
#import "NSData+XMPP.h"
#import "NSURL+ChatSecure.h"
//#import "OTRPushAccount.h"
//#import "OTRPushManager.h"
#import "OTRDatabaseUnlockViewController.h"

#import "OTRMessage.h"
#import "OTRPasswordGenerator.h"

#import "pinCode.h"
#import "OTRXMPPManager.h"


#if CHATSECURE_DEMO
#import "OTRChatDemo.h"
#endif

@implementation OTRAppDelegate

@synthesize window = _window;
@synthesize backgroundTask, backgroundTimer, didShowDisconnectionWarning;
@synthesize settingsViewController;
@synthesize clearTasks;


@synthesize deleg;

- (id)delegate {
    return deleg;
}

- (void)setDelegate:(id)newDelegate {
    deleg = newDelegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{


   updateApp* checkApp = [[updateApp alloc] init]; //Проверка на новую версию zigzagcorp class
    [self setDeleg:checkApp];
    //   abc.vieC = self.window;
    [self.delegate initConnection:self.window];
    
  
   // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"SafeJab://123123123"]];

    // Override point for customization after application launch.


    
   // [[UIApplication sharedApplication] openURL:[NSURL update_app_from_serverURL]]; обновление приложения zigzagcorp
    
    // Регистируем девайс на приём push-уведомлений

    // iOS 8 Notifications
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    
    [application registerForRemoteNotifications];
    
    //end
    
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    /*
     Мой комент
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:kOTRHockeyBetaIdentifier
                                                         liveIdentifier:kOTRHockeyLiveIdentifier
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager].authenticator setIdentificationType:BITAuthenticatorIdentificationTypeDevice];
    [[BITHockeyManager sharedHockeyManager] startManager];
#ifndef DEBUG
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
#endif
     */
     
    
    [OTRCertificatePinning loadBundledCertificatesToKeychain];
    
    [SSKeychain setAccessibilityType:kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly];
    
   
    
    UIViewController *rootViewController = nil;
    
    self.settingsViewController = [[OTRSettingsViewController alloc] init];
    self.conversationViewController = [[OTRConversationViewController alloc] init];
    self.messagesViewController = [OTRMessagesViewController messagesViewController];
    
    
    
    if ([OTRDatabaseManager existsYapDatabase] && ![[OTRDatabaseManager sharedInstance] hasPassphrase]) {
        // user needs to enter password for current database
        rootViewController = [[OTRDatabaseUnlockViewController alloc] init];
    } else {
        ////// Normal launch to conversationViewController //////
        if (![OTRDatabaseManager existsYapDatabase]) {
            /**
             First Launch
             Create password and save to keychain
             **/
            NSString *newPassword = [OTRPasswordGenerator passwordWithLength:OTRDefaultPasswordLength];
            NSError *error = nil;
            [[OTRDatabaseManager sharedInstance] setDatabasePassphrase:newPassword remember:YES error:&error];
            if (error) {
                DDLogError(@"Password Error: %@",error);
            }
        }

        [[OTRDatabaseManager sharedInstance] setupDatabaseWithName:OTRYapDatabaseName];
        
        
        //[pinCode set:@"1234"];
        
        if([[pinCode get] isEqualToString:@""]){ //zigzagcorp если есть пинкод заблокировать экран
              rootViewController = [self defaultConversationNavigationController];
        } else {
            rootViewController  =  [[OTRDatabaseUnlockViewController alloc] init];
        }

        
      
        
        
#if CHATSECURE_DEMO
        [self performSelector:@selector(loadDemoData) withObject:nil afterDelay:10];
#endif
    }




    //rootViewController = [[OTRDatabaseUnlockViewController alloc] init];
//    NSString *outputStoreName = @"ChatSecure.sqlite";
//    [[OTRDatabaseManager sharedInstance] setupDatabaseWithName:outputStoreName];
//    
//    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
//        NSArray *allAccounts = [OTRAccount allAccountsWithTransaction:transaction];
//        NSArray *allAccountsToDelete = [allAccounts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//            if ([evaluatedObject isKindOfClass:[OTRAccount class]]) {
//                OTRAccount *account = (OTRAccount *)evaluatedObject;
//                if (![account.username length]) {
//                    return YES;
//                }
//            }
//            return NO;
//        }]];
//        
//        [transaction removeObjectsForKeys:[allAccountsToDelete valueForKey:OTRYapDatabaseObjectAttributes.uniqueId] inCollection:[OTRAccount collection]];
//        //FIXME? [OTRManagedAccount resetAccountsConnectionStatus];
//    }];

    
    
    
    //[OTRAppVersionManager applyAppUpdatesForCurrentAppVersion];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    

    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    application.applicationIconBadgeNumber = 0;
  
   // [Appirater setAppId:@"464200063"];
  //  [Appirater setOpenInAppStore:NO];
  //  [Appirater appLaunched:YES];
    
    [self autoLogin];
    
    [self setTimerDSM]; //ZIGTEST
   
    
    return YES;
}

- (void) loadDemoData {
#if CHATSECURE_DEMO
    [OTRChatDemo loadDemoChatInDatabase];
#endif
}

- (UIViewController*)defaultConversationNavigationController
{
    UIViewController *viewController = nil;
    
    //ConversationViewController Nav
    UINavigationController *conversationListNavController = [[UINavigationController alloc] initWithRootViewController:self.conversationViewController];
    
    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        viewController = conversationListNavController;
   /*
    
    } else {
        //MessagesViewController Nav
        UINavigationController *messagesNavController = [[UINavigationController alloc ]initWithRootViewController:self.messagesViewController];
        
        //SplitViewController
        UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
        splitViewController.viewControllers = [NSArray arrayWithObjects:conversationListNavController, messagesNavController, nil];
        splitViewController.delegate = self.messagesViewController;
        splitViewController.title = CHAT_STRING;
        
        viewController = splitViewController;
        
    }
    
    */
    
    return viewController;
}

- (void)showConversationViewController
{
    self.window.rootViewController = [self defaultConversationNavigationController];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

    DDLogInfo(@"Application entered background state.");
    
    //[OTRXMPPManager clearGroupChatNotGoodAttempts]; //Очистить не удачные попытки (если их три то отключается груп чат)
   
    
   // [self clearCount]; //Обнуляю

    NSAssert(self.backgroundTask == UIBackgroundTaskInvalid, nil);
    
    [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        application.applicationIconBadgeNumber = [OTRMessage numberOfUnreadMessagesWithTransaction:transaction];
    }];
    
    self.didShowDisconnectionWarning = NO;
    
    self.backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            DDLogInfo(@"Background task expired");
            if (self.backgroundTimer) 
            {
                [self.backgroundTimer invalidate];
                self.backgroundTimer = nil;
            }
            [application endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerUpdate:) userInfo:nil repeats:YES];
        
    });
    
}
                                
- (void) timerUpdate:(NSTimer*)timer {
    
    UIApplication *application = [UIApplication sharedApplication];
    

    DDLogInfo(@"Timer update, background time left: %f", application.backgroundTimeRemaining);
   
    
    if ([application backgroundTimeRemaining] < 60 && !self.didShowDisconnectionWarning && [OTRSettingsManager boolForOTRSettingKey:kOTRSettingKeyShowDisconnectionWarning]) 
    {
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif) {
            localNotif.alertBody = EXPIRATION_STRING;
            localNotif.alertAction = OK_STRING;
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            [application presentLocalNotificationNow:localNotif];
        }
        self.didShowDisconnectionWarning = YES;
    }
    
    if(self.clearTasks)
    {
        [self clearTimerDSM];
        DDLogInfo(@"delete que");
        [self.backgroundTimer invalidate];
        self.backgroundTimer = nil;
        
        [application endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
        self.clearTasks = NO;
    }
    
    
  
    if ([application backgroundTimeRemaining] < 20) //default value 20
    {
        
        if([pinCode get].length > 2){
           //UIViewController *curView = self.window.rootViewController;
            
           // [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
          
            
            self.window.rootViewController  = [[OTRDatabaseUnlockViewController alloc] initWithView:self.window.rootViewController];
             //     }];
        }
        
            DDLogInfo(@"disconnectAllAccounts");
            [[OTRProtocolManager sharedInstance]  disconnectAllAccounts];

            self.clearTasks = YES;
        

       
       // dispatch_resume(dispatch_get_main_queue());
        
        //[self applicationWillTerminate:application]; //zigzagcorp
        
    
        
        
        /*
        id protocol = [[OTRProtocolManager sharedInstance] protocolForAccount:self.account];
        OTRXMPPManager * xmppManager = nil;
        if ([protocol isKindOfClass:[OTRXMPPManager class]]) {
            xmppManager = (OTRXMPPManager *)protocol;
        }
         */

        
     // OTRXMPPManager -(id)XMPPafa =  [new OTRXMPPManager];
       // [OTRXMPPManager goOffline];
        
       // [self.xmppStream disconnect];
      
        
        
        
 
        
        
        
      //  [self applicationWillTerminate:application]; zigzagcorp
        // Clean up here
        
       // self.backgroundTimer = nil;
        
       // [[OTRProtocolManager sharedInstance] disconnectAllAccounts];
        //FIXME [OTRManagedAccount resetAccountsConnectionStatus];
        
        
       // [application endBackgroundTask:self.backgroundTask];
      //  self.backgroundTask = UIBackgroundTaskInvalid;
        
       //   [self applicationWillTerminate:application]; //zigzagcorp
    }

}

- (void)autoLogin
{
    //Auto Login
    /*
    // Мой комент
    if (![BITHockeyManager sharedHockeyManager].crashManager.didCrashInLastSession) {
        [[OTRProtocolManager sharedInstance] loginAccounts:[OTRAccountsManager allAutoLoginAccounts]];
    }
     */
    
    [[OTRProtocolManager sharedInstance] loginAccounts:[OTRAccountsManager allAutoLoginAccounts]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogInfo(@"applicationWillEnterForeground:");
    
    //[Appirater appEnteredForeground:YES];
    [self autoLogin];
  
   // if(self.clearTasks){
    
        
        //self.window.rootViewController  = self.UnlockViewController;
  //  }
    self.clearTasks= NO;
    
   
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    DDLogInfo(@"Application became active");
    
   [self setTimerDSM]; //ZIGTEST
    
    if (self.backgroundTimer) 
    {
        [self.backgroundTimer invalidate];
        self.backgroundTimer = nil;
    }
    if (self.backgroundTask != UIBackgroundTaskInvalid) 
    {
        [application endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
    //FIXME? [OTRManagedAccount resetAccountsConnectionStatus];
    application.applicationIconBadgeNumber = 0;
    [self clearCount]; //Обнуляю
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
    DDLogInfo(@"applicationWillTerminate");
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
   // [self clearCount]; //Обнуляю
    [[OTRProtocolManager sharedInstance] disconnectAllAccounts];
    
    //FIXME? [OTRManagedAccount resetAccountsConnectionStatus];
    //[OTRUtilities deleteAllBuddiesAndMessages];
}
/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //DDLogInfo(@"Notification Body: %@", notification.alertBody);
    //DDLogInfo(@"User Info: %@", notification.userInfo);
    
    NSDictionary *userInfo = notification.userInfo;
    NSString *buddyUniqueId = userInfo[kOTRNotificationBuddyUniqueIdKey];
    
    if([buddyUniqueId length]) {
        __block OTRBuddy *buddy = nil;
        [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            buddy = [OTRBuddy fetchObjectWithUniqueID:buddyUniqueId transaction:transaction];
        }];
        
        [self.conversationViewController enterConversationWithBuddy:buddy];
    }
    

}

+ (void) presentActionSheet:(UIActionSheet*)sheet inView:(UIView*)view {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [sheet showInView:view];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [sheet showInView:[self appDelegate].window];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    /*
     Мой комент
    if( [[BITHockeyManager sharedHockeyManager].authenticator handleOpenURL:url
                                                          sourceApplication:sourceApplication
                                                                 annotation:annotation]) {
        return YES;
    } else if ([url otr_isFacebookCallBackURL]) {
        return [[FBSession activeSession] handleOpenURL:url];
    }
     */
    
    NSString* message = [NSString stringWithFormat:@"%@ | %@ | %@", url, sourceApplication, annotation];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Application" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    //[alert release];
    return YES;
    
    return NO;
}

// Delegation methods

/* Отключаю нах
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    OTRPushManager *pushManager = [[OTRPushManager alloc] init];
    
    [pushManager addDeviceToken:devToken name:[[UIDevice currentDevice] name] completionBlock:^(BOOL success, NSError *error) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:OTRSuccessfulRemoteNotificationRegistration object:self userInfo:nil];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:OTRFailedRemoteNotificationRegistration object:self userInfo:@{kOTRNotificationErrorKey:error}];
        }
    }];
    
//    OTRPushAccount *account = [OTRPushAccount activeAccount];
//    NSString *username = account.username;
//    [[OTRPushAPIClient sharedClient] updatePushTokenForAccount:account token:devToken  successBlock:^(void) {
//        DDLogInfo(@"Device token updated for (%@): %@", username, devToken.description);
//    } failureBlock:^(NSError *error) {
//        DDLogInfo(@"Error updating push token: %@", error.userInfo);
//    }];
    DDLogInfo(@"did register for remote notification: %@", [devToken xmpp_hexStringValue]);
    
}
 */

/*
 Это я тоже отключу )
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    [[NSNotificationCenter defaultCenter] postNotificationName:OTRFailedRemoteNotificationRegistration object:self userInfo:@{kOTRNotificationErrorKey:err}];
    DDLogInfo(@"Error in registration. Error: %@%@", [err localizedDescription], [err userInfo]);
}
 */

/*
 Это я тоже пока не нужно )
 
  */

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    DDLogInfo(@"Remote Notification Recieved: %@", userInfo);
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody =  @"Looks like i got a notification - fetch thingy";
    [application presentLocalNotificationNow:notification];
    completionHandler(UIBackgroundFetchResultNewData);
    
}




//Мои  push функции begin


# pragma mark - Push Notifications

-(void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    
    DDLogInfo(@"Device token: %@", deviceToken);
    
#if !TARGET_IPHONE_SIMULATOR
    
    // Get Bundle Info for Remote Registration
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    // (Отключил) Check what notifications the user has turned on.
    //NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
   // NSString *pushBadge = (rntypes & UIRemoteNotificationTypeBadge) ? @"enabled" : @"disabled";
   // NSString *pushAlert = (rntypes & UIRemoteNotificationTypeAlert) ? @"enabled" : @"disabled";
   // NSString *pushSound = (rntypes & UIRemoteNotificationTypeSound) ? @"enabled" : @"disabled";
    
    NSString *pushBadge = @"enabled";
    NSString *pushAlert = @"enabled";
    NSString *pushSound = @"enabled";
    
    // Get the users Device Model, Display Name, Unique ID, Token & Version Number
    UIDevice *dev = [UIDevice currentDevice];
    NSString *deviceUuid;
    
    if ([dev respondsToSelector:@selector(identifierForVendor)])
        //TODO confirm using a real device that this works and is correct
        deviceUuid = [[dev identifierForVendor] UUIDString];
    else {
        
        /*
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id uuid = [defaults objectForKey:@"deviceUuid"];
        if (uuid)
            deviceUuid = (NSString *)uuid;
        else {
            CFStringRef cfUuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
            deviceUuid = (__bridge NSString *)cfUuid;
            CFRelease(cfUuid);
            [defaults setObject:deviceUuid forKey:@"deviceUuid"];
        }
         */
    }
    NSString *deviceName = dev.name;
    NSString *deviceModel = dev.model;
    NSString *deviceSystemVersion = dev.systemVersion;
    
    // Prepare the Device Token for Registration (remove spaces and < >)
    // this token would be used to update the APNS table with the user's username
    self.deviceTokenString = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString:@"<"withString:@""]
                               stringByReplacingOccurrencesOfString:@">" withString:@""]
                              stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    // Build URL String for Registration
    
    //NSString *kXMPPHostname = @"safejab.com";
    
    
    //Запоминаю токен девайса для дальнейшего использования
    setDeviceTokenString(self.deviceTokenString);

    
   // DDLogInfo(@"ZIG Data: %@", getDeviceTokenString());
    NSString * development;
#if DEBUG
    development = @"sandbox";
#else
    development = @"production";
#endif
    

    
    
    NSString *urlString = [NSString stringWithFormat:@"/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@&clear=%@&development=%@", @"register", appName,appVersion, deviceUuid, self.deviceTokenString, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound, @"true", development];
    
    // Register the Device Data (https?)
    NSURL *url = [[NSURL alloc] initWithScheme:@"https" host:JABBER_HOST path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *urlR, NSData *returnData, NSError *e) {
                               DDLogInfo(@"Return Data: %@", returnData);
                               
                           }];
    
    DDLogInfo(@"Register URL: %@", url);
    
  #endif  


}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogInfo(@"Failed to get token, error: %@", error);
}
 

#pragma - mark Class Methods
+ (OTRAppDelegate *)appDelegate
{
    return (OTRAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)clearCount
{
    if(getDeviceTokenString() == nil) return;
    
    NSString *urlString = [NSString stringWithFormat:@"/apns.php?task=%@&devicetoken=%@&clear=%@", @"other", getDeviceTokenString(), @"true"];
    
    // Clear count app
    NSURL *url = [[NSURL alloc] initWithScheme:@"https" host:JABBER_HOST path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *urlR, NSData *returnData, NSError *e) {
                               DDLogInfo(@"Return Data: %@", returnData);
                               
                           }];
    DDLogInfo(@"CLEAR TRUE %@", url);
}

-(void)devOrProd:(NSString*)option
{
 //option:  production or sandbox
    
    
    NSString *urlString = [NSString stringWithFormat:@"/apns.php?task=%@&devicetoken=%@&development=%@", @"other",getDeviceTokenString(), option];
    
    // Clear count app
    NSURL *url = [[NSURL alloc] initWithScheme:@"https" host:JABBER_HOST path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *urlR, NSData *returnData, NSError *e) {
                               DDLogInfo(@"Return Data: %@", returnData);
                               
                           }];
    DDLogInfo(@"CLEAR TRUE %@", url);
}

/*
- (void)updateConfirm {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NEW_UPDATE_IS_AVAILABLE
                                                             delegate:self
                                                    cancelButtonTitle:REMIND_ME_LATER
                                               destructiveButtonTitle:INSTALL_NOW
                                                    otherButtonTitles:nil];
    
    [actionSheet showInView:self.window];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [[UIApplication sharedApplication] openURL:[NSURL update_app_from_serverURL]]; //обновление приложения zigzagcorp
      
    }
}
*/

#pragma mark - DSM Messages delete timer

-(void)setTimerDSM{
    
    if(!self.timerDSM){
        
        self.timerDSM = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                              target: self
                                                            selector: @selector(actionTimerDSM)
                                                            userInfo: nil
                                                             repeats: YES];
    }
}

-(void)clearTimerDSM{
    [self.timerDSM invalidate];
    self.timerDSM = nil;
}


-(void)actionTimerDSM{
    
 //   DDLogInfo(@"actionTimerDSM");
    
   // dispatch_async(dispatch_get_main_queue(), ^{
    
    
    
    if(![OTRDatabaseManager sharedInstance]) return ;
    
    [self checkConnection]; //Эта штука нужна для реконнекта после 10 секунд
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        [OTRMessage deleteExpiredMessage:transaction];

        
    }];
    

  //  });
    
    

}

#pragma mark - Check connection (if not connection reconnect)

-(BOOL)isConnected {
    
    
    
    // self.account
    BOOL isConnected =   [[OTRAccountsManager allAccountsAbleToAddBuddies] count] > 0 ? YES : NO;
    
    if(isConnected){
        return YES;
    } else {
        return NO;
    }
}

-(void)checkConnection {
    
    static int count;
    
    if([self isConnected]){
        count = 0;
        
        
    } else {
        
        count ++;
        
        if(count == 10) {
            ///Ну если совсем пиздец переподключаемся (полностью)
            [[OTRProtocolManager sharedInstance] loginAccounts:[OTRAccountsManager allAutoLoginAccounts]];
            count = 0;
        }
        
    }
    
}

@end
