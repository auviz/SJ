//
//  OTRAccountTableViewCell.h
//  Off the Record
//
//  Created by David Chiles on 11/27/13.
//  Copyright (c) 2013 Chris Ballinger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTRProtocol.h"

@class OTRAccount;

const float heightAccountTableViewCel = 66;
const float paddingAccountTableViewCel = 10;

@interface OTRAccountTableViewCell : UITableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)identifier;
- (void)setAccount:(OTRAccount *)account;
- (void)setConnectedText:(OTRProtocolConnectionStatus)connectionStatus;



@end
