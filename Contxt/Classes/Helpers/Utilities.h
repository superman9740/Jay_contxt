//
//  Utilities.h
//  Contxt
//
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

#define NAVIGATION_BAR_HEIGHT 44
#define PHONE_STATUS_BAR_HEIGHT 20

#define THUMB_WIDTH     240.0f
#define THUMB_HEIGHT    180.0f

#define PREVIEW_WIDTH   300.0f
#define PREVIEW_HEIGHT  400.0f

#define FULL_IMAGE_WIDTH  1500.0f
#define FULL_IMAGE_HEIGHT 2000.0f

#define IMAGE_QUALITY_ORIG      0.6f
#define IMAGE_QUALITY_THUMB     0.2f
#define IMAGE_QUALITY_PREVIEW   0.4f

#define PIN_IMAGE_SIZE 32.f
#define PIN_DRAG_TOUCH_yOFFSET 60

#define POINTER_PIN_IMAGE [UIImage imageNamed:@"pin-pointer.png"]

#define CAMERA_IMAGE [UIImage imageNamed:@"camera.png"]
#define CAMERA_PIN_IMAGE [UIImage imageNamed:@"pin-camera.png"]
#define CAMERA_PIN_IMAGE_vMIRROR [UIImage imageNamed:@"pin-camera_INVERSE.png"]

#define CHAT_IMAGE [UIImage imageNamed:@"chat.png"]
#define CHAT_PIN_IMAGE [UIImage imageNamed:@"pin-chat.png"]
#define CHAT_PIN_IMAGE_vMIRROR [UIImage imageNamed:@"pin-chat_INVERSE.png"]

#define SOURCE_TYPE_CAMERA @"Camera"
#define SOURCE_TYPE_PHOTO_LIBRARY @"PhotoLibrary"
#define SOURCE_TYPE_CLOUD @"CloudDownload"

#define OBJ_CHANGE_TYPE_NONE   0
#define OBJ_CHANGE_TYPE_ADD    1
#define OBJ_CHANGE_TYPE_UPDATE 2
#define OBJ_CHANGE_TYPE_DELETE 3

#define PLUS_IMAGE [UIImage imageNamed:@"plus.png"]

#define iOS7_yOFFSET 64.0

#define DEFAULT_KXMENU_ITEM_COLOR [UIColor darkGrayColor]


@class ImageInfo;

typedef enum
{
	EStatusImageNone = 0
	, EStatusImageOK
	, EStatusImageError
	, EStatusImageLoading
    , EStatusImageWarning
    , EStatusImageUnknown
} EStatusImage;

@interface Utilities : NSObject

+ (ImageInfo *)createImageInfoFromImage:(UIImage *)image asPreview:(BOOL)createPreview asThumbnail:(BOOL)createThumb preserveSize:(BOOL)preserveSize moc:(NSManagedObjectContext *)moc;
+ (ImageInfo *)createImageInfoFromImage:(UIImage *)image asPreview:(BOOL)createPreview asThumbnail:(BOOL)createThumb preserveSize:(BOOL)preserveSize;
+ (ImageInfo *)createImageInfoFromImage:(UIImage *)image asPreview:(BOOL)createPreview asThumbnail:(BOOL)createThumb;

+ (ImageInfo *)createImageInfoFromURL:(NSURL *)url asPreview:(BOOL)createPreview asThumbnail:(BOOL)createThumb preserveSize:(BOOL)preserveSize;
+ (ImageInfo *)createImageInfoFromURL:(NSURL *)url asPreview:(BOOL)createPreview asThumbnail:(BOOL)createThumb;

+ (ImageInfo *)updateImageInfo:(ImageInfo *)imageInfo
                     withImage:(UIImage *)image
                     asPreview:(BOOL)createPreview
                   asThumbnail:(BOOL)createThumb
                  preserveSize:(BOOL)preserveSize;


+ (BOOL)validateEmail:(NSString *)email;

+ (float) rgbIntConvert:(int)val;

+ (UIColor *)colorWithRed:(uint)red green:(uint)green blue:(uint)blue;
+ (UIColor *)contxtIconColor;

+ (UIColor *)lightGrayColor;

+ (UIColor *)errorBgColor;

+ (NSString *)getFilePath:(NSString *)fileName;
+ (NSString*)md5HexDigest:(NSString*)input;
+ (UIImage *)imageForStatus:(EStatusImage)status;

+ (NSString *)generateGUID;

+ (NSString *)dateToString:(NSDate *)date;
+ (NSString *)dateToTimeString:(NSDate *)date;
+ (NSString *)dateToShortDateString:(NSDate *)date;
+ (NSString *)dateToDbDateString:(NSDate *)date;

+ (NSDate *)dateFromDbString:(NSString *)date;

+ (BOOL) dateIsToday:(NSDate*)dateToCheck;

@end
