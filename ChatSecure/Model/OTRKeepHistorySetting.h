//
//  OTRKeepHistorySetting.h
//  SafeJab
//
//  Created by Самсонов Александр on 08.04.16.
//  Copyright © 2016 Leader Consult. All rights reserved.
//

#import "OTRSetting.h"

@class OTRKeepHistorySetting;

@protocol OTRKeepHistorySettingDelegate <OTRSettingDelegate>
- (void) setKeepHistory:(OTRKeepHistorySetting*)setting;
@end

@interface OTRKeepHistorySetting : OTRSetting

@property (nonatomic, weak) id<OTRKeepHistorySettingDelegate> delegate;

@property (nonatomic, weak) NSString * option;


@end
