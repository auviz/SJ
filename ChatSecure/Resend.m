//
//  Resend.m
//  SafeJab
//
//  Created by Самсонов Александр on 06.05.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "Resend.h"
#import "OTRLog.h"

@implementation Resend


-(id)init
{
    if(self = [super init]){
        return self;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    DDLogInfo(@"Кнопка - %@ - была нажата.", [alertView buttonTitleAtIndex:buttonIndex]);
    
    
}

@end
