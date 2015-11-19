//
//  pinCode.m
//  SafeJab
//
//  Created by Самсонов Александр on 25.02.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "pinCode.h"
#import "OTRDatabaseManager.h"

@implementation pinCode

+(void)set:(NSString *)pin{
    
  //  if(pin == nil) pin = @"";
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
    
    
      [transaction setObject:pin forKey:@"value" inCollection:@"pinCode"];
     }];
    
}

+(NSString *)get {
    
  __block NSString *pin = nil;
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        pin = [transaction objectForKey:@"value" inCollection:@"pinCode"];
    }];
    
    if(pin == nil) return @"";
    
    return pin;
    
}





@end
