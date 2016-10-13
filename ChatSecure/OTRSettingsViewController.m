//
//  OTRSettingsViewController.m
//  Off the Record
//
//  Created by Chris Ballinger on 4/10/12.
//  Copyright (c) 2012 Chris Ballinger. All rights reserved.
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

#import "OTRSettingsViewController.h"
#import "OTRProtocolManager.h"
#import "OTRBoolSetting.h"
#import "Strings.h"
#import "OTRSettingTableViewCell.h"
#import "OTRSettingDetailViewController.h"
#import "OTRAboutViewController.h"
#import "OTRQRCodeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "OTRNewAccountViewController.h"
#import "OTRConstants.h"
#import "UserVoice.h"
#import "OTRAccountTableViewCell.h"
#import "OTRCreateAccountChooserViewController.h"
#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"
#import "OTRSecrets.h"
#import "YAPDatabaseViewMappings.h"
#import "YAPDatabaseConnection.h"
#import "OTRDatabaseManager.h"
#import "OTRDatabaseView.h"
#import "YapDatabase.h"
#import "YapDatabaseView.h"
#import "OTRAccount.h"
#import "OTRAppDelegate.h"
#import "OTRMessage.h"
#import "OTRLog.h"
#import "OTRTabBar.h"
//#import "BlurView.h"
#import "SavePhoto.h"


#include "XMPPvCardTemp.h"
#include "OTRXMPPManager.h"
#import "historyPicker.h"
//#include "ZIGMyVCard.h"
#import "historyManager.h"
#import "dbHistoryOption.h"


#import "OTRDatabaseUnlockViewController.h"

#import "NSURL+ChatSecure.h"

static NSString *const circleImageName = @"31-circle-plus-large.png";

@interface OTRSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, historyPickerDelegate>

@property (nonatomic, strong) YapDatabaseViewMappings *mappings;
@property (nonatomic, strong) YapDatabaseConnection *databaseConnection;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD * HUD;
@property (nonatomic, strong) historyPicker * HP;
@property (nonatomic, strong) historyManager * historyManager;


//@property (nonatomic, strong) OTRKeepHistorySetting * keepHistorySetting;

@property (nonatomic, strong) OTRTabBar *tabBar;



- (void) addAccount:(id)sender;
- (void) showLoginControllerForAccount:(OTRAccount*)account;
@end

@implementation OTRSettingsViewController

- (id) init
{
    if (self = [super init])
    {
        self.title = SETTINGS_STRING;
        self.settingsManager = [[OTRSettingsManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Make sure allAccountsDatabaseView is registered
    [OTRDatabaseView registerAllAccountsDatabaseView];
    
    //User main thread database connection
    self.databaseConnection = [[OTRDatabaseManager sharedInstance] mainThreadReadOnlyDatabaseConnection];
    
    //Create mappings from allAccountsDatabaseView
    self.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[OTRAllAccountGroup] view:OTRAllAccountDatabaseViewExtensionName];
    
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        [self.mappings updateWithTransaction:transaction];
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yapDatabaseModified:)
                                                 name:OTRUIDatabaseConnectionDidUpdateNotification
                                               object:nil];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"OTRInfoIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(showAboutScreen)];

    self.navigationItem.rightBarButtonItem = aboutButton;
    
     [self.tableView setContentInset:UIEdgeInsetsMake(0,0,50,0)];
}


-(void)viewWillLayoutSubviews {
    if(self.tabBar){
        [self.tabBar setTBFrame:CGRectMake(0, (self.view.frame.size.height -50), self.view.frame.size.width, 50)];
    }
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
 
    //Для нормального отображения опции истории
    self.settingsManager.keepHistorySetting.option = [historyPicker valueFromKey:[dbHistoryOption get]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateVCardFromServer)
                                                 name:NOTIFICATION_DID_UPDATE_VCARD_FROM_SERVER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didErrorVCardFromServer)
                                                 name:NOTIFICATION_ERROR_UPDATE_VCARD_FROM_SERVER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetMyVCard)
                                                 name:NOTIFICATION_I_GET_MY_VCARD
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadHistoryCell:)
                                                 name:NOTIFICATION_DID_HISTORY_OPTION_ON_SERVER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadHistoryCell:)
                                                 name:NOTIFICATION_ERROR_SET_HISTORY_OPTION_ON_SERVER
                                               object:nil];
    
    
   
    
    [[OTRProtocolManager sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfConnectedProtocols)) options:NSKeyValueObservingOptionNew context:NULL];
    [[OTRProtocolManager sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfConnectingProtocols)) options:NSKeyValueObservingOptionNew context:NULL];
    
    
    self.tableView.frame = self.view.bounds;
    [self.tableView reloadData];
    

    
    if(!self.tabBar) self.tabBar = [OTRTabBar getTabBar];
        
    
    
    if(![self.tabBar isDescendantOfView:self.view]) {
    
        [self.view addSubview:self.tabBar];
        
        //Исправляет ошибку перекрытия
        [self.view insertSubview:self.tabBar belowSubview:self.HP];
        
       // [self.view sendSubviewToBack:self.tabBar];
    }
    
    [self.tabBar setTBFrame:CGRectMake(0, (self.view.frame.size.height -50), self.view.frame.size.width, 50)];
    
    // self.navigationController.toolbarHidden =NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    



}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_DID_UPDATE_VCARD_FROM_SERVER object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ERROR_UPDATE_VCARD_FROM_SERVER object:nil];
         [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_I_GET_MY_VCARD object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_DID_HISTORY_OPTION_ON_SERVER object:nil];
    
     [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ERROR_SET_HISTORY_OPTION_ON_SERVER object:nil];
    
    
    
    [[OTRProtocolManager sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfConnectedProtocols))];
    [[OTRProtocolManager sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfConnectingProtocols))];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(numberOfConnectedProtocols))] || [keyPath isEqualToString:NSStringFromSelector(@selector(numberOfConnectingProtocols))]) {
            [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    });
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
}

- (OTRAccount *)accountAtIndexPath:(NSIndexPath *)indexPath
{
    __block OTRAccount *account = nil;
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        account = [[transaction extension:OTRAllAccountDatabaseViewExtensionName] objectAtIndexPath:indexPath withMappings:self.mappings];
    }];
    
    return account;
}

#pragma mark UITableViewDataSource methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row != [self.mappings numberOfItemsInSection:0])
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;     
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) { // Accounts 
        static NSString *accountCellIdentifier = @"accountCellIdentifier";
        static NSString *addAccountCellIdentifier = @"addAccountCellIdentifier";
        UITableViewCell * cell = nil;
        if (indexPath.row == [self.mappings numberOfItemsInSection:indexPath.section]) {
            cell = [tableView dequeueReusableCellWithIdentifier:addAccountCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:addAccountCellIdentifier];
                cell.textLabel.text = NEW_ACCOUNT_STRING;
                
                
                cell.imageView.image = [UIImage imageNamed:circleImageName];
                cell.detailTextLabel.text = nil;
               
            }
        }
        else {
            OTRAccount *account = [self accountAtIndexPath:indexPath];
            OTRAccountTableViewCell *accountCell = (OTRAccountTableViewCell*)[tableView dequeueReusableCellWithIdentifier:accountCellIdentifier];
            if (accountCell == nil) {
                accountCell = [[OTRAccountTableViewCell alloc] initWithReuseIdentifier:accountCellIdentifier];
               
            }
            
            [accountCell setAccount:account];
            
            if ([[OTRProtocolManager sharedInstance] existsProtocolForAccount:account]) {
                id <OTRProtocol> protocol = [[OTRProtocolManager sharedInstance] protocolForAccount:account];
                if (protocol) {
                    [accountCell setConnectedText:[protocol connectionStatus]];
                }
            }
            else {
                [accountCell setConnectedText:OTRProtocolConnectionStatusDisconnected];
            }
            
            

            cell = accountCell;
            
            
            
        }
        
        return cell;
    }
    static NSString *cellIdentifier = @"Cell";
    OTRSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil)
	{
		cell = [[OTRSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
	}
    OTRSetting *setting = [self.settingsManager settingAtIndexPath:indexPath];
    
    //Получаю доступ к кнопке для последующего ее обнавления
   // if(!self.keepHistorySetting && [setting.title isEqualToString:KEEP_HISTORY_STRING]){
   //     self.keepHistorySetting = (OTRKeepHistorySetting*) setting;
  //  }
    
    
    setting.delegate = self;
    cell.otrSetting = setting;
    
    
    
    //NSLog(@"%@", setting);
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self.settingsManager.settingsGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0) {
        return [self.mappings numberOfItemsInSection:0]+1;
    }
    return [self.settingsManager numberOfSettingsInSection:sectionIndex];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && indexPath.section == 0){
        return heightAccountTableViewCelAcc;
    }
    
    return 50.0;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.settingsManager stringForGroupInSection:section];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) { // Accounts
    
        
        if (indexPath.row == [self.mappings numberOfItemsInSection:0]) {
            
         
            
            /*
             //Запрет на добавление аккаута если он уже есть в списке
            
            if([self accountAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) {
            
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                return ; //Отработка запрета
            };
         */
            
            
            [self addAccount:[tableView cellForRowAtIndexPath:indexPath]];
        } else {
            OTRAccount *account = [self accountAtIndexPath:indexPath];
            
            BOOL connected = [[OTRProtocolManager sharedInstance] isAccountConnected:account];
            if (!connected) {
                [self showLoginControllerForAccount:account];
            } else {
                RIButtonItem * cancelButtonItem = [RIButtonItem itemWithLabel:CANCEL_STRING];
                RIButtonItem * logoutButtonItem = [RIButtonItem itemWithLabel:LOGOUT_STRING action:^{
                    id<OTRProtocol> protocol = [[OTRProtocolManager sharedInstance] protocolForAccount:account];
                    [protocol disconnect];
                    //Удаляю аккаунт
                     [OTRAccountsManager removeAccount:account];
                }];
                
                RIButtonItem * chAvatarBtn = [RIButtonItem itemWithLabel:CHANGE_AVATAR_STRING action:^{
                    //Перехожу к смене аватарки
       
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.allowsEditing = YES;
                  
                    
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    
                    [self presentViewController:picker animated:YES completion:nil];
                    
                    
                }];
                
                

                UIActionSheet * logoutActionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelButtonItem destructiveButtonItem:logoutButtonItem otherButtonItems:chAvatarBtn, nil];
                
                [OTRAppDelegate presentActionSheet:logoutActionSheet inView:self.view];
            }
        }
    } else {
        OTRSetting *setting = [self.settingsManager settingAtIndexPath:indexPath];
        OTRSettingActionBlock actionBlock = setting.actionBlock;
        if (actionBlock) {
            actionBlock();
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return;
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        OTRAccount *account = [self accountAtIndexPath:indexPath];
        
      //  RIButtonItem * cancelButtonItem = [RIButtonItem itemWithLabel:CANCEL_STRING];
      //  RIButtonItem * okButtonItem = [RIButtonItem itemWithLabel:OK_STRING action:^{
            
            if( [[OTRProtocolManager sharedInstance] isAccountConnected:account])
            {
                id<OTRProtocol> protocol = [[OTRProtocolManager sharedInstance] protocolForAccount:account];
                [protocol disconnect];
            }
            [OTRAccountsManager removeAccount:account];
      //  }];
        
    //    NSString * message = [NSString stringWithFormat:@"%@ %@?", DELETE_ACCOUNT_MESSAGE_STRING, account.username];
    //    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:DELETE_ACCOUNT_TITLE_STRING message:message cancelButtonItem:cancelButtonItem otherButtonItems:okButtonItem, nil];
        
     //   [alertView show];
    }
}

- (void) showLoginControllerForAccount:(OTRAccount *)account {
    OTRLoginViewController *loginViewController = [OTRLoginViewController loginViewControllerWithAcccount:account];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
    
    self.loginController = loginViewController;
}

-(void)showAboutScreen
{
    OTRAboutViewController *aboutController = [[OTRAboutViewController alloc] init];
    [self.navigationController pushViewController:aboutController animated:YES];
}

- (void) addAccount:(id)sender {
    RIButtonItem *cancelButton = [RIButtonItem itemWithLabel:CANCEL_STRING];
    RIButtonItem *createAccountButton = [RIButtonItem itemWithLabel:SIGN_UP_STRING action:^{
        
        [[UIApplication sharedApplication] openURL:[NSURL otr_projectURL]]; //Это мое дерьмо
        
        /*
         
         Делаю тупо переход на сайт вместо работы с приложением
        
        OTRCreateAccountChooserViewController * createAccountChooser = [[OTRCreateAccountChooserViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:createAccountChooser];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
        */
    }];
    
    //Убрать кнопку если есть активный аккаунт
    RIButtonItem *loginAccountButton = nil;
    if(![self accountAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) {
 
    
    loginAccountButton = [RIButtonItem itemWithLabel:LOGIN_STRING action:^{
      
        
        //Сразу перехожу в SafeJab не даю выбора
     
        
        OTRAccount *account = [OTRAccount accountForAccountType:OTRAccountTypeJabber];
        
        
        OTRLoginViewController *loginViewController = [OTRLoginViewController loginViewControllerWithAcccount:account];
        loginViewController.isNewAccount = NO;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
       
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
     
       // self.loginController = loginViewController;
        
        
        
       // OTRLoginViewController *loginViewController = [OTRLoginViewController loginViewControllerWithAcccount:account];
       // loginViewController.isNewAccount = YES;
       // [self.navigationController pushViewController:loginViewController animated:YES];
        
        
        
        //OTRNewAccountViewController * newAccountView = [[OTRNewAccountViewController alloc] init];
        
       // UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:newAccountView];
       // nav.modalPresentationStyle = UIModalPresentationFormSheet;
       // [self presentViewController:nav animated:YES completion:nil];
    }];
        
    }
    
    UIActionSheet *actionSheet;

    if(loginAccountButton){
        
         actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelButton destructiveButtonItem:nil otherButtonItems:loginAccountButton, createAccountButton, nil];
   
    } else {
     
          actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelButton destructiveButtonItem:nil otherButtonItems:createAccountButton, nil];
    }
    
   
    
    [actionSheet showInView:self.view];
}

#pragma mark OTRSettingDelegate method

- (void)refreshView
{
    [self.tableView reloadData];
}

#pragma mark OTRSettingViewDelegate method
- (void) otrSetting:(OTRSetting*)setting showDetailViewControllerClass:(Class)viewControllerClass
{

        
    UIViewController *viewController = [[viewControllerClass alloc] init];
    viewController.title = setting.title;
    
    if ([viewController isKindOfClass:[OTRDatabaseUnlockViewController class]]){
        // DDLogInfo(@"zigClass: %@",  viewControllerClass); //zigzagcorp test
        viewController = [(OTRDatabaseUnlockViewController *) viewController initChangePin];
        // [(OTRDatabaseUnlockViewController *) viewController isChangePin];
    }
    
    
    if ([viewController isKindOfClass:[OTRSettingDetailViewController class]])
    {
        OTRSettingDetailViewController *detailSettingViewController = (OTRSettingDetailViewController*)viewController;
     
        detailSettingViewController.otrSetting = setting;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailSettingViewController];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    } else {
          
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void) donateSettingPressed:(OTRDonateSetting *)setting {
    RIButtonItem *paypalItem = [RIButtonItem itemWithLabel:@"PayPal" action:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6YFSLLQGDZFXY"]];
    }];
    RIButtonItem *bitcoinItem = [RIButtonItem itemWithLabel:@"Bitcoin" action:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://coinbase.com/checkouts/0a35048913df24e0ec3d586734d456d7"]];
    }];
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:CANCEL_STRING];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:DONATE_MESSAGE_STRING cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:paypalItem, bitcoinItem, nil];
    [OTRAppDelegate presentActionSheet:actionSheet inView:self.view];
}

- (void) deleteAllChatsPressed:(OTRDeleteAllChats *)setting {
    //zigzagcorp action
    RIButtonItem *deleteAllChatsItem = [RIButtonItem itemWithLabel:@"OK" action:^{
       // self.databaseConnection.database.o
     NSArray *acc =  [OTRAccountsManager allAccountsAbleToAddBuddies];
        NSString *uid = [[acc objectAtIndex:0] uniqueId]; //zigzagcorp bugs
        
        DDLogInfo(@"Clear All %@", uid);
     
        
   
        
        [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            
        
            
            
            [OTRMessage zigDeleteAllMessagesForAccountId:uid transaction:transaction];
            //[message saveWithTransaction:transaction];
            
        }];
        
      //  id<OTRProtocol> protocol = [[OTRProtocolManager sharedInstance] protocolForAccount:self.account];
      //  [protocol connectWithPassword:self.account.password];
     
        
      
    
    }];
  
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:CANCEL_STRING];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@?", CLEAR_ALL_HISTORY] cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:deleteAllChatsItem, nil];
    [OTRAppDelegate presentActionSheet:actionSheet inView:self.view];
}

- (void)setKeepHistory:(OTRKeepHistorySetting*)setting{
    
    //Если нет связи с сервером ничего не делать
    if(!isConnectedSJAccount()) return;
    
    if(!self.HP ) {
        self.HP  = [[historyPicker alloc] initWithView:self.view];
        self.HP.myDelegate = self;
        self.HP.setting = setting;
    }
    
    
    
    [self.HP show];
    
   // [self.tableView reloadData];

 //   NSLog(@"CLICK");

}
#pragma mark - Get NOTIFICATION

-(void)reloadHistoryCell:(NSNotification *)sender {
  //from historyManager
    
    
   dispatch_async(dispatch_get_main_queue(), ^{
    
       NSString * key = [sender.userInfo objectForKey:@"key"];
     self.settingsManager.keepHistorySetting.option = [historyPicker valueFromKey:key];
    
    
//[self.settingsManager settingAtIndexPath:inde
    
  //
    
  //  self.HP.setting.option = [historyPicker valueFromKey:key];
    //dispatch_async(dispatch_get_main_queue(), ^{
    
    
 //   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //Добавляем отображение таймера
        //NSLog(@"READY");
        [self.tableView reloadData];
   });
  //  });
    
  
    
   // });
    

}

#pragma mark historyPickerDelegate

-(void) setHistoryOption:(NSString *)option{
   
    
    
    
    //NSLog(@"%@", option);
    self.settingsManager.keepHistorySetting.option = @"Applying...";
    [self.tableView reloadData];
    
    if(!self.historyManager){
        self.historyManager = [[historyManager alloc] init];
    }
    
    [self.historyManager setHistoryOptionOnServer:option];
    
   //  self.HP.setting.option = option;
   // [self.tableView reloadData];
}


#pragma mark OTRFeedbackSettingDelegate method

- (void) presentUserVoiceView {
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:CANCEL_STRING];
    RIButtonItem *showUVItem = [RIButtonItem itemWithLabel:OK_STRING action:^{
        UVConfig *config = [UVConfig configWithSite:@"chatsecure.uservoice.com"];
        [UserVoice presentUserVoiceInterfaceForParentViewController:self andConfig:config];
    }];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:SHOW_USERVOICE_STRING cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:showUVItem, nil];
    [OTRAppDelegate presentActionSheet:actionSheet inView:self.view];
}

#pragma - mark YapDatabse Methods

- (void)yapDatabaseModified:(NSNotification *)notification
{
    NSArray *notifications = [notification.userInfo objectForKey:@"notifications"];
    
    // Process the notification(s),
    // and get the change-set(s) as applies to my view and mappings configuration.
    
    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    
    [[self.databaseConnection ext:OTRAllAccountDatabaseViewExtensionName] getSectionChanges:&sectionChanges
                                                                                 rowChanges:&rowChanges
                                                                           forNotifications:notifications
                                                                               withMappings:self.mappings];
    
    [self.tableView beginUpdates];
    
    for (YapDatabaseViewRowChange *rowChange in rowChanges)
    {
        switch (rowChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeMove :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate :
            {
                [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
    
    [self.tableView endUpdates];
}

#pragma mark - add Avatar

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
   // BlurView * bv = [[BlurView alloc] initWithView:[OTRAppDelegate appDelegate].window.rootViewController.view];
   // [bv setupWaitView];
    
    
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [self updateAvatar:chosenImage];
    
   // UIImage * newAva =  [SavePhoto compressImage:chosenImage maxSize:200];
  //  NSData * dataNewAva =   UIImageJPEGRepresentation(newAva, 0.9);
  
  //  NSString *b64NewAva = [dataNewAva base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    
  
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)updateAvatar:(UIImage *)avatar
{
    
    //OTRvCardYapDatabaseStorage *test = [[OTRvCardYapDatabaseStorage alloc] init];
    
  //  [test ]
    
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        
        OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:SJAccount()];
    
    
  
        
        
     //   XMPPvCardTemp *vCard =[xmppManager.xmppvCardTempModule vCardTempForJID:xmppManager.xmppStream.myJID.bareJID shouldFetch:YES];
        
        
      //  NSLog(@"vCard %@", vCard);
    
   // });
    
  
    
    
    UIImage * newAva =  [SavePhoto compressImage:avatar maxSize:200];
    NSData * dataNewAva =   UIImageJPEGRepresentation(newAva, 0.9);
    NSString *b64NewAva = [dataNewAva base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    
    
  //  NSLog(@"xmppvCardTempModule %@", xmppManager.xmppvCardTempModule);
    
    
    
  //  NSData *imageData = UIImagePNGRepresentation(newAva);
    
    
    if(xmppManager.myVCard && b64NewAva.length > 10){
        
       
    
    //dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(dispatch_get_main_queue(), ^{
        
         [self showHUD];
      
        
        OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:SJAccount()];
        
        

        NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
        
        //[imageData1 base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]
        
      
        NSXMLElement *NICKNAME = [NSXMLElement elementWithName:@"NICKNAME"stringValue:xmppManager.myVCard.nickname];
        NSXMLElement *EMAIL = [NSXMLElement elementWithName:@"EMAIL"stringValue:xmppManager.myVCard.email];
            
            NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
            NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE"stringValue:@"image/jpeg"];
            NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:b64NewAva];
        
             [vCardXML addChild:NICKNAME];
        
            [photoXML addChild:typeXML];
            [photoXML addChild:binvalXML];
            [vCardXML addChild:photoXML];
        
            [vCardXML addChild:EMAIL];
        

        
        
        XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
        [xmppManager.xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
        
       
        
       // XMPPvCardTemp *myvCardTemp = [xmppManager.xmppvCardTempModule myvCardTemp];
        
        
     //   NSLog(@"ZZZZIIIFGHFGF_%@", myvCardTemp);
        
        /*
        if (myvCardTemp) {
            [myvCardTemp setPhoto:imageData1];
            [xmppManager.xmppvCardTempModule updateMyvCardTemp
             :myvCardTemp];
            
        }
        else{
            
            XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
            [xmppManager.xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
        }
         */
        
    
        
        /*
        XMPPvCardTempModule *vCardTempModule = xmppManager.xmppvCardTempModule;
        XMPPvCardTemp *myVcardTemp = [vCardTempModule myvCardTemp];
        //[myVcardTemp setName:[NSString stringWithFormat:@"%@",name.text]];
        [myVcardTemp setPhoto:imageData];
        [vCardTempModule updateMyvCardTemp:myVcardTemp];
         */
    });
        
    }
     
}

- (void)showHUD
{
    [self.view endEditing:YES];
    if (!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.HUD];
    }
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = PLEASE_WAIT;
    
    
    [self.HUD show:YES];
}

- (void)hideHUD {
    if (self.HUD) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD hide:YES];
            
        });
        
        
    }
}

-(void)didUpdateVCardFromServer{
    [self hideHUD];
}

-(void)didErrorVCardFromServer{
    [self hideHUD];
    
    
    
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:ERROR_STRING
                                  message:@"Avatar update..."
                                  preferredStyle:UIAlertControllerStyleAlert];
    

    UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:OK_STRING
                             style:UIAlertActionStyleDefault
                             handler:nil];
    
    
    [alert addAction:ok];

    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)didGetMyVCard{
    [self hideHUD];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
            [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        
    });
}
@end
