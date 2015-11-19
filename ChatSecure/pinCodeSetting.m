//
//  pinCodeSetting.m
//  SafeJab
//
//  Created by Самсонов Александр on 26.02.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "pinCodeSetting.h"
#import "OTRDatabaseUnlockViewController.h"

@implementation pinCodeSetting

- (id)initWithTitle:(NSString *)newTitle description:(NSString *)newDescription {
    self = [super initWithTitle:newTitle description:newDescription viewControllerClass:[OTRDatabaseUnlockViewController class]];
    return self;
}

@end

