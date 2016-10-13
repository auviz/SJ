//
//  OTRDatabaseUnlockViewController.m
//  Off the Record
//
//  Created by David Chiles on 5/5/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRDatabaseUnlockViewController.h"
#import "OTRDatabaseManager.h"
#import "OTRConstants.h"
#import "OTRAppDelegate.h"
#import "Strings.h"
#import "pinCode.h"
#import "OTRLog.h"


@interface OTRDatabaseUnlockViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *passphraseTextField;
@property (nonatomic, strong) UIButton *unlockButton;
@property (nonatomic, strong) UIButton *forgotPassphraseButton;
@property (nonatomic, strong) NSLayoutConstraint *textFieldCenterXConstraint;

@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;

@property (nonatomic, weak) id UIKeyboardDidShowNotificationObject;
@property (nonatomic, strong) UIViewController *viewBeforeLock;

@end

@implementation OTRDatabaseUnlockViewController

//@synthesize isChangePin;


-(id)initChangePin
{
    if (self = [super init]) {
        
        self.isChangePin = YES;
        
         return self;
        
    }
    
    return nil;
}

-(id)initWithView:(UIViewController *)view
{
    if (self = [super init]) {
        
        
        self.viewBeforeLock = view;
        
        
        
        
        return self;
        
    }
    return nil;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
 
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.passphraseTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.passphraseTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.passphraseTextField.secureTextEntry = YES;
    self.passphraseTextField.borderStyle = UITextBorderStyleNone;
    self.passphraseTextField.placeholder = @"----";
    self.passphraseTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.passphraseTextField.returnKeyType = UIReturnKeyDone;
    self.passphraseTextField.delegate = self;
    self.passphraseTextField.font = [UIFont boldSystemFontOfSize:81.0f];
    self.passphraseTextField.textColor = [UIColor grayColor];
    self.passphraseTextField.textAlignment = NSTextAlignmentCenter;
    self.passphraseTextField.keyboardAppearance = UIKeyboardAppearanceDark;
  
   
    [self.passphraseTextField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:self.passphraseTextField];
    
 
    
    self.unlockButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.unlockButton setTitle:UNLOCK_STRING forState:UIControlStateNormal];
   // self.unlockButton.enabled = NO;
    [self.unlockButton addTarget:self action:@selector(unlockTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.unlockButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    if(!self.isChangePin){ //zigzagcorp if
         self.unlockButton.hidden = YES;
    }
    
   
    
    [self.view addSubview:self.unlockButton];
    
    
    self.forgotPassphraseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.forgotPassphraseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.forgotPassphraseButton setTitle:FORGOT_PASSPHRASE_STRING forState:UIControlStateNormal];
    [self.forgotPassphraseButton addTarget:self action:@selector(forgotTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if(self.isChangePin){ //zigzagcorp if
         self.forgotPassphraseButton.hidden = YES;
    }
    
    [self.view addSubview:self.forgotPassphraseButton];
    
    
    [self setupConstraints];
    
    
    
    
    [self.passphraseTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    
    __weak OTRDatabaseUnlockViewController *welf = self;
    self.UIKeyboardDidShowNotificationObject = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [welf keyboardDidShow:note];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.UIKeyboardDidShowNotificationObject];
}

- (void)setupConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_unlockButton,_passphraseTextField,_forgotPassphraseButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_unlockButton]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_forgotPassphraseButton]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(100)-[_passphraseTextField]-[_unlockButton]" options:0 metrics:nil views:views]];
    
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.forgotPassphraseButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:self.bottomConstraint];
    
    
    self.textFieldCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.passphraseTextField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [self.view addConstraint:self.textFieldCenterXConstraint];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.passphraseTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.unlockButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
}



-(void)textFieldDidChange :(UITextField *)theTextField{
    
   // self.passphraseTextField.text
    
    if(theTextField.text.length >= 4 ){
        
        if(self.isChangePin){
            
            //Смена пинкода
            
            if(newPinFirstAttempt.length < 2){
                newPinFirstAttempt=theTextField.text;
                self.passphraseTextField.text = @"";
            } else if(newPinSecondAttempt.length < 2) {
                newPinSecondAttempt=theTextField.text;
                
                if([newPinFirstAttempt isEqualToString:newPinSecondAttempt]){
                    //Удача
                    [pinCode set:newPinFirstAttempt];
                    newPinFirstAttempt=nil;
                    newPinSecondAttempt=nil;
                     [self.navigationController popViewControllerAnimated:YES];
                } else {
                    //Провал
                    newPinFirstAttempt=nil;
                    newPinSecondAttempt=nil;
                    [self showPasswordError];
                     self.passphraseTextField.text = @"";
                    
                }
                
            }
      
            
        } else {
        
            //Проверка пинкода
            
            if([theTextField.text isEqualToString:[pinCode get]]){
                
                
                DDLogInfo( @"text changed: %@", theTextField.text);
                [self.passphraseTextField setEnabled:NO];
                
                
                if(self.viewBeforeLock){
                    
                  
                    [OTRAppDelegate appDelegate].window.rootViewController = self.viewBeforeLock;
           
            
                    self.viewBeforeLock = nil;
                    
                    
                   // [self dismissViewControllerAnimated:YES completion:^{
                   //     [OTRAppDelegate appDelegate].window.rootViewController = self.viewBeforeLock;
                    //    self.viewBeforeLock = nil;
                   // }];
                    
                    
                    
                  
                    
                } else{
                    
                      [[OTRAppDelegate appDelegate] showConversationViewController];
     
                
                }
             
                
            
                
               // [self dismissViewControllerAnimated:YES completion:nil];
          
               
                
            } else {
                   [self showPasswordError];
                    self.passphraseTextField.text = @"";
            }
        
    }
    
    }
    
   
}

- (void)unlockTapped:(id)sender
{
    //Удаление пинкода
        [pinCode set:@""];
      [self.navigationController popViewControllerAnimated:YES];
    /*
    if(![self.passphraseTextField.text length]) {
        [self showPasswordError];
        return;
    }
    
    [[OTRDatabaseManager sharedInstance] setDatabasePassphrase:self.passphraseTextField.text remember:NO error:nil];
    if ([[OTRDatabaseManager sharedInstance] setupDatabaseWithName:OTRYapDatabaseName]) {
        [[OTRAppDelegate appDelegate] showConversationViewController];
    }
    else {
        [self showPasswordError];
    }
     */
    
    //[[OTRAppDelegate appDelegate] showConversationViewController];
    
}

- (void)showPasswordError
{
    [self shake:self.passphraseTextField number:10 direction:1];
    [UIView animateWithDuration:0.1 animations:^{
        self.passphraseTextField.backgroundColor = [UIColor redColor];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0.1 options:0 animations:^{
            self.passphraseTextField.backgroundColor = [UIColor whiteColor];
        } completion:nil];
    }];
}

- (void)forgotTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:FORGOT_PASSPHRASE_STRING message:FORGOT_PASSPHRASE_INFO_STRING delegate:nil cancelButtonTitle:nil otherButtonTitles:OK_STRING, nil];
    [alertView show];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSValue *endFrameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    
    self.bottomConstraint.constant = keyboardEndFrame.size.height * -1;
    
    [self.view layoutIfNeeded];
}

-(void)shake:(UIView *)view number:(int)shakes direction:(int)direction
{
    if (shakes > 0) {
        self.textFieldCenterXConstraint.constant = 5*direction;
    }
    else {
        self.textFieldCenterXConstraint.constant = 0.0;
    }
    
    
    [UIView animateWithDuration:0.03 animations:^ {
        [self.view layoutIfNeeded];
    }
                     completion:^(BOOL finished)
    {
         if(shakes > 0)
         {
             [self shake:view number:shakes-1 direction:direction *-1];
         }
        
     }];
}

- (void) checkPasswordLength:(NSString *)password {
    if ([password length]) {
        self.unlockButton.enabled = YES;
    } else {
        self.unlockButton.enabled = NO;
    }
}

#pragma - mark UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
     zigzagcorp comment
    if ([string isEqualToString:@"\n"]) {
        [self unlockTapped:textField];
        return NO;
    }
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self checkPasswordLength:newString];
     */
    return YES;
}


- (BOOL)shouldAutorotate {return YES;}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {return (UIInterfaceOrientationMaskPortrait);}


@end
