//
//  DrawingAnnotation.h
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Annotation.h"

@class AnnotationPoint, AnnotationSize;

@interface DrawingAnnotation : Annotation

@property (nonatomic, retain) NSNumber * anchorLocation;
@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSNumber * drawingType;
@property (nonatomic, retain) NSNumber * fontSize;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSOrderedSet *customPoints;
@property (nonatomic, retain) AnnotationSize *size;
@end

@interface DrawingAnnotation (CoreDataGeneratedAccessors)

- (NSOrderedSet *)removeAllCustomPointsObjects;

- (void)insertObject:(AnnotationPoint *)value inCustomPointsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCustomPointsAtIndex:(NSUInteger)idx;
- (void)insertCustomPoints:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCustomPointsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCustomPointsAtIndex:(NSUInteger)idx withObject:(AnnotationPoint *)value;
- (void)replaceCustomPointsAtIndexes:(NSIndexSet *)indexes withCustomPoints:(NSArray *)values;
- (void)addCustomPointsObject:(AnnotationPoint *)value;
- (void)removeCustomPointsObject:(AnnotationPoint *)value;
- (void)addCustomPoints:(NSOrderedSet *)values;
- (void)removeCustomPoints:(NSOrderedSet *)values;
@end
