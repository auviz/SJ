//
//  OTRAccount.h
//  Off the Record
//
//  Created by David Chiles on 3/28/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRYapDatabaseObject.h"
#import "OTRProtocol.h"

typedef NS_ENUM(int, OTRAccountType) {
    OTRAccountTypeNone        = 0,
    OTRAccountTypeFacebook    = 1,
    OTRAccountTypeGoogleTalk  = 2,
    OTRAccountTypeJabber      = 3,
    OTRAccountTypeAIM         = 4,
    OTRAccountTypeXMPPTor     = 5,
    OTRAccountTypeSecurName = 6
};

//typedef OTRAccountType *OTRAccountTypeSecurName = 3;

extern NSString *const OTRAimImageName;
extern NSString *const OTRGoogleTalkImageName;
extern NSString *const OTRXMPPImageName;
extern NSString *const OTRXMPPTorImageName;
extern NSString *const securImage;

@interface OTRAccount : OTRYapDatabaseObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, readonly) OTRAccountType accountType;
@property (nonatomic, strong) NSString *username;
@property (nonatomic) BOOL rememberPassword;
@property (nonatomic) BOOL autologin;
@property (nonatomic) BOOL isSecurName; //zigzagcorp decur



@property (nonatomic, strong) NSString *password;


- (id)initWithAccountType:(OTRAccountType)accountType;
- (id)initWithAccountTypeSecurName:(OTRAccountType)accountType;

- (Class)protocolClass;
- (UIImage *)accountImage;
- (OTRProtocolType)protocolType;
- (NSString *)accountDisplayName;
- (NSString *)protocolTypeString;

- (NSArray *)allBuddiesWithTransaction:(YapDatabaseReadTransaction *)transaction;

+ (OTRAccount *)accountForAccountType:(OTRAccountType)accountType;
+ (NSArray *)allAccountsWithUsername:(NSString *)username transaction:(YapDatabaseReadTransaction*)transaction;
+ (NSArray *)allAccountsWithTransaction:(YapDatabaseReadTransaction*)transaction;

@end
