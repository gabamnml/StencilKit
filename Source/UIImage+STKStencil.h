//
//  UIImage+STKStencil.h
//  StencilKit
//
//  Created by Ignacio Romero Z. on 12/13/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

/*
 A drop-in API for replacing +imageNamed: for flat images to be colored on runtime, with cache support.
 */
@interface UIImage (STKStencil)

/*
 Renders an image by relacing it's color channel with a custom color, caching in disk the result for reusing later.
 
 @param name The name of the file. If this is the first time the image is being loaded, the method renders a new image and saves it in the system cache folder for reusing later. The image source should have 1 single color, with translucent background for desired alpha.
 @param color The color to be used to render the image.
 @return A new colored image.
 */
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

/*
 Renders an image by relacing it's color channel with a custom color, caching in disk the result for reusing later.
 
 @param name The name of the file. If this is the first time the image is being loaded, the method renders a new image and saves it in the system cache folder for reusing later. The image source should have 1 single color, with translucent background for desired alpha.
 @param bundle The bundle the image file or asset catalog is located in, pass nil to use the main bundle.
 @param color The color to be used to render the image.
 @return A new colored image.
 */
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle withColor:(UIColor *)color;

/*
 Returns a rectangular gradient image, caching in disk the result for reusing later.
 
 @param size The image size.
 @param c1 The starting color.
 @param c1 The starting location.
 @param c2 The ending color.
 @param c2 The ending location.
 @returns A new or cached gradient image.
 */
+ (UIImage *)gradientImageWithSize:(CGSize)size startColor:(UIColor *)c1 startLocation:(CGFloat)l1 endColor:(UIColor *)c2 endLocation:(CGFloat)l2;

/*
 Returns a rectangular tinted image, caching in disk the result for reusing later.
 
 @param color The color to be used to tint the image.
 @param size The image size.
 @returns A new or cached tinted image.
 */
+ (UIImage *)squareImageWithColor:(UIColor *)color size:(CGSize)size;

/*
 Returns a circular tinted image, caching in disk the result for reusing later.
 
 @param color The color to be used to tint the image.
 @param size The image size.
 @returns A new or cached tinted image.
 */
+ (UIImage *)circularImageWithColor:(UIColor *)color size:(CGSize)size;

/*
 Resizes the image, and optionally cache the result to disk.
 
 @param size The new requested size.
 @param identifier An optional identifier to be able to cache the image in disk, and reuse that file instead of creating everytime.
 @returns A new resized image.
 */
- (UIImage *)resizeImageSize:(CGSize)size withIdentifier:(NSString *)identifier;

/*
 Merges the image with another image, and optionally cache the result to disk.
 
 @param img2 The image to merge with.
 @param position The position offset of the merged image.
 @param identifier An optional identifier to be able to cache the image in disk, and reuse that file instead of creating everytime.
 @returns A new merged image from both images.
 */
- (UIImage *)mergeImage:(UIImage *)img2 toPositionRect:(CGPoint)position withIdentifier:(NSString *)identifier;

/*
 Returns a tinted image from the original image.
 
 @param color The tint color.
 @returns A new tinted image.
 */
- (UIImage *)coloredImage:(UIColor *)color;

/*
 Removes all cached images that have been generated with the [+imageNamed:withColor:] method.
 It will wipe all created images located in com.dzn.UIImageCache.default cache folder.
 
 @param log YES if the path of each removed image should be loged in the console.
 */
+ (void)clearCachedImages:(BOOL)log;

@end
