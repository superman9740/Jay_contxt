//
//  DataChangeObservable.h
//  Contxt
//
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import "ServerCommsObserver.h"

@protocol ServerCommsObservable

-(void)addObserver:(id<ServerCommsObserver>)observer;
-(void)removeObserver:(id<ServerCommsObserver>)observer;

@end
