//
//  UIImage+STKStencil.m
//  StencilKit
//
//  Created by Ignacio Romero Z. on 12/13/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//  http://opensource.org/licenses/MIT
//

#import "UIImage+STKStencil.h"
#import "UIColor+STKHex.h"

#define kSTKScreenScale [UIImage screenScale]

static NSString *kStencilKitCacheFolderName = @"com.dzn.StencilKit.DefaultCache";

@implementation UIImage (STKStencil)

#pragma mark - Stencil

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color
{
    return [self imageNamed:name inBundle:[NSBundle mainBundle] withColor:color];
}

+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle withColor:(UIColor *)color
{
    NSString *hex = [color hexFromColor];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@",name,hex];
    
    NSString *path = [self imageCachePathForName:fileName];
    
    // Return the cached file
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        return [UIImage imageWithData:data scale:kSTKScreenScale];
    }
    
    // Create a new image
    UIImage *image = nil;
    
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        image = [[UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil] coloredImage:color];
    }
    else {
        image = [[UIImage imageNamed:name] coloredImage:color];
    }
    
    // Save to disk
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    
    return image;
}

+ (UIImage *)squareImageWithColor:(UIColor *)color size:(CGSize)size
{
    NSString *hex = [color hexFromColor];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@",hex,NSStringFromCGSize(size)];
    
    NSString *path = [self imageCachePathForName:fileName];
    
    // Return the cached file
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        return [UIImage imageWithData:data scale:kSTKScreenScale];
    }
    
    // Create a new image
    UIImage *image = [self imageWithColor:color andSize:size];
    
    // Save to disk
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    
    return image;
}

+ (UIImage *)circularImageWithColor:(UIColor *)color size:(CGSize)size
{
    NSString *hex = [color hexFromColor];
    NSString *fileName = [NSString stringWithFormat:@"circular_%@_%@",hex,NSStringFromCGSize(size)];
    
    NSString *path = [self imageCachePathForName:fileName];
    
    // Return the cached file
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        return [UIImage imageWithData:data scale:kSTKScreenScale];
    }
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:rect];
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [color setStroke];
    [circle addClip];
    [circle fill];
    [circle stroke];
    
    // Create a new image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Save to disk
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    
    return image;
}

+ (UIImage *)gradientImageWithSize:(CGSize)size startColor:(UIColor *)c1 startLocation:(CGFloat)l1 endColor:(UIColor *)c2 endLocation:(CGFloat)l2
{
    NSString *startHex = [c1 hexFromColor];
    NSString *endHex = [c2 hexFromColor];
    NSString *fileName = [NSString stringWithFormat:@"gradient_%@(%.f)_%@(%.f)_%@",startHex,l1,endHex,l2,NSStringFromCGSize(size)];
    
    NSString *path = [self imageCachePathForName:fileName];
    
    // Return the cached file
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        return [UIImage imageWithData:data scale:kSTKScreenScale];
    }
    
    // Create a new image
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat r0; CGFloat g0; CGFloat b0; CGFloat a0;
    [c1 getRed:&r0 green:&g0 blue:&b0 alpha:&a0];
    
    CGFloat r1; CGFloat g1; CGFloat b1; CGFloat a1;
    [c2 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    
    CGFloat gradientComponents[8] = {r0, g0, b0, a0, r1, g1, b1, a1};
    CGFloat gradientLocations[2] = {l1, l2};
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents (colorspace, gradientComponents, gradientLocations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
    
    // Save to disk
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    
    return image;
}

- (UIImage *)resizeImageSize:(CGSize)size withIdentifier:(NSString *)identifier
{
    NSString *path = nil;
    
    if (identifier) {
        NSString *fileName = [NSString stringWithFormat:@"resize_%@(%@)",identifier,NSStringFromCGSize(size)];
        path = [UIImage imageCachePathForName:fileName];
        
        // Return the cached file
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSData *data = [NSData dataWithContentsOfFile:path];
            return [UIImage imageWithData:data scale:kSTKScreenScale];
        }
    }
    
    UIImage *image = [self imageAspectFittingToSize:size];
    
    if (path) {
        // Save to disk
        [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    }
    
    return image;
}

- (UIImage *)mergeImage:(UIImage *)img2 toPositionRect:(CGPoint)position withIdentifier:(NSString *)identifier
{
    NSString *path = nil;
    
    if (identifier) {
        NSString *fileName = [NSString stringWithFormat:@"merge_%@(%@)",identifier,NSStringFromCGPoint(position)];
        path = [UIImage imageCachePathForName:fileName];
        
        // Return the cached file
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSData *data = [NSData dataWithContentsOfFile:path];
            return [UIImage imageWithData:data scale:kSTKScreenScale];
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    
    [self drawAtPoint:CGPointZero];
    [img2 drawAtPoint:position];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (path) {
        // Save to disk
        [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    }
    
    return image;
}


#pragma mark - Tint

- (UIImage *)coloredImage:(UIColor *)color
{
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    UIImage *colorImg = [UIImage imageWithColor:color andSize:size];
    return [colorImg imageWithMask:self];
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    // Create a new image
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width*kSTKScreenScale, size.height*kSTKScreenScale);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, rect.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageWithMask:(UIImage *)maskImg
{
    CGSize size = self.size;
    
    //// Draws the masked over the background colored image.
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGColorSpaceRef colorSpace;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef imageRef = [self CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, bitmapInfo);
    
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) return nil;
    
    CGContextClipToMask(context, CGRectMake(0, 0, size.width, size.height), maskImg.CGImage);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *maskedImg = [UIImage imageWithCGImage:mainViewContentBitmapContext scale:kSTKScreenScale orientation:(self.imageOrientation)];
    CGImageRelease(mainViewContentBitmapContext);
    
    UIGraphicsEndImageContext();
    
    return maskedImg;
}


#pragma mark - Resizing

- (UIImage *)imageAspectFittingToSize:(CGSize)size
{
    if (CGSizeEqualToSize(self.size, size)) {
        return self;
    }
    
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    
    CGFloat scale = 0.0;
    
    CGPoint position = CGPointZero;
    
    CGFloat widthScale = targetWidth / width;
    CGFloat heightScale = targetHeight / height;
    
    if (widthScale > heightScale) scale = heightScale;
    else scale = widthScale;
    
    CGFloat newWidth = width * scale;
    CGFloat newHeight = height * scale;
    
    if (widthScale > heightScale) position.x = (targetWidth - newWidth) * 0.5;
    else position.y = (targetHeight - newHeight) * 0.5;
    
    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    
    CGRect rect = CGRectZero;
    rect.origin = position;
    rect.size.width  = newWidth;
    rect.size.height = newHeight;
    
    [self drawInRect:rect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!image) NSLog(@"could not scale image");
    
    return image;
}


#pragma mark - Caching

+ (void)clearCachedImages:(BOOL)log
{
    NSString *imageCacheDirectoryPath = [self imageCacheDirectoryPath];
    __block NSError *error = nil;
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imageCacheDirectoryPath error:&error];
    if (error) {
        NSLog(@"%s contentsOfDirectoryAtPath error : %@",__FUNCTION__, error.localizedDescription);
        return;
    }
    
    // or in  recent versions of iOS, you can use dispatch_queue_create( "xmpp_message", DISPATCH_QUEUE_CONCURRENT );
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        for (NSString *fileName in contents) {
            
            NSString *filePath = [imageCacheDirectoryPath stringByAppendingPathComponent:fileName];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                if (error) NSLog(@"removeItemAtPath error : %@",error.localizedDescription);
                else if (log) NSLog(@"removed Item At Path : %@",filePath);
            }
        }
    });
}

+ (NSString *)imageCachePathForName:(NSString *)fileName
{
    NSMutableString *path = [[[self imageCacheDirectoryPath] stringByAppendingPathComponent:fileName] mutableCopy];
    
    if (kSTKScreenScale > 1.0) {
        [path appendFormat:@"@%gx", kSTKScreenScale];
    }
    
    [path appendString:@".png"];
    
    return path;
}

+ (NSString *)imageCacheDirectoryPath
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imagesPath = [cachePath stringByAppendingPathComponent:kStencilKitCacheFolderName];
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagesPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) NSLog(@"contentsOfDirectoryAtPath error : %@",error.localizedDescription);
    }
    
    return imagesPath;
}

+ (CGFloat)screenScale
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]) {
        return [[UIScreen mainScreen] nativeScale];
    }
    else {
        return [[UIScreen mainScreen] scale];
    }
}

@end
