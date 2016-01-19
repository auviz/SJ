//
//  OTRAddFriendInGroup.m
//  SafeJab
//
//  Created by Самсонов Александр on 24.08.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "OTRAddFriendInGroup.h"
#import "Strings.h"
#import  "groupChatManager.h"
#import "OTRBuddy.h"
#import "OTRBuddyInfoCell.h"
#import "SetGlobVar.h"
#import "OTRTabBar.h"
#import "OTRLog.h"

@interface OTRAddFriendInGroup ()

@property OTRRoom * room;


@end

@implementation OTRAddFriendInGroup

-(id)initWithRoom: (OTRRoom *)room{
    self = [super init];
  
    if(self){
        self.room = room;
        
        return self;
    }
    
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = nil;
    self.title = ADD_MEMBER;
    self.hideTabBar = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exitRoom)
                                                 name:NOTIFICATION_UPDATE_ROOM_LIST
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backToRoom)
                                                 name:NOTIFICATION_ADD_MUC_FRIEND
                                               object:nil];
}

-(void)backToRoom{
    //Вернуться назад
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.navigationController popViewControllerAnimated:YES];
    });
    
   
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_ROOM_LIST object:nil];
      [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ADD_MUC_FRIEND object:nil];
}

-(void)exitRoom{
    DDLogInfo(@"exitRoom");
    if(self.room.roomId){
        
        if(![OTRRoom isRoomInServer:self.room.roomId]){
            
            [OTRTabBar showConversationViewControllerWithAnimation:self.view];
            
        }
        
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (section == 0) {
        
      
            numberOfRows = 0;
            
      
        
    } else {
        if ([self useSearchResults]) {
            numberOfRows = [self.searchResults count];
        }
        else {
            numberOfRows = [self.mappings numberOfItemsInSection:0];
        }
    }
    
    return numberOfRows;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    
       OTRBuddy *buddy = [[self buddyAtIndexPath:indexPath] copy];
    
    
    if ([self.room.participants containsObject:buddy.username]) {
        
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        //Довляю друга в чат
        groupChatManager *GCM = [[groupChatManager alloc] init];
        [GCM addUserForRoomID:self.room.roomId accountUsername:buddy.username];
        
      
        
       
    }
    
    
   
 
    
    
          //  [tableView deselectRowAtIndexPath:indexPath animated:YES];


    
  //  [GCM sendImAddFriend:buddy.username roomID:<#(NSString *)#>
    
    
     
    }


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OTRBuddy *buddy = [[self buddyAtIndexPath:indexPath] copy];
    OTRBuddyInfoCell *cell = (OTRBuddyInfoCell *)[super tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
    
    
    if ([self.room.participants containsObject:buddy.username]) {
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
      
     
      // cell.accountLabel.text = @"1";
     //   cell.nameLabel.text = @"2";
        
        
        cell.identifierLabel.text = ALREADY_AT_ROOM;
      //cell.accountLabel.text = @"dfge";
    } else {
        cell.backgroundColor = nil;
    }
    return cell;
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
