//
//  GetPhoto.h
//  SafeJab
//
//  Created by Самсонов Александр on 14.04.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTRMessagesViewController.h"
#import "OTRMessage.h"
#import "OTRMessage+JSQMessageData.h"
#import "JSQPhotoMediaItem.h"

@interface GetPhoto : NSObject<NSURLConnectionDelegate>

{
    NSMutableData *_responseData;
    
    NSString *_unicName;
    
}

@property NSURLConnection  *curConnection;

@property (strong, nonatomic) UIImage *urlPhoto;

@property (strong, nonatomic) OTRMessagesViewController * linkToMessagesViewController;
@property (strong, nonatomic) OTRMessage *message;
@property (nonatomic, strong) dispatch_queue_t zigQueue;

// self.zigQueue = dispatch_queue_create("ZIG.queue", DISPATCH_QUEUE_SERIAL);

+ (UIImage*)loadImage:(NSString *)unicName;
+ (UIImage*)loadMiniImage:(NSString *)unicName;

- (void)getPhotoFromServer:(NSString *) unicName;



@end
