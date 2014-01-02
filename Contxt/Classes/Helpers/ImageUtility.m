//
//  ImageUtility.m
//  Contxt
//
//  Created by Chad Morris on 5/22/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "ImageUtility.h"
#import "UIImage+Resize.h"
#import "UIImage+SimpleResize.h"

#import "DataController.h"

@implementation ImageUtility

+ (ImageInfo *)createImageInfoFromImage:(UIImage *)image thumb:(BOOL)createThumb
{
    ImageInfo * imgInfo = [[DataController sharedController] newImageInfo];
    
    // Create path to output images
    NSString  *imagePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@.%@"
                                                                              , imgInfo.filename
                                                                              , imgInfo.extension]];
    
    NSString  *thumbPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@_thumb.%@"
                                                                              , imgInfo.filename
                                                                              , imgInfo.extension]];
    
    [UIImageJPEGRepresentation(image , IMAGE_QUALITY_ORIG) writeToFile:imagePath atomically:NO];
    imgInfo.path = imagePath;
    
    if( createThumb )
    {
        if( image.size.width > image.size.height )
        {
            [UIImageJPEGRepresentation([UIImage imageWithImage:image
                                                  scaledToSize:CGSizeMake(THUMB_WIDTH, THUMB_HEIGHT)], IMAGE_QUALITY_THUMB)
                writeToFile:thumbPath atomically:NO];
        }
        else
        {
            [UIImageJPEGRepresentation([image scaleImageToSizeAspectFill:CGSizeMake(THUMB_WIDTH, THUMB_HEIGHT)], IMAGE_QUALITY_THUMB)
                writeToFile:thumbPath atomically:NO];
        }
    }
    
    imgInfo.thumbPath = thumbPath;
    
    return imgInfo;
}

@end
