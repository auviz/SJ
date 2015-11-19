//
//  OTRMessage+JSQMessageData.m
//  Off the Record
//
//  Created by David Chiles on 5/12/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

//zigzagcorp mes option

#import "OTRMessage+JSQMessageData.h"
#import "OTRDatabaseManager.h"
#import "OTRBuddy.h"
#import "OTRAccount.h"
#import "OTRLog.h"

@implementation OTRMessage (JSQMessageData)



- (NSString *)senderId
{
    __block NSString *sender = @"";
    [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        OTRBuddy *buddy = [self buddyWithTransaction:transaction];
        if (self.isIncoming) {
            sender = buddy.uniqueId;
           
            //NSParameterAssert(self.senderId != nil);
            //NSParameterAssert(self.senderDisplayName != nil);
        }
        else {
            OTRAccount *account = [buddy accountWithTransaction:transaction];
            sender = account.uniqueId;
        }
        
    }];
    return sender;
}

- (BOOL)isMediaMessage{
   // DDLogInfo(@"isMediaMessage"); /9j/

    
  //  BOOL isOTRMes;
    
  /*
    if([self.text length] > 4){

        if([[self.text substringToIndex:4] isEqualToString:@"/9j/"]){
            
            DDLogInfo(@"TRUE isMediaMessage");
            
            return YES;
            
        } else return NO;
        
       
    }
    
   return NO;
   */
    
    if(self.text) {
        return NO;
    } else {
        return YES;
    }
    
}


- (NSUInteger)messageHash{
    
    
    
    
    
    // DDLogInfo(@"messageHash %lu", (unsigned long)self.hash);
     return [self hash];
    
}


- (NSString *)senderDisplayName {
    __block NSString *sender = @"";
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        OTRBuddy *buddy = [self buddyWithTransaction:transaction];
        if (self.isIncoming) {
            if ([buddy.displayName length]) {
                sender = buddy.displayName;
            }
            else {
                sender = buddy.username;
            }
        }
        else {
            OTRAccount *account = [buddy accountWithTransaction:transaction];
            if ([account.displayName length]) {
                sender = account.displayName;
            }
            else {
                sender = account.username;
            }
        }
    }];
    return sender;
}







@end
