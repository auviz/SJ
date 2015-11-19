//
//  OTRFSImageViewerViewController.h
//  SafeJab
//
//  Created by Самсонов Александр on 23.04.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "FSImageViewerViewController.h"
#import "FSBasicImageSource.h"
#import "FSBasicImage.h"


@interface OTRFSImageViewerViewController : FSImageViewerViewController

+(FSBasicImageSource *)getPhotosBuddy:(NSString *)unicPhotoName AllPhotos:(NSMutableArray *)AllPhotos;



@end