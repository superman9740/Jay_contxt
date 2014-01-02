//
//  ImageAnnotation.h
//  Contxt
//
//  Created by Chad Morris on 10/20/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Annotation.h"

@class AnnotationDocument;

@interface ImageAnnotation : Annotation

@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) AnnotationDocument *annotationDoc;

@end
