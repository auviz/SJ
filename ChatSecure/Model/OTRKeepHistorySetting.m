//
//  OTRKeepHistorySetting.m
//  SafeJab
//
//  Created by Самсонов Александр on 08.04.16.
//  Copyright © 2016 Leader Consult. All rights reserved.
//

#import "OTRKeepHistorySetting.h"
#import "dbHistoryOption.h"
#import "historyPicker.h"

@implementation OTRKeepHistorySetting

@dynamic delegate;

-(id)initWithTitle:(NSString *)newTitle description:(NSString *)newDescription
{
    self = [super initWithTitle:newTitle description:newDescription];
    if (self) {
        __weak typeof (self) weakSelf = self;
        self.actionBlock = ^{
            [weakSelf openKeepHistorySetting];
        };
    }
    
   
    
    self.option =  [historyPicker valueFromKey:[dbHistoryOption get]];
    
    return self;
}

- (void) openKeepHistorySetting {
    if (self.delegate) {
        [self.delegate setKeepHistory:self];
    }
}
@end
