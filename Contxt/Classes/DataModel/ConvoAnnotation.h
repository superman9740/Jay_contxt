//
//  ConvoAnnotation.h
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Annotation.h"

@class ConversationThread;

@interface ConvoAnnotation : Annotation

@property (nonatomic, retain) ConversationThread *convoThread;

@end
