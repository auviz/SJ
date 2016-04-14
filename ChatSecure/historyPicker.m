//
//  historyPicker.m
//  SafeJab
//
//  Created by Самсонов Александр on 11.04.16.
//  Copyright © 2016 Leader Consult. All rights reserved.
//

#import "historyPicker.h"
#import "Strings.h"
#import "dbHistoryOption.h"

@implementation historyPicker

-(id)initWithView:(UIView *)superView {
    
    
    [self setupData];
    
    
    
 self.selectedOption = (int)[self.keys indexOfObject:[dbHistoryOption get]];
    
    
    self = [super init];
    
    if(self){
        
        
        self.delegate = self;
        
     
        
        self.superView = superView;
        
     CGRect bounds = self.superView.bounds;
        
        bounds.size.height = (bounds.size.height/3);
       // bounds.origin.y = (self.superView.center.y - (bounds.size.height)/2);
        
        bounds.origin.y  = (self.superView.bounds.size.height -  bounds.size.height);
        
        self.frame = bounds;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        
        self.backgroundColor = [UIColor whiteColor];
        
       // self.b
        
        if(self.selectedOption > 0){
            [self selectRow:self.selectedOption inComponent:0 animated:NO];
        }
        
        return self;
    }
    
    return nil;
    
}

-(void)setupData{
    
    if(self.keys.count == 0){
        
        
        self.keys = [historyPicker keys];
        
        self.values = [historyPicker values];

        
        
    }
    
}

+(NSArray *)keys {
    return [[NSArray alloc] initWithObjects:@"0", @"3600",@"86400", @"604800", nil];
}

+(NSArray *)values {
    return [[NSArray alloc] initWithObjects:@"Off", @"1 hour",@"1 day", @"1 week", nil];
}

+(NSString *)valueFromKey:(NSString *)key{

  int index =  (int)[[self keys] indexOfObject:key];
   
    if(index < 0) index = 0;
    
   // return @"rsfe";
    
    return [[self values] objectAtIndex:index];
    
    
}


-(void)show{
       [self setOverlayButton];
        [self setBarButtons];
   // [self setTitle];
    
    [UIView transitionWithView:self.superView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        
                         if(![overlayButton isDescendantOfView:self.superView]) {
                             [self.superView addSubview:overlayButton];
                         }
                        
                         if(![self isDescendantOfView:self.superView]) {
                            
                             [self.superView addSubview:self];
                             [self.superView  addSubview:cancel];
                              [self.superView  addSubview:title];
                             [self.superView  addSubview:done];
                             
                         }
                     //   title.hidden = NO;
                        cancel.hidden = NO;
                        done.hidden = NO;
                        overlayButton.hidden = NO;
                         self.hidden = NO;
                    } completion:nil
     ];
    

}

-(void)didClickClose{
   
    
    [UIView transitionWithView:self.superView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
    
    overlayButton.hidden = YES;
    done.hidden = YES;
    cancel.hidden = YES;
   // title.hidden = YES;
                        
   self.hidden = YES;
                    } completion:nil];
}

-(void)didClickDone{


    
  //  [dbHistoryOption set:[self.keys objectAtIndex:self.selectedOption]];
    
    [self didClickClose];
    [self.myDelegate setHistoryOption:[self.keys objectAtIndex:self.selectedOption]];
    
}

-(void)setOverlayButton{

    if(!overlayButton){
        
     
        
        
        overlayButton = [[UIButton alloc] init];
        
        overlayButton.frame = self.superView.frame;
        overlayButton.autoresizingMask = self.superView.autoresizingMask;
        [overlayButton addTarget:self action:@selector(didClickClose) forControlEvents:UIControlEventTouchUpInside];
        overlayButton.alpha = 0.6f;
        overlayButton .backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.80f alpha:1.0];
    }

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    //NSLog(@"Select Row %d %d", (int)row,  (int)component);
    
    
    
    self.selectedOption = (int)row;
    //Write the required logic here that should happen after you select a row in Picker View.
}

-(void)setTitle{
    if(!title){
        title = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.origin.y -20), self.frame.size.width, 20)];
       // title.font = [UIFont italicSystemFontOfSize:16];
        title.autoresizingMask = self.autoresizingMask|UIViewAutoresizingFlexibleLeftMargin;
        title.textAlignment = NSTextAlignmentCenter;
        //title.textColor = [UIColor whiteColor];
        title.text = KEEP_HISTORY_STRING;
        title.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    }
    
}

-(void)setBarButtons{
    
     UIColor * btnColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
    
    float withButton = 60;
    float heightButton = 40;

    
  
    
    
    if(!done){
        done = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - withButton*1.5)-5, (self.frame.origin.y), withButton*1.5, heightButton)];
        [done setTitleColor:btnColor forState:UIControlStateNormal];
        [done setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [done setTitle:@"Done" forState:UIControlStateNormal];
        [done addTarget:self action:@selector(didClickDone) forControlEvents:UIControlEventTouchUpInside];
        
         done.autoresizingMask = self.autoresizingMask|UIViewAutoresizingFlexibleLeftMargin;
        done.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
       
      //  CGRect btnDoneFrame = self.frame;
        
      //  selfFrame.size.width
        
       // done.frame = selfFrame
    }
    
    if(!cancel){
        cancel = [[UIButton alloc] initWithFrame:CGRectMake(5, (self.frame.origin.y), withButton, heightButton)];
        [cancel setTitleColor:btnColor forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(didClickClose) forControlEvents:UIControlEventTouchUpInside];
        
        cancel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
 
        
    }
    
}
//Columns in picker views

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}
//Rows in each Column

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
  //   NSLog(@"efsdfsdfs_______");
    
    return  self.keys.count;
}

-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
   // NSLog(@"efsdfsdfs_______");
    
    
    return [self.values objectAtIndex:row];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
