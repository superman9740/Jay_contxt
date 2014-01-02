//
//  DataChangeObserver.h
//  Contxt
//
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import <Foundation/NSString.h>

@protocol DataChangeObserver <NSObject>

@optional

- (void)updatedConvoThread:(NSString *)key;
- (void)didDeleteManagedObjectWithKey:(NSString *)key;

@end
