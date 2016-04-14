//
//  historyPicker.h
//  SafeJab
//
//  Created by Самсонов Александр on 11.04.16.
//  Copyright © 2016 Leader Consult. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTRKeepHistorySetting.h"

@class historyPicker;


@protocol historyPickerDelegate
- (void) setHistoryOption:(NSString *)option;
@end


@interface historyPicker : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>{
    UIButton * overlayButton;
    UIButton * done;
    UIButton * cancel;
    UILabel * title;
}
@property (nonatomic, strong) OTRKeepHistorySetting * setting;
@property (nonatomic, strong) UIView *superView;

@property (nonatomic, strong) id<historyPickerDelegate> myDelegate;

@property  (nonatomic, strong) NSArray * keys;

@property  (nonatomic, strong) NSArray * values;

@property int selectedOption;

-(id)initWithView:(UIView *)superView;
-(void)show;
+(NSString *)valueFromKey:(NSString *)key;


@end
