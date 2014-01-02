//
//  NSDictionary+Contains.m
//  Contxt
//
//  Created by Chad Morris on 8/28/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "NSDictionary+CMJSON.h"
#import <Foundation/NSJSONSerialization.h>

@implementation NSDictionary (CMJSON)

- (NSString *)toJSONstring
{
    NSError * error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    
    if( error )
        return nil;
    else
        return [[NSString alloc] initWithData:jsonData encoding:4];
}

+ (NSDictionary *)dictionaryFromJSONstring:(NSString *)jsonString
{
    if( !jsonString )
        return nil;
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
}

@end
