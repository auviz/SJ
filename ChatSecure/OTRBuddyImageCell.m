//
//  OTRBuddyImageCell.m
//  Off the Record
//
//  Created by David Chiles on 3/3/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRBuddyImageCell.h"
#import "OTRBuddy.h"
#import "OTRImages.h"
#import "OTRColors.h"
#import "PureLayout.h"
#import "SetGlobVar.h"

const CGFloat OTRBuddyImageCellPadding = 12.0;

@interface OTRBuddyImageCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic) BOOL addedConstraints;


@end


@implementation OTRBuddyImageCell

@synthesize imageViewBorderColor = _imageViewBorderColor;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.avatarImageView = [[UIImageView alloc] initWithImage:[self defaultImage]];
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        CALayer *cellImageLayer = self.avatarImageView.layer;
        [cellImageLayer setBorderWidth:2.0];
        
        [cellImageLayer setMasksToBounds:YES];
        [cellImageLayer setBorderColor:[self.imageViewBorderColor CGColor]];
        [self.contentView addSubview:self.avatarImageView];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.addedConstraints = NO;
    }
    return self;
}

- (UIColor *)imageViewBorderColor
{
    if (!_imageViewBorderColor) {
        _imageViewBorderColor = [UIColor blackColor];
    }
    return _imageViewBorderColor;
}

- (void)setImageViewBorderColor:(UIColor *)imageViewBorderColor
{
    _imageViewBorderColor = imageViewBorderColor;
    
    [self.avatarImageView.layer setBorderColor:[_imageViewBorderColor CGColor]];
}

- (void)setBuddy:(OTRBuddy *)buddy
{
    self.welfBody = buddy; //Ну для каждой ячеики сохраняю связь
    
    self.isGroupChat = SafeJabTypeIsEqual(buddy.username, MUC_JABBER_HOST);
    
    
    if(buddy.avatarImage)  { //Надо будет это поменять когда комната будет иметь возможность загружать фотки
        
        self.avatarImageView.image = buddy.avatarImage;
    }
    else {
        self.avatarImageView.image = [self defaultImage];
    }
    
    
    
    UIColor *statusColor =  [OTRColors colorWithStatus:buddy.status];
    self.imageViewBorderColor = statusColor;
    [self.contentView setNeedsUpdateConstraints];
}

- (UIImage *)defaultImage
{
    if(self.isGroupChat){
          return [UIImage imageNamed:@"groupChat"];
    } else {
         return [UIImage imageNamed:@"person"];
    }
    
   
}

- (void)updateConstraints
{
    if (!self.addedConstraints) {
        [self.avatarImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:OTRBuddyImageCellPadding];
        [self.avatarImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:OTRBuddyImageCellPadding];
        [self.avatarImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:OTRBuddyImageCellPadding];
        [self.avatarImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.avatarImageView];
        
        self.addedConstraints = YES;
    }
    [super updateConstraints];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end
