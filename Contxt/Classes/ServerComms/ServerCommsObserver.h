//
//  ServerCommsObserver.h
//  GodThoughts
//
//  Created by Chad Morris on 6/11/12.
//  Copyright (c) 2012 p2websolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerCommsObserver <NSObject>

@required
- (void)serverErrorOccurred:(NSString *)error;

@optional
- (void)newConvoThread:(NSString *)key;
- (void)newDocForImageAnnotation:(NSString *)key;
- (void)shouldRefreshPinAnnotations;
- (void)shouldRefreshDrawingAnnotations;
- (void)shouldUpdateConvoMessageList;
- (void)sharedAnnotationDoc:(NSString *)key success:(BOOL)success message:(NSString *)message;
- (void)sharedImageAnnotation:(NSString *)key success:(BOOL)success message:(NSString *)message;

- (void)savedDrawingAnnotationForKey:(NSString *)key withDate:(NSDate *)date;


- (void)newAnnotationDocs:(NSArray *)keys;
- (void)newConvoMessages:(NSArray *)keys;
- (void)convoThreadDeleted:(NSString *)key;
- (void)drawingAnnotationUpdated:(NSString *)key;
- (void)newDrawingAnnnotation:(NSString *)key;
- (void)newImageAnnotation:(NSString *)key;
- (void)newConvoAnnotation:(NSString *)key;

- (void)completedUserValidationRequest:(bool)status message:(NSString *)message;
- (void)completedSignUpRequest:(bool)status message:(NSString *)message;

- (void)receivedData:(NSData *)data forURL:(NSURL *)url;
- (void)connectionFailedWithError:(NSError *)error url:(NSURL *)url;

@end
