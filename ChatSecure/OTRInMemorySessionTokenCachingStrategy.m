//
//  OTRInMemorySessionTokenCachingStrategy.m
//  ChatSecure
//
//  Created by David Chiles on 10/1/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRInMemorySessionTokenCachingStrategy.h"

@interface OTRInMemorySessionTokenCachingStrategy ()

@property (nonatomic, strong) NSDictionary *tokenDictionary;

@end

@implementation OTRInMemorySessionTokenCachingStrategy

- (instancetype)initWithToken:(NSString *)token
{
   // if (self = [self init]) {
    //    self.tokenDictionary = [token dictionary];
   // }
    return nil;
}

- (void)cacheTokenInformation:(NSDictionary *)tokenInformation
{
    self.tokenDictionary = tokenInformation;
}

- (NSDictionary *)fetchTokenInformation
{
    return self.tokenDictionary;
}

- (void)clearToken
{
    self.tokenDictionary = nil;
}

@end
