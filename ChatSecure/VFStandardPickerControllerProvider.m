#import "VFStandardPickerControllerProvider.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface VFStandardPickerControllerProvider () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation VFStandardPickerControllerProvider {
    UIImagePickerControllerSourceType _sourceType;
}

@synthesize picker;

+ (instancetype)cameraPickerProvider {
    return [[self alloc] initWithSourceType:UIImagePickerControllerSourceTypeCamera];
}

+ (instancetype)photoLibraryPickerProvider {
    return [[self alloc] initWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (instancetype)initWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    self = [super init];
    _sourceType = sourceType;
    return self;
}

- (UIViewController *)pickerController {
    if ([UIImagePickerController isSourceTypeAvailable: _sourceType] == NO) {
        return nil;
    }
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = _sourceType;
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    return  pickerController;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    [self.picker pickerController:pickerController didPickImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    [self.picker pickerControllerDidCancel:pickerController];
}

@end