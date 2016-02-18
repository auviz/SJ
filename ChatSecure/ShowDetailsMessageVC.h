//
//  ShowDetailsMessageVC.h
//  SafeJab
//
//  Created by Самсонов Александр on 19.01.16.
//  Copyright © 2016 Leader Consult. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTRMessagesViewController;
@class OTRMessage;

@interface ShowDetailsMessageVC : UITableViewController

-(id)initWithMessageIndexPath: (NSIndexPath *)indexPath messagesViewController:(OTRMessagesViewController *)messagesVC;

@end

//Параметры ячейки
@interface ZIGItemCell : NSObject
    
    @property (strong, nonatomic) NSString* identifier;
    @property (strong, nonatomic) NSString* titleText;
    @property (strong, nonatomic) NSString* text;
    @property (strong, nonatomic) UIColor* color;
    @property BOOL isDisabled;


@end

