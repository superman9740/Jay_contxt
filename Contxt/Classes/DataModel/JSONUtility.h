//
//  JSONUtility.h
//  Contxt
//
//  Created by Chad Morris on 8/12/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Annotation.h"
#import "AnnotationDetails.h"
#import "AnnotationDocument.h"
#import "AnnotationPoint.h"
#import "AnnotationSize.h"
#import "ContxtContact.h"
#import "ConversationMessage.h"
#import "ConversationThread.h"
#import "ImageInfo.h"
#import "LoginCreds.h"
#import "Project.h"
#import "ConvoAnnotation.h"
#import "DrawingAnnotation.h"
#import "ImageAnnotation.h"
#import "Object.h"


@interface JSONUtility : NSObject

+ (NSDictionary *)annotationDocToJSON:(AnnotationDocument *)obj     cascade:(BOOL)cascade;
+ (NSDictionary *)annotationDetailsToJSON:(AnnotationDetails *)obj  cascade:(BOOL)cascade;
+ (NSDictionary *)annotationPointToJSON:(AnnotationPoint *)obj      cascade:(BOOL)cascade;
+ (NSDictionary *)annotationSizeToJSON:(AnnotationSize *)obj        cascade:(BOOL)cascade;
+ (NSDictionary *)convoAnnotationToJSON:(ConvoAnnotation *)obj      cascade:(BOOL)cascade;
+ (NSDictionary *)drawingAnnotationToJSON:(DrawingAnnotation *)obj  cascade:(BOOL)cascade;
+ (NSDictionary *)imageAnnotationToJSON:(ImageAnnotation *)obj      cascade:(BOOL)cascade;
+ (NSDictionary *)contxtContactToJSON:(ContxtContact *)obj          cascade:(BOOL)cascade;
+ (NSDictionary *)convoMessageToJSON:(ConversationMessage *)obj     cascade:(BOOL)cascade;
+ (NSDictionary *)convoThreadToJSON:(ConversationThread *)obj       cascade:(BOOL)cascade;
+ (NSDictionary *)imageInfoToJSON:(ImageInfo *)obj                  cascade:(BOOL)cascade;
+ (NSDictionary *)loginCredsToJSON:(LoginCreds *)obj                cascade:(BOOL)cascade;

+ (AnnotationDocument *)   annotationDocFromJSON:(NSDictionary *)json;
+ (AnnotationDetails *)annotationDetailsFromJSON:(NSDictionary *)json;
+ (AnnotationPoint *)    annotationPointFromJSON:(NSDictionary *)json;
+ (AnnotationSize *)      annotationSizeFromJSON:(NSDictionary *)json;
+ (ConvoAnnotation *)    convoAnnotationFromJSON:(NSDictionary *)json;
+ (DrawingAnnotation *)drawingAnnotationFromJSON:(NSDictionary *)json;
+ (ImageAnnotation *)    imageAnnotationFromJSON:(NSDictionary *)json;
+ (ContxtContact *)        contxtContactFromJSON:(NSDictionary *)json;
+ (ConversationMessage *)   convoMessageFromJSON:(NSDictionary *)json;
+ (ConversationThread *)     convoThreadFromJSON:(NSDictionary *)json;
+ (ImageInfo *)                imageInfoFromJSON:(NSDictionary *)json;

+ (AnnotationDocument *)   annotationDocFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;
+ (AnnotationDetails *)annotationDetailsFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;
+ (AnnotationPoint *)    annotationPointFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;
+ (AnnotationSize *)      annotationSizeFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;
+ (ConvoAnnotation *)    convoAnnotationFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;
+ (DrawingAnnotation *)drawingAnnotationFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;
+ (ImageAnnotation *)    imageAnnotationFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;
+ (ContxtContact *)        contxtContactFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;
+ (ConversationMessage *)   convoMessageFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;
+ (ConversationThread *)     convoThreadFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;
+ (ImageInfo *)                imageInfoFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;

+ (BOOL)requiredField:(NSString *)field exists:(id)json;


@end
