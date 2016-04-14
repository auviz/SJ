//
//  dbHistoryOptions.m
//  SafeJab
//
//  Created by Самсонов Александр on 13.04.16.
//  Copyright © 2016 Leader Consult. All rights reserved.
//

#import "dbHistoryOption.h"
#import "OTRDatabaseManager.h"

@implementation dbHistoryOption

+(void)set:(NSString *)selected{
    

    //  if(pin == nil) pin = @"";
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        
        [transaction setObject:selected forKey:@"value" inCollection:@"dbHistoryOption"];
    }];
    
}

+(NSString *)get {
    
    __block NSString *option = nil;
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        option = [transaction objectForKey:@"value" inCollection:@"dbHistoryOption"];
    }];
    
    if(!option) return @"";
    
    return option;
    
}

@end
