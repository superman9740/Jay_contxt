//
//  UICustomization.m
//  Contxt
//
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import "UICustomization.h"

@implementation UICustomization

static NSString* sNavBarImage = @"banner.png";
static NSString* sNavBarImage2 = @"banner2.png";
static NSString* sFBNavBarImage = @"fb_banner.png";
static NSString* sTwitterNavBarImage = @"twitter_banner.png";
static NSString* sViewBGImage = @"home.png";
static NSString* sViewBGImageLight = @"bg_light.png";

#pragma mark -
#pragma mark Background / Images

+ (UIImage *) getViewBgAsImage      { return [UIImage imageNamed:sViewBGImage]; }
+ (UIImage *) getViewBgAsImageLight { return [UIImage imageNamed:sViewBGImageLight]; }

+ (UIImage *)  getNavBarBgAsImage { return [UIImage imageNamed:sNavBarImage]; }
+ (NSString *) getNavBarBgName    { return sNavBarImage; }

+ (UIImage *)  getNavBarBg2AsImage { return [UIImage imageNamed:sNavBarImage2]; }
+ (NSString *) getNavBarBg2Name    { return sNavBarImage2; }

+ (UIImage *)  getFBNavBarBgAsImage { return [UIImage imageNamed:sFBNavBarImage]; }
+ (NSString *) getFBNavBarBgName    { return sFBNavBarImage; }

+ (UIImage *)  getTwitterNavBarBgAsImage { return [UIImage imageNamed:sTwitterNavBarImage]; }
+ (NSString *) getTwitterNavBarBgName    { return sTwitterNavBarImage; }

@end
