//
//  DrawingAnnotation.m
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "DrawingAnnotation.h"
#import "AnnotationPoint.h"
#import "AnnotationSize.h"


@implementation DrawingAnnotation

@dynamic anchorLocation;
@dynamic color;
@dynamic drawingType;
@dynamic fontSize;
@dynamic text;
@dynamic customPoints;
@dynamic size;

- (void)addCustomPointsObject:(AnnotationPoint *)value
{
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.customPoints];
    [tempSet addObject:value];
    self.customPoints = tempSet;
}

- (NSOrderedSet *)removeAllCustomPointsObjects
{
    NSMutableOrderedSet * tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.customPoints];
    self.customPoints = [[NSMutableOrderedSet alloc] init];
    return tempSet;
}

@end
