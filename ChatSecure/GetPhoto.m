//
//  GetPhoto.m
//  SafeJab
//
//  Created by Самсонов Александр on 14.04.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "GetPhoto.h"
#import "SavePhoto.h"
#import "OTRLog.h"
#import "SetGlobVar.h"



@implementation GetPhoto

@synthesize curConnection;
@synthesize linkToMessagesViewController;
@synthesize message;



#pragma mark NSURLConnection Delegate Methods

- (id) init{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    return self;
}


- (void)getPhotoFromServer:(NSString *) unicName{
    
    
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
    
    NSString *post =  [NSString stringWithFormat:@"key1=%@", unicName];
    // NSString *post = @"name=val1&photo=val2";
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://safejab.com/getPhoto.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //application/x-www-form-urlencoded multipart/form-data
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    self.curConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self ];
    
    
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
 
    
    NSString *photoBase64 = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    
    UIImage *photo = [self stringToUIImage:photoBase64];
    
    DDLogInfo(@"GET DATA %@", photo);
    
    [SavePhoto saveImage:photo unicName:_unicName];
    [SavePhoto genMiniImage:photo unicName:_unicName];
    
    
      UIImage *newPhoto = [GetPhoto loadMiniImage: self.message.unicPhotoName];
    
     JSQPhotoMediaItem *newPhotoItem = [[JSQPhotoMediaItem alloc] initWithImage:newPhoto];
    
    if(self.message.incoming){
        newPhotoItem.appliesMediaViewMaskAsOutgoing = NO;
    }
     self.message.media =nil;
    
     self.message.media = newPhotoItem;
    
    
    
    
    [self.linkToMessagesViewController.collectionView reloadData];
        


    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    
    DDLogInfo(@"updateApp err:");
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

+ (UIImage*)loadMiniImage:(NSString *)unicName

{
    
  //  NSString *dirBigPhoto = [NSString stringWithFormat:@"%@.jpg", unicName];
 //   NSString *dirMiniPhoto = [NSString stringWithFormat:@"%@%@.jpg", unicName, MINI_PHOTO];
    
    


    


    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@%@.jpg", unicName, MINI_PHOTO]];
            
    //UIImage* image = [UIImage imageNamed:path];
    
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    
    if(image) return image;
    
    DDLogInfo(@"NOT_MINI %@", [NSString stringWithFormat:@"%@%@.jpg", unicName, MINI_PHOTO]);
    
    return nil;
    
    //Иначе сгенертровать миниатюру
    
    NSString* pathBigPhoto = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@.jpg", unicName]];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathBigPhoto]){
        
        UIImage* bigPhoto = [GetPhoto loadImage:unicName];
        [SavePhoto genMiniImage:bigPhoto unicName:unicName];
        return [GetPhoto loadMiniImage:unicName];
        
    } else return nil;
        
    

    
}


+ (UIImage*)loadImage:(NSString *)unicName
{
    
    /*
     __block UIImage *image;
     
     
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
     NSUserDomainMask, YES);
     NSString *documentsDirectory = [paths objectAtIndex:0];
     NSString* path = [documentsDirectory stringByAppendingPathComponent:
     [NSString stringWithFormat:@"%@.jpg", unicName]];
     
     
     dispatch_async(dispatch_get_main_queue(), ^{
     
     image = [UIImage imageWithContentsOfFile:path];
     
     
     });

     
     return image;
     
     */
    

    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@.jpg", unicName]];
    

    
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    

    
    
    return image;
}



@end
