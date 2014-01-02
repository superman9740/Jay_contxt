//
//  Annotation.h
//  Contxt
//
//  Created by Chad Morris on 8/31/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class AnnotationDetails, AnnotationDocument, AnnotationPoint;

@interface Annotation : Object

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateUpdated;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) AnnotationPoint *anchorPoint;
@property (nonatomic, retain) AnnotationPoint *anchorPointCenter;
@property (nonatomic, retain) AnnotationDetails *details;
@property (nonatomic, retain) AnnotationDocument *parentAnnotationDocument;

@end
