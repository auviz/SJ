//
//  OTRComposeViewController.m
//  Off the Record
//
//  Created by David Chiles on 3/4/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRComposeViewController.h"

#import "OTRAppDelegate.h"

#import "OTRBuddy.h"
#import "OTRAccount.h"
#import "OTRDatabaseView.h"
#import "OTRLog.h"
#import "OTRDatabaseManager.h"
#import "OTRDatabaseView.h"
#import "OTRAccountsManager.h"
#import "YapDatabaseFullTextSearchTransaction.h"
#import "Strings.h"
#import "OTRBuddyInfoCell.h"
#import "OTRNewBuddyViewController.h"
#import "OTRChooseAccountViewController.h"

#import "OTRXMPPManager.h"

#import "OTRProtocolManager.h"
#import "SetGlobVar.h"
#import "groupChatManager.h"
//#import "OTRToolBar.h"

#import "OTRConversationViewController.h"
#import "OTRAppDelegate.h"
#import "OTRTabBar.h"






static CGFloat OTRBuddyInfoCellHeight = 80.0;
static CGFloat addAndGroupButtonHeiht = 60.0;

@interface OTRComposeViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSLayoutConstraint *  tableViewBottomConstraint;
@property (nonatomic, strong) YapDatabaseConnection *databaseConnection;
//@property (nonatomic, strong) YapDatabaseViewMappings *mappings;
//@property (nonatomic, strong) NSArray *searchResults;


@property (nonatomic, strong) UIBarButtonItem * cancelBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem * backBarButtonItem;
@property dispatch_queue_t myQueue;
@property OTRTabBar * tabBar;
@property (nonatomic, strong) UIButton *overlayButton;
@property (nonatomic, strong) UIView *overlayButtonlineView;

//@property (nonatomic, strong) OTRToolBar *bar;

@end

@implementation OTRComposeViewController

@synthesize hideTabBar;


-(id)init{
    self= [super init];
    
    if(self){
          self.hideTabBar = NO;
        return self;
    }
    return nil;
}

-(id)initWithHidenTabBar {
    
    self= [super init];
    
    if(self){
        self.hideTabBar = YES;
        return self;
    }
    return nil;
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    self.view.backgroundColor = [UIColor whiteColor];
    
   
    
    /////////// Navigation Bar ///////////
    self.title = COMPOSE_STRING;
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    
       self.backBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:BACK_BTN style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    
   // self.navigationItem.leftBarButtonItem =  self.backBarButtonItem;
    self.navigationItem.leftBarButtonItem = nil;

    
    

    
    /////////// Search Bar ///////////
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.enablesReturnKeyAutomatically = NO;
   
    self.searchBar.placeholder = SEARCH_STRING;

    [self.view addSubview:self.searchBar];
    
    /////////// TableView ///////////
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = OTRBuddyInfoCellHeight;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[OTRBuddyInfoCell class] forCellReuseIdentifier:[OTRBuddyInfoCell reuseIdentifier]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:0 views:@{@"tableView":self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchBar]|" options:0 metrics:0 views:@{@"searchBar":self.searchBar}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayoutGuide][searchBar][tableView]" options:0 metrics:0 views:@{@"tableView":self.tableView,@"searchBar":self.searchBar,@"topLayoutGuide":self.topLayoutGuide}]];
    self.tableViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:self.tableViewBottomConstraint];
    
    //////// YapDatabase Connection /////////
    self.databaseConnection = [[OTRDatabaseManager sharedInstance] mainThreadReadOnlyDatabaseConnection];
    
    self.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[OTRBuddyGroup] view:OTRAllBuddiesDatabaseViewExtensionName];
    
    
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [self.mappings updateWithTransaction:transaction];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yapDatabaseDidUpdate:)
                                                 name:OTRUIDatabaseConnectionDidUpdateNotification
                                               object:nil];
    

}

-(void)viewWillLayoutSubviews {
    
    [self updateFrameOverlayButton];
    if(self.tabBar){
        [self.tabBar setTBFrame:CGRectMake(0, (self.view.frame.size.height -50), self.view.frame.size.width, 50)];
    }
    
    
}



- (void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    
    
    //Скрываю строку заголовка
    if(self.searchBar.text.length > 0){
        [[self navigationController] setNavigationBarHidden:YES animated:NO];
        //И активирую клаву 
          [self.searchBar becomeFirstResponder];
     
    }
    
    
    if(!self.hideTabBar){
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0,0,50,0)];
    
    self.tabBar = [[OTRTabBar alloc] init];
    
    [self.tabBar addTabBar:self.view];
    
    [self.tabBar setTBFrame:CGRectMake(0, (self.view.frame.size.height -50), self.view.frame.size.width, 50)];
    }
    
   // [self.tableView setEditing: YES animated: YES];
    
    //self.tableView.allowsMultipleSelectionDuringEditing = YES;
   // [self.tableView setEditing:YES animated:YES];
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didHideKeyboard:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    
   
   // self.navigationController.toolbarHidden = NO;
    
   [self.tableView reloadData];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear: animated];
    
   
  
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)customSetEditing:(BOOL)editing animated:(BOOL)animated
{
    DDLogInfo(@"setEditing");
    _isEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = editing;
    
   // self.navigationController.toolbarHidden =YES;
     
    // начинаем анимацию
    [UIView beginAnimations:nil context:nil];
    // продолжительность анимации - 1 секунда
    //[UIView setAnimationCurve:1.0];
    // пауза перед началом анимации - 1 секунда
    // [UIView setAnimationDelay:1.0];
    // тип анимации устанавливаем - "начало медленное - конец быстрый"
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    // собственно изменения, которые будут анимированы
   self.tableView.alpha=0;
    // команда, непосредственно запускающая анимацию.
    [UIView commitAnimations];
    
    //Тут меняем то что надо
    [self.tableView setEditing:editing animated:animated];
    [self.tableView reloadData];
    self.title = GROUP_CHAT;
    
    //Меняем кнопку назад на отмена
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
   
    
    // начинаем анимацию
    [UIView beginAnimations:nil context:nil];
    // продолжительность анимации - 1 секунда
    //[UIView setAnimationCurve:1.0];
    // пауза перед началом анимации - 1 секунда
     [UIView setAnimationDelay:0.3];
    // тип анимации устанавливаем - "начало медленное - конец быстрый"
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    // собственно изменения, которые будут анимированы
    self.tableView.alpha=1;
    // команда, непосредственно запускающая анимацию.
    [UIView commitAnimations];
    
    
  
    
}

- (void)doneButtonPressed:(id)sender
{
    /*
    
     NSArray *accounts = [OTRAccountsManager allAccountsAbleToAddBuddies];
    
    OTRAccount *acc = [accounts firstObject];
    
     OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:acc];
    
    [xmppManager getSJRooms:@"group"];
    
    */
    
    
  
    self.navigationItem.rightBarButtonItem = nil;
    
dispatch_async(dispatch_get_main_queue(), ^{
    
   groupChatManager * GCM = [[groupChatManager alloc] init];
    
    GCM.linkToOTRComposeViewController = self;
    
    
    
    
    [GCM createGroupChatWidhFriends : [_selectedItems allValues]]; //Ну вот мы и отдаем друзей на растерзание групповому чату
     });
    
  //  DDLogCInfo(@"doneButtonPressed %@", [groupChatManager sharedRoomsWithFriends]);

    
    
}

-(dispatch_queue_t)getMyQueue {
    
    if(!self.myQueue ) {
         self.myQueue =  dispatch_queue_create("ZIG.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self.myQueue;
   

}



-(void)goChatWithNewRoom:(NSString *)roomID{


   
  
    OTRAccount* SJAcc= SJAccount();
    
    NSString *fullRoomID = [NSString stringWithFormat:@"%@@%@", roomID, MUC_JABBER_HOST];
    
    
    __block OTRBuddy *buddy = nil;
    
    
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), [self getMyQueue], ^{
        
        
        [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            buddy = [OTRBuddy fetchBuddyWithUsername:fullRoomID withAccountUniqueId:SJAcc.uniqueId transaction:transaction];
            
            
            if(!buddy) [self goChatWithNewRoom:roomID]; else {
                
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     /*
                     
                       OTRConversationViewController *nav =  (OTRConversationViewController *)[[OTRAppDelegate appDelegate] defaultConversationNavigationController];
                     */
                     
                   
                     
                     [OTRTabBar setState:center];
                     
                     
                    
                     
                     
                    
                     
                     [UIView transitionWithView:self.view.window
                                       duration:0.5
                                        options: UIViewAnimationOptionTransitionFlipFromLeft
                                     animations:^{
                                         [[OTRAppDelegate appDelegate] showConversationViewController];
                                         
                                           [[OTRAppDelegate appDelegate].conversationViewController enterConversationWithBuddyNoAnimition:buddy];
                                     }
                                     completion:nil];
                     
                    
               
         
       
                     
                 });
                
                 }
            
        }];
        
        
        
    });

        
        

  ///  NSLog(@"ziuuuuu %@", buddy);
    

    
    
    
   // if ([self.delegate respondsToSelector:@selector(controller:didSelectBuddy:)]) {
    //    [self.delegate controller:self didSelectBuddy:buddy];
   // }
          

}



- (void)cancelButtonPressed:(id)sender
{
    
    if(_isEditing){
        
    // self.navigationController.toolbarHidden =NO;
        //[self.bar addItemsToUINavigationController:self.navigationController];
        DDLogInfo(@"setEditing");
        _isEditing = NO;
        self.tableView.allowsMultipleSelectionDuringEditing = NO;
        
        [self.tableView setEditing:NO animated:YES];
        // начинаем анимацию
        [UIView beginAnimations:nil context:nil];
        // продолжительность анимации - 1 секунда
        //[UIView setAnimationCurve:1.0];
        // пауза перед началом анимации - 1 секунда
        // [UIView setAnimationDelay:1.0];
        // тип анимации устанавливаем - "начало медленное - конец быстрый"
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        // собственно изменения, которые будут анимированы
        self.tableView.alpha=0;
        // команда, непосредственно запускающая анимацию.
        [UIView commitAnimations];
        [self.tableView reloadData];

        self.title = COMPOSE_STRING;
        
        //Меняем отмена на назад
        //self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
        self.navigationItem.leftBarButtonItem =nil;
        
        
        //Чищу кнопки от мусора
        self.navigationItem.rightBarButtonItem = nil;
        _selectedItems = nil;
        
    
        
        // начинаем анимацию
        [UIView beginAnimations:nil context:nil];
        // продолжительность анимации - 1 секунда
        //[UIView setAnimationCurve:1.0];
        // пауза перед началом анимации - 1 секунда
        [UIView setAnimationDelay:0.3];
        // тип анимации устанавливаем - "начало медленное - конец быстрый"
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        // собственно изменения, которые будут анимированы
        self.tableView.alpha=1;
        // команда, непосредственно запускающая анимацию.
        [UIView commitAnimations];
        
        
        
        
        
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (BOOL)canAddBuddies
{
    
    return YES;
    
/*
 
 В оригенале выглядело так но так как мне не нужно скрывать кнопки я их показываю всегда
 
    if([OTRAccountsManager allAccountsAbleToAddBuddies]) {
        return YES;
    }
 
 return NO;
  */
    
    
}

- (OTRBuddy *)buddyAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *viewIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    
   
    
    if ([self useSearchResults]) {
        if (indexPath.row < [self.searchResults count]) {
            return self.searchResults[viewIndexPath.row];
        }
    }
    else
    {
        __block OTRBuddy *buddy;
        [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            buddy = [[transaction ext:OTRAllBuddiesDatabaseViewExtensionName] objectAtIndexPath:viewIndexPath withMappings:self.mappings];
        }];
        return buddy;
    }
    
    
    return nil;
}

- (BOOL)useSearchResults
{
    if([self.searchBar.text length])
    {
        return YES;
    }
    return NO;
}

#pragma - mark keyBoardAnimation Methods
- (void)keyboardWillShow:(NSNotification *)notification
{
    [self animateTableViewWithKeyboardNotification:notification];
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    [self animateTableViewWithKeyboardNotification:notification];
    
}

- (void)animateTableViewWithKeyboardNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    //
    // Get keyboard size.
    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    
    //
    // Get keyboard animation.
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    CGFloat height = keyboardEndFrame.size.height;
    if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        height = 0;
    }
    
    [self animateTableViewToKeyboardHeight:height animationCurve:animationCurve animationDuration:animationDuration];
}

- (void)animateTableViewToKeyboardHeight:(CGFloat)keyBoardHeight animationCurve:(UIViewAnimationCurve)animationCurve animationDuration:(NSTimeInterval)animationDuration
{
    self.tableViewBottomConstraint.constant = -keyBoardHeight;
    void (^animations)() = ^() {
        [self.view layoutIfNeeded];
    };
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
    
}

#pragma - mark UISearchBarDelegateMethods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length]) {
        
        [self.overlayButton removeFromSuperview];
        
        searchText = [NSString stringWithFormat:@"%@*",searchText];
        
        NSMutableArray *tempSearchResults = [NSMutableArray new];
        [self.databaseConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [[transaction ext:OTRBuddyNameSearchDatabaseViewExtensionName] enumerateKeysAndObjectsMatching:searchText usingBlock:^(NSString *collection, NSString *key, id object, BOOL *stop) {
                if ([object isKindOfClass:[OTRBuddy class]]) {
                    [tempSearchResults addObject:object];
                }
            }];
        } completionBlock:^{
            self.searchResults = tempSearchResults;
            [self.tableView reloadData];
        }];
    } else {
        [self.tableView reloadData];
        [self showOverlayButton];
    }
}

#pragma - mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    BOOL canAddBuddies = [self canAddBuddies];
    NSInteger sections = 0;
    if ([self useSearchResults]) {
        sections = 1;
    }
    else {
        sections = [self.mappings numberOfSections];
    }
    
    if (canAddBuddies) {
        sections += 1;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (section == 0 && [self canAddBuddies]) {
       
        if([self useSearchResults] || _isEditing){
           //Скрываю кнопки групповой чат и добавить кониакт
            numberOfRows = 0;
            
        } else numberOfRows = 2;
        
    }
    else {
        if ([self useSearchResults]) {
            numberOfRows = [self.searchResults count];
        }
        else {
            numberOfRows = [self.mappings numberOfItemsInSection:0];
        }
    }
   
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(indexPath.section == 0 && [self canAddBuddies]) {
        
        
        if(indexPath.row == 0){
        
  
        
        // if(indexPath.section == 0 && [self canAddBuddies]) zigzagcorp old
        // add new buddy cell
        static NSString *addCellIdentifier = @"addCellIdentifier";
            
            
            
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addCellIdentifier];
            
            //if(cell) return cell;
            
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addCellIdentifier];
            
        }
        cell.textLabel.text = ADD_BUDDY_STRING;
           
        cell.imageView.image = [UIImage imageNamed:@"31-circle-plus"];
            
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        return cell;
            
        } else if (indexPath.row == 1){
            
            static NSString *groupCellIdentifier = @"groupCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:groupCellIdentifier];
            
            //if(cell) return cell;
            
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupCellIdentifier];
            }
            cell.textLabel.text = GROUP_CHAT;
           // UIImageView * vvv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aim"]];
            
            cell.imageView.image = [UIImage imageNamed:@"112-group"];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        
        
        }
    }
    else {
        
      
        
        OTRBuddyInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:[OTRBuddyInfoCell reuseIdentifier] forIndexPath:indexPath];
       
        
        OTRBuddy * buddy = [self buddyAtIndexPath:indexPath];
        
       // cellForRowAtIndexPath
      
        
        __block NSString *buddyAccountName = nil;
        [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            buddyAccountName = [OTRAccount fetchObjectWithUniqueID:buddy.accountUniqueId transaction:transaction].username;
        }];
        
   
        
       // DDLogInfo(@"Account: %@", buddyAccountName);
       
        // if(![buddy.username isEqualToString:buddyAccountName]){
             
            // cell
             
             
        //   }
             
             [cell setBuddy:buddy withAccountName:buddyAccountName];
             
         
        
        [cell.avatarImageView.layer setCornerRadius:(OTRBuddyInfoCellHeight-2.0*OTRBuddyImageCellPadding)/2.0];
        
        
       // if(_isEditing){
           
            
        
       // [cell setSelected:YES animated:NO];
      //  }

       
        return cell;
        
    }
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_isEditing){
        OTRBuddyInfoCell *curCell =   (OTRBuddyInfoCell *)cell;
       // NSLog(@"dasd %@", curCell.welfBody.username);
        
        
    if ( [_selectedItems objectForKey:curCell.welfBody.username]) {
        [cell setSelected:YES animated:NO];
    }
    }
}

#pragma - mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return OTRBuddyInfoCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (indexPath.section == 0) {
    return addAndGroupButtonHeiht;
     } else {
    return OTRBuddyInfoCellHeight;
     }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
  //  OTRBuddy * buddy = [self buddyAtIndexPath:indexPath];
    
OTRBuddyInfoCell *curCell =   (OTRBuddyInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [_selectedItems removeObjectForKey:curCell.welfBody.username];
    
    if(_selectedItems.count == 0){
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    
    
    // NSLog(@"buddy %@", buddy.username);
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_isEditing) {
        
        OTRBuddy * buddy = [self buddyAtIndexPath:indexPath];
        
        
        if( SafeJabTypeIsEqual(buddy.username, MUC_JABBER_HOST)){
            //Если приятель групповой чат проигнорировать
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return ;
        }
        
        //Тут если мы выбираем групповой чат
        
        if(!_selectedItems) _selectedItems = [[NSMutableDictionary alloc] init];
        
       OTRBuddyInfoCell *curCell =   (OTRBuddyInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        
        [_selectedItems setValue:buddy.username forKey:curCell.welfBody.username];
        
       // [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if(_selectedItems.count > 0){
        
        UIBarButtonItem * doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        
        self.navigationItem.rightBarButtonItem = doneBarButtonItem;
        }
        

        
        return ;
    }
    
    //А это уже переход к приятелю
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    //zigzagcorp bugs
    /*
    __block NSArray *accounts = nil;
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        accounts = [OTRAccount allAccountsWithTransaction:transaction];
    }];
    */
    
    NSArray *accounts = [OTRAccountsManager allAccountsAbleToAddBuddies];
    
    
    
    if(indexPath.section == 0)
    {
        if(![accounts count]) return nil; //zigzagcorp if если нет активных Аккаунтов спровоцировать ошибку
        
        if(indexPath.row == 0){
        //add buddy cell
        UIViewController *viewController = nil;
        if([accounts count] > 1) {
            
            // pick wich account
            viewController = [[OTRChooseAccountViewController alloc] init];
            
        }
        else {
            OTRAccount *account = [accounts firstObject];
            viewController = [[OTRNewBuddyViewController alloc] initWithAccountId:account.uniqueId];
        }
        [self.navigationController pushViewController:viewController animated:YES];
        
        } if(indexPath.row == 1) {
            //Start Group Chat
            
            /*
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Групповой чат пока в разработке :("
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction* cansel = [UIAlertAction actionWithTitle:OK_STRING style:UIAlertActionStyleDefault
                                                           handler:nil];
            
     
            [alert addAction:cansel];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
            
                DDLogInfo(@"Start Group Chat");
            */
            
           // XMPPRoomManager *xrm = [[XMPPRoomManager alloc] init];
            [self customSetEditing:YES animated:YES];
            
            /*
             OTRAccount *account = [accounts firstObject];
            
            OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:account];
   
            [xmppManager createChatRoom:@"asd"];
            */
            
    
          //  [xrm createChatRoom:@"mega" withAccount:account];
            
             
           // ZIGGroupChatViewController * zigViewCon = [[ZIGGroupChatViewController alloc] init];
        
         //   [self.navigationController pushViewController:zigViewCon animated:YES];
            
            
        
        }
        
    }
    /*
    else if ([self.delegate respondsToSelector:@selector(controller:didSelectBuddy:)]) {
        OTRBuddy * buddy = [self buddyAtIndexPath:indexPath];
        [self.delegate controller:self didSelectBuddy:buddy];
    }
     */
    else {
      
        
        OTRBuddy * buddy = [self buddyAtIndexPath:indexPath];
        
    OTRMessagesViewController * messagesViewController = [[OTRAppDelegate appDelegate].conversationViewController messagesViewControllerWithBuddy:buddy];
        
        //self.navigationController.toolbarHidden = YES;
      
        [self.navigationController pushViewController:messagesViewController animated:YES];
          [[self navigationController] setNavigationBarHidden:NO animated:YES];
        
    }
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete Boddy
        
      OTRBuddyInfoCell *curCell =   (OTRBuddyInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        
        
      
        
    //    OTRBuddy *cellBuddy = [[self buddyAtIndexPath:indexPath] copy];
        
       
        
        __block OTRAccount *buddyAccount = nil;
        [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            buddyAccount = [OTRAccount fetchObjectWithUniqueID:curCell.welfBody.accountUniqueId transaction:transaction];
        }];
        
        
        [[[OTRProtocolManager sharedInstance] protocolForAccount:buddyAccount] removeBuddies:@[curCell.welfBody]];
    
    
    }
    
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma - mark YapDatabaseViewUpdate

- (void)yapDatabaseDidUpdate:(NSNotification *)notification;
{
    if (_isEditing) return ; //Запрещаю что то делать с ячейками пока редактируем
        
    // Process the notification(s),
    // and get the change-set(s) as applies to my view and mappings configuration.
    NSArray *notifications = notification.userInfo[@"notifications"];
    
    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    
    if ([self useSearchResults]) {
        return;
    }
    
    [[self.databaseConnection ext:OTRAllBuddiesDatabaseViewExtensionName] getSectionChanges:&sectionChanges
                                                                                 rowChanges:&rowChanges
                                                                           forNotifications:notifications
                                                                               withMappings:self.mappings];
    
    // No need to update mappings.
    // The above method did it automatically.
    
    if ([sectionChanges count] == 0 & [rowChanges count] == 0)
    {
        // Nothing has changed that affects our tableView
        return;
    }
    
    // Familiar with NSFetchedResultsController?
    // Then this should look pretty familiar
    
    [self.tableView beginUpdates];
    
    BOOL canAddBuddies = [self canAddBuddies];
    
    for (YapDatabaseViewSectionChange *sectionChange in sectionChanges)
    {
        NSUInteger sectionIndex = sectionChange.index;
        if (canAddBuddies) {
            sectionIndex += 1;
        }
        
        switch (sectionChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeMove :
            case YapDatabaseViewChangeUpdate :
                break;
        }
    }
    
    
    
    for (YapDatabaseViewRowChange *rowChange in rowChanges)
    {
        NSIndexPath *indexPath = rowChange.indexPath;
        NSIndexPath *newIndexPath = rowChange.newIndexPath;
        if (canAddBuddies) {
            indexPath = [NSIndexPath indexPathForItem:rowChange.indexPath.row inSection:1];
            newIndexPath = [NSIndexPath indexPathForItem:rowChange.newIndexPath.row inSection:1];
        }
        else {
            
        }
        
        switch (rowChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeMove :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate :
            {
                [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                                      withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
   
    [self.tableView endUpdates];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)updateFrameOverlayButton {
    
    if(self.overlayButton){
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    float heightSearch = self.searchBar.bounds.size.height +
    [UIApplication sharedApplication].statusBarFrame.size.height;
    
    [self.overlayButton setFrame: CGRectMake(0, heightSearch, width, (height - heightSearch))];
        
         CGRect rect = self.searchBar.frame;
       self.overlayButtonlineView.frame = CGRectMake(0, rect.size.height-1,rect.size.width, 1);
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = nil;
    [self.tableView reloadData];
    [self hideKeyboard:nil];
    
}


-(void)showOverlayButton {
    
    
    
    self.overlayButton.alpha = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    // add to main view
    [self.view addSubview: self.overlayButton ];
    self.overlayButton.alpha = 0.4f;
    [UIView commitAnimations];
    
    if(!self.overlayButtonlineView){
    self.overlayButtonlineView = [[UIView alloc] init];
    self.overlayButtonlineView .backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.80f alpha:1.0];
        
    }
    
    [self.searchBar addSubview:self.overlayButtonlineView ];
}

-(void)hideOverlayButton{
    [self.overlayButtonlineView removeFromSuperview];
    [self.overlayButton removeFromSuperview];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
 
    //  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
   // UIButton *btnCancel = [self.searchBar valueForKey:@"_cancelButton"];
  //  [btnCancel setEnabled:YES];
          
    //  });
}

-(void)didHideKeyboard:(id)sender{
    UIButton *btnCancel = [self.searchBar valueForKey:@"_cancelButton"];
    [btnCancel setEnabled:YES];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{

    if(searchBar.text.length == 0){
    
   // CGRectMake(<#CGFloat x#>, <#CGFloat y#>, width, CGFloat height)
    
   // self.searchBar.
    // add the button to the main view
    if(!self.overlayButton){
   self.overlayButton = [[UIButton alloc] init];
        
        // set the background to black and have some transparency
        self.overlayButton.backgroundColor = [UIColor blackColor];
        
        // add an event listener to the button
        [ self.overlayButton  addTarget:self action:@selector(hideKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateFrameOverlayButton];
    }
    
    [self showOverlayButton];
        
   

    
  
    
   // self.searchBar.showsCancelButton = YES;
         [self.searchBar setShowsCancelButton:YES animated:YES];
    
   [[self navigationController] setNavigationBarHidden:YES animated:YES];
    }
}


- (void)hideKeyboard:(UIButton *)sender
{
    // hide the keyboard
     // self.searchBar.showsCancelButton = NO;
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self.searchBar resignFirstResponder];
    // remove the overlay button
    [self hideOverlayButton];
}


@end
