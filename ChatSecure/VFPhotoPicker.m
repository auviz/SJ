#import "VFPhotoPicker.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+PhotoPicker.h"
#import "VFAspectRatio.h"
#import "VFImageCropViewController.h"
#import "VFStandardPickerControllerProvider.h"
#import "VFImageCropConfiguration.h"
#import "OTRLog.h"

@interface VFPhotoPicker () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation VFPhotoPicker {
    __weak UIViewController *_viewController;
    
    BOOL _statusBarHidden;
    UIStatusBarStyle _statusBarStyle;
    
    id<VFPickerControllerProvider> _standardPickerProvider;
    
    UIModalTransitionStyle _modalTransitionStyle;
    UIModalPresentationStyle _modalPresentationStyle;
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    
    _viewController = viewController;
    
    _cropStandardAspectRatiosAvailable = YES;
    
    _statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    _statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    return self;
}

- (UIViewController *)viewController {
    return _viewController;
}

- (void)setCameraPickerProvider:(id<VFPickerControllerProvider>)cameraPickerProvider {
    _cameraPickerProvider = cameraPickerProvider;
    _cameraPickerProvider.picker = self;
}

- (void)setPhotoLibraryPickerProvider:(id<VFPickerControllerProvider>)photoLibraryPickerProvider {
    _photoLibraryPickerProvider = photoLibraryPickerProvider;
    _photoLibraryPickerProvider.picker = self;
}

#pragma mark Present picker controller

- (void)pickFromPhotoLibrary {
    DDLogInfo(@"Present");
    UIViewController *pickerController = [self photoLibraryPickerController];
    [self presentPickerController:pickerController];
}

- (void)pickFromCamera {
    UIViewController *pickerController = [self cameraPickerController];
    [self presentPickerController:pickerController];
}

- (void)presentPickerController:(UIViewController *)pickerController {
    if (pickerController) {
        _modalTransitionStyle = pickerController.modalTransitionStyle;
        _modalPresentationStyle = pickerController.modalPresentationStyle;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_viewController presentViewController:pickerController animated:YES completion:nil];
        }];
    }
}

#pragma mark Process result from picker controller

- (void)pickerController:(UIViewController *)pickerController didPickImage:(UIImage *)image {
    if (_cropEnabled) {
        [self cropImageAndSendToDelegate:image pickerController:pickerController];
    } else {
        [self resizeImageIfNeededAndSendToDelegate:image];
        [self dismissImagePickerController];
    }
}

- (void)pickerController:(UIViewController *)pickerController didPickAssets:(NSArray *)assets fromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary {
    [self notifyDidPickPhotoAssets:assets fromAssetsLibrary:assetsLibrary];
    [self dismissImagePickerController];
}

- (void)pickerControllerDidCancel:(UIViewController *)pickerController {
    [self dismissImagePickerController];
}

#pragma mark Crop and resize

- (void)resizeImageIfNeededAndSendToDelegate:(UIImage *)originalImage {
    UIImage *resizedImage = originalImage;
    if (_photoSize.width != 0 || _photoSize.height != 0) {
        resizedImage = [originalImage resizeWithSize:_photoSize];
    }
    
    [self notifyDidPickPhoto:resizedImage];
}

- (void)cropImageAndSendToDelegate:(UIImage *)image pickerController:(__weak UIViewController *)pickerController {
    VFAspectRatio *aspectRatio = nil;
    
    if (CGSizeEqualToSize(_cropAspectRatio, CGSizeZero) == NO) {
        NSInteger w = _cropAspectRatio.width;
        NSInteger h = _cropAspectRatio.height;
        aspectRatio = VFAspectRatioMake(w, h);
    }
    
    VFImageCropViewController *crop = [[VFImageCropViewController alloc] initWithImage:image
                                                                           aspectRatio:aspectRatio];
    
    crop.aspectRatioFixed = _cropAspectRatioFixed;
    crop.restoreStatusBarStyle = @(_statusBarStyle);
    
    crop.cancelActionHandler = ^(VFImageCropViewController *sender) {
        [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden];
        [pickerController dismissViewControllerAnimated:YES completion:nil];
    };
    
    crop.cropImageActionHandler = ^(VFImageCropViewController *sender, UIImage *image, CGRect cropRect) {
        [self resizeImageIfNeededAndSendToDelegate:image];
        [self dismissImagePickerController];
    };
    
    VFImageCropConfiguration *configuration = [VFImageCropConfiguration new];
    configuration.selectAspectRatioActionAvailable = _cropStandardAspectRatiosAvailable;
    
    UINavigationController *navigationVC = [configuration imageCropViewControllerModalConfiguration:crop];
    navigationVC.modalTransitionStyle = _modalTransitionStyle;
    navigationVC.modalPresentationStyle = _modalPresentationStyle;
    
    [pickerController presentViewController:navigationVC animated:YES completion:nil];
}

- (void)dismissImagePickerController {
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden];
    
    [_viewController dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle animated:NO];
    }];
}

#pragma mark Create picker controllers

- (UIViewController *)photoLibraryPickerController {
    if (self.photoLibraryPickerProvider) {
        return [self.photoLibraryPickerProvider pickerController];
    }
    
    _standardPickerProvider = [VFStandardPickerControllerProvider photoLibraryPickerProvider];
    _standardPickerProvider.picker = self;
    return [_standardPickerProvider pickerController];
}

- (UIViewController *)cameraPickerController {
    if (self.cameraPickerProvider) {
        return [self.cameraPickerProvider pickerController];
    }
    
    _standardPickerProvider = [VFStandardPickerControllerProvider cameraPickerProvider];
    _standardPickerProvider.picker = self;
    return [_standardPickerProvider pickerController];
}

#pragma mark Delegate notifications

- (void)notifyDidPickPhoto:(UIImage *)photo {
    if ([self.delegate respondsToSelector:@selector(photoPicker:didPickPhoto:)]) {
        [self.delegate photoPicker:self didPickPhoto:photo];
    }
}

- (void)notifyDidPickPhotoAssets:(NSArray *)assets fromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary {
    if ([self.delegate respondsToSelector:@selector(photoPicker:didPickPhotoAssets:fromAssetsLibrary:)]) {
        [self.delegate photoPicker:self didPickPhotoAssets:assets fromAssetsLibrary:assetsLibrary];
    }
}

@end
