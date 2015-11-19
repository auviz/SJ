//
//  OTRDeleteAllChats.m
//  SafeJab
//
//  Created by Самсонов Александр on 12.02.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "OTRDeleteAllChats.h"
#import "Strings.h"

@implementation OTRDeleteAllChats

@dynamic delegate;

-(id)initWithTitle:(NSString *)newTitle description:(NSString *)newDescription
{
    self = [super initWithTitle:newTitle description:newDescription];
    if (self) {
        __weak typeof (self) weakSelf = self;
        self.actionBlock = ^{
            [weakSelf openDeleteAllDialog];
        };
    }
    return self;
}

- (void) openDeleteAllDialog {
    if (self.delegate) {
        [self.delegate deleteAllChatsPressed:self];
    }
}
@end
