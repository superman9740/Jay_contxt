//
//  Utilities.m
//  Contxt
//
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import "Utilities.h"
#import <CommonCrypto/CommonDigest.h>
#import "ImageInfo.h"
#import "DataController.h"

#import "UIImage+Resize.h"
#import "UIImage+SimpleResize.h"

// Seconds per day (24h * 60m * 60s)
#define kSecondsPerDay 86400.0f

@implementation Utilities


+ (BOOL) dateIsToday:(NSDate*)dateToCheck
{
    // Split today into components
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit)
                                           fromDate:[NSDate date]];
    
    // Set to this morning 00:00:00
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate* theMidnightHour = [gregorian dateFromComponents:comps];
    
    // Get time difference (in seconds) between date and then
    NSTimeInterval diff = [dateToCheck timeIntervalSinceDate:theMidnightHour];
    return ( diff>=0.0f && diff<kSecondsPerDay );
}

+ (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    
    return isValid;
}

+ (ImageInfo *)createImageInfoFromURL:(NSURL *)url asPreview:(BOOL)createPreview asThumbnail:(BOOL)createThumb
{
    if( !createPreview && !createThumb )
        return [Utilities createImageInfoFromURL:url asPreview:createPreview asThumbnail:createThumb preserveSize:YES];
    else
        return [Utilities createImageInfoFromURL:url asPreview:createPreview asThumbnail:createThumb preserveSize:NO];
}

+ (ImageInfo *)createImageInfoFromURL:(NSURL *)url asPreview:(BOOL)createPreview asThumbnail:(BOOL)createThumb preserveSize:(BOOL)preserveSize
{
//    ImageInfo * imageInfo = [[DataController sharedController] newImageInfoWithPathExtension:[url pathExtension]];
    ImageInfo * imageInfo = [[DataController sharedController] newImageInfo];
    
    UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];

    return [Utilities updateImageInfo:imageInfo withImage:image asPreview:createPreview asThumbnail:createThumb preserveSize:preserveSize];
}

+ (ImageInfo *)createImageInfoFromImage:(UIImage *)image asPreview:(BOOL)createPreview asThumbnail:(BOOL)createThumb
{
    if( !createPreview && !createThumb )
        return [Utilities createImageInfoFromImage:image asPreview:createPreview asThumbnail:createThumb preserveSize:YES];
    else
        return [Utilities createImageInfoFromImage:image asPreview:createPreview asThumbnail:createThumb preserveSize:NO];
}

+ (ImageInfo *)createImageInfoFromImage:(UIImage *)image asPreview:(BOOL)createPreview asThumbnail:(BOOL)createThumb preserveSize:(BOOL)preserveSize moc:(NSManagedObjectContext *)moc
{
    ImageInfo * imageInfo = [[DataController sharedController] newImageInfoWithMOC:moc];
    
    return [Utilities updateImageInfo:imageInfo withImage:image asPreview:createPreview asThumbnail:createThumb preserveSize:preserveSize];
}

+ (ImageInfo *)createImageInfoFromImage:(UIImage *)image asPreview:(BOOL)createPreview asThumbnail:(BOOL)createThumb preserveSize:(BOOL)preserveSize
{
    return [self createImageInfoFromImage:image asPreview:createPreview asThumbnail:createThumb preserveSize:preserveSize moc:[DataController sharedController].managedObjectContext];
}

+ (ImageInfo *)updateImageInfo:(ImageInfo *)imageInfo
                     withImage:(UIImage *)image
                     asPreview:(BOOL)createPreview
                   asThumbnail:(BOOL)createThumb
                  preserveSize:(BOOL)preserveSize
{
    // Create path to output images
    NSString  *imagePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@.%@"
                                                                              , imageInfo.filename
                                                                              , imageInfo.extension]];
    imageInfo.path = imagePath;
    
    BOOL bSaved = FALSE;

    if( preserveSize )
    {
        bSaved = [UIImageJPEGRepresentation(image , IMAGE_QUALITY_PREVIEW) writeToFile:imagePath atomically:NO];
    }
    else
    {
        bSaved = [UIImageJPEGRepresentation([UIImage imageWithImage:image
                                                       scaledToSize:CGSizeMake(FULL_IMAGE_WIDTH, FULL_IMAGE_HEIGHT)], IMAGE_QUALITY_PREVIEW)
                   writeToFile:imagePath atomically:NO];
    }
    
    if( !bSaved )
    {
        NSLog( @"Couldn't save by scaling image, so trying original format..." );
        bSaved = [UIImageJPEGRepresentation(image , IMAGE_QUALITY_PREVIEW) writeToFile:imagePath atomically:NO];

        // @TODO: Should we return NIL and let the caller handle notifying the user???
        if( !bSaved )
            NSLog( @"COULD NOT SAVE IMAGE..." );
    }
    
    if( bSaved )
    {
        if( createPreview )
        {
            NSString  *previewPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@_preview.%@"
                                                                                        , imageInfo.filename
                                                                                        , imageInfo.extension]];

            if( preserveSize )
            {
                [UIImageJPEGRepresentation(image, IMAGE_QUALITY_PREVIEW) writeToFile:previewPath atomically:NO];
            }
            else
            {
                [UIImageJPEGRepresentation([UIImage imageWithImage:image
                                                      scaledToSize:CGSizeMake(PREVIEW_WIDTH, PREVIEW_HEIGHT)], IMAGE_QUALITY_PREVIEW)
                        writeToFile:previewPath
                         atomically:NO];
            }
            
            imageInfo.previewPath = previewPath;
        }
        
        if( createThumb )
        {
            NSString  *thumbPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@_thumb.%@"
                                                                                      , imageInfo.filename
                                                                                      , imageInfo.extension]];
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
            
            imageInfo.thumbPath = thumbPath;
        }
    }
    
    return imageInfo;
}

+(float) rgbIntConvert:(int)val
{
	return (float) val/255;
}

+ (UIColor *)contxtIconColor
{
    return [Utilities colorWithRed:166 green:23 blue:129];
}

+ (UIColor *)lightGrayColor
{
    return [Utilities colorWithRed:202 green:202 blue:202];
}

+ (UIColor *)colorWithRed:(uint)red green:(uint)green blue:(uint)blue
{
    return [UIColor colorWithRed:[Utilities rgbIntConvert:red]
                           green:[Utilities rgbIntConvert:green]
                            blue:[Utilities rgbIntConvert:blue]
                           alpha:1.0f];
}


+ (UIColor *)errorBgColor
{
    return [UIColor colorWithRed:[Utilities rgbIntConvert:254]
                           green:[Utilities rgbIntConvert:214]
                            blue:[Utilities rgbIntConvert:216]
                           alpha:1.0f];
}

+ (NSString *)dateToString:(NSDate *)date
{
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterShortStyle];
}

+ (NSString *)dateToTimeString:(NSDate *)date
{
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterNoStyle
                                          timeStyle:NSDateFormatterShortStyle];
}

+ (NSString *)dateToShortDateString:(NSDate *)date
{
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterNoStyle];
}

+ (NSString *)dateToDbDateString:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if( !date )
        return nil;
    
    return [dateFormat stringFromDate:date];
}

+ (NSDate *)dateFromDbString:(NSString *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [df dateFromString:date];
}

+ (NSString *)generateGUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    return uuidString;
}


+ (NSString *)getFilePath:(NSString *)fileName
{
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [libraryPath stringByAppendingPathComponent:fileName];
}

+ (NSString*)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+ (UIImage *)imageForStatus:(EStatusImage)status
{
    switch( status )
    {
        case EStatusImageOK:
            return [UIImage imageNamed:@"status_ok.png"];
        case EStatusImageError:
            return [UIImage imageNamed:@"status_error.png"];
        case EStatusImageWarning:
            return [UIImage imageNamed:@"status_warning.png"];
            
        default: return [UIImage imageNamed:@"status_unknown.png"];
    }
}

@end
