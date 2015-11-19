//
//  timePicker.m
//  pickerView
//
//  Created by Самсонов Александр on 02.11.15.
//  Copyright © 2015 LC. All rights reserved.
//

#import "timePicker.h"



@implementation timePicker


-(id)initWithParent:(UIViewController *)VC{
    
    
    self = [super init];
    
    if(self){
        self.vc = VC;
        [self setupData];
        [self setupCustomView];
        [self updateFramesCustomView];
        return  self;
    }
    
    
    return  nil;
    
}




-(void)setupData{
    
    if(self.keys.count == 0){
        
        
        self.keys = [[NSArray alloc] initWithObjects:@"0", @"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"
                          ,@"11",@"12",@"13",@"14",@"15",@"30",@"60",@"3600",@"86400", @"604800", nil];
        
        self.values = [[NSArray alloc] initWithObjects:@"Off", @"1 second",@"2 seconds",@"3 seconds",@"4 seconds",@"5 seconds",@"6 seconds",@"7 seconds",@"8 seconds",@"9 seconds",@"10 seconds"
                          ,@"11 seconds",@"12 seconds",@"13 seconds",@"14 seconds",@"15 seconds",@"30 seconds",@"1 minute",@"1 hour",@"1 day", @"1 week", nil];
        
        
        
     
  
   
    
        
    
        
    }
    
}




-(void)setupCustomView{
  //  pickerData= [[NSMutableArray alloc] initWithObjects:@"English",@"Spanish",@"French",@"Greek",
                // @"Japaneese",@"Korean",@"Hindi", nil];
    
    if(!picker){
        picker = [[UIPickerView alloc] init];
        picker.showsSelectionIndicator = YES;
        picker.hidden = YES;
        picker.delegate = self;
        picker.backgroundColor = [UIColor whiteColor];
    
        
        
        
        
        [picker selectRow:5 inComponent:0 animated:NO];
        
          [self.vc.view addSubview:picker];
    }
    
    if(!overlayButton){
        overlayButton = [[UIButton alloc] init];
        [overlayButton addTarget:self action:@selector(didClickClose:) forControlEvents:UIControlEventTouchUpInside];
        overlayButton.alpha = 0.6f;
        overlayButton .backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.80f alpha:1.0];
    }
    
    
    UIColor * btnColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
    
    
    if(!done){
        done = [[UIButton alloc] init];
        [done setTitleColor:btnColor forState:UIControlStateNormal];
        [done setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [done setTitle:@"Done" forState:UIControlStateNormal];
        [done addTarget:self action:@selector(didClickDone:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if(!cancel){
        cancel = [[UIButton alloc] init];
        [cancel setTitleColor:btnColor forState:UIControlStateNormal];
         [cancel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(didClickClose:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

-(void)updateFramesCustomView {
    
    if(picker){
        
        
        float width = self.vc.view.frame.size.width;
        float height = self.vc.view.frame.size.height;
        float pickerHeght = height / 3;
        CGRect newPickerFrame = CGRectMake(0, (height - pickerHeght), width, pickerHeght);
       
        picker.frame = newPickerFrame;
        

 
        
        
        
        overlayButton.frame = CGRectMake(0, 0, width, (height - pickerHeght));
        
        float withButton = 60;
        float heightButton = 30;
        
        CGRect btnDoneFrame = CGRectMake((width - withButton), (height - pickerHeght), withButton, heightButton);
        done.frame = btnDoneFrame;
        
        CGRect btnCancelFrame = CGRectMake(0, (height - pickerHeght), withButton, heightButton);
        cancel.frame = btnCancelFrame;
        
    }
    
    
}


-(void)addToView {
    
 
    
    [self.vc.view addSubview:overlayButton];
    picker.hidden = NO;
    [self.vc.view addSubview:done];
    [self.vc.view addSubview:cancel];
}

-(void)removeToView{
    [overlayButton removeFromSuperview];
   // [picker removeFromSuperview];
    picker.hidden = YES;
    [done removeFromSuperview];
    [cancel removeFromSuperview];
}





-(void)didClickDone:(id)sender{
    
   // self.selectedOption = [pickerData objectAtIndex:row];

    [self chTitleTimeButtom:self.selectedOption];
    [self hidePicker];
    

    
}

-(void)hidePicker{
    
    [UIView transitionWithView:self.vc.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self removeToView];
                    } completion:nil
     ];
    
}

-(void)didClickClose:(id)sender{
    

    
    [self hidePicker];
  //  self.selectedOption = nil;
    
    /*
     // начинаем анимацию
     [UIView beginAnimations:nil context:nil];
     // продолжительность анимации - 1 секунда
     [UIView setAnimationCurve:1.0];
     // пауза перед началом анимации - 1 секунда
     // [UIView setAnimationDelay:1.0];
     // тип анимации устанавливаем - "начало медленное - конец быстрый"
     [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
     // собственно изменения, которые будут анимированы
     
     [self removeToView];
     // команда, непосредственно запускающая анимацию.
     [UIView commitAnimations];
     */
    
}

//Columns in picker views

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}
//Rows in each Column

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    

    
    return  self.keys.count;
}

-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    

    
    return [self.values objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    //NSLog(@"Select Row %d %d", (int)row,  (int)component);
    
   
    
    self.selectedOption = [self.keys objectAtIndex:row];
    //Write the required logic here that should happen after you select a row in Picker View.
}


-(void)chTitleTimeButtom:(NSString *)selectedOption{
    
    if(!selectedOption) {
        selectedOption =@"5"; //Default value
        self.selectedOption =  selectedOption;
    }
    
    NSString * newTitle;
    
    if([selectedOption isEqualToString:@"0"]) { newTitle = nil; }
    else if([selectedOption isEqualToString:@"60"]) { newTitle = @"1m"; }
    else if([selectedOption isEqualToString:@"3600"]) { newTitle = @"1h"; }
    else if([selectedOption isEqualToString:@"86400"]) { newTitle = @"1d"; }
    else if([selectedOption isEqualToString:@"604800"]) { newTitle = @"1w"; }
    else {
        newTitle =[NSString stringWithFormat:@"%@s", selectedOption];
    }

    
    
    if(!newTitle){
        
        
        
        [timeButton setImage:[UIImage imageNamed:@"timer"] forState:UIControlStateNormal];
        [timeButton setTitle:nil forState:UIControlStateNormal];
    } else {
        
      
        [timeButton setImage:nil forState:UIControlStateNormal];
        
         [timeButton setTitle:newTitle forState:UIControlStateNormal];
       // [timeButton setImage:nil forState:UIControlStateNormal];
       
        
    }
    
}


-(void)genTimeButtom:(UITextField *)textField{
    
    curTextField = textField;
    
    float width = textField.frame.size.width;
   // float height = textField.frame.size.height;
    float height = 30;

    float btnWidth= 30; //Оригинальный размер image
    float btnHeight = 34; //Оригинальный размер image
    
   
        btnWidth = (btnWidth);
        btnHeight = (btnHeight);
    
    CGRect newFrame = CGRectMake((width - btnWidth) , ((height/2)- (btnHeight/2)), btnWidth, btnHeight);
    
    
    
    if(!timeButton){
    
    timeButton = [[UIButton alloc] init];
    [timeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    //[timeButton setTitle:@"Cancel" forState:UIControlStateNormal];
    timeButton.titleLabel.autoresizesSubviews = YES;
    timeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    //    timeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    timeButton.frame = newFrame;
    [timeButton setImage:[UIImage imageNamed:@"timer"] forState:UIControlStateNormal];
    [timeButton addTarget:self action:@selector(didOpenPicker:) forControlEvents:UIControlEventTouchUpInside];
  
      [textField addSubview:timeButton];
    
    } else {
         timeButton.frame = newFrame;
    }
    
  
}

-(void)didOpenPicker: (id )sender{
  
     [curTextField resignFirstResponder];
    [UIView transitionWithView:self.vc.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                       
                        [self addToView];
                    
                    } completion:nil
     ];
}

-(NSString *)getSelectedOption {
    
    if([self.selectedOption isEqualToString:@"0"]){
        
        return nil;
        
    } else if(self.selectedOption){
        
        return self.selectedOption;
        
    } else {
        
        return nil;
        
    }
}


@end
