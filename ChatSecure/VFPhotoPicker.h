#import <Foundation/Foundation.h>

@class ALAssetsLibrary;
@protocol VFPhotoPickerDelegate;
@protocol VFPickerControllerProvider;

@interface VFPhotoPicker : NSObject

@property (nonatomic) BOOL    cropEnabled;
@property (nonatomic) CGSize  cropAspectRatio;
@property (nonatomic) BOOL    cropAspectRatioFixed;
@property (nonatomic) BOOL    cropStandardAspectRatiosAvailable;
@property (nonatomic) CGSize  photoSize;

@property (nonatomic, readonly) UIViewController *viewController;
@property (nonatomic, weak) id <VFPhotoPickerDelegate> delegate;

@property (nonatomic, strong) id<VFPickerControllerProvider> cameraPickerProvider;
@property (nonatomic, strong) id<VFPickerControllerProvider> photoLibraryPickerProvider;

- (instancetype)initWithViewController:(UIViewController *)viewController;

- (void)pickFromPhotoLibrary;
- (void)pickFromCamera;

/**
  * This methods must be called from custom pickers to deliver image ar assets.
*/
- (void)pickerController:(UIViewController *)pickerController didPickImage:(UIImage *)image;
- (void)pickerController:(UIViewController *)pickerController didPickAssets:(NSArray *)assets fromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary;
- (void)pickerControllerDidCancel:(UIViewController *)pickerController;

@end

@protocol VFPhotoPickerDelegate <NSObject>

@optional

- (void)photoPicker:(VFPhotoPicker *)photoPicker didPickPhoto:(UIImage *)photo;
- (void)photoPicker:(VFPhotoPicker *)photoPicker didPickPhotoAssets:(NSArray *)assets fromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary;

@end


@protocol VFPickerControllerProvider <NSObject>

// will be set by VFPhotoPicker
@property (nonatomic, weak) VFPhotoPicker *picker;

/**
  * Custom picker controller
*/
- (UIViewController *)pickerController;

@end