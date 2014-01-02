//
//  ConversationThread.h
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class ContxtContact, ConversationMessage, ConvoAnnotation;

@interface ConversationThread : Object

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) NSSet *convoMessages;
@property (nonatomic, retain) ConvoAnnotation *parentAnnotation;
@property (nonatomic, retain) NSSet *participants;
@end

@interface ConversationThread (CoreDataGeneratedAccessors)

- (void)addConvoMessagesObject:(ConversationMessage *)value;
- (void)removeConvoMessagesObject:(ConversationMessage *)value;
- (void)addConvoMessages:(NSSet *)values;
- (void)removeConvoMessages:(NSSet *)values;

- (void)addParticipantsObject:(ContxtContact *)value;
- (void)removeParticipantsObject:(ContxtContact *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;

@end
