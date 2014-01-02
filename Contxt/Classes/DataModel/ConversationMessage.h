//
//  ConversationMessage.h
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class ConversationThread, ImageInfo;

@interface ConversationMessage : Object

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * imageInfoExt;
@property (nonatomic, retain) NSString * imageInfoKey;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) ImageInfo *image;
@property (nonatomic, retain) ConversationThread *parentConvoThread;

@end
