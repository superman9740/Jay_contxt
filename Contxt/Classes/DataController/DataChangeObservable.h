//
//  DataChangeObservable.h
//  Contxt
//
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import "DataChangeObserver.h"

@protocol DataChangeObservable

-(void)addObserver:(id<DataChangeObserver>)observer;
-(void)removeObserver:(id<DataChangeObserver>)observer;

@end
