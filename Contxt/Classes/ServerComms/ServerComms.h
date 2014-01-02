//
//  ServerUrlBuilder.h
//  TestBC
//
//  Created by Chad Morris on 5/5/12.
//  Copyright (c) 2012 p2websolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServerCommsObserver.h"
#import "ServerCommsObservable.h"
#import "LoginCreds.h"

@class Annotation;
@class ImageInfo;
@class ImageAnnotation;
@class ConvoAnnotation;
@class ConversationThread;
@class ConversationMessage;
@class AnnotationDocument;

@interface ServerComms : NSObject <NSURLConnectionDataDelegate , ServerCommsObservable>
{
    NSURLConnection * _connection;
    NSMutableData * _receivedData;
    NSURL * _url;
    
    NSMutableArray * _observers;
}

+ (ServerComms *)sharedComms;

// Login/Signup
- (void)processValidateEmail:(NSDictionary *)params;
- (void)processSignUp:(NSDictionary *)params;

// Fetching
- (BOOL)checkForNewAnnotationDocuments;
- (BOOL)checkForNewConversationMessages;
- (BOOL)getConvoThreadForConvoAnnotation:(ConvoAnnotation *)annotation;
- (BOOL)getAnnotationDocForImageAnnotation:(ImageAnnotation *)annotation;
- (BOOL)getAnnotationsForDoc:(AnnotationDocument *)doc;

// Sharing
- (BOOL)shareAnnotationDoc:(AnnotationDocument *)doc withEmailList:(NSArray *)emailList;
- (BOOL)shareImageAnnotation:(ImageAnnotation *)annotation withEmails:(NSArray *)emailList;
- (BOOL)addParticipants:(NSArray *)participantEmails forConvoThreadKey:(NSString *)threadKey;
- (BOOL)removeParticipants:(NSArray *)participantEmails forConvoThreadKey:(NSString *)threadKey;

// Saving
- (BOOL)saveAnnotation:(Annotation *)annotation;
- (BOOL)saveAnnotationDoc:(AnnotationDocument *)doc;
- (BOOL)saveConvoMessage:(ConversationMessage *)message;
- (void)processPendingChanges;

// Deleting
- (BOOL)deleteObject:(Object *)obj;
- (void)processPendingDeletes;

+ (NSString *)host;
+ (NSString *)path;

+ (NSString *)urlStringForImageInfo:(ImageInfo *)image;
+ (NSString *)urlStringForImageKey:(NSString *)key extension:(NSString *)ext;

@end
