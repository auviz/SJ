//
//  OTRShareSetting.m
//  Off the Record
//
//  Created by David on 11/10/12.
//  Copyright (c) 2012 Chris Ballinger. All rights reserved.
//

#import "OTRShareSetting.h"
#import "Strings.h"
#import "OTRAppDelegate.h"
#import "OTRQRCodeViewController.h"
#import "OTRUtilities.h"
#import "OTRActivityItemProvider.h"
#import "OTRQRCodeActivity.h"
#import "OTRConstants.h"

NSUInteger const kOTRActionSheetShareTag = 333;


@implementation OTRShareSetting

@synthesize delegate;
@synthesize lastActionLink;



-(id)initWithTitle:(NSString *)newTitle description:(NSString *)newDescription
{
    self = [super initWithTitle:newTitle description:newDescription];
    if (self) {
        __weak typeof (self) weakSelf = self;
        self.actionBlock = ^{
            [weakSelf showActionSheet];
        };
    }
    return self;
}

-(void)showActionSheet
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        OTRActivityItemProvider * itemProvider = [[OTRActivityItemProvider alloc] initWithPlaceholderItem:self];
        OTRQRCodeActivity * qrCodeActivity = [[OTRQRCodeActivity alloc] init];
        
        
        UIActivityViewController * activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[itemProvider] applicationActivities:@[qrCodeActivity]];
        activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
        
        [delegate presentViewController:activityViewController animated:YES completion:nil];
    }
    else{
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:SHARE_STRING delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        NSArray *buttonTitles = [self buttonTitlesForShareButton];
        for (NSString *title in buttonTitles) {
            [sheet addButtonWithTitle:title];
        }
        sheet.tag = kOTRActionSheetShareTag;
        sheet.cancelButtonIndex = [buttonTitles count] - 1;
        
        [OTRAppDelegate presentActionSheet:sheet inView:[delegate view]];
    }
}

- (NSArray*) buttonTitlesForShareButton {
    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:4];
    [titleArray addObject:@"SMS"];
    [titleArray addObject:@"E-mail"];
    [titleArray addObject:@"QR Code"];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        [titleArray addObject:@"Twitter"];
    }
    [titleArray addObject:CANCEL_STRING];
    return titleArray;
}

- (NSString*) shareString {
    return [NSString stringWithFormat:@"%@: https://get.chatsecure.org", SHARE_MESSAGE_STRING];
}

- (NSString*) twitterShareString {
    return [NSString stringWithFormat:@"%@ @ChatSecure", [self shareString]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (actionSheet.tag == kOTRActionSheetShareTag) {
        if (buttonIndex == 0) // SMS
        {
            if (![MFMessageComposeViewController canSendText]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_STRING message:[NSString stringWithFormat:@"SMS %@", NOT_AVAILABLE_STRING] delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
                [alert show];
            } else {
                MFMessageComposeViewController *sms = [[MFMessageComposeViewController alloc] init];
                sms.messageComposeDelegate = self;
                sms.body = [self shareString];
                sms.modalPresentationStyle = UIModalPresentationFormSheet;
                [delegate presentViewController:sms animated:YES completion:nil];
                
        
                
            }
        }
        else if (buttonIndex == 1) // Email
        {
            if (![MFMailComposeViewController canSendMail])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_STRING message:[NSString stringWithFormat:@"E-mail %@", NOT_AVAILABLE_STRING] delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                MFMailComposeViewController *email = [[MFMailComposeViewController alloc] init];
                email.mailComposeDelegate = self;
                [email setSubject:@"ChatSecure"];
                [email setMessageBody:[self shareString] isHTML:NO];
                email.modalPresentationStyle = UIModalPresentationFormSheet;
                
                [delegate presentViewController:email animated:YES completion:nil];
            }
        }
        else if (buttonIndex == 2) // QR code
        {
            OTRQRCodeViewController *qrCode = [[OTRQRCodeViewController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:qrCode];
            nav.modalPresentationStyle = UIModalPresentationFormSheet;
            [delegate presentViewController:nav animated:YES completion:nil];
        } else if (buttonIndex == [[self buttonTitlesForShareButton] count] - 2 && [[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
        {
            SLComposeViewController * tweetComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetComposeViewController setInitialText:[self twitterShareString]];
            [delegate presentViewController:tweetComposeViewController animated:YES completion:nil];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString isEqualToString:@"file:///"]) {
        return YES;
    }
    if ([[UIApplication sharedApplication] canOpenURL:request.URL])
    {
        self.lastActionLink = request.URL;
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:[[request.URL absoluteURL] description] delegate:self cancelButtonTitle:CANCEL_STRING destructiveButtonTitle:nil otherButtonTitles:OPEN_IN_SAFARI_STRING, nil];
        action.tag = kOTRActionSheetLinkTag;
        [OTRAppDelegate presentActionSheet:action inView:[delegate view]];
    }
    return NO;
}

#pragma mark MFMessageComposeViewControllerDelegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [delegate dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [delegate dismissViewControllerAnimated:YES completion:nil];
}

@end
