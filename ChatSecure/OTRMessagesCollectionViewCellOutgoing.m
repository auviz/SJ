//
//  OTRMessagesCollectionViewCellOutgoing.m
//  Off the Record
//
//  Created by David Chiles on 6/3/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRMessagesCollectionViewCellOutgoing.h"

@implementation OTRMessagesCollectionViewCellOutgoing

#pragma mark - Overrides

- (void)setupConstraints
{
    [super setupConstraints];
    
    NSDictionary *views = @{@"errorImageView":self.errorImageView};
    NSDictionary *metrics = @{@"margin":@(6)};
    
    
    [self.leftRightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[errorImageView]-(margin)-|" options:0 metrics:metrics views:views]];
    
    
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([OTRMessagesCollectionViewCellOutgoing class])
                          bundle:[NSBundle mainBundle]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([OTRMessagesCollectionViewCellOutgoing class]);
}

+ (NSString *)mediaCellReuseIdentifier
{
    return [NSString stringWithFormat:@"%@_JSQMedia", NSStringFromClass([OTRMessagesCollectionViewCellOutgoing class])];
}


#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentLeft;
    self.cellBottomLabel.textAlignment = NSTextAlignmentLeft;
}


@end
