//
//  OTRFSImageViewerViewController.m
//  SafeJab
//
//  Created by Самсонов Александр on 23.04.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "OTRFSImageViewerViewController.h"
#import "GetPhoto.h"
#import "OTRLog.h"


@interface OTRFSImageViewerViewController () <FSImageViewerViewControllerDelegate>

@end

@implementation OTRFSImageViewerViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    

}




+(NSString *)dateToString:(NSDate *)date
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    return [formatter stringFromDate:date];

    
}


+(FSBasicImageSource *)getPhotosBuddy:(NSString *)unicPhotoName AllPhotos:(NSMutableArray *)AllPhotos{

    NSMutableArray *arrPhotos = [[NSMutableArray alloc] init];
    FSBasicImage *PhotoCopy;
   
    DDLogInfo(@"unicPhotoName %@", unicPhotoName);
    
    int i=0;
    
    for(OTRMessage *massage in AllPhotos){
        
        NSString *otherUnicPhotoName = massage.text ? massage.text : massage.unicPhotoName;
        
        
        
        /*
        UIImage *midlePhoto = [GetPhoto loadImage:otherUnicPhotoName];
        
        float actualHeight = midlePhoto.size.height;
        
        float actualWidth = midlePhoto.size.width;
        
        
        
        float ratio=600/actualWidth;
        actualHeight = actualHeight*ratio;
        
        CGRect rect = CGRectMake(0.0, 0.0, 600, actualHeight);
        // UIGraphicsBeginImageContext(rect.size);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
        [midlePhoto drawInRect:rect];
        UIImage *newPhoto = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        */

    
        
        FSBasicImage *Photo = [[FSBasicImage alloc] initWithImage:[GetPhoto loadImage:otherUnicPhotoName] name:[OTRFSImageViewerViewController dateToString:massage.date]];
        
        
    
        
        if(([otherUnicPhotoName isEqualToString:unicPhotoName] || [massage.unicPhotoName isEqualToString:unicPhotoName] ) && [arrPhotos count] > 0){
            
            
            PhotoCopy = [arrPhotos objectAtIndex:0];
            
      
            [arrPhotos removeObjectAtIndex:0];
            [arrPhotos insertObject:Photo atIndex:0];
           
            
            
            [arrPhotos insertObject:PhotoCopy atIndex:i];
           
        } else {
            
            [arrPhotos insertObject:Photo atIndex:i];
           
            
        }
        
         i++;
        
    }
    
    
    /*
FSBasicImage *firstPhoto = [[FSBasicImage alloc] initWithImage:[UIImage imageNamed:@"background"] name:@"Photo 1"];
FSBasicImage *secondPhoto = [[FSBasicImage alloc] initWithImage:[UIImage imageNamed:@"background"]  name:@"Photo 2"];
*/
return [[FSBasicImageSource alloc] initWithImages:arrPhotos];
}



- (void)imageViewerViewController:(OTRFSImageViewerViewController *)imageViewerViewController didMoveToImageAtIndex:(NSInteger)index {
    
    

   
 
   // NSLog(@"Self %@", self);
    
    //self.imageSource =  //FSBasicImage *Photo = [[FSBasicImage alloc] initWithImage:
    
//FSBasicImage *wImageSource  =   [imageViewerViewController.imageSource objectAtIndexedSubscript:index];
 

 ///   wImageSource.image = [UIImage imageNamed:@"aim"] ;
    

  // wImageSource.image = [UIImage imageNamed:@"aim"];
    
    
    
  //  [imageViewerViewController layoutScrollViewSubviews];
   
    
  //  [imageViewerViewController.imageSource

 
 //   [self setViewState];
    
//    [imageViewerViewController.view reloadInputViews];
    
  /// [imageViewerViewController re];
    
    //imageViewerViewController.view.i
    
   
    
// self
    
    DDLogInfo(@"FSImageViewerViewController: %@ ZiG: %li",imageViewerViewController, (long)index);
}



@end
