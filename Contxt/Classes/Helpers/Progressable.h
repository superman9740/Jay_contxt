//
//  Progressable.h
//  Contxt
//
//  Created by Chad Morris on 9/8/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Progressable <NSObject>

- (void)progressUpdated:(float)progress ofTotal:(float)total;

@end
