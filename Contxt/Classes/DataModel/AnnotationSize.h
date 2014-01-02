//
//  AnnotationSize.h
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DrawingAnnotation;

@interface AnnotationSize : NSManagedObject

@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) DrawingAnnotation *parentAnnotation;

@end
