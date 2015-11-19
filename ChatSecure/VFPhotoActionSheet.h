#import "VFPhotoPicker.h"


@class ALAssetsLibrary;
@protocol VFPhotoActionSheetDelegate;

@interface VFPhotoActionSheet : NSObject

@property (nonatomic, weak) id <VFPhotoActionSheetDelegate> delegate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *photoLibraryButtonTitle;
@property (nonatomic, copy) NSString *cameraButtonTitle;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *destructiveButtonTitle;
@property (nonatomic, copy) NSString *locationButtonTitle;

@property (nonatomic) BOOL    cropEnabled;
@property (nonatomic) CGSize  cropAspectRatio;
@property (nonatomic) BOOL    cropAspectRatioFixed;
@property (nonatomic) BOOL    cropStandardAspectRatiosAvailable;
@property (nonatomic) CGSize  photoSize;

@property (nonatomic, strong) id<VFPickerControllerProvider> cameraPickerProvider;
@property (nonatomic, strong) id<VFPickerControllerProvider> photoLibraryPickerProvider;

- (instancetype)initWithViewController:(UIViewController *)viewController;
- (void)show;
- (void)showWithDestructiveButton:(BOOL)hasDestructiveButton;
- (void)cancel;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

//Путь до Message
@property (nonatomic, strong) id linkToBuddy;

@end

@protocol VFPhotoActionSheetDelegate <NSObject>

@optional

/**
 * @returns An unpacked UIImage object.
 * @see photoActionSheet:didPickPhotoAssets:fromAssetsLibrary:
 */
- (void)photoActionSheet:(VFPhotoActionSheet *)photoActionSheet didPickPhoto:(UIImage *)photo;

/**
 * @returns An array of assets (they take much less memory than unpacked UIImages)
 * and a library these assets belong to. The assets can't live without a library, so we need to keep it around.
 * @see http://www.mindsea.com/2012/12/downscaling-huge-alassets-without-fear-of-sigkill/
 */
- (void)photoActionSheet:(VFPhotoActionSheet *)photoActionSheet didPickPhotoAssets:(NSArray *)assets fromAssetsLibrary:(ALAssetsLibrary *)assetsLibrary;

- (void)photoActionSheetDidDestructPhoto:(VFPhotoActionSheet *)photoActionSheet;




@end