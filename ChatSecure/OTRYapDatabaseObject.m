//
//  OTRYapDatabaseObject.m
//  Off the Record
//
//  Created by David Chiles on 3/28/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRYapDatabaseObject.h"
#import "OTRMessage.h"

@interface OTRYapDatabaseObject ()

@property (nonatomic, strong) NSString *uniqueId;

@end

@implementation OTRYapDatabaseObject

- (id)init
{
    if (self = [super init])
    {
        self.uniqueId = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (instancetype)initWithUniqueId:(NSString *)uniqueId
{
    if (self = [super init]) {
        self.uniqueId = uniqueId;
    }
    return self;
}

-(void)setOTRMessageUniqueId{
    
   
    
    if([self isKindOfClass:[OTRMessage class]]){
        
        OTRMessage * message = (OTRMessage *) self;
        
        if(message.messageId.length > 0){
            self.uniqueId = message.messageId;
        }
        
        
    }
    
}

- (void)saveWithTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    //Мое катомное дермо (для того чтоб идентификатор в совподал с id сообщения)
    [self setOTRMessageUniqueId];
    
    [transaction setObject:self forKey:self.uniqueId inCollection:[[self class] collection]];
}

- (void)removeWithTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    [transaction removeObjectForKey:self.uniqueId inCollection:[[self class] collection]];
}

#pragma - mark Class Methods

+ (NSString *)collection
{
    return NSStringFromClass([self class]);
}


+ (instancetype) fetchObjectWithUniqueID:(NSString *)uniqueID transaction:(YapDatabaseReadTransaction *)transaction {
    return [transaction objectForKey:uniqueID inCollection:[self collection]];
}

@end
