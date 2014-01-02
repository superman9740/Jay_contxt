//
//  NSString+CMContains.h
//
//  Created by Chad Morris on 6/6/12.
//  Copyright (c) 2012 p2websolutions. All rights reserved.
//


@interface NSString (CMContains)

- (BOOL) containsString:(NSString *) string;
- (BOOL) containsString:(NSString *) string
                options:(NSStringCompareOptions) options;

@end
