//
//  UIImage_SDAdditions.m

#import "UIImage_SDAdditions.h"

@implementation UIImage (UIImage_SDAdditions)

+ (UIImage *)stretchableImageNamed:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    
    return [image stretchableImageWithLeftCapWidth:(image.size.width - 2) / 2
                                      topCapHeight:(image.size.height - 2) / 2];
}

+ (UIImage *)stretchableImageNamed:(NSString *)name withMargins:(CGPoint)margins
{
    UIImage *image = [UIImage imageNamed:name];
    
    return [image stretchableImageWithLeftCapWidth:margins.x topCapHeight:margins.y];
}

static inline double radians (double degrees) {return degrees * M_PI/180;}

+ (UIImage*)cropImage:(UIImage*)originalImage toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], rect);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    CGContextRef bitmap = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    
    if (originalImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -rect.size.height);
        
    } else if (originalImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -rect.size.width, 0);
        
    } else if (originalImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (originalImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, rect.size.width, rect.size.height);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, rect.size.width, rect.size.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    
    UIImage *resultImage=[UIImage imageWithCGImage:ref];
    CGImageRelease(imageRef);
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return resultImage;
}

//- (UIImage *)resizedImageWithSize:(CGSize)size
//{
//    UIGraphicsBeginImageContext(size);
//    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();    
//    UIGraphicsEndImageContext();
//    
//    return resizedImage;
//}

- (UIImage *)resizedImageWithSize:(CGSize)newSize
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = self.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);  
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();    
    
    return newImage;
}

- (UIImage *)thumbnailWithSize:(CGSize)size
                       quality:(CGInterpolationQuality)quality
               keepAspectRatio:(BOOL)keepAspectRatio;
{
    if (self.size.width * self.size.height == 0)
    {
        return nil;
    }
    
    UIImage *scaledImage = nil;
    
    BOOL transpose = (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored
    || self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored) && [[[UIDevice currentDevice] systemVersion] floatValue] < 5.0;
    
    UIGraphicsBeginImageContext(size);
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), quality);
    
    if (!keepAspectRatio) 
    {
        CGRect rect = transpose ? CGRectMake(0, 0, size.height, size.width) : CGRectMake(0, 0, size.width, size.height);
        
        CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, self.CGImage);
    }
    else
    {      
        CGFloat horizontalScaleFactor  = size.width / self.size.width;
        CGFloat verticalScaleFactor = size.height / self.size.height;
        
        CGFloat scaleFactor = MAX(horizontalScaleFactor, verticalScaleFactor);
        
        CGRect rect = CGRectMake((size.width - self.size.width * scaleFactor) / 2,
                                 (size.height - self.size.height * scaleFactor) / 2,
                                 self.size.width * scaleFactor, self.size.height * scaleFactor);
        
        [self drawInRect:transpose ? CGRectMake(0, 0, rect.size.height, rect.size.width) : rect];
    }
    
    scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)roundedImageWithCornerRadius:(CGFloat)radius
{
    return [self roundedImageWithCornerRadius:radius backgroundImage:nil margin:0];
}

- (UIImage *)roundedImageWithCornerRadius:(CGFloat)radius backgroundImage:(UIImage *)background margin:(CGFloat)margin
{
    return [self roundedImageWithSize:self.size cornerRadius:radius backgroundImage:background margin:margin];
}

- (UIImage *)roundedImageWithSize:(CGSize)size cornerRadius:(CGFloat)radius backgroundImage:(UIImage *)background margin:(CGFloat)margin
{
    // Begin a new image that will be the new image with the rounded corners
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    
    // Draw your image
    [self drawInRect:rect];
    
    // Get the image, here setting the UIImageView image
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    if (background != nil && margin > 0)
    {
        // Begin a new image that will be the new image with the rounded corners
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width + 2 * margin, size.height + 2 * margin), NO, 0.0);
        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
        
        // Add a clip before drawing anything, in the shape of an rounded rect
        CGRect rect = CGRectMake(0, 0, size.width + 2 * margin, size.height + 2 * margin);
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
        
        [background drawInRect:rect];
        [roundedImage drawInRect:CGRectMake(margin, margin, size.width, size.height)];
        
        // Get the image, here setting the UIImageView image
        roundedImage =  UIGraphicsGetImageFromCurrentImageContext();
        
        // Lets forget about that we were drawing
        UIGraphicsEndImageContext();
    }
    
    return roundedImage;
}

-(UIImage*)cropToSize:(CGSize)newSize usingMode:(NYXCropMode)cropMode
{
	const CGSize size = self.size;
	CGFloat x, y;
	switch (cropMode)
	{
		case NYXCropModeTopLeft:
			x = y = 0.0f;
			break;
		case NYXCropModeTopCenter:
			x = (size.width - newSize.width) * 0.5f;
			y = 0.0f;
			break;
		case NYXCropModeTopRight:
			x = size.width - newSize.width;
			y = 0.0f;
			break;
		case NYXCropModeBottomLeft:
			x = 0.0f;
			y = size.height - newSize.height;
			break;
		case NYXCropModeBottomCenter:
			x = (size.width - newSize.width) * 0.5f;
			y = size.height - newSize.height;
			break;
		case NYXCropModeBottomRight:
			x = size.width - newSize.width;
			y = size.height - newSize.height;
			break;
		case NYXCropModeLeftCenter:
			x = 0.0f;
			y = (size.height - newSize.height) * 0.5f;
			break;
		case NYXCropModeRightCenter:
			x = size.width - newSize.width;
			y = (size.height - newSize.height) * 0.5f;
			break;
		case NYXCropModeCenter:
			x = (size.width - newSize.width) * 0.5f;
			y = (size.height - newSize.height) * 0.5f;
			break;
		default: // Default to top left
			x = y = 0.0f;
			break;
	}
    
	if (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored || self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored)
	{
		CGFloat temp = x;
		x = y;
		y = temp;
	}
    
	CGRect cropRect = CGRectMake(x * self.scale, y * self.scale, newSize.width * self.scale, newSize.height * self.scale);
    
	/// Create the cropped image
	CGImageRef croppedImageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
	UIImage* cropped = [UIImage imageWithCGImage:croppedImageRef scale:self.scale orientation:self.imageOrientation];
    
	/// Cleanup
	CGImageRelease(croppedImageRef);
    
	return cropped;
}

/* Convenience method to crop the image from the top left corner */
-(UIImage*)cropToSize:(CGSize)newSize
{
	return [self cropToSize:newSize usingMode:NYXCropModeTopLeft];
}

- (UIColor *)averageColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)flipImageHorizontally:(UIImage *)originalImage
{
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:originalImage];
    
    UIGraphicsBeginImageContext(tempImageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform flipHorizontal = CGAffineTransformMake(
                                                           -1, 0, 0, 1, tempImageView.frame.size.width, 0
                                                           );
    CGContextConcatCTM(context, flipHorizontal);
    
    [tempImageView.layer renderInContext:context];
    
    UIImage *flipedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return flipedImage;
}

@end
