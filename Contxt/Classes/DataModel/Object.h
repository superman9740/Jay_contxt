//
//  Object.h
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define OBJ_STATUS_DELETE  -1
#define OBJ_STATUS_PENDING  0
#define OBJ_STATUS_SAVED    1

@interface Object : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * pendingChangeJSON;
@property (nonatomic, retain) NSNumber * pendingChangeStatus;
@property (nonatomic, retain) NSNumber * status;

@end
