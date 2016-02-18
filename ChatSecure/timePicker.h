//
//  timePicker.h
//  pickerView
//
//  Created by Самсонов Александр on 02.11.15.
//  Copyright © 2015 LC. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "OTRBuddy.h"

@class JSQMessagesInputToolbar;


@interface timePicker : NSObject<UIPickerViewDataSource, UIPickerViewDelegate>{
    UIPickerView *picker;
  //  NSMutableArray *pickerData;
    UIButton * done;
    UIButton * cancel;
    UIButton * overlayButton;
    UIButton * timeButton;
    OTRBuddy * buddy;
   
    UITextField * curTextField;
    
}

@property (nonatomic, strong) NSArray * keys;
@property (nonatomic, strong) NSArray * values;

@property (nonatomic, strong) UIViewController * vc;

@property (nonatomic, strong) NSString * selectedOption;

-(id)initWithParent:(UIViewController *)VC;
-(void)genTimeButtom:(UITextField *)textField;
-(void)updateFramesCustomView;
-(NSString *)getSelectedOption;
-(UIPickerView *)getPickerView;
-(void)removeToView;
-(UIButton *)getTimeButtonView;
+(NSString *)getSyncTimeOption: (NSString *)buddyUsername;
+(NSString *)secondsToWord:(NSString *)seconds;
@end
