//
//  AnnotationDocument.h
//  Contxt
//
//  Created by Chad Morris on 11/24/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Annotation, ImageAnnotation, ImageInfo, Project;

@interface AnnotationDocument : Object

@property (nonatomic, retain) NSNumber * isShared;
@property (nonatomic, retain) NSSet *annotations;
@property (nonatomic, retain) ImageInfo *image;
@property (nonatomic, retain) ImageAnnotation *parentAnnotation;
@property (nonatomic, retain) Project *parentProject;
@end

@interface AnnotationDocument (CoreDataGeneratedAccessors)

- (void)addAnnotationsObject:(Annotation *)value;
- (void)removeAnnotationsObject:(Annotation *)value;
- (void)addAnnotations:(NSSet *)values;
- (void)removeAnnotations:(NSSet *)values;

@end
