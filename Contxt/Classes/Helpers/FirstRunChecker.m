//
//  FirstRunChecker.m
//
//  Created by Chad Morris on 11/21/10.
//  Copyright 2010 SEIApps. All rights reserved.
//

#import "FirstRunChecker.h"

#define PREV_VERSION_RUN_FILE @""
#define FIRST_RUN_FILE        @"FirstRun_v1.0"
#define PREFIX_FIRST_RUN_VERSION @"FirstRunOfVersion__v"
#define FIRST_RUN_iCLOUD      @"FirstRun_iCloud"


@interface FirstRunChecker()
+ (BOOL)checkFirstRunForFile:(NSString *)file;
+ (BOOL)checkFirstRunForFile:(NSString *)file andCreateifDNE:(BOOL)create;
+ (BOOL)createFirstRunForFile:(NSString *)file;
@end


@implementation FirstRunChecker


+ (NSString *)firstRunFilePath:(NSString *)path
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	
	return [documentsDirectory stringByAppendingPathComponent:path];
}


#pragma mark -
#pragma LEGACY: First Run of App

+ (BOOL)isFirstRunOfApp
{
    return [FirstRunChecker checkFirstRunForFile:FIRST_RUN_FILE];
}


#pragma mark -
#pragma NEW: First Run of Version

+ (BOOL)isFirstRunOfVersionWithVersion:(NSString *)version;
{
    NSString * versionFile = [NSString stringWithFormat:@"%@%@", PREFIX_FIRST_RUN_VERSION, version];
    return [FirstRunChecker checkFirstRunForFile:versionFile];
}

+ (BOOL)isFirstRunWithiCloud
{
    return [FirstRunChecker checkFirstRunForFile:FIRST_RUN_iCLOUD andCreateifDNE:NO];
}

+ (BOOL)createFirstRunWithiCloud
{
    return [FirstRunChecker createFirstRunForFile:FIRST_RUN_iCLOUD];
}


#pragma mark -
#pragma Helper Methods

+ (BOOL)checkFirstRunForFile:(NSString *)file
{
    return [FirstRunChecker checkFirstRunForFile:file andCreateifDNE:YES];
}

+ (BOOL)checkFirstRunForFile:(NSString *)file andCreateifDNE:(BOOL)create
{
	if( ![[NSFileManager defaultManager] fileExistsAtPath:[FirstRunChecker firstRunFilePath:file]] )
	{
        if( create )
            return [FirstRunChecker createFirstRunForFile:file];
        else
            return TRUE;
	}
	
	return FALSE;
}

+ (BOOL)createFirstRunForFile:(NSString *)file
{
	return [[NSFileManager defaultManager] createFileAtPath:[FirstRunChecker firstRunFilePath:file] contents:nil attributes:nil];
}

@end
