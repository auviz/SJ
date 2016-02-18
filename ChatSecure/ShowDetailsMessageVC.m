//
//  ShowDetailsMessageVC.m
//  SafeJab
//
//  Created by Самсонов Александр on 19.01.16.
//  Copyright © 2016 Leader Consult. All rights reserved.
//

#import "ShowDetailsMessageVC.h"
#import "OTRMessage.h"
#import "OTRMessagesViewController.h"
#import "SetGlobVar.h"
#import "Strings.h"
#import "OTRRoom.h"
#import "customColor+UIColor.h"
#import "timePicker.h"
#import "OTRDatabaseManager.h"

@implementation ZIGItemCell

//Без релизации пока

@end


@interface ShowDetailsMessageVC ()



@property  ZIGItemCell * itemCell;
@property (strong, nonatomic)  NSMutableArray *itemsCollection;

@property (strong, nonatomic) OTRMessage * message;
@property (strong, nonatomic) NSIndexPath *messageIndexPath;
@property (strong, nonatomic) UIView * jsqCell;
@property (strong, nonatomic) NSString * lifeTimeWord;

@property (strong, nonatomic) NSMutableArray * participants;
@property (strong, nonatomic) NSArray *notReceivedMessage;

@property BOOL isGroupChat;

@end

@implementation ShowDetailsMessageVC

//Cell identifeters
NSString *const CELL_IDENT_INFO = @"CELL_IDENT_INFO";
NSString *const CELL_IDENT_DELIMITER = @"CELL_IDENT_DELIMITER";
NSString *const CELL_IDENT_CANCEL_SENDING = @"CELL_IDENT_CANCEL_SENDING";

//Main


-(id)initWithMessageIndexPath: (NSIndexPath *)indexPath messagesViewController:(OTRMessagesViewController *)messagesVC{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
 
    if(self){
        self.messageIndexPath = indexPath;
        self.message = [messagesVC messageAtIndexPath:indexPath];
        self.jsqCell = [messagesVC getBubbleFromCellAtIndexPath:indexPath];
        self.isGroupChat = [messagesVC getIsGroupChat];
        
        if(self.message.lifeTime){
            self.lifeTimeWord = [timePicker secondsToWord:self.message.lifeTime];
        }
        
        
        if(self.isGroupChat){
            
        
            self.participants = [[NSMutableArray alloc] initWithArray:[OTRRoom roomById:messagesVC.buddy.username].participants];
            
            [self.participants removeObject:messagesVC.account.username];
        }
    
        
       // self = [self initWithStyle:UITableViewStyleGrouped];
         return  self;
    }
    
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = DETAILS_MESSAGE_STRING;
    
    if(!self.isGroupChat){
    [self setupItemsCollectionForChat];
    } else {
        
        [self setupItemsCollectionForGroupChat];
        
      //  dispatch_async(dispatch_get_main_queue(), ^{
            [self getWhoNotReceivedMessage:self.message.messageId];
      //  });
        
    }
    
    
    
    
    
    // [self.tableView setTableHeaderView:self.jsqCell];
    //self.tableView.tableHeaderView = self.jsqCell;
   
    
    //self.tableView.delegate = self;
    // self.tableView.dataSource = self;
    
  //  [self.tableView registerNib:self forCellReuseIdentifier:CELL_IDENT_INFO];
    
   // [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_IDENT_INFO];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
   
    
    CGRect contFrame =  self.view.frame;
    CGRect jsqFrame = self.jsqCell.frame;
    
    contFrame.size.height = (jsqFrame.size.height +20);
    UIView * conteiner = [[ UIView alloc] initWithFrame:contFrame];
    conteiner.backgroundColor = [UIColor whiteColor];
    
    
    UIImage *imgBubble = imageWithView(self.jsqCell);
    UIImageView * viewImgBubble = [[UIImageView alloc] initWithImage:imgBubble];
    viewImgBubble.frame = CGRectMake(jsqFrame.origin.x, (contFrame.size.height - jsqFrame.size.height)/2, jsqFrame.size.width, jsqFrame.size.height);

    

  
    
    
    
    
    [conteiner addSubview:viewImgBubble];
    
    
    viewImgBubble.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  
 
    
        [self.tableView setTableHeaderView:conteiner];
    

   
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return  20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    //#warning Incomplete implementation, return the number of rows
    
    return  [self.itemsCollection count];
   // return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    ZIGItemCell *item = [self getItemCellAtIndexPath:indexPath];
    
    
    if([item.identifier isEqualToString:CELL_IDENT_CANCEL_SENDING]){
        
        if( item.isDisabled ) return; //Блокировка повторного нажатия
        
        //Если это кнопка отмены то:
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:[NSString stringWithFormat:@"%@?" ,CANCEL_SENDING_STRING]
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:OK_STRING
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 item.isDisabled = YES;
                                 
                               //  [self querySendCanceledForUsers];
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:CANCEL_STRING
                                 style:UIAlertActionStyleDefault
                                 handler:nil];
        
        
        [alert addAction:cancel];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    
 
    
    
    
    
    
    [self.tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
    
    ZIGItemCell *item = [self getItemCellAtIndexPath:indexPath];
    
    if([item.identifier isEqualToString:CELL_IDENT_DELIMITER]){
        return 20;
    }
    
    return [super tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 

    ZIGItemCell *item = [self getItemCellAtIndexPath:indexPath];
    
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.identifier];
    
    
    //Cell cansel send
    
    if([item.identifier isEqualToString:CELL_IDENT_CANCEL_SENDING]){
        
        if (cell == nil){
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:item.identifier];
            
            cell.textLabel.textColor = [UIColor redColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
    
        }
        cell.textLabel.text = item.titleText;
     
        
        return cell;
    }
    
    
    
    
    //Cell delimiter
    
    if([item.identifier isEqualToString:CELL_IDENT_DELIMITER]){
    
    if (cell == nil){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:item.identifier];
        cell.textLabel.font = [UIFont italicSystemFontOfSize:14];
        cell.backgroundColor = [UIColor clearColor];
        
    }
        cell.textLabel.text = item.titleText;
       
        
        return cell;
    }
   
    // Configure the cell info
    
    if (cell == nil) {
         //NSLog(@"CELL_IDENT_INFO %@", CELL_IDENT_INFO);
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:item.identifier];

    }
    
    
    cell.textLabel.text = item.titleText;
    cell.detailTextLabel.text = item.text;
    
    if(item.color != nil){
        cell.detailTextLabel.textColor = item.color;
    }
    
   
    
    
      //  cell.backgroundColor = [UIColor redColor];
        
   
      return cell;
   // [cell addSubview:self.jsqCell];
    
  
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Setup items

-(ZIGItemCell  *)getItemCellAtIndexPath:(NSIndexPath *)indexPath{
    if(self.itemsCollection){
       return [self.itemsCollection objectAtIndex:indexPath.row ];
    }
    
    return nil;
}

-(void)addItemToCell:(ZIGItemCell *)item{
    
    if(!self.itemsCollection){
        self.itemsCollection = [[NSMutableArray alloc] init];
    }
    
   int count = (int)[self.itemsCollection count];
    
    [self.itemsCollection insertObject:item atIndex:count];
    
    
}

-(void)setupItemsCollectionForGroupChat{
    ZIGItemCell *  item;
    
    
    [self addItemDate];
    
    [self addItemLifetime];
    
   item = [[ZIGItemCell alloc] init];
    item.identifier = CELL_IDENT_DELIMITER;
    item.titleText = MEMBERS;
    [self addItemToCell:item];
    
    
    for(NSString * participant in self.participants){
        
        
   
        
        
        item = [[ZIGItemCell alloc] init];
        
        item.titleText = participant;
        
        
        if(!self.notReceivedMessage ){
               item.text = @"Loading...";
        } else if([self.notReceivedMessage containsObject:participant]){
            item.text = SUBMITTED_STRING;
        } else {
            item.text = DELIVERED_STRING;
            item.color = [UIColor darkGreen];
        }

        
        item.identifier = CELL_IDENT_INFO;
        [self addItemToCell:item];
        
    }
    
    //Кнопка отмены
   if(self.notReceivedMessage.count != 0) [self addItemCancelSending];

    
    
    
}

-(void)setupItemsCollectionForChat{
    
  
    
    //int count = [self.itemsCollection count];
    
    ZIGItemCell * item = [[ZIGItemCell alloc] init];

    
    //Статус доставки
    
    if(self.message.error){
        item.text = NOT_DELIVERED;
        item.color = [UIColor redColor];
    }else if(self.message.delivered){
        item.text = DELIVERED_STRING;
        item.color = [UIColor darkGreen];
        
    } else if(!self.message.delivered){
        item.text = SUBMITTED_STRING;
       // item.color = [UIColor clearColor];
    }
    
    item.titleText = STATUS_STRING;
    item.identifier = CELL_IDENT_INFO;
    
    [self addItemToCell:item];
    
    //Дата доставки
    
    [self addItemDate];

    
    //Время жизни
    
    [self addItemLifetime];
    
    
    //Кнопка отмены
  if(!self.message.delivered)  [self addItemCancelSending];

    
  //  item = [[ZIGItemCell alloc] init];
    
 //   item.titleText = @"Время жизни";
    
  //  if(self.message.lifeTime){
 //       item.titleText = [NSString stringWithFormat:@"%@ %"]
 //   }
    
    
    
}

-(void)addItemDate{
   ZIGItemCell * item = [[ZIGItemCell alloc] init];
    
    item.titleText = SUBMITTED_DATE;
    item.text = dateToStringWithMask(self.message.date, @"dd.MM.yyyy HH:mm:ss");
    item.identifier = CELL_IDENT_INFO;
    [self addItemToCell:item];
    
}

-(void)addItemLifetime{
    if (self.lifeTimeWord){
       ZIGItemCell * item = [[ZIGItemCell alloc] init];
        
        item.titleText = LIFETIME_STRING;
        item.text = self.lifeTimeWord;
        item.color = [UIColor orangeColor];
        item.identifier = CELL_IDENT_INFO;
        [self addItemToCell:item];
    }
    
}


-(void)addItemCancelSending{
    ZIGItemCell * item = [[ZIGItemCell alloc] init];
    item.identifier = CELL_IDENT_DELIMITER;
   // item.titleText = @"  ";
    [self addItemToCell:item];
    
    
    
    item = [[ZIGItemCell alloc] init];
    
    item.titleText = CANCEL_SENDING_STRING;
    item.identifier = CELL_IDENT_CANCEL_SENDING;
    [self addItemToCell:item];
}

-(void)reloadTable {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView transitionWithView:self.tableView
                          duration:0.3f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^(void) {
                            //  dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                            //    });
                        } completion:NULL];
        
    });
    
    
}

#pragma mark - Работа с OTRMessage

-(void)setMessageSendCanceledForUsers:(NSArray *)canceledForUsers {
    
    self.message.sendCanceledForUsers = canceledForUsers;
    self.message.read = YES;
    
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [self.message saveWithTransaction:transaction];
    } completionBlock:^{
        
        //Ну обновляю виев
        
        if(self.isGroupChat){
            [self setupItemsCollectionForGroupChat];
        } else {
            [self setupItemsCollectionForChat];
        }
        
        
        [self reloadTable];
       
    }];
    
    
}



#pragma mark - Генерация запроса для групповых сообщений

-(void)querySendCanceledForUsers{
    
    
    
    
    NSString *post =  [NSString stringWithFormat:@"messageID=%@&isGroupChat=%d", self.message.messageId, self.isGroupChat];
    
    [NSURLConnection
     sendAsynchronousRequest:[self genRequest:post url:@"https://safejab.com/forAll/sendCanceledForUsers.php"]
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if ([data length] >0 && error == nil)
         {
             // DO YOUR WORK HERE
             self.itemsCollection = nil;
             
             NSString *usersCanseled = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSArray *arrUsersCanseled = [usersCanseled componentsSeparatedByString:@"|"];
          
             [self setMessageSendCanceledForUsers:arrUsersCanseled];
             
             
         } else if (error != nil){
             
           //  NSLog(@"ERROR_LIST");
            
             
         }
         
     }];
    
}


-(void)getWhoNotReceivedMessage:(NSString *)messageId{
    
    
    
    NSString *post =  [NSString stringWithFormat:@"messageID=%@", messageId];
    
    [NSURLConnection
     sendAsynchronousRequest:[self genRequest:post url:@"https://safejab.com/groupChat/recipientsWhoNotReceivedMessage.php"]
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if ([data length] >0 && error == nil)
         {
             // DO YOUR WORK HERE
            self.itemsCollection = nil;
             
              NSString *messages = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             self.notReceivedMessage = [messages componentsSeparatedByString:@"|"];
             [self setupItemsCollectionForGroupChat];
             
             
             [self reloadTable];
           
             
         }
         else if ([data length] == 0 && error == nil)
         {
             self.itemsCollection = nil;
             self.notReceivedMessage = [[NSArray alloc] init];
             [self setupItemsCollectionForGroupChat];
            
             [self reloadTable];
             //  NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             
             NSLog(@"ERROR_LIST");
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 //Добавляем отображение таймера
                 [self getWhoNotReceivedMessage:self.message.messageId];
             });
             
         }
         
     }];
    
}



-(NSMutableURLRequest *)genRequest:(NSString *)post url:(NSString *)url{
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    return request;
}




@end
