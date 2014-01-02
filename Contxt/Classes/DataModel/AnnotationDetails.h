//
//  AnnotationDetails.h
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Annotation;

@interface AnnotationDetails : Object

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateUpdated;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) Annotation *parentAnnotation;

@end
