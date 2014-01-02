//
//  DataController.h
//  Contxt
//
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataChangeObservable.h"
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

#import "AFNetworking.h"

#define DM_ANNOTATION           @"Annotation"
#define DM_ANNOTATION_DETAILS   @"AnnotationDetails"
#define DM_ANNOTATION_DOCUMENT  @"AnnotationDocument"
#define DM_ANNOTATION_POINT     @"AnnotationPoint"
#define DM_ANNOTATION_SIZE      @"AnnotationSize"
#define DM_CONTXT_CONTACT       @"ContxtContact"
#define DM_CONVERSATION_MESSAGE @"ConversationMessage"
#define DM_CONVERSATION_THREAD  @"ConversationThread"
#define DM_IMAGE_INFO           @"ImageInfo"
#define DM_LOGIN_CREDS          @"LoginCreds"
#define DM_OBJECT               @"Object"
#define DM_PROJECT              @"Project"
#define DM_CONVO_ANNOTATION     @"ConvoAnnotation"
#define DM_DRAWING_ANNOTATION   @"DrawingAnnotation"
#define DM_IMAGE_ANNOTATION     @"ImageAnnotation"

#define UNTITLED_PROJECT_GUID   @"170D8B2C-9E96-41CA-9928-F27C219BC646"
#define SHARED_IMAGES_GUID      @"221e3b01-c90b-4638-bea5-4a8f2bd732e9"

#define USER_KEY @"x978z54"
#define PASS_KEY @"x302y18"


// @TODO: CHANGE THIS TO BE PRODUCTION SERVER PATH
// @TODO: CHANGE THIS TO BE PRODUCTION SERVER PATH
#define HTTP_BASE_URL @"http://www.1182angelina.com"
// @TODO: CHANGE THIS TO BE PRODUCTION SERVER PATH
// @TODO: CHANGE THIS TO BE PRODUCTION SERVER PATH


@interface DataController : NSObject <DataChangeObservable>
{
	NSMutableArray*	_observers;
    NSTimer * _newMessageTimer;
    
    AFHTTPClient * _httpClient;
    NSDictionary * _credParams;
}

@property (readonly, strong, nonatomic) NSString * baseURL;
@property (readonly, strong , nonatomic) AFHTTPClient * httpClient;
@property (readonly, strong , nonatomic) NSDictionary * credParams;

// Core Data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *privateMOC;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (void)saveContextWithMoc:(NSManagedObjectContext *)moc;
- (NSURL *)applicationDocumentsDirectory;

- (void)resetCredParams;

// Data Controller Setup
+ (DataController *)sharedController;

-(void)addObserver:(id<DataChangeObserver>)observer;
-(void)removeObserver:(id<DataChangeObserver>)observer;

- (BOOL)saveManagedObjectContext;
- (BOOL)saveManagedObjectContextWithMoc:(NSManagedObjectContext *)moc;

// Create New Objects
- (Project *)            untitledProject;
- (Project *)            newProject;
- (ImageInfo *)          newImageInfo;
- (ImageInfo *)          newImageInfoWithPathExtension:(NSString *)ext;
- (AnnotationDocument *) newAnnotationDocument;
- (AnnotationDetails *)  newAnnotationDetails;
- (AnnotationPoint *)    newAnnotationPoint;
- (AnnotationSize *)     newAnnotationSize;
- (ContxtContact *)      newContxtContact;
- (ConversationMessage *)newConversationMessage;
- (ConversationThread *) newConversationThread;
- (ConvoAnnotation *)    newConvoAnnotation;
- (DrawingAnnotation *)  newDrawingAnnotation;
- (ImageAnnotation *)    newImageAnnotation;
- (ContxtContact *)      contactWithEmail:(NSString *)email;

- (Project *)            untitledProjectWithMOC:(NSManagedObjectContext *)moc;
- (Project *)            newProjectWithMOC:(NSManagedObjectContext *)moc;
- (ImageInfo *)          newImageInfoWithMOC:(NSManagedObjectContext *)moc;
- (ImageInfo *)          newImageInfoWithPathExtension:(NSString *)ext moc:(NSManagedObjectContext *)moc;
- (AnnotationDocument *) newAnnotationDocumentWithMOC:(NSManagedObjectContext *)moc;
- (AnnotationDetails *)  newAnnotationDetailsWithMOC:(NSManagedObjectContext *)moc;
- (AnnotationPoint *)    newAnnotationPointWithMOC:(NSManagedObjectContext *)moc;
- (AnnotationSize *)     newAnnotationSizeWithMOC:(NSManagedObjectContext *)moc;
- (ContxtContact *)      newContxtContactWithMOC:(NSManagedObjectContext *)moc;
- (ConversationMessage *)newConversationMessageWithMOC:(NSManagedObjectContext *)moc;
- (ConversationThread *) newConversationThreadWithMOC:(NSManagedObjectContext *)moc;
- (ConvoAnnotation *)    newConvoAnnotationWithMOC:(NSManagedObjectContext *)moc;
- (DrawingAnnotation *)  newDrawingAnnotationWithMOC:(NSManagedObjectContext *)moc;
- (ImageAnnotation *)    newImageAnnotationWithMOC:(NSManagedObjectContext *)moc;
- (ContxtContact *)      contactWithEmail:(NSString *)email moc:(NSManagedObjectContext *)moc;



// Associations for relationships
- (BOOL)associateAnnotation:(Annotation *)annotation withAnnotationDocument:(AnnotationDocument *)doc;
- (BOOL)associateImageInfo:(ImageInfo *)imageInfo withAnnotationDocument:(AnnotationDocument *)doc;
- (BOOL)associateImageInfo:(ImageInfo *)imageInfo withMessage:(ConversationMessage *)message;
- (BOOL)associateAnnotationDocument:(AnnotationDocument *)doc withProject:(Project *)project;
- (BOOL)associateAnnotationDocument:(AnnotationDocument *)doc withImageAnnotation:(ImageAnnotation *)annotation;
- (BOOL)associateThumbnailImageInfo:(ImageInfo *)imageInfo withProject:(Project *)project;
- (BOOL)associateMessage:(ConversationMessage *)message withThread:(ConversationThread *)thread;

// Delete Actions
- (void)deleteAnnotation:(Annotation *)annotation;
- (void)deleteAnnotationDocument:(AnnotationDocument *)doc;

// Fetch Requests
- (AnnotationDetails *)   annotationDetailsForKey:(NSString *)key;
- (AnnotationDocument *) annotationDocumentForKey:(NSString *)key;
- (AnnotationPoint *)       annotationPointForKey:(NSString *)key;
- (AnnotationSize *)         annotationSizeForKey:(NSString *)key;
- (ContxtContact *)           contxtContactForKey:(NSString *)key;
- (ConversationMessage *)      convoMessageForKey:(NSString *)key;
- (ConversationThread *)        convoThreadForKey:(NSString *)key;
- (ConvoAnnotation *)       convoAnnotationForKey:(NSString *)key;
- (DrawingAnnotation *)   drawingAnnotationForKey:(NSString *)key;
- (ImageAnnotation *)       imageAnnotationForKey:(NSString *)key;
- (ImageInfo *)                   imageInfoForKey:(NSString *)key;
- (Project *)                       projectForKey:(NSString *)key;

- (Object *)                         objectForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (AnnotationDetails *)   annotationDetailsForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (AnnotationDocument *) annotationDocumentForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (AnnotationPoint *)       annotationPointForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (AnnotationSize *)         annotationSizeForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (ContxtContact *)           contxtContactForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (ConversationMessage *)      convoMessageForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (ConversationThread *)        convoThreadForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (ConvoAnnotation *)       convoAnnotationForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (DrawingAnnotation *)   drawingAnnotationForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (ImageAnnotation *)       imageAnnotationForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (ImageInfo *)                   imageInfoForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;
- (Project *)                       projectForKey:(NSString *)key moc:(NSManagedObjectContext *)moc;

- (NSArray *)getObjectsWithEntityName:(NSString *)name status:(short)status;
- (NSArray *)getAllObjectsWithStatus:(short)status;
- (NSArray *)getAnnotationDocsWithStatusPending;
- (NSArray *)getAnnotationsWithStatusPending;
- (NSArray *)getConvoMessagesWithStatusPending;
- (NSArray *)getContxtContactsWithStatusPending;

- (NSArray *)projectList;

- (NSArray *)convoMessagesForConvoThread:(NSString *)key;
- (NSArray *)newestMessageFromEachConvoThread;

- (BOOL)removeParticipant:(ContxtContact *)contact fromConversationThread:(ConversationThread *)thread;
- (BOOL)removeParticipantByEmail:(NSString *)email fromConversationThread:(ConversationThread *)thread;
- (BOOL)shareConversationThread:(ConversationThread *)thread withContact:(ContxtContact *)contact;
- (BOOL)doesNewMessageExist;
- (BOOL)doesNewMessageExistForConversationThreadKey:(NSString *)key;

// Login
- (void)setUserValidated;
- (NSString *)signedUpUser;
- (BOOL)signupUser:(NSString *)username withPassword:(NSString *)password;
- (BOOL)isSignedUp;
- (BOOL)isSignedUpWithUser:(NSString *)username;

@end
