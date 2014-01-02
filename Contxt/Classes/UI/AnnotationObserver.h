//
//  ConvoViewControllerObserver.h
//  Contxt
//
//  Created by Chad Morris on 7/13/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AnnotationObserver <NSObject>

@optional
- (void)didDeleteAnnotationWithKey:(NSString *)key;
- (void)willDeleteAnnotationWithKey:(NSString *)key;

@end

