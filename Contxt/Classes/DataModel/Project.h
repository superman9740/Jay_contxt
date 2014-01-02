//
//  Project.h
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class AnnotationDocument, ImageInfo;

@interface Project : Object

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateUpdated;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *annotationDocs;
@property (nonatomic, retain) ImageInfo *thumbnail;
@end

@interface Project (CoreDataGeneratedAccessors)

- (void)addAnnotationDocsObject:(AnnotationDocument *)value;
- (void)removeAnnotationDocsObject:(AnnotationDocument *)value;
- (void)addAnnotationDocs:(NSSet *)values;
- (void)removeAnnotationDocs:(NSSet *)values;

@end
