//
//  AnnotationPoint.h
//  Contxt
//
//  Created by Chad Morris on 10/30/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Annotation, DrawingAnnotation;

@interface AnnotationPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) Annotation *parentAnnotation;
@property (nonatomic, retain) Annotation *parentCenterAnnotationPoint;
@property (nonatomic, retain) DrawingAnnotation *parentDrawingAnnotation;

@end
