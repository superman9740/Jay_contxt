//
//  NSDictionary+JSON.h
//  Contxt
//
//  Created by Chad Morris on 11/26/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CMJSON)

- (NSString *)toJSONstring;
+ (NSDictionary *)dictionaryFromJSONstring:(NSString *)jsonString;

@end
