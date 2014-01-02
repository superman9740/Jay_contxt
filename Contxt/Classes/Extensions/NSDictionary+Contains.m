//
//  NSDictionary+Contains.m
//  Contxt
//
//  Created by Chad Morris on 8/28/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "NSDictionary+Contains.h"

@implementation NSDictionary (Contains)

- (BOOL)containsKey:(NSString *)key
{
    if( self.count <= 0 || [self allKeys].count <= 0 )
        return NO;
    
    return [[self allKeys] containsObject:key];
}

@end
