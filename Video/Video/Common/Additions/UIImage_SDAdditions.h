//
//  UIImage_SDAdditions.h


#import <UIKit/UIKit.h>

typedef enum
{
	NYXCropModeTopLeft,
	NYXCropModeTopCenter,
	NYXCropModeTopRight,
	NYXCropModeBottomLeft,
	NYXCropModeBottomCenter,
	NYXCropModeBottomRight,
	NYXCropModeLeftCenter,
	NYXCropModeRightCenter,
	NYXCropModeCenter
} NYXCropMode;

typedef enum
{
	NYXResizeModeScaleToFill,
	NYXResizeModeAspectFit,
	NYXResizeModeAspectFill
} NYXResizeMode;

@interface UIImage (UIImage_SDAdditions)

+ (UIImage *)stretchableImageNamed:(NSString *)name;
+ (UIImage *)stretchableImageNamed:(NSString *)name withMargins:(CGPoint)margins;

+ (UIImage*)cropImage:(UIImage*)originalImage toRect:(CGRect)rect;

- (UIImage *)resizedImageWithSize:(CGSize)size;

- (UIImage *)thumbnailWithSize:(CGSize)size quality:(CGInterpolationQuality)quality keepAspectRatio:(BOOL)keepAspectRatio;

- (UIImage *)roundedImageWithCornerRadius:(CGFloat)radius;
- (UIImage *)roundedImageWithCornerRadius:(CGFloat)radius backgroundImage:(UIImage *)background margin:(CGFloat)margin;
- (UIImage *)roundedImageWithSize:(CGSize)size cornerRadius:(CGFloat)radius backgroundImage:(UIImage *)background margin:(CGFloat)margin;

-(UIImage*)cropToSize:(CGSize)newSize usingMode:(NYXCropMode)cropMode;

// NYXCropModeTopLeft crop mode used
-(UIImage*)cropToSize:(CGSize)newSize;

- (UIColor *)averageColor;

- (UIImage *)fixOrientation;

+ (UIImage *)flipImageHorizontally:(UIImage *)originalImage;

@end
