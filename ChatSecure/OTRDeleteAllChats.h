//
//  OTRDeleteAllChats.h
//  SafeJab
//
//  Created by Самсонов Александр on 12.02.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "OTRSetting.h"

@class OTRDeleteAllChats;

@protocol OTRDeleteAllChatsDelegate <OTRSettingDelegate>
- (void) deleteAllChatsPressed:(OTRDeleteAllChats*)setting;
@end

@interface OTRDeleteAllChats : OTRSetting

@property (nonatomic, weak) id<OTRDeleteAllChatsDelegate> delegate;

@end
