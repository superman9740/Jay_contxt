//  UIImage+SimpleResize.h
//
//  Created by Robert Ryan on 5/19/11.
//

#import <Foundation/Foundation.h>


@interface UIImage (SimpleResize)

- (UIImage*)scaleImageToSizeFill:(CGSize)newSize;
- (UIImage*)scaleImageToSizeAspectFill:(CGSize)newSize;
- (UIImage*)scaleImageToSizeAspectFit:(CGSize)newSize;

@end