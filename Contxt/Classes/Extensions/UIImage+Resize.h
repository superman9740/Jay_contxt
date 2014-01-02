//
//  UIImage+Resize.h
//  Contxt
//
//  Created by Chad Morris on 5/6/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
- (UIImage*)resizeToSize:(CGSize)newSize thenCropWithRect:(CGRect)cropRect;


@end
