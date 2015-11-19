//
//  savePhoto.m
//  testPostPhoto
//
//  Created by Самсонов Александр on 09.04.15.
//  Copyright (c) 2015 LC. All rights reserved.
//

#import "SavePhoto.h"
#import <UIKit/UIKit.h>
#import "OTRMessagesViewController.h"
#import "SetGlobVar.h"
#import "Strings.h"
#import "OTRLog.h"

@implementation SavePhoto

@synthesize curConnection;
@synthesize linkToMessagesViewController;


#pragma mark NSURLConnection Delegate Methods

- (id) init{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    return self;
}

+(NSString *)genUnicNameForPhoto{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    uuid =  [uuid stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    
    return [NSString stringWithFormat:@"%@%@", MARK_PHOTO, uuid];
}



- (void)postToServer: (UIImage *) photo unicName:(NSString *) unicName{
    
    
   _unicName = unicName;

    // self = [super init];
    
    //  if (!self) {
    //     return nil;
    //  }
    

   // NSURL *url = [NSURL URLWithString:@"https://mail.lc-rus.com/install/getVersionApp.php"];
    // Create the request.
   // NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    // Create url connection and fire request
  //
  //  UIImage *photo = [UIImage imageNamed:@"photoTest.jpg"];
    
    photo = [SavePhoto compressImage:photo maxSize:1280];
    
   _imageData= UIImageJPEGRepresentation(photo, 0.9);
    NSString *strPhoto = [_imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *post =  [NSString stringWithFormat:@"key1=%@&key2=%@", unicName, strPhoto];
   // NSString *post = @"name=val1&photo=val2";
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"http://safejab.com/savePhoto.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //application/x-www-form-urlencoded multipart/form-data
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
     self.curConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self ];
    
  _message = [self.linkToMessagesViewController setPreviewUidPhoto:_unicName];

    // return self;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    NSString *status = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    
   // NSString *versionAppInDevice = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
  //  BOOL *isEqual= [versionAppOnServer isEqualToString:versionAppInDevice];
    
    
  //  if(!isEqual){
        
   //     self.aboutVersion =[NSString stringWithFormat:@"%@ %@%@?", INSTALL_NOW, @"SafeJab v", versionAppOnServer];
     //   [self show];
        
        
   // }
   // UIImage *photo = [self stringToUIImage:versionAppOnServer];
    
   // [self.link setPhoto:photo];
    
    BOOL *isPostOk= [@"ok" isEqualToString:status];
    
     DDLogInfo(@"GET DATA: %@ ", status);
    
    if(isPostOk){
    
   
        UIImage *cashePhoto = [UIImage imageWithData:_imageData];
        
        
        [SavePhoto genMiniImage:cashePhoto unicName:_unicName];
        [SavePhoto saveImage:cashePhoto unicName:_unicName];
       
        
        [self.linkToMessagesViewController sendUidPhoto:_message];
    
    
    }
    //  self.testImg.image =   [UIImage imageNamed:@"photoTest.jpg"];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self.linkToMessagesViewController deleteMessage:_message];
    
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Photo Message Error"
                                                       message:XMPP_FAIL_STRING
                                                      delegate:self
                                             cancelButtonTitle:OK_STRING
                                             otherButtonTitles:nil];
    
    
    //  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Error" message:message.error.description cancelButtonItem: otherButtonItems:okButton];
    
    [alertView show];
}



-(void)show{
    /*
    DDLogInfo(@"show");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NEW_UPDATE_IS_AVAILABLE
                                                             delegate:self
                                                    cancelButtonTitle:REMIND_ME_LATER
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:self.aboutVersion, nil];
    
    
    
    
    [actionSheet showInView:self.view];
     */
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*
    if(buttonIndex == 0){
        
        [[UIApplication sharedApplication] openURL:[NSURL update_app_from_serverURL]]; //обновление приложения zigzagcorp
        exit(0);
        
    }
    
    */
}


- (UIImage *)stringToUIImage:(NSString *)string
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string
                                                      options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

+(UIImage *)compressImage:(UIImage *)image maxSize: (int)maxSize {
    
    if(!maxSize) maxSize = 30;
    CGRect rect;
    float ratio;
    
   
    
    float actualHeight = image.size.height;
    
    float actualWidth = image.size.width;
    
    
   //  if(actualHeight >= maxSize || actualWidth >= )
    
    
    if (actualHeight >= actualWidth) {
        //портрет
        
        if(actualHeight <= maxSize) return image;
        
        ratio=maxSize/actualHeight;
        actualWidth = actualWidth*ratio;
        
        rect = CGRectMake(0.0, 0.0, actualWidth, maxSize);
    } else {
        //панорама
        if(actualWidth <= maxSize) return image;
        
        ratio=maxSize/actualWidth;
        actualHeight = actualHeight*ratio;
        
        rect = CGRectMake(0.0, 0.0, maxSize, actualHeight);
    }
    
    
    

    // UIGraphicsBeginImageContext(rect.size);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
    
}


+(void)genMiniImage: (UIImage *)image unicName: (NSString *)unicName
{
    
    float actualHeight = image.size.height;
    
    float actualWidth = image.size.width;
    
    
    
    float ratio=250/actualWidth;
    actualHeight = actualHeight*ratio;
    
    CGRect rect = CGRectMake(0.0, 0.0, 250, actualHeight);
    // UIGraphicsBeginImageContext(rect.size);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    if (img != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@%@.jpg", unicName, MINI_PHOTO]];
        
        NSData *data = UIImageJPEGRepresentation(img, 1.0);
        [data writeToFile:path atomically:YES];
        
    }
 
    
    
    
    /*
     
     int width = image.size.width;
     int height = image.size.height;
     
     int newHeigt;
     int newWidth;
     
     int toWidth = 150;
     int toHeight = 150;
     
     
     
     if(width <= toWidth){
     return image;
     }else{
     newHeigt=(height*toWidth)/width; // h1 = (h * w1)/w // w1 = (w * h1)/h
     
     //  newWidth = (width * toHeight)/height;
     
     //if($h1>500) {$popravka=(500/$h1); $h1=500;} else $popravka=1; // Масштаб по высоте
     // $new=ImageCreateTrueColor(toWidth, newHeigt);
     //  $staroe=imageCreateFromjpeg("$nameJPG");
     // imagecopyresampled($new,$staroe,0,0,0,0,(400),$h1,$size[0],$size[1]);
     //  $minijepeg=$DOCUMENT_ROOT.'/phototov/big/IMG_'.$name.$extra.'.jpg';
     // imagejpeg($new,$minijepeg, 98);// Создание большого фото
     
     return resizedImage(image, CGRectMake(0, 0, toWidth, newHeigt));
     
     
     }
     
     */
    
}


+ (void)saveImage: (UIImage*)image unicName: (NSString *)unicName
{
    if (image != nil)
    {
    
       
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                         [NSString stringWithFormat:@"%@.jpg", unicName]];
        
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        [data writeToFile:path atomically:YES];
        
        
        //This is log
        
        // Create file manager
        NSError *error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        
        // Point to Document directory
        NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        // Write out the contents of home directory to console
        DDLogInfo(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:dir error:&error]);
    }
}






@end
