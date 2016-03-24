//
//  ZIGMyVCard.h
//  SafeJab
//
//  Created by Самсонов Александр on 03.03.16.
//  Copyright © 2016 Leader Consult. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSXMLElement;

@interface ZIGMyVCard : NSObject


@property (nonatomic, strong) NSString * nickname;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * binval;
@property (nonatomic, strong) NSData *photoData;

-(id)initWithVCard:(NSXMLElement *)vCard;


@end
