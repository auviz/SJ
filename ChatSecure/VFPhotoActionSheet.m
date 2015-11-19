#import "VFPhotoActionSheet.h"
#import "VFPhotoPicker.h"
#import "Strings.h"
#import "OTRMessagesViewController.h"
#import "SavePhoto.h"
#import "OTRLog.h"


//static NSString *kDefaultTitle = @"Choose photo";
//static NSString *kDefaultPhotoLibraryButtonTitle = @"From Photo Library";
//static NSString *kDefaultCameraButtonTitle = @"From Camera";
//static NSString *kDefaultCancelButtonTitle = @"Cancel";
static NSString *kDefaultDestructiveButtonTitle = @"Delete";

@interface VFPhotoActionSheet () <UIActionSheetDelegate, VFPhotoPickerDelegate>



@end

@implementation VFPhotoActionSheet {
    UIActionSheet *_actionSheet;
    VFPhotoPicker *_photoPicker;
}

@synthesize linkToBuddy;

- (instancetype)initWithViewController: (UIViewController *)viewController {
    self = [super init];
    
    _photoPicker = [[VFPhotoPicker alloc] initWithViewController:viewController];
    _photoPicker.delegate = self;
    
    _title = nil;
    _photoLibraryButtonTitle = FROM_PHOTO_LIBRARY;
    _cameraButtonTitle = FROM_CAMERA;
    _cancelButtonTitle = CANCEL_STRING;
    _locationButtonTitle = MY_LOCATION;
    _destructiveButtonTitle = kDefaultDestructiveButtonTitle;
    
    return self;
}

- (void)setCropEnabled:(BOOL)cropEnabled {
    _photoPicker.cropEnabled = cropEnabled;
}

- (BOOL)cropEnabled {
    return _photoPicker.cropEnabled;
}

- (void)setCropAspectRatio:(CGSize)cropAspectRatio {
    _photoPicker.cropAspectRatio = cropAspectRatio;
}

- (CGSize) cropAspectRatio {
    return _photoPicker.cropAspectRatio;
}

- (void)setCropAspectRatioFixed:(BOOL)cropAspectRatioFixed {
    _photoPicker.cropAspectRatioFixed = cropAspectRatioFixed;
}

- (BOOL)cropAspectRatioFixed {
    return _photoPicker.cropAspectRatioFixed;
}

- (void)setCropStandardAspectRatiosAvailable:(BOOL)cropStandardAspectRatiosAvailable {
    _photoPicker.cropStandardAspectRatiosAvailable = cropStandardAspectRatiosAvailable;
}

- (BOOL)cropStandardAspectRatiosAvailable {
    return _photoPicker.cropStandardAspectRatiosAvailable;
}

- (void)setPhotoSize:(CGSize)photoSize {
    _photoPicker.photoSize = photoSize;
}

- (CGSize)photoSize {
    return _photoPicker.photoSize;
}

- (void)setCameraPickerProvider:(id<VFPickerControllerProvider>)cameraPickerProvider {
    _photoPicker.cameraPickerProvider = cameraPickerProvider;
}

- (id<VFPickerControllerProvider>)cameraPickerProvider {
    return _photoPicker.cameraPickerProvider;
}

- (void)setPhotoLibraryPickerProvider:(id<VFPickerControllerProvider>)photoLibraryPickerProvider {
    _photoPicker.photoLibraryPickerProvider = photoLibraryPickerProvider;
}

- (id<VFPickerControllerProvider>)photoLibraryPickerProvider {
    return _photoPicker.photoLibraryPickerProvider;
}

- (void)show {
    [self showWithDestructiveButton:NO];
}

- (void)showWithDestructiveButton:(BOOL)hasDestructiveButton {
    NSString *destructiveButtonTitle = (hasDestructiveButton) ? _destructiveButtonTitle : nil;
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:_title
                                               delegate:self
                                      cancelButtonTitle:_cancelButtonTitle
                                 destructiveButtonTitle:destructiveButtonTitle
                                      otherButtonTitles:_photoLibraryButtonTitle, _cameraButtonTitle, _locationButtonTitle, nil];
    [_actionSheet showInView:_photoPicker.viewController.view];
}

- (void) showWithDestructiveButtonTitle:(NSString *)destructiveButtonTitle {
    _actionSheet = [[UIActionSheet alloc] initWithTitle:_title
                                               delegate:self
                                      cancelButtonTitle:_cancelButtonTitle
                                 destructiveButtonTitle:_destructiveButtonTitle
                                      otherButtonTitles:_photoLibraryButtonTitle, _cameraButtonTitle, nil];

    
    [_actionSheet showInView:_photoPicker.viewController.view];
}

- (void)cancel {
    [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:NO];
    _actionSheet = nil;
}

- (void)toPhotoLibrary {
    [_photoPicker pickFromPhotoLibrary];
}

- (void)startCamera {
    [_photoPicker pickFromCamera];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    _actionSheet = nil;
    
  
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self notifyDidDestructPhoto];
        return;
    }
    
    NSInteger index = buttonIndex;
    if (actionSheet.destructiveButtonIndex != -1) {
        index--;
    }
    
    if (index == 0) {
        
        
        [self toPhotoLibrary];
    } else if (index == 1) {
        [self startCamera];
    }
}

#pragma mark VFPhotoPickerDelegate

- (void)photoPicker:(VFPhotoPicker *)photoPicker didPickPhoto:(UIImage *)photo {
    
    
      DDLogInfo(@"PICK PHOTO ZIG");
    
    
    NSString* uid = [SavePhoto genUnicNameForPhoto];
    
    SavePhoto *sp = [[SavePhoto alloc] init];
    
    sp.linkToMessagesViewController = self.linkToBuddy;
    
    [sp postToServer:photo unicName:uid];
    
    
 //   [self.linkToBuddy sendPhoto:photo];
  
   // [self notifyDidPickPhoto:photo];
}

- (void)photoPicker:(VFPhotoPicker *)photoPicker didPickPhotoAssets:(NSArray *)assets fromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary {
    [self notifyDidPickPhotoAssets:assets fromAssetsLibrary:assetsLibrary];
}

#pragma mark  Delegate notifications

- (void)notifyDidPickPhoto:(UIImage *)photo {
    if ([self.delegate respondsToSelector:@selector(photoActionSheet:didPickPhoto:)]) {
        [self.delegate photoActionSheet:self didPickPhoto:photo];
    }
}

- (void)notifyDidPickPhotoAssets:(NSArray *)assets fromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary {
    if ([self.delegate respondsToSelector:@selector(photoActionSheet:didPickPhotoAssets:fromAssetsLibrary:)]) {
        [self.delegate photoActionSheet:self didPickPhotoAssets:assets fromAssetsLibrary:assetsLibrary];
    }
}

- (void)notifyDidDestructPhoto {
    if ([self.delegate respondsToSelector:@selector(photoActionSheetDidDestructPhoto:)]) {
        [self.delegate photoActionSheetDidDestructPhoto:self];
    }
}

@end
