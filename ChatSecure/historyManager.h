//
//  historyManager.h
//  SafeJab
//
//  Created by Самсонов Александр on 13.04.16.
//  Copyright © 2016 Leader Consult. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface historyManager : NSObject

-(void)setHistoryOptionOnServer: (NSString *)value;

-(void)getHistoryOptionFromServer;

@end
