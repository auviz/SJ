//
//  timePicker.h
//  pickerView
//
//  Created by Самсонов Александр on 02.11.15.
//  Copyright © 2015 LC. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class JSQMessagesInputToolbar;

@interface timePicker : NSObject<UIPickerViewDataSource, UIPickerViewDelegate>{
    UIPickerView *picker;
  //  NSMutableArray *pickerData;
    UIButton * done;
    UIButton * cancel;
    UIButton * overlayButton;
    UIButton * timeButton;
   
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

@end
