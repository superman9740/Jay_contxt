//
//  NSMutableArray+Queue.m
//
//  Created by Chad Morris on 2/14/11.
//  Copyright 2011 SEIApps. All rights reserved.
//

#import "NSMutableArray+Queue.h"


@implementation NSMutableArray (QueueAdditions)

// Queues are first-in-first-out, so we remove objects from the head
- (void) pop 
{
    if( [self count] > 0 ) // To avoid raising an exception 
        [self removeLastObject];
}

// Add to the tail of the queue (no one likes it when people cut in line!)
- (void) push:(id)obj 
{
    if( obj )
        [self insertObject:obj atIndex:0];
}

- (id) peek
{
	return [self count] > 0 ? [self lastObject] : nil;
}

@end
