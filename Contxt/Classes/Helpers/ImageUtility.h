//
//  ImageUtility.h
//  Contxt
//
//  Created by Chad Morris on 5/22/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import "ImageInfo.h"

#define THUMB_WIDTH     240.0f
#define THUMB_HEIGHT    180.0f

#define PREVIEW_WIDTH   180.0f
#define PREVIEW_HEIGHT  240.0f

#define IMAGE_QUALITY_ORIG      0.5f
#define IMAGE_QUALITY_THUMB     0.8f
#define IMAGE_QUALITY_PREVIEW   0.5f


@interface ImageUtility : NSObject

+ (ImageInfo *)createImageInfoFromImage:(UIImage *)image thumb:(BOOL)createThumb;

@end
