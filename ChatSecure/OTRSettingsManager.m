//
//  OTRSettingsManager.m
//  Off the Record
//
//  Created by Chris Ballinger on 4/10/12.
//  Copyright (c) 2012 Chris Ballinger. All rights reserved.
//
//  This file is part of ChatSecure.
//
//  ChatSecure is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ChatSecure is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ChatSecure.  If not, see <http://www.gnu.org/licenses/>.

#import "OTRSettingsManager.h"
#import "OTRViewSetting.h"
#import "Strings.h"
#import "OTRSettingsGroup.h"
#import "OTRSetting.h"
#import "OTRBoolSetting.h"
#import "OTRViewSetting.h"
#import "OTRDoubleSetting.h"
#import "OTRFeedbackSetting.h"
#import "OTRConstants.h"
#import "OTRShareSetting.h"
#import "OTRLanguageSetting.h"
#import "OTRDonateSetting.h"
#import "OTRIntSetting.h"
#import "OTRCertificateSetting.h"
#import "OTRUtilities.h"
#import "OTRFingerprintSetting.h"
#import "OTRPushViewSetting.h"
#import "OTRChangeDatabasePassphraseViewController.h"
#import "OTRDeleteAllChats.h"
#import "OTRKeepHistorySetting.h"

#import "pinCodeSetting.h"

#import "OTRUtilities.h"

@interface OTRSettingsManager(Private)
- (void) populateSettings;
@end

@implementation OTRSettingsManager
@synthesize settingsGroups, settingsDictionary;

- (void) dealloc
{
    settingsGroups = nil;
    settingsDictionary = nil;
}

- (id) init
{
    if (self = [super init])
    {
        settingsGroups = [NSMutableArray array];
        [self populateSettings];
    }
    return self;
}

- (void) populateSettings
{
    NSMutableDictionary *newSettingsDictionary = [NSMutableDictionary dictionary];
    // Leave this in for now
    OTRViewSetting *accountsViewSetting = [[OTRViewSetting alloc] initWithTitle:ACCOUNTS_STRING description:nil viewControllerClass:nil];
    OTRSettingsGroup *accountsGroup = [[OTRSettingsGroup alloc] initWithTitle:ACCOUNTS_STRING settings:[NSArray arrayWithObject:accountsViewSetting]];
    [settingsGroups addObject:accountsGroup];
    
    OTRIntSetting *fontSizeSetting;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        fontSizeSetting = [[OTRIntSetting alloc] initWithTitle:FONT_SIZE_STRING description:FONT_SIZE_DESCRIPTION_STRING settingsKey:kOTRSettingKeyFontSize];
        fontSizeSetting.maxValue = 20;
        fontSizeSetting.minValue = 12;
        fontSizeSetting.numValues = 4;
        fontSizeSetting.defaultValue = [NSNumber numberWithInt:16];

        [newSettingsDictionary setObject:fontSizeSetting forKey:kOTRSettingKeyFontSize];
    }
    OTRBoolSetting *deletedDisconnectedConversations = [[OTRBoolSetting alloc] initWithTitle:DELETE_CONVERSATIONS_ON_DISCONNECT_TITLE_STRING
                                                                                 description:DELETE_CONVERSATIONS_ON_DISCONNECT_DESCRIPTION_STRING
                                                                                 settingsKey:kOTRSettingKeyDeleteOnDisconnect];
    
    [newSettingsDictionary setObject:deletedDisconnectedConversations forKey:kOTRSettingKeyDeleteOnDisconnect];
    
    OTRBoolSetting *showDisconnectionWarning = [[OTRBoolSetting alloc] initWithTitle:DISCONNECTION_WARNING_TITLE_STRING
                                                                         description:DISCONNECTION_WARNING_DESC_STRING
                                                                         settingsKey:kOTRSettingKeyShowDisconnectionWarning];
    showDisconnectionWarning.defaultValue = @(NO);
    [newSettingsDictionary setObject:showDisconnectionWarning forKey:kOTRSettingKeyShowDisconnectionWarning];
    
    
    
    
    OTRKeepHistorySetting *historyOnServerBtn = [[OTRKeepHistorySetting alloc] initWithTitle:KEEP_HISTORY_STRING
                                                                         description:STORING_HISTORI_STRING
                                                ];
    
    self.keepHistorySetting = historyOnServerBtn;

    
   // [newSettingsDictionary setObject:historyOnServerBtn forKey:kOTRSettingKeyHistoryOnServer];
    
    
    OTRBoolSetting *opportunisticOtrSetting = [[OTRBoolSetting alloc] initWithTitle:OPPORTUNISTIC_OTR_SETTING_TITLE
                                                                        description:OPPORTUNISTIC_OTR_SETTING_DESCRIPTION
                                                                        settingsKey:kOTRSettingKeyOpportunisticOtr];
    opportunisticOtrSetting.defaultValue = @(NO); //Ебанутое авто шифрование
    [newSettingsDictionary setObject:opportunisticOtrSetting forKey:kOTRSettingKeyOpportunisticOtr];
    
    OTRCertificateSetting * certSetting = [[OTRCertificateSetting alloc] initWithTitle:PINNED_CERTIFICATES_STRING
                                                                           description:PINNED_CERTIFICATES_DESCRIPTION_STRING];
    
    certSetting.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    /*
   
    OTRFingerprintSetting * fingerprintSetting = [[OTRFingerprintSetting alloc] initWithTitle:OTR_FINGERPRINTS_STRING
                                                                                  description:OTR_FINGERPRINTS_SUBTITLE_STRING];
    fingerprintSetting.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    */
     pinCodeSetting * pinCodeSettingButton = [[pinCodeSetting alloc] initWithTitle:PIN_CODE
                                                                                  description:ENTERING_PROGRAM_BY_PIN];
    pinCodeSettingButton.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    // Disable OTRChangeDatabasePassphraseViewController until we add support within YapDatabase
    //OTRViewSetting *changeDatabasePassphraseSetting = [[OTRViewSetting alloc] initWithTitle:CHANGE_PASSPHRASE_STRING description:SET_NEW_DATABASE_PASSPHRASE_STRING viewControllerClass:[OTRChangeDatabasePassphraseViewController class]];
    //changeDatabasePassphraseSetting.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
#if CHATSECURE_PUSH
    OTRViewSetting *pushViewSetting = [[OTRPushViewSetting alloc] initWithTitle:CHATSECURE_PUSH_STRING description:MANAGE_CHATSECURE_PUSH_ACCOUNT_STRING];
    pushViewSetting.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    OTRSettingsGroup *pushGroup = [[OTRSettingsGroup alloc] initWithTitle:PUSH_TITLE_STRING settings:@[pushViewSetting]];
    [settingsGroups addObject:pushGroup];
#endif
    
    NSArray *chatSettings;
    NSArray * securitySettings;
    
   // if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
   //     chatSettings = [NSArray arrayWithObjects:fontSizeSetting,deletedDisconnectedConversations, showDisconnectionWarning, nil];
  //  } else {
        chatSettings = [NSArray arrayWithObjects:deletedDisconnectedConversations, showDisconnectionWarning, historyOnServerBtn, nil];
   // }
    OTRSettingsGroup *chatSettingsGroup = [[OTRSettingsGroup alloc] initWithTitle:CHAT_STRING settings:chatSettings];
    [settingsGroups addObject:chatSettingsGroup];
    
    securitySettings = @[certSetting, pinCodeSettingButton]; //opportunisticOtrSetting fingerprintSetting
    OTRSettingsGroup *securitySettingsGroup = [[OTRSettingsGroup alloc] initWithTitle:SECURITY_STRING settings:securitySettings];
    [settingsGroups addObject:securitySettingsGroup];
    
    OTRFeedbackSetting * feedbackViewSetting = [[OTRFeedbackSetting alloc] initWithTitle:SEND_FEEDBACK_STRING description:nil];
    feedbackViewSetting.imageName = @"18-envelope.png";
    
    OTRShareSetting * shareViewSetting = [[OTRShareSetting alloc] initWithTitle:SHARE_STRING description:nil];
    shareViewSetting.imageName = @"275-broadcast.png";
    
    OTRLanguageSetting * languageSetting = [[OTRLanguageSetting alloc]initWithTitle:LANGUAGE_STRING description:nil settingsKey:kOTRSettingKeyLanguage];
    languageSetting.imageName = @"globe.png";
    
    
    // zigzagcorp coment
  //  OTRDonateSetting *donateSetting = [[OTRDonateSetting alloc] initWithTitle:DONATE_STRING description:nil];
  //  donateSetting.imageName = @"29-heart.png";
    
    OTRDeleteAllChats *deleteAllChats = [[OTRDeleteAllChats alloc] initWithTitle:CLEAR_ALL_HISTORY description:nil];
    deleteAllChats.imageName = @"delete.png";
    
    NSMutableArray *otherSettings = [NSMutableArray arrayWithCapacity:5];
    
    /*
     Оставляю только язык
     [otherSettings addObjectsFromArray:@[languageSetting,donateSetting, shareViewSetting,feedbackViewSetting]];
     */
    
     [otherSettings addObjectsFromArray:@[languageSetting, deleteAllChats]];
    
    OTRSettingsGroup *otherGroup = [[OTRSettingsGroup alloc] initWithTitle:OTHER_STRING settings:otherSettings];
    [settingsGroups addObject:otherGroup];
    settingsDictionary = newSettingsDictionary;
}

- (OTRSetting*) settingAtIndexPath:(NSIndexPath*)indexPath
{
    OTRSettingsGroup *settingsGroup = [settingsGroups objectAtIndex:indexPath.section];
    return [settingsGroup.settings objectAtIndex:indexPath.row];
}

- (NSString*) stringForGroupInSection:(NSUInteger)section
{
    OTRSettingsGroup *settingsGroup = [settingsGroups objectAtIndex:section];
    return settingsGroup.title;
}

- (NSUInteger) numberOfSettingsInSection:(NSUInteger)section
{
    OTRSettingsGroup *settingsGroup = [settingsGroups objectAtIndex:section];
    return [settingsGroup.settings count];
}

+ (BOOL) boolForOTRSettingKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:key];
}

+ (double) doubleForOTRSettingKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults doubleForKey:key];
}

+ (NSInteger) intForOTRSettingKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:key];
}

+ (float) floatForOTRSettingKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults floatForKey:key];
}

- (OTRSetting*) settingForOTRSettingKey:(NSString*)key {
    return [settingsDictionary objectForKey:key];
}

@end
