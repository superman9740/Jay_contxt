//
//  DrawingFreehandView.h
//  Contxt
//
//  Created by Chad Morris on 6/19/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "DrawingView.h"

@interface DrawingFreehandView : DrawingView
{
    NSMutableArray * _points;
    
    CGPoint _min;
    CGPoint _max;
}

@property (nonatomic , readonly) NSArray * points;
@property (nonatomic) CGSize delta;

- (void)updatePoint:(CGPoint)point;
- (CGPoint)topLeftPoint;
- (CGPoint)bottomRightPoint;
- (void)adjustPointsByDistance:(CGSize)distance;

@end
