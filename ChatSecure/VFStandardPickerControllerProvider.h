#import "VFPhotoPicker.h"

@interface VFStandardPickerControllerProvider : NSObject <VFPickerControllerProvider>

+ (instancetype)cameraPickerProvider;
+ (instancetype)photoLibraryPickerProvider;

- (instancetype)initWithSourceType:(UIImagePickerControllerSourceType)sourceType;

@end
