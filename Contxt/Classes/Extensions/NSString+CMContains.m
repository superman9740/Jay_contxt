//
//  NSString+CMContains.m
//
//  Created by Chad Morris on 6/6/12.
//  Copyright (c) 2012 p2websolutions. All rights reserved.
//

#import "NSString+CMContains.h"

@implementation NSString (CMContains)

- (BOOL) containsString:(NSString *) string options:(NSStringCompareOptions) options 
{
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL) containsString:(NSString *) string 
{
    return [self containsString:string options:0];
}

@end
