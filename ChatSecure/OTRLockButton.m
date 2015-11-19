//
//  OTRLockButton.m
//  Off the Record
//
//  Created by David Chiles on 2/10/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRLockButton.h"
#import "UIControl+JTTargetActionBlock.h"


static NSString *const kOTRStatusRoom            = @"iconAboutRoom";
static NSString *const kOTRUnlockImageName          = @"iconAboutPerson"; //new zigzagcorp




@implementation OTRLockButton

- (void)setLockStatus:(OTRLockStatus)lockStatus
{
    UIImage * backgroundImage = nil;
    
    switch (lockStatus) {
        case OTRStatusRoom:
            backgroundImage = [UIImage imageNamed:kOTRStatusRoom];
            break;
        case OTRStatusChat:
            backgroundImage = [UIImage imageNamed:kOTRUnlockImageName];
            break;
        default:
            backgroundImage = [UIImage imageNamed:kOTRUnlockImageName];
            break;
    }
    
    CGRect buttonFrame = [self frame];
    
    buttonFrame.size.width = backgroundImage.size.width;
    buttonFrame.size.height = backgroundImage.size.height;
    [self setFrame:buttonFrame];
    
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(lockStatus))];
    _lockStatus = lockStatus;
    [self didChangeValueForKey:NSStringFromSelector(@selector(lockStatus))];
}

+(instancetype)lockButtonWithInitailLockStatus:(OTRLockStatus)lockStatus withBlock:(void(^)(OTRLockStatus currentStatus))block
{
    OTRLockButton * lockButton = [self buttonWithType:UIButtonTypeCustom];
    lockButton.lockStatus = lockStatus;
    //  /*
    //  zigzagcorp coment
    [lockButton addEventHandler:^(id sender, UIEvent *event) {
        if (block) {
            OTRLockStatus status = OTRLockStatusUnknown;
            if ([sender isKindOfClass:[OTRLockButton class]]) {
                status = ((OTRLockButton *)sender).lockStatus;
            }
            
            block(status);
        }
    } forControlEvent:UIControlEventTouchUpInside];
    //  */
    return lockButton;
}
@end
