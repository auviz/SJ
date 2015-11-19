//
//  OTRMessagesCollectionViewCell.m
//  Off the Record
//
//  Created by David Chiles on 6/3/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//


#import "OTRMessagesCollectionViewCell.h"
#import "OTRMessage.h"
#import "OTRImages.h"

@interface OTRMessagesCollectionViewCell ()


@property (nonatomic, weak) IBOutlet UIView *leftRightView;
@property (nonatomic, strong) UIImageView *errorImageView;
@property (nonatomic, strong) UIImageView *deliveredImageView;
@property (nonatomic, strong) UIImageView *lockImageView;
@property (nonatomic, strong) NSLayoutConstraint *lockWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *deliveredWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *errorWidthConstraint;
@property (nonatomic, strong) UITapGestureRecognizer *tap;


@end

@implementation OTRMessagesCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
  
    
    self.errorImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.errorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.errorImageView.userInteractionEnabled = YES;

    
    [self.leftRightView addSubview:self.errorImageView];

    
    [self setupConstraints];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorImageTap:)];
    [self.errorImageView addGestureRecognizer:tapGesture];
    self.tap = tapGesture;
  
}

- (void)setupConstraints
{
    
    //zigzagcorp big bug
    
    if(self.leftRightView ){
 
   [self.leftRightView addConstraint:[NSLayoutConstraint constraintWithItem:self.errorImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.leftRightView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    }
    
    [self.errorImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.errorImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:33.0]];

    
    

    self.errorWidthConstraint = [NSLayoutConstraint constraintWithItem:self.errorImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.0];
    [self.errorImageView addConstraint:self.errorWidthConstraint];
 
    
}

- (void)errorImageTap:(UITapGestureRecognizer *)tap
{

    if ([self.actionDelegate respondsToSelector:@selector(messagesCollectionViewCellDidTapError:)]) {
        [self.actionDelegate messagesCollectionViewCellDidTapError:self];
    }
     
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
    BOOL result = [super canPerformAction:action withSender:sender];
    if (!result) {
        result = (action == @selector(delete:));
    }
    return result;
   
}

- (void)delete:(id)sender
{
    if ([self.actionDelegate respondsToSelector:@selector(messagesCollectionViewCellDidTapDelete:)]) {
        [self.actionDelegate messagesCollectionViewCellDidTapDelete:self];
    }
   
}

- (void)updateConstraints
{
    
    [super updateConstraints];

    
    /*
    if (!self.errorImageView.image){
        self.errorWidthConstraint.constant = 0.0;
    }
    else{
        self.errorWidthConstraint.constant = 33.0;
    }
     
      zigzagcorp костыль бля без этого не отображаются ошибка доставки
    */
    
    self.errorWidthConstraint.constant = 33.0;
    
}

- (void) setMessage:(OTRMessage*)message {
    
    //zigzagcorp old
    /*
   
    if (message.isIncoming) {
        self.textView.textColor = [UIColor blackColor]; //Color for Incoming mes zigzagcorp
    } else {
        self.textView.textColor = [UIColor blackColor]; //Color for outgoing mes zigzagcorp
    }
    */
    
    self.errorImageView.image = [OTRImages warningImage];
    
    if (message.error) {
        self.errorImageView.image = [OTRImages warningImage];
    } else {
        self.errorImageView.image = nil;
    }
     
}

@end
