//
//  NSMutableArray+Queue.h
//
//  Created by Chad Morris on 2/14/11.
//  Copyright 2011 SEIApps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableArray (QueueAdditions)

- (void) push:(id)obj;
- (void) pop;
- (id)   peek;

@end