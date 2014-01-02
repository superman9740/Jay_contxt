//
//  FirstRunChecker.h
//
//  Created by Chad Morris on 11/21/10.
//  Copyright 2010 SEIApps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FirstRunChecker : NSObject

+ (BOOL)isFirstRunOfApp;
+ (BOOL)isFirstRunOfVersionWithVersion:(NSString *)version;
+ (BOOL)isFirstRunWithiCloud;
+ (BOOL)createFirstRunWithiCloud;

@end
