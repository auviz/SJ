//
//  OTRConversationCell.m
//  Off the Record
//
//  Created by David Chiles on 3/3/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//
#import "OTRConversationCell.h"
#import "OTRBuddy.h"
#import "OTRAccount.h"
#import "OTRMessage.h"
#import "OTRDatabaseManager.h"
#import "YapDatabaseConnection.h"
#import "YapDatabaseTransaction.h"
#import "SetGlobVar.h"
#import "OTRRoom.h"
#import "Strings.h"

@interface OTRConversationCell ()

@property (nonatomic, strong) NSArray *verticalConstraints;
@property (nonatomic, strong) NSArray *accountHorizontalConstraints;

@end

@implementation OTRConversationCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.showAccountLabel = NO;
        
        UIColor *darkGreyColor = [UIColor colorWithWhite:.45 alpha:1.0];
        UIColor *lightGreyColor = [UIColor colorWithWhite:.6 alpha:1.0];
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        self.dateLabel.textColor = darkGreyColor;
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]+2.0];
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.nameLabel.textColor = darkGreyColor;
        
        self.conversationLabel = [[UILabel alloc] init];
        self.conversationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.conversationLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.conversationLabel.numberOfLines = 0;
        self.conversationLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        self.conversationLabel.textColor = lightGreyColor;
        
        
        
      
        
  
        
        self.notReadCountLabel = [[UILabel alloc] init];
        
        
        UIColor *defColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:0.8 alpha:1.0];
        
       self.notReadCountLabel.layer.masksToBounds = YES;
        self.notReadCountLabel.layer.backgroundColor = defColor.CGColor;
         self.notReadCountLabel.layer.cornerRadius = 8.0;
       // self.notReadCountLabel.layer.cornerRadius = 3;
     //   self.notReadCountLabel.layer.borderWidth = 1.0;
     //   self.notReadCountLabel.layer.borderColor = [UIColor greenColor].CGColor;
        self.notReadCountLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.notReadCountLabel.textColor = [UIColor whiteColor];
      //  self.notReadCountLabel.backgroundColor = [UIColor blueColor];
        self.notReadCountLabel.translatesAutoresizingMaskIntoConstraints = NO;

      

        
        self.accountLabel = [[UILabel alloc] init];
        self.accountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.conversationLabel];
        [self.contentView addSubview:self.notReadCountLabel];
        
    }
    return self;
}

- (void)setShowAccountLabel:(BOOL)showAccountLabel
{
    _showAccountLabel = showAccountLabel;
    
    if (!self.showAccountLabel) {
        [self.accountLabel removeFromSuperview];
    }
    else {
        [self.contentView addSubview:self.accountLabel];
    }
}

- (void)setBuddy:(OTRBuddy *)buddy
{
   
  

    
    [super setBuddy:buddy];
    
    OTRRoom * room;
    
    
    
    NSString * nameString = nil;
    
    
 if (buddy.displayName.length) {
     
        nameString = buddy.displayName;
     
 } else if(super.isGroupChat){
     

     
     room = [OTRRoom roomById:buddy.username];
     nameString = [room roomName];
     
     // OTRRoom *room = [OTRRoom roomById: (NSString* )roomId];
     
 }
    else {
        nameString = buddy.username;
    }
    
    
    
    self.nameLabel.text = nameString;
    
    __block OTRAccount *account = nil;
    __block OTRMessage *lastMessage = nil;
        __block NSInteger* notReadCount = 0;
    
    [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        account = [transaction objectForKey:buddy.accountUniqueId inCollection:[OTRAccount collection]];
        
    
        
        lastMessage = [buddy lastMessageWithTransaction:transaction];
        
        if(isMarkPhoto(lastMessage.text)){ //Если сообщение фотография подменить текст zigzagcorp replace
            lastMessage.text = @"Photo";
        } else if (isMarkLocation(lastMessage.text)){
             lastMessage.text = @"Location";
        } if(lastMessage.securBody.length > 0 && lastMessage.incoming) {
            lastMessage.text = @"🔒";
        }
        

        
        notReadCount = [OTRMessage countUnreadMessagesForBuddyId:buddy.uniqueId transaction:transaction];
        
    }];
    
    
    if (notReadCount > 0) {
        self.notReadCountLabel.text=[NSString stringWithFormat:@" %d ", (int)notReadCount];
    }
    else {
        self.notReadCountLabel.text=nil;
    }
    



    
    self.accountLabel.text = account.username;
    
    UIFont *currentFont = self.conversationLabel.font;
    CGFloat fontSize = currentFont.pointSize;
    
    
    if(!lastMessage.text && super.isGroupChat){
        
        if(!room) room = [OTRRoom roomById:buddy.username];
        
        if([account.username isEqualToString:room.roomAdmin]){
            self.conversationLabel.text = YOU_ARE_THE_ADMINISTRATOR_OF_THE_ROOM;
        } else {
            self.conversationLabel.text = [NSString stringWithFormat:@"%@\n%@", room.roomAdmin, OWNER_OF_THIS_ROOM];
        }
        
        
    } else {
            self.conversationLabel.text =  lastMessage.text;
    }
        
        
      
        
            
    
    
    

  
    
    
    if (!lastMessage.isRead) {
        //unread message
        self.nameLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        self.nameLabel.textColor = [UIColor blackColor];
        
    }
    else {
        self.nameLabel.font = [UIFont systemFontOfSize:fontSize];
        self.nameLabel.textColor = [UIColor colorWithWhite:.45 alpha:1.0];
    }
    self.dateLabel.textColor = self.nameLabel.textColor;
    
    [self updateDateString:lastMessage.date];
}

- (void)updateDateString:(NSDate *)date
{
    self.dateLabel.text = [self dateString:date];
}

- (NSString *)dateString:(NSDate *)messageDate
{
    NSTimeInterval timeInterval = fabs([messageDate timeIntervalSinceNow]);
    NSString * dateString = nil;
    if (timeInterval < 60){
        dateString = @"Now";
    }
    else if (timeInterval < 60*60) {
        int minsInt = timeInterval/60;
        NSString * minString = @"mins";
        if (minsInt == 1) {
            minString = @"min";
        }
        dateString = [NSString stringWithFormat:@"%d %@",minsInt,minString];
    }
    else if (timeInterval < 60*60*24){
        // show time in format 11:00 PM
        dateString = [NSDateFormatter localizedStringFromDate:messageDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    }
    else if (timeInterval < 60*60*24*7) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEE" options:0 locale:[NSLocale currentLocale]];
        dateString = [dateFormatter stringFromDate:messageDate];
        
    }
    else if (timeInterval < 60*60*25*365) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dMMM" options:0
                                                                    locale:[NSLocale currentLocale]];
        dateString = [dateFormatter stringFromDate:messageDate];
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dMMMYYYY" options:0
                                                                    locale:[NSLocale currentLocale]];
        dateString = [dateFormatter stringFromDate:messageDate];
    }
    
    
    
    return dateString;
}

- (void)updateConstraints
{
    NSDictionary *views = @{@"imageView": self.avatarImageView,
                            @"conversationLabel": self.conversationLabel,
                            @"dateLabel":self.dateLabel,
                            @"nameLabel":self.nameLabel,
                            @"conversationLabel":self.conversationLabel,
                            @"accountLabel":self.accountLabel,
                            @"notReadCountLabel":self.notReadCountLabel};
    
    NSDictionary *metrics = @{@"margin":[NSNumber numberWithFloat:OTRBuddyImageCellPadding]};
    if (!self.addedConstraints) {
        
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView]-margin-[nameLabel]->=0-[dateLabel]-margin-|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView]-margin-[conversationLabel]->=0-[notReadCountLabel(>=11)]-margin-|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[dateLabel]-margin-[notReadCountLabel]" options:0 metrics:metrics
                                                                                   views:views]];
        
        
    }
    
    if([self.accountHorizontalConstraints count])
    {
        [self.contentView removeConstraints:self.accountHorizontalConstraints];
    }
    
    if([self.verticalConstraints count]) {
        [self.contentView removeConstraints:self.verticalConstraints];
    }
    
    if (self.showAccountLabel) {
        self.accountHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView]-margin-[accountLabel]|"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:views];
        
        self.verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[nameLabel][conversationLabel][accountLabel]-margin-|"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:views];
        
    }
    else {
        self.accountHorizontalConstraints = @[];
        
        self.verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[nameLabel(15)][conversationLabel]-margin-|"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:views];
    }
    if([self.accountHorizontalConstraints count]) {
        [self.contentView addConstraints:self.accountHorizontalConstraints];
    }
    
    [self.contentView addConstraints:self.verticalConstraints];
    [super updateConstraints];
}

@end