//
//  ZIGMyVCard.m
//  SafeJab
//
//  Created by Самсонов Александр on 03.03.16.
//  Copyright © 2016 Leader Consult. All rights reserved.
//

#import "ZIGMyVCard.h"

#import "NSXMLElement+XMPP.h"
#import "SetGlobVar.h"

@implementation ZIGMyVCard

-(id)initWithVCard:(NSXMLElement *)vCard{
    
    
    self = [super init];
    
    
    if(self){
    
    // NSXMLElement * vCard = [iq elementForName:@"vCard" xmlns:@"vcard-temp"];
    
    self.nickname = [[vCard elementForName:@"NICKNAME"] stringValue];
    
    self.email = [[vCard elementForName:@"EMAIL"] stringValue];
    
    self.binval = [[[vCard elementForName:@"PHOTO"] elementForName:@"BINVAL"] stringValue];
    
    //  BINVAL =   [BINVAL stringByTrimmingCharactersInSet:
    //  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(self.binval.length > 10){
           //Если у чувака есть аватарка то записать е в дату
                self.photoData =    [[NSData alloc] initWithBase64EncodedString:self.binval  options:NSDataBase64DecodingIgnoreUnknownCharacters];
            
            
        }
    
       
        
        return self;
    }
    
    return nil;
}


@end
