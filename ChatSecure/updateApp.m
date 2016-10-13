//
//  updateApp.m
//  SafeJab
//
//  Created by Самсонов Александр on 18.02.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//
#import "updateApp.h"
#import "NSURL+ChatSecure.h"
#import "Strings.h"
#import <UIKit/UIKit.h>
#import "OTRLog.h"

@implementation updateApp

@synthesize curConnection;

#pragma mark NSURLConnection Delegate Methods

- (id) init{
    self = [super init];
    
      if (!self) {
         return nil;
     }
    return self;
}

- (void)initConnection:(UIView *)view {
   // self = [super init];
    
  //  if (!self) {
   //     return nil;
  //  }
    
    self.view = view;
    
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL get_version_appURL]];
    
    // Create url connection and fire request
    self.curConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
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
    
    NSString *versionAppOnServer = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    
     NSString *versionAppInDevice = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    BOOL isEqual= [versionAppOnServer isEqualToString:versionAppInDevice];
    
   
    
    if(!isEqual){
        
        NSString * lastLetter = [updateApp lastLetter:versionAppOnServer];
       
        if([lastLetter isEqualToString:@"c"]){
            
            //Если "c" значит критическое обновление
            [self setCritical:versionAppOnServer];
            [self showAleert];
            return ;
        } else if ([self isCritical]){
            [self showAleert]; //Если уж мы попали в крит то до конца
            return;
        }
        
        //Обычное обновление
        
        self.aboutVersion =[NSString stringWithFormat:@"%@ %@%@?", INSTALL_NOW, @"SafeJab v", versionAppOnServer];
        [self show];
   
   
    } else {
        [self setNotCritical]; //Отключаем крит
    }
    
    DDLogInfo(@"GET DATA: %@ DEV: %@", versionAppOnServer, versionAppInDevice);
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    
    if([self isCritical]){
        [self showAleert]; //Если мы в офлайн все равно заставить обновится
    }
  
    DDLogInfo(@"updateApp err:");
}


-(void)show{
    DDLogInfo(@"show");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NEW_UPDATE_IS_AVAILABLE
                                                             delegate:self
                                                    cancelButtonTitle:REMIND_ME_LATER
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:self.aboutVersion, nil];
    
 
    
    
    [actionSheet showInView:self.view];
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0){
        
        [[UIApplication sharedApplication] openURL:[NSURL update_app_from_serverURL]]; //обновление приложения zigzagcorp
        exit(0);
        
    }
    

}

//Критическое обновление

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0){
        
        [[UIApplication sharedApplication] openURL:[NSURL update_app_from_serverURL]]; //обновление приложения zigzagcorp
        exit(0);
        
    }
}


-(void)genDir{

        
        //если лежит в документах проекта
    if(self.dirWithFile.length == 0){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.dirWithFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CUpdate.txt"];
    }
    
    
}

-(NSString *)getCriticalVer{
    [self genDir];
    NSError *err1 = nil;
    return  [NSString stringWithContentsOfFile:self.dirWithFile usedEncoding:nil error:&err1];
    
}


-(void)setCritical:(NSString *)ver{
    
    [self genDir];
    
    NSError *err = nil;
    
    [ver writeToFile:self.dirWithFile atomically:YES
            encoding:NSUTF8StringEncoding error:&err];
    
}



-(BOOL)isCritical{
    
    [self genDir];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isFileExists = [fileManager fileExistsAtPath:self.dirWithFile];
    
    if(!isFileExists) return NO;
    
    return YES;
    
}

+(NSString *)lastLetter:(NSString *)str{
    
    if(str.length == 0) return nil;
    
    unichar lastLatter =  [str characterAtIndex:(str.length - 1)];
    
    return [NSString stringWithCharacters: &lastLatter length: 1];
    
    
}
/*
 BOOL success = [fileManager removeItemAtPath:miniPhotoPath error:&error];
 if (!success) NSLog(@"ErrorDelete: %@", [error localizedDescription]);
 */

-(void)setNotCritical{
    
    [self genDir];
    
     NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isCreated = [fileManager fileExistsAtPath:self.dirWithFile];
    
    if(isCreated){
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:self.dirWithFile error:&error];
        if (!success) NSLog(@"ErrorDelete: %@", [error localizedDescription]);
    }
    

    
    
    
}


-(void)showAleert{
    
    NSString * verCrit = [self getCriticalVer];
    
   
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Critical update"
                                                        message:[NSString stringWithFormat:@"%@ SJ %@", NEW_UPDATE_IS_AVAILABLE, verCrit]
                                                       delegate:self
                                              cancelButtonTitle:INSTALL_NOW
                                              otherButtonTitles:nil];
    [alertView show];
}



@end

