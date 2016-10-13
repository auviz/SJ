//
//  OTRRoomSettingsViewController.m
//  SafeJab
//
//  Created by Самсонов Александр on 13.08.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "OTRRoomSettingsViewController.h"
#import "Strings.h"
#import "OTRRoom.h"
#import "OTRImages.h"
#import "groupChatManager.h"
#import "OTRDatabaseManager.h"
#import "OTRMessage.h"
#import  "SetGlobVar.h"
#import "OTRAddFriendInGroup.h"
#import "OTRProtocolManager.h"
#import "OTRAppDelegate.h"
#import "OTRTabBar.h"
#import "historyManager.h"

const float heightFirstSection = 75;

@interface OTRRoomSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) OTRBuddy *buddy;
@property (nonatomic, strong, readwrite) OTRRoom *room;

@property (nonatomic, strong) NSMutableArray *participants;

@property (nonatomic, strong) UITextField * textFieldRoomName;

@property  BOOL isAdminRoom;

@end

@implementation OTRRoomSettingsViewController

-(id)initWithBuddy:(OTRBuddy* )buddy{
    
    self = [super init];
    
    if(self){
        
    
        
        self.buddy = buddy;
        self.room = [OTRRoom roomById:buddy.username];
        self.isAdminRoom = [SJAccount().username isEqualToString:self.room.roomAdmin];
        
        return self;
    }
    
    return nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = GROUP_STRING;
    
    self.textFieldRoomName = [self roomNameTextField];


    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
  //  self.tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   
    
    [self refreshData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData)
                                                 name:NOTIFICATION_UPDATE_ROOM_LIST
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
          [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_ROOM_LIST object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshData
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
  
   // NSLog(@"ZiGrefreshData");
   //  [self.tableView reloadData];
    if(self.room.roomId.length > 0){
    
        if(![OTRRoom isRoomInServer:self.room.roomId]){
            
            [OTRTabBar showConversationViewControllerWithAnimation:self.view];
            
            
            return;
        }
        
    }
    
    
    
    self.room = nil;
    
    self.room = [OTRRoom roomById:self.buddy.username];
    

    self.isAdminRoom = [SJAccount().username isEqualToString:self.room.roomAdmin];
    
    if(self.room.nameRoom && ![self.room.nameRoom isEqualToString:@""]){
        
        
         self.textFieldRoomName.text = self.room.nameRoom;
        
    } else {
        
        self.textFieldRoomName.placeholder = [self.room roomName];
    }
    
    
    self.participants =  [[NSMutableArray alloc] initWithArray:self.room.participants];
    
 
    [self.participants  removeObject:SJAccount().username];
    
    
    
    NSRange range = NSMakeRange(0, 2);
   NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];

[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
        

    
   // [self.tableView reloadData];
  //  NSRange range = NSMakeRange(0,1);
  //  NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    
   // [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
 


    /*
    self.certificateDictionary = [OTRCertificatePinning allCertificates];
    self.certificateDomains = [[self.certificateDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    if ([self.certificateDomains count]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing:)];
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
     */
    });
}

- (void)toggleEditing:(id)sender {
     /*
    UIBarButtonItem * editButton;
    
    
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing:)];
    }
    else{
        [self.tableView setEditing:YES animated:YES];
        editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditing:)];
    }
    self.navigationItem.rightBarButtonItem = editButton;
       */
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.section == 0 || indexPath.section == 2) {
    return UITableViewCellEditingStyleNone;
    }
    
      return UITableViewCellEditingStyleDelete;
 
     
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    
    if (indexPath.section == 1) {
        
    
        NSString * member = [self.participants objectAtIndex:indexPath.row];
        if([member isEqualToString:self.room.roomAdmin]) return NO;
        
           return YES;
    }
    return NO;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 3;
    /*
    NSInteger count = 0;
    if ([self.certificateDomains count]) {
        count +=1;
    }
    
    return count;
     */
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if(section == 1){
    return MEMBERS;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(section == 0){
        return 1;
    } else if(section == 1){
        
       // NSLog(@"self.participants.count %d", (int)self.participants.count);
        
        return self.participants.count;
    } else if(section == 2){
        
        //if(self.isAdminRoom) return 4;
            
  
        return 4;
    }
    
    return 0;
    
    //return [self.certificateDomains count];
}


-(UITextField *)roomNameTextField {
    UITextField *txtField = [[UITextField alloc] initWithFrame:CGRectMake(100, ((heightFirstSection/2)-15), 300, 30)];
    //txtField.backgroundColor = [UIColor redColor];
   
    if(self.room.nameRoom.length > 0){
        
        txtField.text = self.room.nameRoom;
        
    } else {
         txtField.placeholder = [self.room roomName];
    }
   
    
      txtField.font = [UIFont systemFontOfSize:21];
    txtField.delegate = self;
    txtField.returnKeyType = UIReturnKeyDone;
    
    return txtField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if([textField.text isEqualToString:self.room.nameRoom]) return NO;
    
    //Переименовать комнату Rename
    self.room.nameRoom = textField.text;
    
    groupChatManager *GCM = [[groupChatManager alloc] init];
    
    [GCM renameRoomById:self.room.roomId newRoomName:textField.text];
    
   // [GCM sendRenameRoomForRoomID:self.room.roomId];
 
    return NO;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * tableViewCellIdentifier = [NSString stringWithFormat:@"cellId_%d", (int)indexPath.section];
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellIdentifier];


   //cell.accessoryType = UITableViewCellStyleSubtitle;
    
   
    if (indexPath.section == 0){
        
        
        
        if(indexPath.row == 0){
            
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:tableViewCellIdentifier];
            }
           
  
             cell.imageView.image =  [self.buddy avatarImage];
     
         
          
            [cell.contentView addSubview:self.textFieldRoomName];
            
            //cell.accessoryView = txtField;
            
        
        
       cell.accessoryType = UITableViewCellAccessoryNone;
        
        }
    }
    
    if (indexPath.section == 1){
        
         //NSString * tableViewCellIdentifier = @"tableViewCellIdentifierFriends";
        
        
        //Если друзья
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableViewCellIdentifier];
        }
        
   
    
       // static int i = 0;
        
       // self.room.participants
      NSString * member = [self.participants objectAtIndex:indexPath.row];
    
    cell.textLabel.text = member;
 
      
       if([member isEqualToString:self.room.roomAdmin]){

        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.detailTextLabel.text = @"admin";
       }
    
 
    
    }
    
    if (indexPath.section == 2){
        
      //  NSString * tableViewCellIdentifier = @"tableViewCellIdentifierSettings";
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCellIdentifier];
        }
        

        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if(indexPath.row == 0) {
            
           /// cell.textLabel.textAlignment = NSTextAlignmentCenter;
             cell.textLabel.text = ADD_STRING;
            cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
            
        }
        
       
        if(indexPath.row == 1) {
        
            cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        }
        
        if(indexPath.row == 2){
            cell.textLabel.text = CLEAR_CHAT_HISTORY_STRING;
            cell.textLabel.textColor = [UIColor redColor];
        }
        
        if(indexPath.row == 3 ){
            
             NSString *title = self.isAdminRoom ? DESTROY_THE_ROOM : SIGN_OUT_OF_ROOM;
            
            cell.textLabel.text = title;
            cell.textLabel.textColor = [UIColor redColor];
        }
        
 
        
       
        
        
    }
    
    
    
       return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return heightFirstSection;
    }
    
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if(indexPath.section == 2 && indexPath.row == 0){
 
        
        
        OTRAddFriendInGroup *OCVC = [[OTRAddFriendInGroup alloc] initWithRoom:self.room];
        [self.navigationController pushViewController:OCVC animated:YES];
    }
    
    
    if(indexPath.section == 2 && indexPath.row == 2){
        
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:[NSString stringWithFormat:@"%@?" ,CLEAR_CHAT_HISTORY_STRING]
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:OK_STRING
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Просто очищаем историю
                                 [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                                     
                                     [OTRMessage deleteAllMessagesForBuddyId:self.buddy.uniqueId transaction:transaction];
                                     
                                     
                                 }];
                                 
                                 //Удаление сообщений из истории (для приятеля)
                                 [historyManager deleteAllMessagesForUser:SJAccount().username withBuddy:self.buddy.username];
                                 
                                 //[alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:CANCEL_STRING
                                 style:UIAlertActionStyleDefault
                                 handler:nil];
        
       
        [alert addAction:cancel];
         [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
        
        
        
       
      
        
    }
    
    if(indexPath.section == 2 && indexPath.row == 3){
        
        
        NSString *title = self.isAdminRoom ? DESTROY_THE_ROOM : SIGN_OUT_OF_ROOM;
        
    
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:[NSString stringWithFormat:@"%@?" ,title]
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:OK_STRING
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Уничтожение комнаты
                                 groupChatManager *GCM = [[groupChatManager alloc] init];
                                 
                                 
                                 if(self.isAdminRoom)
                                {
                                 
                                 [GCM deleteOrLeaveTheRoom:self.room.roomId];
                                 GCM.needDestroyRoomWithId = self.room.roomId; //Удаляем комнату на сервере если являемся админом комнаты
                                 
                             } else {
                                 //Или просто покинуть комнату
                                // [GCM sendByeForRoomID:self.room.roomId];
                                 [GCM deleteOrLeaveTheRoom:self.room.roomId];
                                 GCM.needLeaveRoomWithId = self.room.roomId;
                             }
                             
                                
                                 
                                     [[[OTRProtocolManager sharedInstance] protocolForAccount:SJAccount()] removeBuddies:@[self.buddy]];
                                 
                                 
                                 //[OTRTabBar showConversationViewControllerWithAnimation:self.view];
                                 
                                 //[alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:CANCEL_STRING
                                 style:UIAlertActionStyleDefault
                                 handler:nil];
        
        
        [alert addAction:cancel];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    
    }
    /*
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * hostname = nil;
    NSArray * certArray = nil;
    BOOL canEdit = YES;
    
    hostname = self.certificateDomains[indexPath.row];
    certArray = self.certificateDictionary[hostname];
    
    OTRCertificatesViewController * viewController = [[OTRCertificatesViewController alloc] initWithHostName:hostname withCertificates:certArray];
    viewController.canEdit = canEdit;
    
    [self.navigationController pushViewController:viewController animated:YES];
     */
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        
        groupChatManager *GCM = [[groupChatManager alloc] init];
        [GCM deleteUserForRoomID:self.room.roomId accountUsername: [self.participants objectAtIndex:indexPath.row] ];
   
   
        
    //    [self.participants removeObjectAtIndex:indexPath.row];

        
     
      //  [self.tableView beginUpdates];
      //  [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      //  [self.tableView endUpdates];
                
     
     
     
       
        
    
       
       
   
    }
   
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

