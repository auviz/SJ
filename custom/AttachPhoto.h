//
//  AttachPhoto.h
//  SafeJab
//
//  Created by Самсонов Александр on 20.03.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VFPhotoActionSheet.h"
#import "OTRAboutViewController.h"
#import "Strings.h"
#import "OTRMessagesViewController.h"


@interface AttachPhoto : VFPhotoActionSheet<VFPhotoActionSheetDelegate>

@property (nonatomic, strong) UIViewController *ViewController;


-(id) initWithView:(UIViewController *)ViewController;


- (UIButton *)AttachButton;

- (void)pickButtonTap:(id)sender;

//Delegate
@property(strong, nonatomic) id deleg;

- (id)delegate;

- (void)setDelegate:(id)newDelegate;

//Путь до Message
@property (nonatomic, strong) OTRMessagesViewController * linkToBuddy;





@end
