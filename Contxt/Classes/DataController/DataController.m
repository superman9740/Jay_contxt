//
//  DataController.m
//  Contxt
//
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import "DataController.h"
#import "NSMutableArray+Queue.h"
#import "Utilities.h"
#import "Object.h"
#import "ServerComms.h"


#ifndef NDEBUG
    #include <stdlib.h>
#endif


static DataController *sharedController = nil;

@interface DataController()

- (id)managedObject:(NSString *)type forKey:(NSString *)key;
- (id)managedObject:(NSString *)type forKey:(NSString *)key moc:(NSManagedObjectContext *)moc;

@end

@implementation DataController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize privateMOC = _privateMOC;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (NSString *)baseURL
{
    return HTTP_BASE_URL;
}

- (AFHTTPClient *)httpClient
{
    if( !_httpClient )
    {
        NSURL * url = [NSURL URLWithString:HTTP_BASE_URL];
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        _httpClient.parameterEncoding = AFJSONParameterEncoding;
    }
    
    return _httpClient;
}

- (NSDictionary *)credParams
{
    if( !_credParams )
    {
        LoginCreds * creds = [self signedUpUserCreds];
        
        if( !creds )
            return nil;
        
        _credParams = [NSDictionary dictionaryWithObjectsAndKeys:creds.password , PASS_KEY, creds.username, USER_KEY, nil];
    }
    
    return _credParams;
}

- (void)resetCredParams
{
    _credParams = nil;
}

- (void)setUserValidated
{
    LoginCreds * creds = [self signedUpUserCreds];
    creds.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
    
    [self saveContext];
}


#pragma mark - Login

- (BOOL)signupUser:(NSString *)username withPassword:(NSString *)password
{
    LoginCreds * creds = [self signedUpUserCreds];
    
    if( !creds )
    {
        creds = [NSEntityDescription insertNewObjectForEntityForName:DM_LOGIN_CREDS
                                              inManagedObjectContext:self.managedObjectContext];
    }
    
    creds.key = [Utilities generateGUID];
    creds.username = username;
    creds.password = [Utilities md5HexDigest:password];
    
    NSLog( @"password: %@" , creds.password );
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return FALSE;
    }
    
    [self saveContext];
    
    return TRUE;
}

- (BOOL)saveManagedObjectContext
{
    return [self saveManagedObjectContextWithMoc:self.managedObjectContext];
}

- (BOOL)saveManagedObjectContextWithMoc:(NSManagedObjectContext *)moc
{
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return FALSE;
    }
    
    return TRUE;
}


#pragma mark - Helper Methods

- (id)managedObject:(NSString *)type forKey:(NSString *)key
{
    return [self managedObject:type forKey:key moc:self.managedObjectContext];
}

- (id)managedObject:(NSString *)type forKey:(NSString *)key moc:(NSManagedObjectContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:type
                                              inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key == %@",key]];
    
    NSError *error;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    
    if( [fetchedObjects count] <= 0 )
        return nil;
    
    return [fetchedObjects objectAtIndex:0];
}


#pragma mark - Create New NSManageObject instances

- (Project *)untitledProject
{
    return [self untitledProjectWithMOC:self.managedObjectContext];
}

- (Project *)untitledProjectWithMOC:(NSManagedObjectContext *)moc
{
    Project * p = [self projectForKey:UNTITLED_PROJECT_GUID moc:moc];
    
    if( !p )
    {
        p = [self newProjectWithMOC:moc];
        p.key = UNTITLED_PROJECT_GUID;
        p.title = @"Untitled Project";
    }
    
    return p;
}

- (Project *)newProject
{
    return [self newProjectWithMOC:self.managedObjectContext];
}

- (Project *)newProjectWithMOC:(NSManagedObjectContext *)moc
{
    Project * newProj = [NSEntityDescription
                         insertNewObjectForEntityForName:DM_PROJECT
                         inManagedObjectContext:moc];
    
    newProj.title = @"New Project";
    newProj.key = [Utilities generateGUID];
    newProj.dateCreated = [NSDate date];
    newProj.dateUpdated = [NSDate date];
    
    return newProj;
}

- (ImageInfo *)newImageInfo
{
    return [self newImageInfoWithPathExtension:@"jpg"];
}

- (ImageInfo *)newImageInfoWithMOC:(NSManagedObjectContext *)moc
{
    return [self newImageInfoWithPathExtension:@"jpg" moc:moc];
}

- (ImageInfo *)newImageInfoWithPathExtension:(NSString *)ext
{
    return [self newImageInfoWithPathExtension:ext moc:self.managedObjectContext];
}

- (ImageInfo *)newImageInfoWithPathExtension:(NSString *)ext moc:(NSManagedObjectContext *)moc
{
    ImageInfo * newImageInfo = [NSEntityDescription
                                insertNewObjectForEntityForName:DM_IMAGE_INFO
                                inManagedObjectContext:moc];
    
    newImageInfo.key = [Utilities generateGUID];
    newImageInfo.filename = newImageInfo.key;
    newImageInfo.extension = ext;
    newImageInfo.path = @"Documents";
    newImageInfo.owner = [self signedUpUser];
    newImageInfo.dateCreated = [NSDate date];
    
    return newImageInfo;
}

- (AnnotationDetails *)newAnnotationDetails
{
    return [self newAnnotationDetailsWithMOC:self.managedObjectContext];
}
- (AnnotationDetails *)newAnnotationDetailsWithMOC:(NSManagedObjectContext *)moc
{
    AnnotationDetails * details = [NSEntityDescription
                                   insertNewObjectForEntityForName:DM_ANNOTATION_DETAILS
                                   inManagedObjectContext:moc];
    
    details.key = [Utilities generateGUID];
    details.owner = [self signedUpUser];
    details.dateCreated = [NSDate date];
    details.dateUpdated = [NSDate date];
    
    return details;
}

- (AnnotationDocument *)newAnnotationDocument
{
    return [self newAnnotationDocumentWithMOC:self.managedObjectContext];
}

- (AnnotationDocument *)newAnnotationDocumentWithMOC:(NSManagedObjectContext *)moc
{
    AnnotationDocument * annDoc = [NSEntityDescription
                                   insertNewObjectForEntityForName:DM_ANNOTATION_DOCUMENT
                                   inManagedObjectContext:moc];
    
    annDoc.key = [Utilities generateGUID];
    
    return annDoc;
}

- (AnnotationPoint *)newAnnotationPoint
{
    return [self newAnnotationPointWithMOC:self.managedObjectContext];
}

- (AnnotationPoint *)newAnnotationPointWithMOC:(NSManagedObjectContext *)moc
{
    AnnotationPoint * point = [NSEntityDescription
                                   insertNewObjectForEntityForName:DM_ANNOTATION_POINT
                                   inManagedObjectContext:moc];
    
    return point;
}

- (AnnotationSize *)newAnnotationSize
{
    return [self newAnnotationSizeWithMOC:self.managedObjectContext];
}

- (AnnotationSize *)newAnnotationSizeWithMOC:(NSManagedObjectContext *)moc
{
    AnnotationSize * size = [NSEntityDescription
                               insertNewObjectForEntityForName:DM_ANNOTATION_SIZE
                               inManagedObjectContext:moc];
    
    return size;
}

- (ContxtContact *)newContxtContact
{
    return [self newContxtContactWithMOC:self.managedObjectContext];
}

- (ContxtContact *)newContxtContactWithMOC:(NSManagedObjectContext *)moc
{
    ContxtContact * contact = [NSEntityDescription
                                   insertNewObjectForEntityForName:DM_CONTXT_CONTACT
                                   inManagedObjectContext:moc];
    
    contact.key = [Utilities generateGUID];
    
    return contact;
}

- (ConversationMessage *)newConversationMessage
{
    return [self newConversationMessageWithMOC:self.managedObjectContext];
}

- (ConversationMessage *)newConversationMessageWithMOC:(NSManagedObjectContext *)moc
{
    ConversationMessage * msg = [NSEntityDescription
                                 insertNewObjectForEntityForName:DM_CONVERSATION_MESSAGE
                                 inManagedObjectContext:moc];
    
    msg.key = [Utilities generateGUID];
    msg.dateCreated = [NSDate date];
    
    return msg;
}

- (ConversationThread *)newConversationThread
{
    return [self newConversationThreadWithMOC:self.managedObjectContext];
}

- (ConversationThread *)newConversationThreadWithMOC:(NSManagedObjectContext *)moc
{
    ConversationThread * thread = [NSEntityDescription
                                   insertNewObjectForEntityForName:DM_CONVERSATION_THREAD
                                   inManagedObjectContext:moc];
    
    thread.key = [Utilities generateGUID];
    thread.dateCreated = [NSDate date];

    return thread;
}

- (ConvoAnnotation *)newConvoAnnotation
{
    return [self newConvoAnnotationWithMOC:self.managedObjectContext];
}

- (ConvoAnnotation *)newConvoAnnotationWithMOC:(NSManagedObjectContext *)moc
{
    ConvoAnnotation * annot = [NSEntityDescription
                                   insertNewObjectForEntityForName:DM_CONVO_ANNOTATION
                                   inManagedObjectContext:moc];
    
    annot.key = [Utilities generateGUID];
    annot.dateCreated = [NSDate date];
    annot.dateUpdated = [NSDate date];
    annot.owner = [self signedUpUser];
    
    return annot;
}

- (DrawingAnnotation *)newDrawingAnnotation
{
    return [self newDrawingAnnotationWithMOC:self.managedObjectContext];
}

- (DrawingAnnotation *)newDrawingAnnotationWithMOC:(NSManagedObjectContext *)moc
{
    DrawingAnnotation * annot = [NSEntityDescription
                                   insertNewObjectForEntityForName:DM_DRAWING_ANNOTATION
                                   inManagedObjectContext:moc];
    
    annot.key = [Utilities generateGUID];
    annot.dateCreated = [NSDate date];
    annot.dateUpdated = [NSDate date];
    annot.owner = [self signedUpUser];
    annot.anchorPoint = [self newAnnotationPointWithMOC:moc];
    annot.size = [self newAnnotationSizeWithMOC:moc];
    annot.text = nil;
    
    annot.details = [self newAnnotationDetailsWithMOC:moc];
    
    return annot;
}

- (ImageAnnotation *)newImageAnnotation
{
    return [self newImageAnnotationWithMOC:self.managedObjectContext];
}

- (ImageAnnotation *)newImageAnnotationWithMOC:(NSManagedObjectContext *)moc
{
    ImageAnnotation * annot = [NSEntityDescription
                                   insertNewObjectForEntityForName:DM_IMAGE_ANNOTATION
                                   inManagedObjectContext:moc];
    
    annot.key = [Utilities generateGUID];
    annot.dateCreated = [NSDate date];
    annot.dateUpdated = [NSDate date];
    annot.owner = [self signedUpUser];
    
    return annot;
}


#pragma mark - Associations

- (BOOL)associateAnnotation:(Annotation *)annotation withAnnotationDocument:(AnnotationDocument *)doc
{
    if( !annotation || !doc )
        return FALSE;
    
    if( annotation.parentAnnotationDocument )
        [annotation.parentAnnotationDocument removeAnnotationsObject:annotation];
    
    annotation.parentAnnotationDocument = doc;
    [doc addAnnotationsObject:annotation];
    
    return TRUE;
}

- (BOOL)associateAnnotationDocument:(AnnotationDocument *)doc withProject:(Project *)project
{
    if( !doc || !project )
        return FALSE;
    
    if( doc.parentProject )
        [doc.parentProject removeAnnotationDocsObject:doc];
    
    doc.parentProject = project;
    [project addAnnotationDocsObject:doc];
    
    return TRUE;
}

- (BOOL)associateAnnotationDocument:(AnnotationDocument *)doc withImageAnnotation:(ImageAnnotation *)annotation
{
    if( !doc || !annotation )
        return FALSE;

    doc.parentAnnotation = annotation;
    annotation.annotationDoc = doc;
    
    return TRUE;
}

- (BOOL)associateImageInfo:(ImageInfo *)imageInfo withAnnotationDocument:(AnnotationDocument *)doc
{
    if( !doc || !imageInfo )
        return FALSE;
    
    doc.image = imageInfo;
    imageInfo.parentAnnotationDocument = doc;
    
    return TRUE;
}

- (BOOL)associateImageInfo:(ImageInfo *)imageInfo withMessage:(ConversationMessage *)message
{
    if( !message || !imageInfo )
        return FALSE;
    
    message.image = imageInfo;
    imageInfo.parentConversationMessage = message;
    
    return TRUE;
}

- (BOOL)associateThumbnailImageInfo:(ImageInfo *)imageInfo withProject:(Project *)project
{
    if( !imageInfo || !project )
        return FALSE;
    
    project.thumbnail = imageInfo;
    imageInfo.parentProject = project;
    
    return TRUE;
}

- (BOOL)associateMessage:(ConversationMessage *)message withThread:(ConversationThread *)thread
{
    if( !message || !thread )
        return FALSE;
    
    message.parentConvoThread = thread;
    [thread addConvoMessagesObject:message];
    
    return TRUE;
}


#pragma mark - FETCHES

#pragma mark ManagedObject for Key

- (Project *)                      projectForKey:(NSString *)key { return (Project *)            [self managedObject:DM_PROJECT              forKey:key]; }
- (AnnotationDetails *)  annotationDetailsForKey:(NSString *)key { return (AnnotationDetails *)  [self managedObject:DM_ANNOTATION_DETAILS   forKey:key]; }
- (AnnotationDocument *)annotationDocumentForKey:(NSString *)key { return (AnnotationDocument *) [self managedObject:DM_ANNOTATION_DOCUMENT  forKey:key]; }
- (AnnotationPoint *)      annotationPointForKey:(NSString *)key { return (AnnotationPoint *)    [self managedObject:DM_ANNOTATION_POINT     forKey:key]; }
- (AnnotationSize *)        annotationSizeForKey:(NSString *)key { return (AnnotationSize *)     [self managedObject:DM_ANNOTATION_SIZE      forKey:key]; }
- (ImageInfo *)                  imageInfoForKey:(NSString *)key { return (ImageInfo *)          [self managedObject:DM_IMAGE_INFO           forKey:key]; }
- (ConversationMessage *)     convoMessageForKey:(NSString *)key { return (ConversationMessage *)[self managedObject:DM_CONVERSATION_MESSAGE forKey:key]; }
- (ConversationThread *)       convoThreadForKey:(NSString *)key { return (ConversationThread *) [self managedObject:DM_CONVERSATION_THREAD  forKey:key]; }
- (ContxtContact *)          contxtContactForKey:(NSString *)key { return (ContxtContact *)      [self managedObject:DM_CONTXT_CONTACT       forKey:key]; }
- (ConvoAnnotation *)      convoAnnotationForKey:(NSString *)key { return (ConvoAnnotation *)    [self managedObject:DM_CONVO_ANNOTATION     forKey:key]; }
- (DrawingAnnotation *)  drawingAnnotationForKey:(NSString *)key { return (DrawingAnnotation *)  [self managedObject:DM_DRAWING_ANNOTATION   forKey:key]; }
- (ImageAnnotation *)      imageAnnotationForKey:(NSString *)key { return (ImageAnnotation *)    [self managedObject:DM_IMAGE_ANNOTATION     forKey:key]; }

- (Object *)                        objectForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (Object *)             [self managedObject:DM_OBJECT               forKey:key moc:moc]; }
- (Project *)                      projectForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (Project *)            [self managedObject:DM_PROJECT              forKey:key moc:moc]; }
- (AnnotationDetails *)  annotationDetailsForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (AnnotationDetails *)  [self managedObject:DM_ANNOTATION_DETAILS   forKey:key moc:moc]; }
- (AnnotationDocument *)annotationDocumentForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (AnnotationDocument *) [self managedObject:DM_ANNOTATION_DOCUMENT  forKey:key moc:moc]; }
- (AnnotationPoint *)      annotationPointForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (AnnotationPoint *)    [self managedObject:DM_ANNOTATION_POINT     forKey:key moc:moc]; }
- (AnnotationSize *)        annotationSizeForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (AnnotationSize *)     [self managedObject:DM_ANNOTATION_SIZE      forKey:key moc:moc]; }
- (ImageInfo *)                  imageInfoForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (ImageInfo *)          [self managedObject:DM_IMAGE_INFO           forKey:key moc:moc]; }
- (ConversationMessage *)     convoMessageForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (ConversationMessage *)[self managedObject:DM_CONVERSATION_MESSAGE forKey:key moc:moc]; }
- (ConversationThread *)       convoThreadForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (ConversationThread *) [self managedObject:DM_CONVERSATION_THREAD  forKey:key moc:moc]; }
- (ContxtContact *)          contxtContactForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (ContxtContact *)      [self managedObject:DM_CONTXT_CONTACT       forKey:key moc:moc]; }
- (ConvoAnnotation *)      convoAnnotationForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (ConvoAnnotation *)    [self managedObject:DM_CONVO_ANNOTATION     forKey:key moc:moc]; }
- (DrawingAnnotation *)  drawingAnnotationForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (DrawingAnnotation *)  [self managedObject:DM_DRAWING_ANNOTATION   forKey:key moc:moc]; }
- (ImageAnnotation *)      imageAnnotationForKey:(NSString *)key moc:(NSManagedObjectContext *)moc { return (ImageAnnotation *)    [self managedObject:DM_IMAGE_ANNOTATION     forKey:key moc:moc]; }


#pragma mark By Status

- (NSArray *)getObjectsWithEntityName:(NSString *)name status:(short)status
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"status == %@",[NSNumber numberWithInt:status]]];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if( [fetchedObjects count] > 0 )
        return fetchedObjects;
    
    return nil;
}

- (NSArray *)getAllObjectsWithStatus:(short)status
{
    return [self getObjectsWithEntityName:DM_OBJECT status:OBJ_STATUS_DELETE];
}

- (NSArray *)getAnnotationDocsWithStatusPending
{
    return [self getObjectsWithEntityName:DM_ANNOTATION_DOCUMENT status:OBJ_STATUS_PENDING];
}

- (NSArray *)getAnnotationsWithStatusPending
{
    return [self getObjectsWithEntityName:DM_ANNOTATION status:OBJ_STATUS_PENDING];
}

- (NSArray *)getConvoMessagesWithStatusPending
{
    return [self getObjectsWithEntityName:DM_CONVERSATION_MESSAGE status:OBJ_STATUS_PENDING];
}

- (NSArray *)getContxtContactsWithStatusPending
{
    return [self getObjectsWithEntityName:DM_CONTXT_CONTACT status:OBJ_STATUS_PENDING];
}


#pragma mark Others

- (NSArray *)projectList
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DM_PROJECT
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if( [fetchedObjects count] <= 0 )
        return nil;
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"dateUpdated" ascending:NO];
    
    NSArray * sortedArray = [fetchedObjects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    
    return sortedArray;
}


- (NSArray *)convoMessagesForConvoThread:(NSString *)key
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DM_CONVERSATION_MESSAGE
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentConvoThread.key == %@",key]];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if( [fetchedObjects count] <= 0 )
        return nil;

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
    NSArray * sortedArray = [fetchedObjects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    
    return sortedArray;
}

- (NSArray *)newestMessageFromEachConvoThread
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DM_CONVERSATION_THREAD
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray * messages = [[NSMutableArray alloc] init];
    for( ConversationThread * convo in fetchedObjects )
    {
        NSArray * threadMessages = [self convoMessagesForConvoThread:convo.key];
        
        if( [threadMessages count] > 0 )
            [messages addObject:[threadMessages lastObject]];
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray * sortedArray = [messages sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];

    return sortedArray;
}

- (BOOL)doesNewMessageExist
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DM_CONVERSATION_MESSAGE
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"unread == 1"]];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if( [fetchedObjects count] > 0 )
        return YES;
    else
        return NO;
}

- (BOOL)doesNewMessageExistForConversationThreadKey:(NSString *)key
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DM_CONVERSATION_MESSAGE
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate * unreadPredicate = [NSPredicate predicateWithFormat:@"unread == 1"];
    NSPredicate * convoKeyPredicate = [NSPredicate predicateWithFormat:@"parentConvoThread.key == %@",key];
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:unreadPredicate, convoKeyPredicate, nil]];
    [fetchRequest setPredicate:compoundPredicate];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if( [fetchedObjects count] > 0 )
        return YES;
    else
        return NO;
}

- (ContxtContact *)contactWithEmail:(NSString *)email
{
    return [self contactWithEmail:email moc:self.managedObjectContext];
}

- (ContxtContact *)contactWithEmail:(NSString *)email moc:(NSManagedObjectContext *)moc;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DM_CONTXT_CONTACT
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"email == %@",email]];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if( [fetchedObjects count] > 0 )
    {
        return (ContxtContact *) [fetchedObjects objectAtIndex:0];
    }
    else
    {
        ContxtContact * contact = [self newContxtContact];
        contact.email = email;
        return contact;
    }
}

- (BOOL)doesContactExist:(NSString *)email
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DM_CONTXT_CONTACT
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"email == %@",email]];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if( [fetchedObjects count] > 0 )
        return YES;
    else
        return NO;
}


- (BOOL)removeParticipant:(ContxtContact *)contact fromConversationThread:(ConversationThread *)thread
{
    if( !contact || !thread )
        return FALSE;
    
    [thread removeParticipantsObject:contact];
    [[DataController sharedController] saveContext];
    
    return TRUE;
}

- (BOOL)removeParticipantByEmail:(NSString *)email fromConversationThread:(ConversationThread *)thread
{
    if( [self doesContactExist:email] )
    {
        return [self removeParticipant:[self contactWithEmail:email] fromConversationThread:thread];
    }
    
    return FALSE;
}


- (BOOL)shareConversationThread:(ConversationThread *)thread withContact:(ContxtContact *)contact
{
    if( !contact || !thread )
        return FALSE;
    
    [contact addParentConvoThreadObject:thread];
    [thread addParticipantsObject:contact];
    
    return TRUE;
}


#pragma mark - Credentials

- (LoginCreds *)signedUpUserCreds
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DM_LOGIN_CREDS
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if( [fetchedObjects count] > 0 )
        return ((LoginCreds *)[fetchedObjects objectAtIndex:0]);
    
    return nil;
}

- (NSString *)signedUpUser
{
    LoginCreds * creds = [self signedUpUserCreds];
    
    if( creds && creds.username && [creds.username length] > 0 )
        return creds.username;
    
    return nil;
}

- (BOOL)isSignedUp
{
    LoginCreds * creds = [self signedUpUserCreds];
    
    if( creds && creds.status == [NSNumber numberWithInt:OBJ_STATUS_SAVED] )  // ADD THIS CHECK after STATE is added
    {
        return TRUE;
    }
    
    return FALSE;
}

- (BOOL)isSignedUpWithUser:(NSString *)username
{
    NSLog( @"username: %@" , username );
    // Test out what we stored
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DM_LOGIN_CREDS
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"username == %@",username]];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if( [fetchedObjects count] > 0 )
        return TRUE;
    
    return FALSE;
}


#pragma mark - Delete Actions

- (void)deleteAnnotation:(Annotation *)annotation
{
    [self deleteAnnotation:annotation publishToServer:YES];
}
- (void)deleteAnnotation:(Annotation *)annotation publishToServer:(BOOL)publishDelete
{
    annotation.parentAnnotationDocument = nil;
    
    if( [annotation isKindOfClass:[ConvoAnnotation class]] )
        [self deleteImagesFromConvoAnnotation:(ConvoAnnotation *)annotation];
    else if( [annotation isKindOfClass:[ImageAnnotation class]] )
        [self deleteImagesFromImageAnnotation:(ImageAnnotation *)annotation];

    if( publishDelete )
    {
        annotation.status = [NSNumber numberWithInt:OBJ_STATUS_DELETE];
        [self saveContext];

        [[ServerComms sharedComms] deleteObject:annotation];
    }
    else
    {
        [self.managedObjectContext deleteObject:annotation];
        [self saveContext];
    }
}

- (void)deleteAnnotationDocument:(AnnotationDocument *)doc
{
    [self deleteAnnotationDocument:doc publishToServer:YES];
}

- (void)deleteAnnotationDocument:(AnnotationDocument *)doc publishToServer:(BOOL)publishDelete
{
    [self deleteImageFromImageInfo:doc.image];
    doc.parentProject = nil;
    
    for( Annotation * annotation in doc.annotations )
    {
        if( [annotation isKindOfClass:[ConvoAnnotation class]] )
            [self deleteImagesFromConvoAnnotation:(ConvoAnnotation *)annotation];
        else if( [annotation isKindOfClass:[ImageAnnotation class]] )
            [self deleteImagesFromImageAnnotation:(ImageAnnotation *)annotation];
    }
    
    if( publishDelete )
    {
        doc.status = [NSNumber numberWithInt:OBJ_STATUS_DELETE];
        [self saveContext];
        
        [[ServerComms sharedComms] deleteObject:doc];
    }
    else
    {
        [self.managedObjectContext deleteObject:doc];
        [self saveContext];
    }
}

- (void)deleteImagesFromConvoAnnotation:(ConvoAnnotation *)annotation
{
    if( annotation.convoThread && annotation.convoThread.convoMessages )
        for( ConversationMessage * message in annotation.convoThread.convoMessages )
            if( message.image )
                [self deleteImageFromImageInfo:message.image];
}

- (void)deleteImagesFromImageAnnotation:(ImageAnnotation *)annotation
{
    if( annotation && annotation.annotationDoc )
        [self deleteAnnotationDocument:annotation.annotationDoc publishToServer:NO];
}

- (void)deleteImageFromImageInfo:(ImageInfo *)imageInfo
{
    if( !imageInfo )
        return;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if( imageInfo.path )
        [fileManager removeItemAtPath:imageInfo.path error:nil];
    if( imageInfo.previewPath )
        [fileManager removeItemAtPath:imageInfo.previewPath error:nil];
    if( imageInfo.thumbPath )
        [fileManager removeItemAtPath:imageInfo.thumbPath error:nil];
}


#pragma mark -
#pragma mark Singleton

// Initialize the singleton instance if needed and return
+ (DataController *)sharedController
{
	if( !sharedController )
		sharedController = [[DataController alloc] init];
    
	return sharedController;
}


#pragma mark -
#pragma mark Delegate

-(void)addObserver:(id<DataChangeObserver>)observer
{
	if( nil == _observers )
		_observers = [[NSMutableArray alloc] init];
	
	if( ![_observers containsObject:observer] )
		[_observers addObject:observer];
}

-(void)removeObserver:(id<DataChangeObserver>)observer
{
	if( nil != _observers && [_observers containsObject:observer])
		[_observers removeObject:observer];
}


#pragma mark - Save Context

- (void)saveContext
{
    [self saveContextWithMoc:self.managedObjectContext];
}

- (void)saveContextWithMoc:(NSManagedObjectContext *)moc
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = moc;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectContext *)privateMOC
{
    if (_privateMOC != nil) {
        return _privateMOC;
    }
    
    _privateMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_privateMOC setParentContext:_managedObjectContext];
    
    return _privateMOC;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Contxt" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Contxt.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
