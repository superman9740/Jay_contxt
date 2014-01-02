//
//  AnnotationButton.h
//  Contxt
//
//  Created by Chad Morris on 5/16/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Annotation;

@interface AnnotationButton : UIButton

@property (nonatomic , strong) Annotation * annotation;

@end
