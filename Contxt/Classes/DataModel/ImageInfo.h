//
//  ImageInfo.h
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class AnnotationDocument, ConversationMessage, Project;

@interface ImageInfo : Object

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * extension;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * previewPath;
@property (nonatomic, retain) NSString * thumbPath;
@property (nonatomic, retain) AnnotationDocument *parentAnnotationDocument;
@property (nonatomic, retain) ConversationMessage *parentConversationMessage;
@property (nonatomic, retain) Project *parentProject;

@end
