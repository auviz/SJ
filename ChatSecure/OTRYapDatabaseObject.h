//
//  OTRYapDatabaseObject.h
//  Off the Record
//
//  Created by David Chiles on 3/28/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YapDatabaseRelationshipNode.h"
#import "YapDatabaseTransaction.h"
#import "MTLModel+NSCoding.h"


@interface OTRYapDatabaseObject : MTLModel

@property (nonatomic, readonly) NSString *uniqueId;

- (instancetype)initWithUniqueId:(NSString *)uniqueId;

- (void)saveWithTransaction:(YapDatabaseReadWriteTransaction *)transaction;
- (void)removeWithTransaction:(YapDatabaseReadWriteTransaction *)transaction;
-(void)setUniqueId:(NSString *)uniqueId;

+ (NSString *)collection;

+ (instancetype)fetchObjectWithUniqueID:(NSString*)uniqueID transaction:(YapDatabaseReadTransaction*)transaction;

@end
