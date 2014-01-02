//
//  ContxtContact.h
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class ConversationThread;

@interface ContxtContact : Object

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *parentConvoThread;
@end

@interface ContxtContact (CoreDataGeneratedAccessors)

- (void)addParentConvoThreadObject:(ConversationThread *)value;
- (void)removeParentConvoThreadObject:(ConversationThread *)value;
- (void)addParentConvoThread:(NSSet *)values;
- (void)removeParentConvoThread:(NSSet *)values;

@end
