//
//  OTRAccountTableViewCell.m
//  Off the Record
//
//  Created by David Chiles on 11/27/13.
//  Copyright (c) 2013 Chris Ballinger. All rights reserved.
//

#import "OTRAccountTableViewCell.h"

#import "OTRAccount.h"
#import "Strings.h"
#import "OTRImages.h"
#import "SavePhoto.h"

@implementation OTRAccountTableViewCell

- (id)initWithReuseIdentifier:(NSString *)identifier
{
    return [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
}

- (void)setAccount:(OTRAccount *)account
{
    self.textLabel.text = account.username;
    if (account.displayName.length){
        self.textLabel.text = account.displayName;
    }
    
    float widthHeight = (heightAccountTableViewCelAcc - paddingAccountTableViewCelAcc);
    
    UIImage * accImage = [account accountImage];
    
    if(accImage.size.width > 60){
        self.imageView.image = [SavePhoto compressImage:accImage maxSize:widthHeight];
    } else {
         self.imageView.image = [account accountImage];
    }
    
    


    
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = widthHeight/2; //Половина от всоты ячейки c учетом отступа
    
    
    
    
   // }
}

- (void)setConnectedText:(OTRProtocolConnectionStatus)connectionStatus {
    if (connectionStatus == OTRProtocolConnectionStatusConnected) {
        self.detailTextLabel.text = CONNECTED_STRING;
    }
    else if (connectionStatus == OTRProtocolConnectionStatusConnecting)
    {
        self.detailTextLabel.text = CONNECTING_STRING;
    }
    else {
        self.detailTextLabel.text = WAITING_FOR_INTERNET_CONNECTION;
    }
}

@end
