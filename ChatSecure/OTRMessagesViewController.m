//
//  OTRMessagesViewController.m
//  Off the Record
//
//  Created by David Chiles on 5/12/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
// zigzagcorp add photo

// [JSQSystemSoundPlayer jsq_playMessageReceivedSound];

#import "OTRMessagesViewController.h"


#import "OTRDatabaseView.h"
#import "OTRDatabaseManager.h"
#import "OTRLog.h"

#import "OTRBuddy.h"
#import "OTRAccount.h"
#import "OTRMessage+JSQMessageData.h"
#import "JSQMessages.h"
#import "OTRProtocolManager.h"
#import "OTRXMPPTorAccount.h"
#import "OTRXMPPManager.h"
#import "OTRLockButton.h"
#import "OTRButtonView.h"
#import "Strings.h"
#import "UIAlertView+Blocks.h"
#import "OTRTitleSubtitleView.h"
#import "OTRKit.h"
//#import "OTRMessagesCollectionViewCellIncoming.h"
//#import "OTRMessagesCollectionViewCellOutgoing.h"
#import "OTRImages.h"
#import "AttachPhoto.h"
#import "SetGlobVar.h"
#import "SavePhoto.h"
#import "GetPhoto.h"
#import "OTRFSImageViewerViewController.h"
#import "OTRRoom.h"
#import "OTRTabBar.h"

#import "OTRRoomSettingsViewController.h"
#import "OTRLocation.h"
#import "OTRMapViewController.h"
#import "timePicker.h"
#import "destroySecureMessage.h"

static NSTimeInterval const kOTRMessageSentDateShowTimeInterval = 5 * 60;

typedef NS_ENUM(int, OTRDropDownType) {
    OTRDropDownTypeNone          = 0,
    OTRDropDownTypeEncryption    = 1,
    OTRDropDownTypePush          = 2
};

@interface OTRMessagesViewController () <JSQMessagesCollectionViewCellDelegate>

@property (nonatomic, strong) OTRAccount *account;

@property (nonatomic, strong) YapDatabaseConnection *uiDatabaseConnection;
@property (nonatomic, strong) YapDatabaseViewMappings *messageMappings;
@property (nonatomic, strong) YapDatabaseViewMappings *buddyMappings;

@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageView;
@property (nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageView;

@property (nonatomic, weak) id textViewNotificationObject;
@property (nonatomic, weak) id databaseConnectionDidUpdateNotificationObject;
@property (nonatomic, weak) id didFinishGeneratingPrivateKeyNotificationObject;
@property (nonatomic, weak) id messageStateDidChangeNotificationObject;



@property (nonatomic ,strong) UIBarButtonItem *lockBarButtonItem;
@property (nonatomic, strong) OTRLockButton *lockButton;
@property (nonatomic, strong) OTRButtonView *buttonDropdownView;
@property (nonatomic, strong) OTRTitleSubtitleView *titleView;

//@property (nonatomic, strong) NSMutableDictionary *allCachingPhotos;
@property (nonatomic, strong) NSMutableDictionary *allMessagesCach;

@property (nonatomic, strong) NSMutableDictionary *isPhotosLoading;
@property (nonatomic, strong) OTRLocation *location;
@property (nonatomic, strong) timePicker * TP;


//Delegate
@property(nonatomic, strong) id deleg;

- (id)delegate;

- (void)setDelegate:(id)newDelegate;


@property NSTimer *timerWaitingConnection;



@end

@implementation OTRMessagesViewController

@synthesize deleg, timerWaitingConnection;

- (id)delegate {
    return deleg;
}

- (void)setDelegate:(id)newDelegate {
    deleg = newDelegate;
}

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}



- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    //Фиксю баг в текст инпуте
    
    //  if(action == @selector(delete:)) return NO;
    
    return NO;
    
}


- (void)delete:(id)sender
{
    
    DDLogInfo(@"Delete");
    
    if([sender isKindOfClass:[JSQMessagesCollectionViewCell class]]){
        self.automaticallyScrollsToMostRecentMessage = NO;
        [self messagesCollectionViewCellDidTapDelete:sender];
    }
    
    
    //   [self messagesCollectionViewCellDidTapDelete:sender];
    
}



-(void)cachMessages:(OTRMessage *)message IndexPath: (NSIndexPath *)IndexPath
{
    
    if(!self.allMessagesCach){
        self.allMessagesCach = [[NSMutableDictionary alloc] init];
    }
    
    [self.allMessagesCach setValue:message forKey:
     [NSString stringWithFormat:@"%ld_%ld", (long)IndexPath.row, (long)IndexPath.section]];
    
}

-(OTRMessage *)getCachMessages: (NSIndexPath *)IndexPath{
    
    if(!self.allMessagesCach) return nil;
    
    return [self.allMessagesCach valueForKey:[NSString stringWithFormat:@"%ld_%ld", (long)IndexPath.row, (long)IndexPath.section]];
    
}


-(void)setPhotoLoading:(GetPhoto *)gp IndexPath: (NSIndexPath *)IndexPath
{
    
    if(!self.isPhotosLoading){
        self.isPhotosLoading = [[NSMutableDictionary alloc] init];
    }
    
    [self.isPhotosLoading setValue:gp forKey:
     [NSString stringWithFormat:@"%ld_%ld", (long)IndexPath.row, (long)IndexPath.section]];
    
}

-(GetPhoto *)getPhotoLoading:(NSIndexPath *)IndexPath{
    
    if(!self.isPhotosLoading) return nil;
    
    return [self.isPhotosLoading valueForKey:[NSString stringWithFormat:@"%ld_%ld", (long)IndexPath.row, (long)IndexPath.section]];
    
}

-(void)delPhotoLoading:(NSIndexPath *)IndexPath{
    if(!self.isPhotosLoading) return nil;
    
    [self.isPhotosLoading removeObjectForKey:[NSString stringWithFormat:@"%ld_%ld", (long)IndexPath.row, (long)IndexPath.section]];
    
}


-(void)clearTimerWaitingConnection{
    [self.timerWaitingConnection invalidate];
    self.timerWaitingConnection = nil;
}



-(void)setTimerWaitingConnection{

    
    dispatch_async(dispatch_get_main_queue(), ^{
    
    BOOL isConnected = [self isConnected];
    
    
    if(self.timerWaitingConnection) [self clearTimerWaitingConnection];
    
    
    if (isConnected) {
        
        [self stopIndicatorView];
        return;
    }
    
    //Если нет поключения запустить таймер
    
    if(!isConnected){
        [self startIndicatorView];
        [self checkСonnection];
        self.timerWaitingConnection = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                                       target: self
                                                                     selector: @selector(checkСonnection)
                                                                     userInfo: nil
                                                                      repeats: YES];
        
    }
    });
    
}

-(void)checkСonnection {
    
    static int count;
    
    if([self isConnected]){
        count = 0;
        
        
         // NSLog(@"connectM");
        
        
        
        [self.inputToolbar toggleSendButtonEnabled];
        
        [self stopIndicatorView];
        
        [self clearTimerWaitingConnection];
        
    } else {
        
        count ++;
        
        if(count == 10) {
            ///Ну если совсем пиздец переподключаемся (полностью)
            [[OTRProtocolManager sharedInstance] loginAccounts:[OTRAccountsManager allAutoLoginAccounts]];
            count = 0;
        }
        
        //  NSLog(@"NOTconnectM %d", (int)count);
        
        [self startIndicatorView];
        
        self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
        
    }
    
}


-(BOOL)isConnected {
    
    if(_isGroupChat){
        //В групповом чате проверяем присоденились ли мы к комнате
        
        
        OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:self.account];
        
        NSArray *strArr = [self.buddy.username componentsSeparatedByString:@"@"];
        
        NSString*  roomId = [strArr firstObject];
        
        return [xmppManager getSJRooms:roomId].isJoined;
        
    }
    
    // self.account
    BOOL isConnected =  [[OTRProtocolManager sharedInstance] isAccountConnected:self.account] ;
    
    if(isConnected){
        return YES;
    } else {
        return NO;
    }
}

-(void)startIndicatorView {
    
    if(![self.titleView.indicatorView isAnimating]){
        
        [self.titleView.indicatorView startAnimating];
        self.titleView.titleLabel.alpha = 0;
        self.titleView.subtitleLabel.alpha=0;
        
    }
}

-(void)stopIndicatorView {
    
    [self.titleView.indicatorView stopAnimating];
    
    if(self.titleView.titleLabel.alpha == 0){
        
        // начинаем анимацию
        [UIView beginAnimations:nil context:nil];
        // продолжительность анимации - 1 секунда
        [UIView setAnimationCurve:2.0];
        // пауза перед началом анимации - 1 секунда
        // [UIView setAnimationDelay:1.0];
        // тип анимации устанавливаем - "начало медленное - конец быстрый"
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        // собственно изменения, которые будут анимированы
        self.titleView.titleLabel.alpha = 1;
        self.titleView.subtitleLabel.alpha=1;
        
        // команда, непосредственно запускающая анимацию.
        [UIView commitAnimations];
        
    }
    
}




/*
 -(void)cachingPhotos{
 
 
 
 NSUInteger lastMessageIndex = [self.collectionView numberOfItemsInSection:0] - 1;
 NSIndexPath *lastMessageIndexPath = [NSIndexPath indexPathForRow:lastMessageIndex inSection:0];
 OTRMessage *mostRecentMessage = [self messageAtIndexPath:lastMessageIndexPath];
 
 
 
 if(!self.allCachingPhotos){
 
 self.allCachingPhotos = [[NSMutableDictionary alloc] init];
 
 NSMutableArray *arrAllPhotos = [self getAllPhotos];
 
 for(OTRMessage *photoMessage in arrAllPhotos){
 
 UIImage *photo =  [GetPhoto loadImage:photoMessage.text];
 
 if(!photo) continue;
 
 JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:photo];
 
 
 photoMessage.unicPhotoName = photoMessage.text;ытш
 photoMessage.text = nil;
 
 if(photoMessage.incoming){
 
 photoItem.appliesMediaViewMaskAsOutgoing = NO;
 }
 
 photoMessage.media = photoItem;
 
 
 if(photoMessage.unicPhotoName){
 
 [self.allCachingPhotos setValue:photoMessage forKey:photoMessage.unicPhotoName];
 
 }
 
 
 }
 
 }
 
 }
 */

/*
 -(OTRMessage *)getPhotoFromCash:(NSString *)unicPhotoName {
 
 // UIImage *tempImg;
 
 
 return [self.allCachingPhotos valueForKey:unicPhotoName];
 //  tempImg = [self.allCachingPhotos valueForKey:unicPhotoName];
 
 
 }
 */

-(NSMutableArray *)getAllPhotos{
    
    
    
    __block NSMutableArray *photos;
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        DDLogInfo(@"self.buddy.uniqueId %@", self.buddy.uniqueId);
        photos = [OTRMessage getAllPhotosForBuddyId:self.buddy.uniqueId transaction:transaction];
        //[message saveWithTransaction:transaction];
        
    }];
    
    return photos;
    
}


-(void)showBigPhoto: (NSString *)unicPhotoName{
    
    ///DDLogInfo(@"Back btn %@", self.backBtnTitle);
    
    
    
    FSBasicImageSource *photoSource = [OTRFSImageViewerViewController getPhotosBuddy:unicPhotoName AllPhotos:[self getAllPhotos]];
    
    
    
    OTRFSImageViewerViewController *imageViewController = [[OTRFSImageViewerViewController alloc] initWithImageSource:photoSource];
    
    
    
    //  imageViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"CCC" style:UIBarButtonItemStyleBordered target:self action:@selector(showTest)] ;
    
    [self.navigationController pushViewController:imageViewController animated:YES];
    
    // UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imageViewController];
    // [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    
    /*
     UIImage *bigPhoto = [GetPhoto loadImage:unicPhotoName];
     
     if(bigPhoto){
     UIImageView *ourImageView = [[UIImageView alloc] initWithImage:bigPhoto];
     [ourImageView setFrame:[[UIScreen mainScreen] bounds]];
     UIViewController *controller = [[UIViewController alloc] init];
     [controller setView:ourImageView];
     [self.navigationController pushViewController:controller animated:YES];
     }
     */
    
    
}

-(void)setBackgroundBody
{
    UIColor *color = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background"]];
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    [background setBackgroundColor:color];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self.view insertSubview: background atIndex: 0 ];
}

- (UIImage *)stringToUIImage:(NSString *)string
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string
                                                      options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    
    if(SafeJabTypeIsEqual(self.buddy.username, MUC_JABBER_HOST)) _isGroupChat = YES; else _isGroupChat = NO;
    
    
    // [self cachingPhotos];
    
    
    
    
    //zigzagcorp cr Создание скрепки
    //   AttachPhoto *attBtn = [[AttachPhoto alloc] init];
    //[attBtn setLinkToBuddy:self];
    
    //[self setDeleg:attBtn];
    //   abc.vieC = self.window;
    // UIButton *btn =  [self.delegate AttachButton];
    
    
    
    // [self setBackgroundBody];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    
    //[self addTarget:self action:@selector(pickButtonTap:)  forControlEvents: UIControlEventTouchUpInside];
    
    //self.collectionView.frame = self.view.bounds;
    
    
    
    
    self.automaticallyScrollsToMostRecentMessage = YES;
    
    
    
    self.inputToolbar.contentView.leftBarButtonItem.hidden = NO; //zigzagcorp btn
    
    // self.outgoingCellIdentifier = [OTRMessagesCollectionViewCellOutgoing cellReuseIdentifier];
    
    // self.outgoingMediaCellIdentifier = [OTRMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier];
    
    
    //  self.incomingCellIdentifier = [OTRMessagesCollectionViewCellIncoming cellReuseIdentifier];
    
    //  self.incomingMediaCellIdentifier = [OTRMessagesCollectionViewCellIncoming mediaCellReuseIdentifier];
    
    
    
    
    
    
    
    // [JSQMessagesCollectionViewCellOutgoing cellReuseIdentifier];
    
    // [self.collectionView registerNib:[OTRMessagesCollectionViewCellOutgoing nib] forCellWithReuseIdentifier:[OTRMessagesCollectionViewCellOutgoing cellReuseIdentifier]];
    /// [self.collectionView registerNib:[OTRMessagesCollectionViewCellIncoming nib] forCellWithReuseIdentifier:[OTRMessagesCollectionViewCellIncoming cellReuseIdentifier]];
    
    
    //Media buble
    
    //  [self.collectionView registerNib:[OTRMessagesCollectionViewCellIncoming nib]
    //forCellWithReuseIdentifier:[OTRMessagesCollectionViewCellIncoming mediaCellReuseIdentifier]];
    
    //  [self.collectionView registerNib:[OTRMessagesCollectionViewCellOutgoing nib]
    //forCellWithReuseIdentifier:[OTRMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier]];
    
    ////// bubbles ////// zigzagcorp info
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageView = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor  jsq_messageBubbleGreenColor]];
    
    self.incomingBubbleImageView  = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    
    
    
    // self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleZigGreenColor]];
    
    // self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleWhiteColor]]; //zigzagcorp white
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    ////// Lock Button //////
    [self setupLockButton];
    
    ////// TitleView //////
    self.titleView = [[OTRTitleSubtitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    self.titleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.navigationItem.titleView = self.titleView;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTitleView:)];
    [self.titleView addGestureRecognizer:tapGestureRecognizer];
    
    [self refreshTitleView];
    
    
    
    
    // self.collectionView.hidden = YES;
    
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)]; //Регестрирую пункт в меню
    
    
    
    //Для анимации
    self.collectionView.alpha = 0.0; // скрываем элемент
    
    
    self.location = [[OTRLocation alloc] init];
    
    

    
   
   // self.inputToolbar.contentView.textView.bounds
    

    
    
    
   //  UIButton * bbb = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //  [bbb setTitle:@"eee" forState:UIControlStateNormal];
    
  //  bbb.backgroundColor = [UIColor redColor];
    
 //   [self.inputToolbar.contentView.textView addSubview:bbb];
 
    


    
}



- (void)resetLayoutAndCaches {

    
    //Если с рамерами коллекции фигня
    if(self.collectionView.frame.size.width > self.navigationController.toolbar.frame.size.width && self.collectionView.frame.size.width && self.navigationController.toolbar.frame.size.width){
      
      //Сбросить их нах Пузыри И Их Фреим
    JSQMessagesCollectionViewFlowLayoutInvalidationContext *context = [JSQMessagesCollectionViewFlowLayoutInvalidationContext context];
    context.invalidateFlowLayoutMessagesCache = YES;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:context];
        
        //Исправляет ошибку title после поворота
        self.titleView.frame = CGRectMake(0, 0, 200, 44);
        self.titleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        //Picker view
      //  [self.TP updateFramesCustomView];
       // [self.TP genTimeButtom:(UITextField *)self.inputToolbar.contentView.textView];

    }
    
    
}




- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];


    
    //Init to VC for DSM
    [destroySecureMessage setViewController:self];
    
    
    //Прошу перерисовать а то глюк после поворота экрана
    [self resetLayoutAndCaches];

    
    
    [self setTimerWaitingConnection];
    
    
    
    [self refreshLockButton];
    [self refreshTitleView];
    
    __weak typeof(self)weakSelf = self;
    
    
    /*
     self.textViewNotificationObject = [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:self.inputToolbar.contentView.textView queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
     [weakSelf textViewDidChangeNotifcation:note];
     
     
     
     }];
     */
    
    /* Commented out while debugging crash
     self.databaseConnectionDidUpdateNotificationObject = [[NSNotificationCenter defaultCenter] addObserverForName:OTRUIDatabaseConnectionDidUpdateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
     [welf yapDatabaseModified:note];
     }];
     */
    
    [self.uiDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [weakSelf.messageMappings updateWithTransaction:transaction];
        [weakSelf.buddyMappings updateWithTransaction:transaction];
    }];
    
    /*
     
     zigzagcorp i don't know now what this do
     
     void (^refreshGeneratingLock)(OTRAccount *) = ^void(OTRAccount * account) {
     if ([account.uniqueId isEqualToString:welf.account.uniqueId]) {
     [welf refreshLockButton];
     }
     };
     
     self.didFinishGeneratingPrivateKeyNotificationObject = [[NSNotificationCenter defaultCenter] addObserverForName:OTRDidFinishGeneratingPrivateKeyNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
     if ([note.object isKindOfClass:[OTRAccount class]]) {
     refreshGeneratingLock(note.object);
     }
     }];
     
     */
    /*
     self.messageStateDidChangeNotificationObject = [[NSNotificationCenter defaultCenter] addObserverForName:OTRMessageStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
     if ([note.object isKindOfClass:[OTRBuddy class]]) {
     OTRBuddy *notificationBuddy = note.object;
     if ([notificationBuddy.uniqueId isEqualToString:weakSelf.buddy.uniqueId]) {
     [weakSelf refreshLockButton];
     }
     }
     }];
     
     */
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateRoomList)
                                                 name:NOTIFICATION_UPDATE_ROOM_LIST
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendLocation)
                                                 name:NOTIFICATION_DID_UPDATE_LOCATION
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setTimerWaitingConnection)
                                                 name:NOTIFICATION_XMPP_STREAM_DID_DISCONNECT
                                               object:nil];
    
    
  
    [self.collectionView reloadData];
}

-(void)updateRoomList{
    
    DDLogInfo(@"updateRoomList %@", self.buddy.username);
    // NSLog(@"updateRoomList 123");
    // if(self.buddy.username){
    
    if(_isGroupChat){
        
        if(![OTRRoom isRoomInServer:self.buddy.username] || !self.buddy.username){
            
            [OTRTabBar showConversationViewControllerWithAnimation:self.view];
            
            
            return;
        }
    }
    
    //}
    
    
    
    [self refreshTitleView];
}




- (void)viewDidAppear:(BOOL)animated
{
    DDLogInfo(@"viewDidAppear");
    
    
    [super viewDidAppear:animated];
    
    
    [self.location checkGps:self]; //Проверка на геолокацию
    
    
    /*
     
     UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     CGRect frame = spinner.frame;
     frame.origin.x = self.titleView.frame.size.width / 2 - frame.size.width / 2;
     frame.origin.y = self.titleView.frame.size.height / 2 - frame.size.height / 2;
     spinner.frame = frame;
     [self.titleView addSubview:spinner];
     
     
     
     
     [spinner startAnimating];
     */
    
    
    if(self.collectionView.alpha == 0){
        
        // начинаем анимацию
        [UIView beginAnimations:nil context:nil];
        // продолжительность анимации - 1 секунда
        [UIView setAnimationCurve:1.0];
        // пауза перед началом анимации - 1 секунда
        // [UIView setAnimationDelay:1.0];
        // тип анимации устанавливаем - "начало медленное - конец быстрый"
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        // собственно изменения, которые будут анимированы
        self.collectionView.alpha = 1.0;
        // команда, непосредственно запускающая анимацию.
        [UIView commitAnimations];
        
    }
    
    
    // self.collectionView.hidden = NO;
    
    //  [self scrollToBottomAnimated:NO];
    
    
    if([self.inputToolbar.contentView.textView isFirstResponder]){
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }
    

    
    
    //InitPicker
    if(!self.TP && !_isGroupChat){ //Отключаю пока для группового чата
        
    self.TP = [[timePicker alloc] initWithParent:self];
    UIEdgeInsets edge = self.inputToolbar.contentView.textView.textContainerInset;
    self.inputToolbar.contentView.textView.textContainerInset = UIEdgeInsetsMake(edge.top, edge.left, edge.bottom, (20));
    [self.TP genTimeButtom:(UITextField *)self.inputToolbar.contentView.textView];
        
   // [self.TP getPickerView].delegate = self;
    }
    
    

    
}




- (void)viewWillDisappear:(BOOL)animated
{
    
    
    
    //[self jsq_setToolbarBottomLayoutGuideConstant:0.0f];
    
    
    [super viewWillDisappear:animated];
    
    [self clearTimerWaitingConnection];
    
    self.automaticallyScrollsToMostRecentMessage = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_ROOM_LIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_DID_UPDATE_LOCATION object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_XMPP_STREAM_DID_DISCONNECT object:nil];
    
    // [self.inputToolbar.contentView.textView.h;
    
    
    
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.textViewNotificationObject];
    [[NSNotificationCenter defaultCenter] removeObserver:self.databaseConnectionDidUpdateNotificationObject];
    [[NSNotificationCenter defaultCenter] removeObserver:self.messageStateDidChangeNotificationObject];
    [[NSNotificationCenter defaultCenter] removeObserver:self.didFinishGeneratingPrivateKeyNotificationObject];
    
    // [self hideDropdownAnimated:animated completion:nil]; //zigzagcorp hide
    
    
    //Clear DSM
    [destroySecureMessage deleteAllSharedMessagesFromDic];
    
    //Cler Time Picker
    
    if(self.TP){
        [self.TP removeToView];
        [[self.TP getPickerView] removeFromSuperview];
        [[self.TP getTimeButtonView] removeFromSuperview];
        self.TP = nil;
    }
    


   
}

- (YapDatabaseConnection *)uiDatabaseConnection
{
    NSAssert([NSThread isMainThread], @"Must access uiDatabaseConnection on main thread!");
    if (!_uiDatabaseConnection) {
        YapDatabase *database = [OTRDatabaseManager sharedInstance].database;
        _uiDatabaseConnection = [database newConnection];
        [_uiDatabaseConnection beginLongLivedReadTransaction];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(yapDatabaseModified:)
                                                     name:YapDatabaseModifiedNotification
                                                   object:database];
    }
    return _uiDatabaseConnection;
    
    
}

- (NSArray*) indexPathsToCount:(NSUInteger)count {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
    
    
    
}





- (void)setBuddy:(OTRBuddy *)buddy
{
    OTRBuddy *originalBuddy = self.buddy;
    
    
    if ([originalBuddy.uniqueId isEqualToString:buddy.uniqueId]) {
        _buddy = buddy;
        
        //Update chatstate if it changed
        if (originalBuddy.chatState != self.buddy.chatState) {
            if (buddy.chatState == kOTRChatStateComposing || buddy.chatState == kOTRChatStatePaused) {
                self.showTypingIndicator = YES;
            }
            else {
                self.showTypingIndicator = NO;
            }
        }
        
        //Update title view if the status or username or display name have changed
        if (originalBuddy.status != self.buddy.status || ![originalBuddy.username isEqualToString:self.buddy.username] || ![originalBuddy.displayName isEqualToString:self.buddy.displayName]) {
            [self refreshTitleView];
        }
        
        
    } else {
        //different buddy
        [self saveCurrentMessageText];
        
        _buddy = buddy;
        if (self.buddy) {
            NSParameterAssert(self.buddy.uniqueId != nil);
            self.messageMappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[self.buddy.uniqueId] view:OTRChatDatabaseViewExtensionName];
            self.inputToolbar.contentView.textView.text = self.buddy.composingMessageString;
            
            [self.uiDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                _account = [self.buddy accountWithTransaction:transaction];
                [self.messageMappings updateWithTransaction:transaction];
            }];
            
            if ([self.account isKindOfClass:[OTRXMPPAccount class]]) {
                _xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:self.account];
            }
        } else {
            self.messageMappings = nil;
            _account = nil;
            _xmppManager = nil;
        }
        [self refreshTitleView];
        [self.collectionView reloadData];
    }
}

- (void)refreshTitleView
{
    
    OTRRoom *room;
    
    if(_isGroupChat){
        room = [OTRRoom roomById:self.buddy.username];
    }
    
    
    
    if ([self.buddy.displayName length]) {
        self.titleView.titleLabel.text = self.buddy.displayName;
    } else if(_isGroupChat){
        
        self.titleView.titleLabel.text  = [room roomName];
        
        
    } else {
        self.titleView.titleLabel.text = self.buddy.username;
    }
    
    if(_isGroupChat){
        
        self.titleView.subtitleLabel.text = room.roomAdmin;
        
    } else if(self.account.displayName.length) {
        self.titleView.subtitleLabel.text = self.account.displayName;
    }
    else {
        self.titleView.subtitleLabel.text = self.account.username;
    }
}

- (void)showErrorMessageForCell:(NSIndexPath *)indexPath
{
    OTRMessage *message = nil;
    if (indexPath) {
        message = [self messageAtIndexPath:indexPath];
    }
    
    if (message.error) {
        //  RIButtonItem *okButton = [RIButtonItem itemWithLabel:OK_STRING];
        
        //Повторная отправка сообщения
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Message Error (sending)"
                                                                       message:message.error.description
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:RESEND style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                       message.error=nil;
                                                       
                                                       [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                                                           [message saveWithTransaction:transaction];
                                                       } completionBlock:^{
                                                           // [[OTRKit sharedInstance] encodeMessage:message.text tlvs:nil username:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString tag:message];
                                                           
                                                           [self.xmppManager  sendMessage:(OTRMessage*)message];
                                                       }];
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       
                                                       DDLogInfo(@"OK %@", message);
                                                   }];
        
        UIAlertAction* cansel = [UIAlertAction actionWithTitle:CANCEL_STRING style:UIAlertActionStyleDefault
                                                       handler:nil];
        [alert addAction:ok];
        [alert addAction:cansel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

#pragma - mark titleView Methods

- (void)didTapTitleView:(id)sender
{
    /*
     
     #ifndef CHATSECURE_PUSH
     return;
     #endif
     void (^showPushDropDown)(void) = ^void(void) {
     UIButton *requestPushTokenButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [requestPushTokenButton setTitle:@"Request" forState:UIControlStateNormal];
     [requestPushTokenButton addTarget:self action:@selector(requestPushToken:) forControlEvents:UIControlEventTouchUpInside];
     
     UIButton *revokePushTokenButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [revokePushTokenButton setTitle:@"Revoke" forState:UIControlStateNormal];
     [revokePushTokenButton addTarget:self action:@selector(revokePushToken:) forControlEvents:UIControlEventTouchUpInside];
     
     UIButton *sendPushTokenButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [sendPushTokenButton setTitle:@"Send" forState:UIControlStateNormal];
     [sendPushTokenButton addTarget:self action:@selector(sendPushToken:) forControlEvents:UIControlEventTouchUpInside];
     
     
     [self showDropdownWithTitle:@"Push Token Actions" buttons:@[requestPushTokenButton,revokePushTokenButton,sendPushTokenButton] animated:YES tag:OTRDropDownTypePush];
     };
     
     if (!self.buttonDropdownView) {
     showPushDropDown();
     }
     else {
     if (self.buttonDropdownView.tag == OTRDropDownTypePush) {
     [self hideDropdownAnimated:YES completion:nil];
     }
     else {
     [self hideDropdownAnimated:YES completion:showPushDropDown];
     }
     }
     */
}


#pragma - mark lockButton Methods

- (void)setupLockButton
{
    OTRLockStatus status;
    
    if(_isGroupChat) {
        status = OTRStatusRoom;
        
        
        
    } else {
        status = OTRStatusChat;
    }
    
    
    
    self.lockButton = [OTRLockButton lockButtonWithInitailLockStatus:status withBlock:^(OTRLockStatus currentStatus) {
        
        void (^showEncryptionDropDown)(void) = ^void(void) {
            
            if(currentStatus == OTRStatusRoom){
                
                OTRRoomSettingsViewController *RSVC = [[OTRRoomSettingsViewController alloc] initWithBuddy:self.buddy];
                [self.navigationController pushViewController:RSVC animated:YES];
                
                
                
            }else if(currentStatus == OTRStatusChat){
                
                
                NSString *encryptionString = CLEAR_CHAT_HISTORY_STRING; //zigzagcorp
                
                
                NSArray * buttons = nil;
                
                
                NSString * title = nil;
                
                
                title = [NSString stringWithFormat:@"%@: %@", ACCOUNT_STRING, self.buddy.username];  //zigzagcorp title
                
                
                UIButton *encryptionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                encryptionButton.tintColor = [UIColor redColor];
                [encryptionButton setTitle:encryptionString forState:UIControlStateNormal];
                [encryptionButton addTarget:self action:@selector(encryptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                //Rename button zigzagcorp
                UIButton *renameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [renameButton setTitle:RENAME_STRING forState:UIControlStateNormal];
                [renameButton addTarget:self action:@selector(renameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                
                buttons = @[renameButton, encryptionButton];
                
                
                
                [self showDropdownWithTitle:title buttons:buttons animated:YES tag:OTRDropDownTypeEncryption];
                
            }
            
            
        };
        if (!self.buttonDropdownView) {
            showEncryptionDropDown();
        }
        else{
            if (self.buttonDropdownView.tag == OTRDropDownTypeEncryption) {
                [self hideDropdownAnimated:YES completion:nil];
            }
            else {
                [self hideDropdownAnimated:YES completion:showEncryptionDropDown];
            }
        }
        
        
    }];
    
    
    self.lockBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.lockButton];
    [self.navigationItem setRightBarButtonItem:self.lockBarButtonItem];
}

-(void)refreshLockButton
{
    /*
     [[OTRKit sharedInstance] checkIfGeneratingKeyForAccountName:self.account.username protocol:self.account.protocolTypeString completion:^(BOOL isGeneratingKey) {
     if( isGeneratingKey) {
     [self addLockSpinner];
     }
     else {
     UIBarButtonItem * rightBarItem = self.navigationItem.rightBarButtonItem;
     if ([rightBarItem isEqual:self.lockBarButtonItem]) {
     
     
     [[OTRKit sharedInstance] activeFingerprintIsVerifiedForUsername:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString completion:^(BOOL isTrusted) {
     
     [[OTRKit sharedInstance] hasVerifiedFingerprintsForUsername:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString completion:^(BOOL hasVerifiedFingerprints) { //zigzagcorp FINGER
     
     [[OTRKit sharedInstance] messageStateForUsername:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString completion:^(OTRKitMessageState messageState) {
     
     
     if (messageState == OTRKitMessageStateEncrypted && isTrusted) {
     self.lockButton.lockStatus = OTRLockStatusLockedAndVerified;
     }
     else if (messageState == OTRKitMessageStateEncrypted && hasVerifiedFingerprints)
     {
     self.lockButton.lockStatus = OTRLockStatusLockedAndError;
     }
     else if (messageState == OTRKitMessageStateEncrypted) {
     self.lockButton.lockStatus = OTRLockStatusLockedAndWarn;
     
     //DDLogInfo(@"HI PINGI %@", self.buddy.username);
     
     //Сохраняю автоматом отпечаток begin zigzagcorp
     
     [[OTRKit sharedInstance] setActiveFingerprintVerificationForUsername:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString verified:YES completion:^{
     [self refreshLockButton];
     }];
     //Сохраняю автоматом отпечаток end
     
     //   DDLogInfo(@"YO wuser %@, wuseracc %@, saccprot %@", self.buddy.username, self.account.username, self.account.protocolTypeString);
     
     }
     else {
     self.lockButton.lockStatus = OTRLockStatusUnlocked;
     */
    
    //Предлагаю шифровать сообщения автоматом zigzagcorp
    /*
     [[OTRKit sharedInstance] messageStateForUsername:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString completion:^(OTRKitMessageState messageState) {
     
     
     if (messageState != OTRKitMessageStateEncrypted) {
     
     [[OTRKit sharedInstance] initiateEncryptionWithUsername:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString];
     }
     
     
     }];
     */
    //Предлагаю шифровать сообщения автоматом End
    /*
     
     
     
     }
     
     }];
     
     }];
     
     }];
     }
     
     }
     
     }];
     
     */
}




- (void)didPresentAlertView:(UIAlertView *)alertView {
    
    
    // hack alert: fix bug in iOS 8 that prevents text field from appearing
    UITextRange *textRange = [[alertView textFieldAtIndex:0] selectedTextRange];
    [[alertView textFieldAtIndex:0] selectAll:nil];
    [[alertView textFieldAtIndex:0] setSelectedTextRange:textRange];
    
}



- (void)renameButtonPressed:(id)sender{
    
    [self.inputToolbar.contentView.textView resignFirstResponder]; //zigzagcorp keyboard
    
    
    DDLogInfo(@"renameButtonPressed");
    //self.inputToolbar.hidden=YES;
    
    
    
    [self hideDropdownAnimated:YES completion:nil]; //zigzagcorp hide
    
    NSString *name= self.buddy.displayName ? self.buddy.displayName : self.buddy.username;
    
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ %@", ENTER_NEW_NAME, name]
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:CANCEL_STRING
                                             otherButtonTitles:OK_STRING, nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    
    
    UITextField *input = [alertView textFieldAtIndex:0];
    
    input.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    //[input becomeFirstResponder];
    
    
    //[input resignFirstResponder];
    //[input removeFromSuperview];
    
    //  input.placeholder = NAME_STRING;
    
    
    
    [alertView show];
    
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self scrollToBottomAnimated:YES];
    
    
    if(buttonIndex == 1){
        
        UITextField *name = [alertView textFieldAtIndex:0];
        DDLogInfo(@"REname");
        
        id<OTRXMPPProtocol> protocol = (id<OTRXMPPProtocol>)[[OTRProtocolManager sharedInstance] protocolForAccount:self.account];
        [protocol setDisplayName:name.text forBuddy:self.buddy];
        
        if(![name.text isEqualToString:@""]){
            self.titleView.titleLabel.text = name.text;
        } else {
            self.titleView.titleLabel.text = self.buddy.username;
        }
    }
}

- (void)encryptionButtonPressed:(id)sender
{
 
    
    //zigzagcorp point
    
    
    /*
     NSDate *currentDate = [NSDate date];
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"dd.MM.yyyy HH:mm"];
     [formatter stringFromDate:currentDate]];
     */
    
    
    // OTRMessage *message = [[OTRMessage alloc] init];
    // message.text = @"Chat has been deleted...";
    // message.buddyUniqueId = self.buddy.uniqueId;
    //message.incoming = YES;
    
    
    
    [self hideDropdownAnimated:YES completion:nil];
    
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        [OTRMessage deleteAllMessagesForBuddyId:self.buddy.uniqueId transaction:transaction];
        //[message saveWithTransaction:transaction];
        
    }];
    
    self.allMessagesCach = nil;
    self.isPhotosLoading = nil;
    
    /*
     
     [[OTRKit sharedInstance] messageStateForUsername:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString completion:^(OTRKitMessageState messageState) {
     
     if (messageState == OTRKitMessageStateEncrypted) {
     [[OTRKit sharedInstance] disableEncryptionWithUsername:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString];
     }
     else {
     [[OTRKit sharedInstance] initiateEncryptionWithUsername:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString];
     }
     
     
     }];
     */
}

- (void)verifyButtonPressed:(id)sender
{
    [self hideDropdownAnimated:YES completion:nil];
    
    [[OTRKit sharedInstance] fingerprintForAccountName:self.account.username protocol:self.account.protocolTypeString completion:^(NSString *ourFingerprintString) {
        
        [[OTRKit sharedInstance] activeFingerprintForUsername:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString completion:^(NSString *theirFingerprintString) {
            
            [[OTRKit sharedInstance] activeFingerprintIsVerifiedForUsername:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString completion:^(BOOL verified) {
                
                
                UIAlertView * alert;
                __weak OTRMessagesViewController * welf = self;
                
                
                
                RIButtonItem * verifiedButtonItem = [RIButtonItem itemWithLabel:VERIFIED_STRING action:^{
                    [[OTRKit sharedInstance] setActiveFingerprintVerificationForUsername:welf.buddy.username accountName:welf.account.username protocol:self.account.protocolTypeString verified:YES completion:^{
                        [welf refreshLockButton];
                        
                    }];
                }]; //zigzagcorp
                
                RIButtonItem * notVerifiedButtonItem = [RIButtonItem itemWithLabel:NOT_VERIFIED_STRING action:^{
                    
                    [[OTRKit sharedInstance] setActiveFingerprintVerificationForUsername:welf.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString verified:NO completion:^{
                        [welf refreshLockButton];
                    }];
                }];
                
                RIButtonItem * verifyLaterButtonItem = [RIButtonItem itemWithLabel:VERIFY_LATER_STRING action:^{
                    [[OTRKit sharedInstance] setActiveFingerprintVerificationForUsername:welf.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString verified:NO completion:^{
                        [welf refreshLockButton];
                    }];
                }];
                
                if(ourFingerprintString && theirFingerprintString) {
                    NSString *msg = [NSString stringWithFormat:@"%@, %@:\n%@\n\n%@ %@:\n%@\n", YOUR_FINGERPRINT_STRING, self.account.username, ourFingerprintString, THEIR_FINGERPRINT_STRING, self.buddy.username, theirFingerprintString];
                    if(verified)
                    {
                        
                        alert = [[UIAlertView alloc] initWithTitle:VERIFY_FINGERPRINT_STRING message:msg cancelButtonItem:verifiedButtonItem otherButtonItems:notVerifiedButtonItem, nil];
                    }
                    else
                    {
                        alert = [[UIAlertView alloc] initWithTitle:VERIFY_FINGERPRINT_STRING message:msg cancelButtonItem:verifyLaterButtonItem otherButtonItems:verifiedButtonItem, nil];
                    }
                } else {
                    NSString *msg = SECURE_CONVERSATION_STRING;
                    alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:OK_STRING, nil];
                }
                
                [alert show];
                
            }];
            
        }];
        
    }];
    
    
    
}

#pragma - mark  dropDown Methods

- (void)showDropdownWithTitle:(NSString *)title buttons:(NSArray *)buttons animated:(BOOL)animated tag:(NSInteger)tag
{
    NSTimeInterval duration = 0.3;
    if (!animated) {
        duration = 0.0;
    }
    
    
    self.buttonDropdownView = [[OTRButtonView alloc] initWithTitle:title buttons:buttons];
    self.buttonDropdownView.tag = tag;
    
    self.buttonDropdownView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height+self.navigationController.navigationBar.frame.origin.y-44, self.view.bounds.size.width, 44);
    
    [self.view addSubview:self.buttonDropdownView];
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.buttonDropdownView.frame;
        frame.origin.y = self.navigationController.navigationBar.frame.size.height+self.navigationController.navigationBar.frame.origin.y;
        self.buttonDropdownView.frame = frame;
    } completion:nil];
    
}
- (void)hideDropdownAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    if (!self.buttonDropdownView) {
        if (completion) {
            completion();
        }
    }
    else {
        NSTimeInterval duration = 0.3;
        if (!animated) {
            duration = 0.0;
        }
        
        [UIView animateWithDuration:duration animations:^{
            CGRect frame = self.buttonDropdownView.frame;
            CGFloat navBarBottom = self.navigationController.navigationBar.frame.size.height+self.navigationController.navigationBar.frame.origin.y;
            frame.origin.y = navBarBottom - frame.size.height;
            self.buttonDropdownView.frame = frame;
            
        } completion:^(BOOL finished) {
            if (finished) {
                [self.buttonDropdownView removeFromSuperview];
                self.buttonDropdownView = nil;
            }
            
            if (completion) {
                completion();
            }
        }];
    }
}

- (void)saveCurrentMessageText
{
    if (!self.buddy) {
        return;
    }
    self.buddy.composingMessageString = self.inputToolbar.contentView.textView.text;
    if(![self.buddy.composingMessageString length])
    {
        [self.xmppManager sendChatState:kOTRChatStateInactive withBuddyID:self.buddy.uniqueId];
    }
}

- (OTRMessage *)messageAtIndexPath:(NSIndexPath *)indexPath
{
    
    OTRMessage * mediaMessage = [self getCachMessages:indexPath];
    
    if(mediaMessage){
        DDLogInfo(@"Return Media!!!");
        return mediaMessage;
        
    }
    
    
    
    __block OTRMessage *message = nil;
    [self.uiDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        YapDatabaseViewTransaction *viewTransaction = [transaction ext:OTRChatDatabaseViewExtensionName];
        NSParameterAssert(viewTransaction != nil);
        NSParameterAssert(self.messageMappings != nil);
        NSParameterAssert(indexPath != nil);
        NSUInteger row = indexPath.row;
        NSUInteger section = indexPath.section;
        
        NSAssert(row < [self.messageMappings numberOfItemsInSection:section], @"Cannot fetch message because row %d is >= numberOfItemsInSection %d", (int)row, (int)[self.messageMappings numberOfItemsInSection:section]);
        
        message = [viewTransaction objectAtRow:row inSection:section withMappings:self.messageMappings];
        NSParameterAssert(message != nil);
    }];
    
    
    //Begin location
    
    if(isMarkLocation(message.text) || message.unicLocationName){
        
        if(!message.unicLocationName) message.unicLocationName = message.text;
        
        struct locationXY loc = [OTRLocation OTRMessageToLocation:message.unicLocationName];
        
        CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
        
        
        JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
        [locationItem setLocation:ferryBuildingInSF withCompletionHandler:^{
            [self.collectionView reloadData];
        }];
        
        
        if(message.incoming) locationItem.appliesMediaViewMaskAsOutgoing = NO;
        
        message.text = nil;
        message.media = locationItem;
        
        
        [self cachMessages:message IndexPath:indexPath]; //Кинуть локацию в кеш
        
        return message;
        
    }
    
    
    
    //End location
    
    
    
    if(isMarkPhoto(message.text) ||  message.unicPhotoName){
        
        
        /*
         NSURL *photoURL = [NSURL URLWithString:@"https://safejab.com/showPhoto.php"];
         NSData *data = [NSData dataWithContentsOfURL:photoURL];
         UIImage *photo = [UIImage imageWithData:data];
         */
        if(!message.unicPhotoName) message.unicPhotoName = message.text;
        
        
        //Пытаемся взять фотото сообщение из кеша
        
        //  OTRMessage *photoMessage =  [self getPhotoFromCash: message.unicPhotoName];
        
        //   if(photoMessage) return photoMessage;
        
        
        UIImage *photo = nil;
        
        photo = [GetPhoto loadMiniImage:message.unicPhotoName];
        
        //  photo =  [self genMiniImage:photo];
        
        message.text = nil;
        
        
        // UIImage *photo = [self stringToUIImage:message.text];
        
        if(!photo && message.isIncoming){
            
            //   message.getPhoto = NO;
            GetPhoto *gp =  [self getPhotoLoading:indexPath];
            
            if(!gp){
                gp = [[GetPhoto alloc] init];
                [gp getPhotoFromServer:message.unicPhotoName];
                gp.linkToMessagesViewController = self; //zigzagcorp bug
                gp.message = message;
                [self setPhotoLoading:gp IndexPath:indexPath];
            }
            
            
        }
        
        
        
        
        
        //DDLogInfo(@"ZigTest: %@", message.text);
        
        
        
        //JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:photo];
        
        JSQPhotoMediaItem *photoItem = nil;
        
        
        photoItem = [[JSQPhotoMediaItem alloc] initWithImage:photo];
        
        
        
        if(message.incoming){
            
            photoItem.appliesMediaViewMaskAsOutgoing = NO;
        }
        
        
        
        message.media = photoItem;
        
        
        if(photo) [self cachMessages:message IndexPath:indexPath]; //Если фото существует то кинуть в кеш
        
        // self.testPhoto = (OTRMessage *)photoMessage;
        return  (OTRMessage *)message;
    }
    
    //Secur message
    destroySecureMessage *DSM = [destroySecureMessage addMessageToShared:message];
    if(DSM) return DSM.message;
    
    return message;
}

- (BOOL)showDateAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL showDate = NO;
    if (indexPath.row == 0) {
        showDate = YES;
    }
    else {
        OTRMessage *currentMessage = [self messageAtIndexPath:indexPath];
        OTRMessage *previousMessage = [self messageAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row-1 inSection:indexPath.section]];
        
        NSTimeInterval timeDifference = [currentMessage.date timeIntervalSinceDate:previousMessage.date];
        if (timeDifference > kOTRMessageSentDateShowTimeInterval) {
            showDate = YES;
        }
    }
    return showDate;
}

- (void)textViewDidChangeNotifcation:(NSNotification *)notification
{

    /*
     disabled
     
     
     zigzagcorp comment не отсылаем пока state что пишем другу сообщение
     
     JSQMessagesComposerTextView *textView = notification.object;
     if ([textView.text length]) {
     //typing
     [self.xmppManager sendChatState:kOTRChatStateComposing withBuddyID:self.buddy.uniqueId];
     }
     else {
     [self.xmppManager sendChatState:kOTRChatStateActive withBuddyID:self.buddy.uniqueId];
     //done typing
     }
     */
}

-(OTRMessage *)setPreviewUidPhoto:(NSString *)uid{
    
    OTRMessage *message = [[OTRMessage alloc] init];
    message.buddyUniqueId = self.buddy.uniqueId;
    message.text = uid;
    message.read = YES;
    message.transportedSecurely = NO;
    message.lifeTime = [self getTimeOption];
  
    
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [message saveWithTransaction:transaction];
    } completionBlock:^{
        // [[OTRKit sharedInstance] encodeMessage:message.text tlvs:nil username:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString tag:message];
    }];
    
    
    
    return message;
    
    
}


-(void)sendUidPhoto:(OTRMessage *)selfMessage{
    
    
    // grab the original image
    // UIImage *originalImage = [UIImage imageNamed:@"myImage.png"];
    // scaling set to 2.0 makes the image 1/2 the size.
    
    /*
     
     float width =  photo.size.width;
     float height =  photo.size.height;
     float new_height;
     
     
     if(width >= 100){
     
     new_height=(height*100)/width; // h1 = (h * w1)/w
     CGRect rect = CGRectMake(0, 0, 100, new_height);
     
     photo =  resizedImage(photo, rect);
     
     
     }
     
     
     
     //   [photo resizedImage]
     
     
     
     NSData *imageData = UIImageJPEGRepresentation(photo, 1.0);
     
     DDLogInfo(@"PHOTO ZZZZZZZZZ");
     
     // message.text = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
     
     
     //[imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
     *//*
        OTRMessage *message = [[OTRMessage alloc] init];
        message.buddyUniqueId = self.buddy.uniqueId;
        message.text = uid;
        message.read = YES;
        message.transportedSecurely = NO;
        */
    
    self.automaticallyScrollsToMostRecentMessage = YES;
    
    [self scrollToBottomAnimated:YES];
    
    
    
    NSString *timeOption = [self getTimeOption];
    

    
    
    
    if(timeOption){
        
        //Отправка фотографии с временем жизни
        [self.xmppManager sendTimeMessage:(OTRMessage*)selfMessage timeOption:timeOption];
    } else {
        //Обычная отправка
        [self.xmppManager  sendMessage:(OTRMessage*)selfMessage];
    }
    
    
    //[self.xmppManager  sendMessage:(OTRMessage*)selfMessage];
    // [[OTRKit sharedInstance] encodeMessage:selfMessage.text tlvs:nil username:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString tag:selfMessage];
    
    [self.collectionView reloadData];
    
}

-(void)initSendLocation {
    
    [self.location checkGps:self];
    [self.location startAndSend];
    
    
    //По уведомлению потом вызываем sendLocation
    
}


-(void)sendLocation {
    
    
    double latitude =  [OTRLocation sharedLocation].latitude;
    double longitude =  [OTRLocation sharedLocation].longitude;
    
    
    //location Latitude_longitude
    
    NSString *fullStrLocation = [NSString stringWithFormat:@"%@%f@_%f", MARK_LOCATION, latitude, longitude];
    
    OTRMessage *message = [[OTRMessage alloc] init];
    message.buddyUniqueId = self.buddy.uniqueId;
    message.text = fullStrLocation;
    message.read = YES;
    message.transportedSecurely = NO;
    
    NSString *timeOption = [self getTimeOption];
    message.lifeTime =timeOption;
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [message saveWithTransaction:transaction];
    } completionBlock:^{
        
        
      
        
        
        if(timeOption){
            //Отправка локации с временем жизни
            [self.xmppManager sendTimeMessage:message timeOption:timeOption];
        } else {
            //Обычная отправка
            [self.xmppManager  sendMessage:message];
        
        }
    }];
    
    
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressAccessoryButton:(UIButton *)sender
{

    
    DDLogInfo(@"GOOD");
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    AttachPhoto *ap = [[AttachPhoto alloc] initWithView:self];
    
    [ap pickButtonTap:self];
    
    /*
     VFPhotoActionSheet *photoActionSheet = [[VFPhotoActionSheet alloc] initWithViewController:self.navigationController];
     // photoActionSheet.delegate = nil;
     
     [photoActionSheet setLinkToBuddy:self];
     
     [self setDeleg:photoActionSheet];
     
     
     
     [self.delegate showWithDestructiveButton:NO];
     */
}



- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    self.automaticallyScrollsToMostRecentMessage = YES;
    
    if(![self isConnected]){
        //Если нет подключения не отправлять сообщение
        [self setTimerWaitingConnection];
        self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
        return;
    }
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    OTRMessage *message = [[OTRMessage alloc] init];
    message.buddyUniqueId = self.buddy.uniqueId;
    message.text = text;
    message.read = YES;
    message.transportedSecurely = NO;
   
    NSString *timeOption = [self getTimeOption];
    message.lifeTime = timeOption;
    
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [message saveWithTransaction:transaction];
    } completionBlock:^{
        
        
   
        
        
        if(timeOption){
            
            //Отправка с временем жизни
            [self.xmppManager sendTimeMessage:(OTRMessage*)message timeOption:timeOption];
        } else {
             //Обычная отправка
            [self.xmppManager  sendMessage:(OTRMessage*)message];
        }
        
        
        
        
        //  self.bodd
        
        // Нахуй мне этот OTR )))
        // [[OTRKit sharedInstance] encodeMessage:message.text tlvs:nil username:self.buddy.username accountName:self.account.username protocol:self.account.protocolTypeString tag:message];
    }];
    
    
    // DDLogInfo(@"CLICK BUTTON %@", [OTRKit sharedInstance]); //zigzagcorp log
    
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    
    OTRMessage *message = [self messageAtIndexPath:indexPath];
    
    if(message.isIncoming){
    
        destroySecureMessage * DSM = [destroySecureMessage getDSMessageById:message.messageId];
        
        if(DSM.message.messageId.length > 0){
           
          
    
            
            if([cell.cellBottomLabel subviews].count > 0){
                [[[cell.cellBottomLabel subviews] objectAtIndex:0] removeFromSuperview];
            }
            
            
          
                    // dispatch_async(dispatch_get_main_queue(), ^{
            if([cell.cellBottomLabel subviews].count == 0){
                
               dispatch_async(dispatch_get_main_queue(), ^{
                   
                   [UIView transitionWithView:cell.cellBottomLabel duration:0.3
                                      options:UIViewAnimationOptionTransitionCrossDissolve //change to whatever animation you like
                                   animations:^ {
                   
                   
                [cell.cellBottomLabel insertSubview:DSM.timerLabelForMessage atIndex:0];
                                       
                                   }
                                   completion:nil];
               });
            }
          //  });
            // if([cell.cellBottomLabel subviews].count == 0){
                /*
            [UIView transitionWithView:cell.cellBottomLabel duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve //change to whatever animation you like
                            animations:^ {
                                
                               
                                
                                    [cell.cellBottomLabel  addSubview:DSM.timerLabelForMessage];
                      
                               
                            }
                            completion:nil];
                 */
           // });
                 
               //   }
          
            
           
        } else if([cell.cellBottomLabel subviews].count > 0){
          //   dispatch_async(dispatch_get_main_queue(), ^{
            [[[cell.cellBottomLabel subviews] objectAtIndex:0] removeFromSuperview];
           //  });
        }
    
    }
    
    //ZIGTEST
  
    /*
    if(message.isIncoming){
    
        if(!self.lab){
            self.lab = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 60, 20)];
            self.lab.font = [UIFont systemFontOfSize:8];
            self.lab.textColor = [UIColor redColor];
            self.lab.text = @"12.12.2015";
        }
        

    
    [cell.cellBottomLabel addSubview:self.lab];
        
    }
     */
  //  [cell addSubview:lab];
    
    
    // if (message.error) {
    //     cell.errorImageView.image = [OTRImages warningImage];
    //  } else {
    //     cell.errorImageView.image = nil;
    //  }
    // [cell setMessage:message]; //zigzagcorp bugs
    
    
    //  if(message.error){
    //    UIImageView *errImg = [[UIImageView alloc] initWithImage:[OTRImages warningImage]];
    
    //    [cell.textView addSubview:errImg];
    // }
    
    
    
    
    
    if (!message.isMediaMessage) {
        
        
        
        if ([message.senderId isEqualToString:self.senderId]) {
            
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
        
        // cell.textView.delegate = self; ХЗ надо это или нет
        
    }   else {
        
        DDLogInfo(@"EvaXXX");
        
        /*
         if(!message.isGetPhoto){
         
         UIImage *photo = [GetPhoto loadImage:message.unicPhotoName];
         
         if(photo){
         
         DDLogInfo(@"GetPhoto loadImage");
         
         message.getPhoto = YES;
         
         
         JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:photo];
         
         
         if(message.incoming){
         photoItem.appliesMediaViewMaskAsOutgoing = NO;
         }
         
         message.media = photoItem;
         
         
         
         
         
         }
         
         }
         
         */
        
        /*
         
         UIImage *photo = [GetPhoto loadImage:message.text]
         
         JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:photo];
         message.media = photoItem;
         
         */
        
        
        //UIImage *photo = [GetPhoto loadImage:message.text];
        
        
        // if ([message.senderId isEqualToString:self.senderId]) {
        // message.media.appliesMediaViewMaskAsOutgoing = NO;
        
        // }
        
        
        //  JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"background"]];
        //  JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
        //                                                displayName:nil
        //                                                      media:photoItem];
        
        // message = (OTRMessage *)photoMessage;
        
        // JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"background"]];
        //JSQMessage *photoMessage = [JSQMessage messageWithSenderId:nil
        //                                displayName:nil
        //                                     media:photoItem];
        
        //cell.mediaView = photoMessage;
        //id<JSQMessageMediaData> messageMedia = [message media];
        //cell.mediaView = [messageMedia mediaView] ?: [messageMedia mediaPlaceholderView];
        //NSParameterAssert(cell.mediaView != nil);
    }
    
    
    
    
    
    //  cell.actionDelegate = self;
    
    // cell.layer.rasterizationScale = [UIScreen mainScreen].scale; //Ускоряем скролл
    //  cell.layer.shouldRasterize = YES;
    
    
    return cell;
}

#pragma - mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    [self hideDropdownAnimated:YES completion:nil];
}





/*
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 
 
 DDLogInfo(@"SSS %f", scrollView.contentOffset.y);
 }
 */

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfMessages = [self.messageMappings numberOfItemsInSection:section];
    return numberOfMessages;
}

#pragma - mark JSQMessagesCollectionViewCellDelegate Methods

- (void)messagesCollectionViewCellDidTapAvatar:(JSQMessagesCollectionViewCell *)cell {
    
}

- (void)messagesCollectionViewCellDidTapMessageBubble:(JSQMessagesCollectionViewCell *)cell {
    
    
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    
 
    
    DDLogInfo(@"Tapped message bubble!");
    OTRMessage *message = [self messageAtIndexPath:indexPath];
    

    
    if(message.error){
        
        [self showErrorMessageForCell:indexPath];
        
    } else if (message.securBody.length > 0 && message.isIncoming){
    
    
        destroySecureMessage *DSM =  [destroySecureMessage getDSMessageById:message.messageId];
        
        
        if(DSM){
            [DSM setExpireMessageIncoming];
        }
        
      //  NSLog(@"DSM %@",DSM);
       
        //Тут мы открываем секурное сообщение
        
      //  dispatch_async(dispatch_get_main_queue(), ^{
        
        
            
         //   if(DSMX){
         //       [DSMX setExpireMessageIncoming];
         //   }
        
      //  });
        
  
    } else if(message.unicPhotoName){
        
        self.automaticallyScrollsToMostRecentMessage = NO;    
        [self showBigPhoto:message.unicPhotoName];
        
    } else if(message.unicLocationName){
        
        struct locationXY curLoc =  [OTRLocation OTRMessageToLocation:message.unicLocationName];
        
        OTRMapViewController *mapViewController = [[OTRMapViewController alloc] initWithBigLocation:curLoc];
        [self.navigationController pushViewController:mapViewController animated:YES];
        
    }
    
}

- (void)messagesCollectionViewCellDidTapCell:(JSQMessagesCollectionViewCell *)cell atPosition:(CGPoint)position {
    
}

#pragma - mark JSQMessagesCollectionViewDataSource Methods

////// Required //////
- (NSString *)senderId
{
    NSString *senderId = nil;
    if (self.account) {
        senderId = self.account.uniqueId;
    } else {
        senderId = @"";
    }
    return senderId;
}

- (BOOL)isMediaMessage{
    DDLogInfo(@"isMediaMessageZORG");
    
    return NO;
}


- (NSUInteger)messageHash{
    DDLogInfo(@"messageHashZORG");
    return self.hash;
    // return self.buddy.uniqueId;
}


- (NSString *)senderDisplayName
{
    NSString *senderDisplayName = nil;
    if (self.account) {
        if ([self.account.displayName length]) {
            senderDisplayName = self.account.displayName;
        } else {
            senderDisplayName = self.account.username;
        }
    } else {
        senderDisplayName = @"";
    }
    
    return senderDisplayName;
}




- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
       messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self messageAtIndexPath:indexPath];
}


- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    
    OTRMessage *message = [self messageAtIndexPath:indexPath];
    
    if (message.isIncoming) {
        
        return self.incomingBubbleImageView;
        
        
    }
    
    return self.outgoingBubbleImageView;
    
    
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

////// Optional //////

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self showDateAtIndexPath:indexPath]) {
        OTRMessage *message = [self messageAtIndexPath:indexPath];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_isGroupChat) {
        
        OTRMessage *message = [self messageAtIndexPath:indexPath];
        
        /**
         *  iOS7-style sender name labels
         */
        if (!message.isIncoming) {
            return nil;
        }
        
        /*
         if (indexPath.item - 1 > 0) {
         JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
         if ([[previousMessage senderId] isEqualToString:message.senderId]) {
         return nil;
         }
         }
         */
        // message.senderDisplayName = @"wrwerw";
        /**
         *  Don't specify attributes to use the defaults.
         */
        
        NSString *fromGroupChatUser = message.groupChatUserJid ? message.groupChatUserJid : @"I will be named soon";
        
        return [[NSAttributedString alloc] initWithString:fromGroupChatUser];
    }
    
    return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    OTRMessage *message = [self messageAtIndexPath:indexPath];
    
    NSString * strTime = dateToStringWithMask(message.date, @"HH:mm");
    
    
    NSAttributedString *attributedString = nil;
    
    if(message.error){
        
        NSMutableParagraphStyle *paragrapStyle = NSMutableParagraphStyle.new;
        paragrapStyle.alignment                = NSTextAlignmentRight;
        
        attributedString = [NSAttributedString.alloc initWithString:
                            [NSString stringWithFormat:@"%@ %@", NOT_DELIVERED, strTime]
                                                         attributes: @{NSParagraphStyleAttributeName:paragrapStyle,
                                                                       NSForegroundColorAttributeName:[UIColor redColor]}];
        
        
    } else if (message.isDelivered) {
        
        NSMutableParagraphStyle *paragrapStyle = NSMutableParagraphStyle.new;
        paragrapStyle.alignment                = NSTextAlignmentRight;
        
        NSDictionary *attributes;
        
        if(message.lifeTime.length >0){
            attributes = @{NSParagraphStyleAttributeName:paragrapStyle,
                           NSForegroundColorAttributeName:[UIColor orangeColor]};
        } else {
            attributes = @{NSParagraphStyleAttributeName:paragrapStyle};
        }
        
        
        
        
        attributedString = [NSAttributedString.alloc initWithString:
                            [NSString stringWithFormat:@"%@ %@", DELIVERED_STRING, strTime]
                                                         attributes:attributes];
        
        
        
        
    } else {
        NSMutableParagraphStyle *paragrapStyle = NSMutableParagraphStyle.new;
        
        if (message.incoming){
            paragrapStyle.alignment = NSTextAlignmentLeft;
        } else {
            paragrapStyle.alignment = NSTextAlignmentRight;
        }
        
        NSDictionary *attributes;
        
        if(message.lifeTime.length >0 && !message.incoming){
            
            attributes = @{NSParagraphStyleAttributeName:paragrapStyle,
                           NSForegroundColorAttributeName:[UIColor orangeColor]};
        } else {
          attributes = @{NSParagraphStyleAttributeName:paragrapStyle};
        }
        
        
        attributedString = [NSAttributedString.alloc initWithString:strTime
                                                         attributes:attributes];
        
    }
    
    return attributedString;
}



#pragma - mark  JSQMessagesCollectionViewDelegateFlowLayout Methods

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    
    OTRMessage *message = [self messageAtIndexPath:indexPath];
    
    
    
    if(action == @selector(copy:) &&  !message.isMediaMessage){
        
        return YES;
        
    }
    
    
    if (action == @selector(delete:))
        
    {
        
        
        return YES;
    }
    
    
    
    
    
    return NO;
    
    
    
}


- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(delete:)) {
        [self delete:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}


- (BOOL)collectionView:(JSQMessagesCollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //  Enable menu for media messages
    OTRMessage *message = [self messageAtIndexPath:indexPath];
    
    if (message.isMediaMessage) {
        return YES;
    }
    
    
    return  [super collectionView:collectionView shouldShowMenuForItemAtIndexPath:indexPath];
}



- (void)messagesCollectionViewCell:(JSQMessagesCollectionViewCell *)cell didPerformAction:(SEL)action withSender:(id)sender
{
    DDLogInfo(@"XZ EVENT %@", sender);
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [textView becomeFirstResponder];
    
    
    [self scrollToBottomAnimated:YES];
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    //Тут я работаю над активацией кнопки отправка
    
  
    
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    
    
    if([self isConnected]) {
        [self.inputToolbar toggleSendButtonEnabled];
    } else {
        
        [self setTimerWaitingConnection];
        self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
    }
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self showDateAtIndexPath:indexPath]) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    // OTRMessage *message = [self messageAtIndexPath:indexPath];
    //if (message.isDelivered) {
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
    // }
    // return 0.0f;
}


- (void)messagesCollectionViewCellDidTapDelete:(JSQMessagesCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    
    
    
    
    
    __block OTRMessage *message = [self messageAtIndexPath:indexPath];
    
    if(message.isMediaMessage){
        DDLogInfo(@"Delete allMessagesCach");
        self.isPhotosLoading = nil;
        self.allMessagesCach = nil;
    }
    
    
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [message removeWithTransaction:transaction];
        deletePhotosWithPreview(message.unicPhotoName);
        
        //Update Last message date for sorting and grouping
        [self.buddy updateLastMessageDateWithTransaction:transaction];
        [self.buddy saveWithTransaction:transaction];
    }];
}

-(void)deleteMessage: (OTRMessage *)message {
    
    // __block OTRMessage *message;
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [message removeWithTransaction:transaction];
        
        deletePhotosWithPreview(message.unicPhotoName);
        
        //Update Last message date for sorting and grouping
        [self.buddy updateLastMessageDateWithTransaction:transaction];
        [self.buddy saveWithTransaction:transaction];
    }];
    
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    DDLogInfo(@"Tapped cell");
    
    [self.inputToolbar.contentView.textView resignFirstResponder]; //zigzagcorp keyboard
}

- (NSString *) reuseIdentifier {
    //Zigzagcorp это не используется
    return @"myIdentifier";
}




- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_isGroupChat){
        
        OTRMessage *message = [self messageAtIndexPath:indexPath];
        
        if(!message.isIncoming) return 0.0f;
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
        
    } else return 0.0f;
    
}
/*
 
 - (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapAvatarImageView:(UIImageView *)avatarImageView
 atIndexPath:(NSIndexPath *)indexPath
 {
 
 }
 
 
 - (void)collectionView:(JSQMessagesCollectionView *)collectionView
 header:(JSQMessagesLoadEarlierHeaderView *)headerView
 didTapLoadEarlierMessagesButton:(UIButton *)sender
 {
 
 }*/



#pragma mark - YapDatabaseNotificatino Method

- (void)yapDatabaseModified:(NSNotification *)notification
{
    // Process the notification(s),
    // and get the change-set(s) as applies to my view and mappings configuration.
    NSArray *notifications = [self.uiDatabaseConnection beginLongLivedReadTransaction];
    
    
    //TODO check if the view is not visible
    // If the view isn't visible, we might decide to skip the UI animation stuff.
    //    if ([self viewIsNotVisible])
    //    {
    //        // Since we moved our databaseConnection to a new commit,
    //        // we need to update the mappings too.
    //        [self.uiDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
    //            [self.messageMappings updateWithTransaction:transaction];
    //        }];
    //        return;
    //    }
    
    NSArray *messageRowChanges = nil;
    
    [[self.uiDatabaseConnection ext:OTRChatDatabaseViewExtensionName] getSectionChanges:nil
                                                                             rowChanges:&messageRowChanges
                                                                       forNotifications:notifications
                                                                           withMappings:self.messageMappings];
    
    
    BOOL buddyChanged = [self.uiDatabaseConnection hasChangeForKey:self.buddy.uniqueId inCollection:[OTRBuddy collection] inNotifications:notifications];
    if (buddyChanged)
    {
        __block OTRBuddy *updatedBuddy = nil;
        [self.uiDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            updatedBuddy = [OTRBuddy fetchObjectWithUniqueID:self.buddy.uniqueId transaction:transaction];
        }];
        self.buddy = updatedBuddy;
    }
    
    // When deleting messages/buddies we shouldn't animate the changes
    if (!self.buddy) {
        [self.collectionView reloadData];
        return;
    }
    
    
    
    //Changes in the messages add new one or deleted some
    if (messageRowChanges.count) {
        NSUInteger collectionViewNumberOfItems = [self.collectionView numberOfItemsInSection:0];
        NSUInteger numberMappingsItems = [self.messageMappings numberOfItemsInSection:0];
        
        
        
        
        if(numberMappingsItems > collectionViewNumberOfItems && numberMappingsItems > 0) {
            //Inserted new item, probably at the end
            //Get last message and test if isIncoming
            NSIndexPath *lastMessageIndexPath = [NSIndexPath indexPathForRow:numberMappingsItems - 1 inSection:0];
            OTRMessage *lastMessage = [self messageAtIndexPath:lastMessageIndexPath];
            if (lastMessage.isIncoming) {
                [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                self.automaticallyScrollsToMostRecentMessage = YES;
                [self finishReceivingMessage];
                
            } else {
                self.automaticallyScrollsToMostRecentMessage = YES;
                [self finishSendingMessage];
            }
        } else {
            //deleted a message or message updated
            [self.collectionView performBatchUpdates:^{
                
                for (YapDatabaseViewRowChange *rowChange in messageRowChanges)
                {
                    switch (rowChange.type)
                    {
                        case YapDatabaseViewChangeDelete :
                        {
                            //Чищу кеш фоток
                            self.allMessagesCach = nil;
                            self.isPhotosLoading = nil;
                            
                            [self.collectionView deleteItemsAtIndexPaths:@[rowChange.indexPath]];
                            break;
                        }
                        case YapDatabaseViewChangeInsert :
                        {
                            [self.collectionView insertItemsAtIndexPaths:@[ rowChange.newIndexPath ]];
                            
                            break;
                        }
                        case YapDatabaseViewChangeMove :
                        {
                            [self.collectionView moveItemAtIndexPath:rowChange.indexPath toIndexPath:rowChange.newIndexPath];
                            break;
                        }
                        case YapDatabaseViewChangeUpdate :
                        {
                            [self.collectionView reloadItemsAtIndexPaths:@[ rowChange.indexPath]];
                            break;
                        }
                    }
                }
            } completion:nil];
        }
    }
}



#pragma mark - UIResponder


- (BOOL)canBecomeFirstResponder
{
    return YES;
}


#pragma mark - Обновление при повороте экрана



-(void) viewWillLayoutSubviews {

    [super  viewWillLayoutSubviews];
    //UpdatePicker
    if(self.TP){
       
        [self.TP updateFramesCustomView];
        [self.TP genTimeButtom:(UITextField *)self.inputToolbar.contentView.textView];
     
  // [self.TP updateFramesCustomView];
 
  //  [self.TP genTimeButtom:(UITextField *)self.inputToolbar.contentView.textView];
    
    }
    
    
    
  //  [self.TP updateFramesCustomView];
 // [self.TP genTimeButtom:(UITextField *)self.inputToolbar.contentView.textView];
 //   UIEdgeInsets edge = self.inputToolbar.contentView.textView.textContainerInset;
  //  self.inputToolbar.contentView.textView.textContainerInset = UIEdgeInsetsMake(edge.top, edge.left, edge.bottom, (20));
    
}

#pragma mark - mini actions

-(void)reloadDataForCollectionView{
    [self.collectionView reloadData];
}

-(NSString *)getTimeOption{
    NSString *timeOption = nil;
    
    if(self.TP){
        timeOption = [self.TP getSelectedOption];
        
    } else {
        timeOption = nil;
    }
    
    return timeOption;
}


@end
