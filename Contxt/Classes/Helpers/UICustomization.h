//
//  UICustomization.h
//  Contxt
//
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"

@interface UICustomization : NSObject 

// Backgrounds / Images
+ (UIImage *) getViewBgAsImage;
+ (UIImage *) getViewBgAsImageLight;

+ (UIImage *) getNavBarBgAsImage;
+ (NSString *) getNavBarBgName;

+ (UIImage *) getNavBarBg2AsImage;
+ (NSString *) getNavBarBg2Name;

+ (UIImage *) getFBNavBarBgAsImage;
+ (NSString *) getFBNavBarBgName;

+ (UIImage *) getTwitterNavBarBgAsImage;
+ (NSString *) getTwitterNavBarBgName;

@end
