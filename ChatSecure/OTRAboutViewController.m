//
//  OTRAboutViewController.m
//  Off the Record
//
//  Created by Chris Ballinger on 12/9/11.
//  Copyright (c) 2011 Chris Ballinger. All rights reserved.
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

#import "OTRAboutViewController.h"
#import "Strings.h"
#import "OTRConstants.h"
#import "UIActionSheet+Blocks.h"
#import "OTRAppDelegate.h"
#import "PureLayout.h"
#import "TTTAttributedLabel.h"
#import "OTRSocialButtonsView.h"
#import "OTRAcknowledgementsViewController.h"
#import "OTRSafariActionSheet.h"
#import "NSURL+chatsecure.h"


static NSString *const kDefaultCellReuseIdentifier = @"kDefaultCellReuseIdentifier";

@interface OTRAboutTableCellData : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *url;
+ (instancetype) cellDataWithTitle:(NSString*)title url:(NSURL*)url;
@end
@implementation OTRAboutTableCellData
+ (instancetype) cellDataWithTitle:(NSString *)title url:(NSURL *)url {
    OTRAboutTableCellData *cellData = [[OTRAboutTableCellData alloc] init];
    cellData.title = title;
    cellData.url = url;
    return cellData;
}
@end

@interface OTRAboutViewController() <TTTAttributedLabelDelegate>

@property (nonatomic, strong) UIView *socialView;
@property (nonatomic, strong) TTTAttributedLabel *headerLabel;
@property (nonatomic, strong) OTRSocialButtonsView *socialButtonsView;
@property (nonatomic, strong) NSArray *cellData;
@property (nonatomic) BOOL hasAddedConstraints;
@end

@implementation OTRAboutViewController

- (id)init {
    if (self = [super init]) {
        self.title = ABOUT_STRING;
        self.hasAddedConstraints = NO;
    }
    return self;
}

#pragma mark - View lifecycle



-(void)setupLabelView {

    
    NSDate *date = [[NSDate alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:date];
    
    
    //float width = [[self view] bounds].size.width;
    NSString *versionAppInDevice = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    self.LabelView = [[UILabel alloc] init];
    
    self.LabelView.alpha = 0.9f;
    self.LabelView.layer.zPosition = 10;
    self.LabelView.shadowColor = [UIColor blackColor];

    self.LabelView.font = [UIFont italicSystemFontOfSize:16];
    self.LabelView.text = [NSString stringWithFormat:@"Safe Jab v%@ © %@ LC", versionAppInDevice, year];
   // self.LabelView.numberOfLines = 1;
   // self.LabelView.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone

    //self.LabelView.adjustsFontSizeToFitWidth = YES;
    //self.LabelView.minimumScaleFactor = 10.0f/12.0f;
    //self.LabelView.clipsToBounds = YES;
    self.LabelView.backgroundColor = [UIColor grayColor];
    self.LabelView.textColor = [UIColor whiteColor];
  
    self.LabelView.textAlignment = NSTextAlignmentCenter;
    
    self.LabelView.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    
    [self.LabelView addGestureRecognizer:recognizer];

  
    [self.view addSubview:self.LabelView];
}

- (void)tapAction {
   [self handleOpeningURL:[NSURL otr_projectURL]];
}

-(void)setupWebView {
    
   // float width = [[self view] bounds].size.width;
  //  float height = [[self view] bounds].size.height;
    
    self.webView = [[UIWebView alloc] init];
    [self.webView  setDelegate:self];
    self.webView.layer.zPosition = 1;
    NSString *urlAddress = @"https://safejab.com/reviews/index.php";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView  loadRequest:requestObj];
    
    [self.view addSubview:self.webView ];
    
}

-(void)setupBackGround{
    self.backGround = [[UIView alloc] init];
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background"]];

    
    
     self.backGround.layer.zPosition = -100;
    self.backGround.backgroundColor = background;
    [self.view addSubview: self.backGround];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Fixes frame problems on iOS 7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
    }

    

    
    //[self setupVersionLabel];
   // [self setupImageView];
    [self setupBackGround];
    [self setupWebView];
    [self setupLabelView];
    
    //[self setupSocialView];
    //[self setupTableView];

  //   [self customUpdateView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     self.webView.alpha= 0;
    

}




-(void)viewWillLayoutSubviews {
   // NSLog(@"viewWillLayoutSubviews");
    [super viewWillLayoutSubviews];
    [self customUpdateView];
    
    
}

- (void) customUpdateView{

    float width = [[self view] bounds].size.width;
    float height = [[self view] bounds].size.height;
    
    self.webView.frame = CGRectMake(0, 0, width, height);
    self.backGround.frame = CGRectMake(0, 0, width, height);
    self.LabelView.frame  = CGRectMake(0, 0, width, 25);
  
}




- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    
    OTRAccount * acc = SJAccount();
    NSString *versionAppInDevice = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    
   NSString *jsStrAcc = [NSString stringWithFormat:@"document.getElementById('nameInput').value = '%@'", acc.username];
    
     NSString *jsStrVer = [NSString stringWithFormat:@"document.getElementById('sjInput').value = '%@'", versionAppInDevice];
    
    [webView stringByEvaluatingJavaScriptFromString:jsStrAcc];
    [webView stringByEvaluatingJavaScriptFromString:jsStrVer];
    


    // начинаем анимацию
    [UIView beginAnimations:nil context:nil];
    // продолжительность анимации - 1 секунда
    [UIView setAnimationCurve:1.0];
    // пауза перед началом анимации - 1 секунда
     [UIView setAnimationDelay:1.0];
    // тип анимации устанавливаем - "начало медленное - конец быстрый"
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    // собственно изменения, которые будут анимированы
    self.webView.alpha = 1;
    // команда, непосредственно запускающая анимацию.
    [UIView commitAnimations];
 
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
}

- (void)didTapImageView:(id)sender
{
  
    [self handleOpeningURL:[NSURL otr_projectURL]];
}

- (void)handleOpeningURL:(NSURL *)url
{
    OTRSafariActionSheet *safariActionSheet = [[OTRSafariActionSheet alloc] initWithUrl:url];
    [OTRAppDelegate presentActionSheet:safariActionSheet inView:self.view];
}


#pragma - mark TTTatributedLabelDelegate Methods

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [self handleOpeningURL:url];
}

@end
