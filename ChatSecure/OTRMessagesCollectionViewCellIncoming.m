//
//  OTRMessagesCollectionViewCellIncoming.m
//  Off the Record
//
//  Created by David Chiles on 6/3/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRMessagesCollectionViewCellIncoming.h"

@implementation OTRMessagesCollectionViewCellIncoming

#pragma mark - Overrides

- (void)setupConstraints
{
   
    [super setupConstraints];
   
    /*
    NSDictionary *views = @{@"errorImageView":self.errorImageView,@"deliveredImageView":self.deliveredImageView,@"lockImageView":self.lockImageView};
    NSDictionary *metrics = @{@"margin":@(6)};
    
    
    [self.leftRightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[lockImageView][deliveredImageView][errorImageView]-(>=0)-|" options:0 metrics:metrics views:views]];
    */
    
    
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([OTRMessagesCollectionViewCellIncoming class])
                          bundle:[NSBundle mainBundle]];
    
       //return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([OTRMessagesCollectionViewCellIncoming class]);
}

+ (NSString *)mediaCellReuseIdentifier
{
 //   DDLogInfo(@"ERERERERERERERERERERERR %@", [NSString stringWithFormat:@"%@_JSQMedia", NSStringFromClass([OTRMessagesCollectionViewCellIncoming class])]);
    return [NSString stringWithFormat:@"%@_JSQMedia", NSStringFromClass([OTRMessagesCollectionViewCellIncoming class])];
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
  self.messageBubbleTopLabel.textAlignment = NSTextAlignmentLeft;
   self.cellBottomLabel.textAlignment = NSTextAlignmentLeft;
}

@end
