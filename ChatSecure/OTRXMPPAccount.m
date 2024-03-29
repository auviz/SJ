//
//  OTRXMPPAccount.m
//  Off the Record
//
//  Created by David Chiles on 3/28/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRXMPPAccount.h"
#import "OTRXMPPManager.h"
#import "Strings.h"
#import "OTRConstants.h"
#import "OTRImages.h"
#import "OTRXMPPManager.h"
#import "OTRProtocolManager.h"
#import "SetGlobVar.h"



static NSUInteger const OTRDefaultPortNumber = 5222;

@implementation OTRXMPPAccount

- (id)init
{
    if (self = [super init]) {
        self.port = [OTRXMPPAccount defaultPort];
        self.resource = [OTRXMPPAccount newResource];
      
    }
    return self;
}

- (OTRProtocolType)protocolType
{
    return OTRProtocolTypeXMPP;
}

- (NSString *)protocolTypeString
{
    return kOTRProtocolTypeXMPP;
}

- (UIImage *)accountImage
{

    
    
    
        OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:self];
    

    
   UIImage *ava = [OTRImages avatarImageWithUniqueIdentifier:nil avatarData:xmppManager.myVCard.photoData displayName:nil username:self.username];
    
    if(ava){
        return ava;
    }else if(self.isSecurName){ //zigzagcorp disp img
         return [UIImage imageNamed:securImage];
    } else {
        return [UIImage imageNamed:OTRXMPPImageName];
    }
    
    
}
- (NSString *)accountDisplayName
{
    if(self.isSecurName){ //zigzagcorp disp name
      return SECUR_STRING;
    } else {
    return JABBER_STRING;
    }
}

- (Class)protocolClass {
    return [OTRXMPPManager class];
}

#pragma - mark Class Methods

+ (NSString *)collection
{
    return NSStringFromClass([OTRAccount class]);
}

+ (int)defaultPort
{
    return OTRDefaultPortNumber;
}

+ (instancetype)accountForStream:(XMPPStream *)stream transaction:(YapDatabaseReadTransaction *)transaction
{
    id xmppAccount = nil;
    if([stream.tag isKindOfClass:[NSString class]]) {
        
        xmppAccount = [self fetchObjectWithUniqueID:stream.tag transaction:transaction];
    }
    return xmppAccount;
}

+ (NSString * )newResource
{
    int r = arc4random() % 99999;
    return [NSString stringWithFormat:@"%@%d",kOTRXMPPResource,r];
}

+ (NSDictionary*) encodingBehaviorsByPropertyKey {
    
    
    NSMutableDictionary *encodingBehaviors = [NSMutableDictionary dictionaryWithDictionary:[super encodingBehaviorsByPropertyKey]];
    [encodingBehaviors setObject:@(MTLModelEncodingBehaviorExcluded) forKey:NSStringFromSelector(@selector(accountSpecificToken))];
    [encodingBehaviors setObject:@(MTLModelEncodingBehaviorExcluded) forKey:NSStringFromSelector(@selector(oAuthTokenDictionary))];
    return encodingBehaviors;
}


@end
