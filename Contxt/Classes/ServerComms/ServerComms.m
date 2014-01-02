//
//  ServerUrlBuilder.m
//  TestBC
//
//  Created by Chad Morris on 5/5/12.
//  Copyright (c) 2012 p2websolutions. All rights reserved.
//

#import "ServerComms.h"
#import "DDURLBuilder.h"
//#import "JSONKit.h"

#import "AFNetworking.h"
#import "AFImageRequestOperation.h"
#import "DataController.h"
#import "JSONUtility.h"
#import "Utilities.h"

#import "NSDictionary+Contains.h"
#import "NSDictionary+CMJSON.h"

#import "Annotation.h"
#import "AnnotationDocument.h"
#import "ImageAnnotation.h"
#import "ConvoAnnotation.h"
#import "ImageInfo.h"

#import "ConversationThread.h"
#import "ConversationMessage.h"


static ServerComms *sharedComms = nil;
static int _processingDeletes = 0;
static int _processingChanges = 0;
static int _proccessingNewDocsOperation = 0;
static int _processingNewConvoMsgsOperation = 0;
static int _processingAnnotationsForDocOperation = 0;
static int _processingConvoThreadForAnnotOperation = 0;
static int _processingDocForImageAnnotOperation = 0;

@interface ServerComms()
{
    AFHTTPRequestOperation * _newDocsOperation;
    AFHTTPRequestOperation * _newConvoMsgsOperation;
    AFHTTPRequestOperation * _convoThreadForAnnotOperation;
    AFHTTPRequestOperation * _docForImageAnnotOperation;
    AFHTTPRequestOperation * _annotationsForDocOperation;
}

- (BOOL)saveImageAnnotation:(ImageAnnotation *)annotation;
- (BOOL)saveConvoAnnotation:(ConvoAnnotation *)annotation;
- (BOOL)uploadImageForImageInfoKey:(NSString *)key;
- (BOOL)performAddRemoveAction:(NSNumber *)objChangeType participants:(NSArray *)participantEmails convoThreadKey:(NSString *)threadKey;

@end

@implementation ServerComms

NSString * _host = @"1182angelina.com";

// @TODO: CHANGE THIS TO BE PRODUCTION SERVER PATH
NSString * _path = @"Contxt/tmp";


+ (NSString *)path
{
    return _path;
}

+ (NSString *)host
{
    return _host;
}

+ (NSString *)urlStringForImageInfo:(ImageInfo *)image
{
    return [self urlStringForImageKey:image.filename extension:image.extension];
}

+ (NSString *)urlStringForImageKey:(NSString *)key extension:(NSString *)ext
{
    return [NSString stringWithFormat:@"%@/%@/%@/%@.%@"
            , HTTP_BASE_URL
            , _path
            , @"uploads"
            , key
            , ( !ext || [ext isEqualToString:@""] ? @"jpg" : ext )];
}


#pragma mark - Login / Signup Operations

- (void)processValidateEmail:(NSDictionary *)params
{
    NSString * path = [NSString stringWithFormat:@"/%@/authenticate.php",_path];

    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:params];
    
    NSLog( @"path: %@" , path );
    NSLog( @"params: %@" , allParams );

    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    AFJSONRequestOperation *validateEmailOperation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            NSDictionary * JSONresponse = (NSDictionary *)JSON;
            NSLog( @"json: %@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
            
            NSString * status = [[JSONresponse objectForKey:@"status"] uppercaseString];
            
            for( id<ServerCommsObserver> observer in _observers )
                [observer completedUserValidationRequest:([[status lowercaseString] isEqualToString:@"success"] ? true : false )
                                                 message:[JSONresponse objectForKey:@"message"]];
        }

        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSDictionary * JSONresponse = (NSDictionary *)JSON;
            
            NSLog( @"Acknowledgement request failed with error: %@" , [NSString stringWithFormat:@"%@" , error] );

            for( id<ServerCommsObserver> observer in _observers )
                [observer completedUserValidationRequest:false
                                                 message:[JSONresponse objectForKey:@"message"]];
        }
    ];
    
    [validateEmailOperation start];
}


- (void)processSignUp:(NSDictionary *)params
{
    NSString * path = [NSString stringWithFormat:@"/%@/authenticate.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:params];
    
    NSLog( @"path: %@" , path );
    NSLog( @"params: %@" , allParams );
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    AFJSONRequestOperation *signUpOperation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSDictionary * JSONresponse = (NSDictionary *)JSON;
            NSLog( @"json: %@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
            
            NSString * status = [[JSONresponse objectForKey:@"status"] uppercaseString];
            
            for( id<ServerCommsObserver> observer in _observers )
                [observer completedSignUpRequest:([[status lowercaseString] isEqualToString:@"success"] ? true : false)
                                         message:[JSONresponse objectForKey:@"message"]];
        }

        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSDictionary * JSONresponse = (NSDictionary *)JSON;
            
            for( id<ServerCommsObserver> observer in _observers )
                [observer completedSignUpRequest:false
                                         message:[JSONresponse objectForKey:@"message"]];
        }
    ];
    
    [signUpOperation start];
}


#pragma mark - Fetch Operations

- (void)sendSavedAcknowledgementForType:(NSString *)type key:(NSString *)key
{
    NSString * path = [NSString stringWithFormat:@"/%@/acknowledgement.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"type" : type }];
    [allParams addEntriesFromDictionary:@{ @"key" : key }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSLog( @"Acknowledgement Status: %@ .. Message: %@" , [JSONresponse objectForKey:@"status"] , [JSONresponse objectForKey:@"message"] );
         } // end of success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             NSLog( @"Acknowledgement request failed with error: %@" , [NSString stringWithFormat:@"%@" , error] );
         }
    ];
    
    [operation start];
}

- (BOOL)checkForNewAnnotationDocuments
{
    if( _proccessingNewDocsOperation )
    {
        NSLog( @"checkForNewAnnotationDocuments is still processing" );
        return FALSE;
    }
    
    NSString * path = [NSString stringWithFormat:@"/%@/getObjects.php",_path];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [params setObject:@"ANNOTATION_DOC_NEW" forKey:@"request_type"];

    NSURLRequest * requestImageInfoURL = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                                    path:path
                                                                                              parameters:params];
    
    _newDocsOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestImageInfoURL
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             
             if( [[[JSONresponse objectForKey:@"status"] uppercaseString] isEqualToString:@"ERROR"] )
             {
                 for( id<ServerCommsObserver> observer in _observers )
                     [observer serverErrorOccurred:[JSONresponse objectForKey:@"message"]];
             }
             else
             {
                 if( [JSON objectForKey:@"annotation_docs"] )
                 {
                     NSArray * docList = [JSON objectForKey:@"annotation_docs"];
                     NSMutableArray * docKeys = [[NSMutableArray alloc] init];

                     NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                     tempContext.parentContext = [DataController sharedController].managedObjectContext;
                     
                     for( int i = 0 ; i < docList.count ; i++ )
                     {
                         if( [[docList objectAtIndex:i] containsKey:@"key"] )
                         {
                             AnnotationDocument * foundDoc = [[DataController sharedController] annotationDocumentForKey:[[docList objectAtIndex:i] objectForKey:@"key"] moc:tempContext];
                             if( foundDoc )
                                 continue;
                         }
                         
                         AnnotationDocument * doc = [JSONUtility annotationDocFromJSON:[docList objectAtIndex:i] moc:tempContext];
                         [[DataController sharedController] saveContextWithMoc:tempContext];
                         
                         if( !doc )
                             NSLog( @"Error: Doc was nil" );
                         else
                         {
                             [docKeys addObject:doc.key];
                             
                             NSString * imageURL = [ServerComms urlStringForImageInfo:doc.image];

                             NSURLRequest *requestImageURL = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
                             AFImageRequestOperation * imageOperation;
                             imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:requestImageURL
                                   imageProcessingBlock:^UIImage *(UIImage *image) {
                                       return image;
                                   } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       [Utilities updateImageInfo:doc.image
                                                        withImage:image
                                                        asPreview:YES
                                                      asThumbnail:YES
                                                     preserveSize:YES];

                                       NSLog( @"Successfully downloaded image for ANNOTATION_DOC!" );
                                       [[DataController sharedController] saveContextWithMoc:tempContext];
                                       
                                       for( id<ServerCommsObserver> observer in _observers )
                                           [observer newAnnotationDocs:@[doc.key]];
                                       
                                       [self sendSavedAcknowledgementForType:@"ANNOTATION_DOC" key:doc.key];
                                       
                                       _proccessingNewDocsOperation--;
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSLog( @"Image DOWNLOAD error... \n%@" , [NSString stringWithFormat:@"%@" , error] );
                                       
                                       // Don't save the doc in this case...We will try again later
                                       [docKeys removeObject:doc.key];

                                       [tempContext deleteObject:doc];
                                       [tempContext processPendingChanges];
                                       [[DataController sharedController] saveContextWithMoc:tempContext];
                                       _proccessingNewDocsOperation--;
                                   }];
                             
                             _proccessingNewDocsOperation++;
                             [imageOperation start];
                         }
                     } // End for loop of docList
                     
                 } // End if JSON annotation_docs

             } // End outer if statement
             
             _proccessingNewDocsOperation--;
             
         } // End Success 

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             _proccessingNewDocsOperation--;
             NSLog( @"JSON: \n%@" , JSON );
         }
    ];
    
    _proccessingNewDocsOperation++;
    [_newDocsOperation start];
    return TRUE;
}


- (BOOL)checkForNewConversationMessages
{
    if( _processingNewConvoMsgsOperation )
    {
        NSLog( @"checkForNewConversationMessages is still executing........" );
        return FALSE;
    }
    
    NSString * path = [NSString stringWithFormat:@"/%@/getNewConvoMessages.php",_path];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    
    NSURLRequest * requestImageInfoURL = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                                    path:path
                                                                                              parameters:params];
    
    _newConvoMsgsOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestImageInfoURL
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             
             if( [[[JSONresponse objectForKey:@"status"] uppercaseString] isEqualToString:@"ERROR"] )
             {
                 for( id<ServerCommsObserver> observer in _observers )
                     [observer serverErrorOccurred:[JSONresponse objectForKey:@"message"]];
             }
             else
             {
                 if( [JSONresponse containsKey:@"convo_messages"] &&
                     [JSONresponse containsKey:@"message_count"] &&
                     [[JSONresponse objectForKey:@"message_count"] integerValue] > 0 )
                 {
                     NSArray * messageList = [JSON objectForKey:@"convo_messages"];

                     NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                     tempContext.parentContext = [DataController sharedController].managedObjectContext;
                     
                     for( int i = 0 ; i < messageList.count ; i++ )
                     {
                         if( [[messageList objectAtIndex:i] containsKey:@"key"] )
                         {
                             ConversationMessage * foundMessage = [[DataController sharedController] convoMessageForKey:[[messageList objectAtIndex:i] objectForKey:@"key"] moc:tempContext];
                             
                             if( foundMessage )
                                 continue;
                         }
                         
                         ConversationMessage * message = [JSONUtility convoMessageFromJSON:[messageList objectAtIndex:i] moc:tempContext];
                         
                         if( !message )
                             NSLog( @"Couldn't create the new message..." );
                         else
                         {
                             message.unread = [NSNumber numberWithBool:YES];
                             [[DataController sharedController] saveContextWithMoc:tempContext];

                             if( !message.managedObjectContext )
                                 NSLog( @"message MOC was NIL even AFTER I JUST SAVED..." );

                             if( (!message.text || [message.text isEqualToString:@""]) && (message.image || message.imageInfoKey) )
                             {
                                 NSString * imageURL = (message.image ? [ServerComms urlStringForImageInfo:message.image] : [ServerComms urlStringForImageKey:message.imageInfoKey extension:message.imageInfoExt]);
                                 
                                 NSURLRequest *requestImageURL = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
                                 AFImageRequestOperation * imageOperation;
                                 imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:requestImageURL
                                       imageProcessingBlock:^UIImage *(UIImage *image) {
                                           return image;
                                       } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           if( message.image )
                                           {
                                               NSLog( @".............updating imageInfo for message" );
                                               
                                               [Utilities updateImageInfo:message.image
                                                                withImage:image
                                                                asPreview:YES
                                                              asThumbnail:YES
                                                             preserveSize:YES];
                                           }
                                           else
                                           {
                                               NSLog( @".............creating a new imageInfo for message" );

                                               ImageInfo * imageInfo = [Utilities createImageInfoFromImage:image asPreview:NO asThumbnail:NO preserveSize:YES moc:tempContext];
                                               
                                               if( imageInfo.managedObjectContext == nil )
                                                   NSLog( @"imageInfo MOC is NIL" );
                                               else if( message.managedObjectContext == nil )
                                               {
                                                   NSLog( @"message MOC is NIL" );

                                                   if( !message )
                                                       NSLog( @"message is NIL, meaning it wasn't found in the MOC" );
                                                   else if( !message.managedObjectContext )
                                                       NSLog( @"message MOC was STILL NIL" );
                                                   else
                                                       NSLog( @"problem solved..." );

                                               }
                                               
                                               if( imageInfo )
                                                   [[DataController sharedController] associateImageInfo:imageInfo withMessage:message];
                                           }
                                           
                                           [[DataController sharedController] saveContextWithMoc:tempContext];

                                           for( id<ServerCommsObserver> observer in _observers )
                                               [observer newConvoMessages:@[message.key]];

                                           [self sendSavedAcknowledgementForType:@"CONVO_MESSAGE" key:message.key];

                                           _processingNewConvoMsgsOperation--;
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           _processingNewConvoMsgsOperation--;
                                           NSLog( @"Image DOWNLOAD error... \n%@" , [NSString stringWithFormat:@"%@" , error] );
                                       }];
                             
                                 _processingNewConvoMsgsOperation++;
                                 [imageOperation start];
                             }
                             else
                             {
                                 for( id<ServerCommsObserver> observer in _observers )
                                     [observer newConvoMessages:@[message.key]];
                             }
                         }
                     } // End for loop of messageList

                 } // End if JSONresponse
                 
             } // End outer if ERROR statement
             
             _processingNewConvoMsgsOperation--;
             
         } // End Success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             _processingNewConvoMsgsOperation--;
             NSLog( @"Error: \n%@" , [NSString stringWithFormat:@"%@" , error] );
         }
    ];

    _processingNewConvoMsgsOperation++;
    [_newConvoMsgsOperation start];
    return TRUE;
}

- (BOOL)getConvoThreadForConvoAnnotation:(ConvoAnnotation *)annotation
{
    if( _processingConvoThreadForAnnotOperation )
    {
        NSLog( @"getConvoThreadForConvoAnnotation is still processing..." );
        return FALSE;
    }
    
    NSString * annotationKey = annotation.key;
    
    NSString * path = [NSString stringWithFormat:@"/%@/getConvoThreadForConvoAnnotation.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"key" : annotationKey }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    _convoThreadForAnnotOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 
                 NSDictionary * JSONresponse = (NSDictionary *)JSON;
                 
                 NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                 tempContext.parentContext = [DataController sharedController].managedObjectContext;
                 
                 ConversationThread * thread = [JSONUtility convoThreadFromJSON:[JSONresponse objectForKey:@"convo_thread"] moc:tempContext];
                 [[DataController sharedController] saveContextWithMoc:tempContext];
                 
                 if( !thread )
                 {
                     NSLog( @"Error: thread was nil" );
                 }
                 else
                 {
                     for( ConversationMessage * message in thread.convoMessages )
                     {
                         NSLog( @"checking messages for images..." );
                         
                         if( !message.image )
                             continue;
                         
                         NSLog( @"found an image to download -- %@" , message.image.filename );
                         
                         NSString * imageURL = [ServerComms urlStringForImageInfo:message.image];
                         
                         NSURLRequest *requestImageURL = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
                         AFImageRequestOperation * imageOperation;
                         imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:requestImageURL
                               imageProcessingBlock:^UIImage *(UIImage *image) {
                                   return image;
                               } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   [Utilities updateImageInfo:message.image
                                                    withImage:image
                                                    asPreview:YES
                                                  asThumbnail:YES
                                                 preserveSize:YES];
                                   
                                   [[DataController sharedController] saveContextWithMoc:tempContext];

                                   for( id<ServerCommsObserver> observer in _observers )
                                       [observer newConvoMessages:@[message.key]];
                                   
                                   _processingConvoThreadForAnnotOperation--;
                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                   NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
                                   
                                   for( id<ServerCommsObserver> observer in _observers )
                                       [observer serverErrorOccurred:@"Could not download image. Please try again later."];

                                   _processingConvoThreadForAnnotOperation--;
                               }
                         ];

                         _processingConvoThreadForAnnotOperation++;
                         [imageOperation start];
                         
                     } // end For loop
                     
                     for( id<ServerCommsObserver> observer in _observers )
                         [observer newConvoThread:annotationKey];
                     
                 } // end if/else
                 
                 _processingConvoThreadForAnnotOperation--;
             } // end success

             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                 _processingConvoThreadForAnnotOperation--;
                 NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             }
        ];
    
    _processingConvoThreadForAnnotOperation++;
    [_convoThreadForAnnotOperation start];
    return TRUE;
}

- (BOOL)getAnnotationDocForImageAnnotation:(ImageAnnotation *)annotation
{
    if( _processingDocForImageAnnotOperation )
    {
        NSLog( @"getAnnotationDocForImageAnnotation is still processing..." );
        return FALSE;
    }
    
    NSString * annotationKey = annotation.key;
    
    NSString * path = [NSString stringWithFormat:@"/%@/getAnnotationDocForImageAnnotation.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"key" : annotationKey }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    _docForImageAnnotOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             
             NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
             tempContext.parentContext = [DataController sharedController].managedObjectContext;
             
             AnnotationDocument * newDoc = [JSONUtility annotationDocFromJSON:[JSONresponse objectForKey:@"annotation_doc"] moc:tempContext];
             ImageAnnotation * localAnnotation = [[DataController sharedController] imageAnnotationForKey:annotationKey moc:tempContext];
             
             if( !localAnnotation )
                 NSLog( @"Error: Couldn't find local annotation doc." );
             else if( !newDoc )
                 NSLog( @"Error: Doc was nil" );
             else
             {
                 NSString * imageURL = [ServerComms urlStringForImageInfo:newDoc.image];
                 
                 NSURLRequest *requestImageURL = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
                 AFImageRequestOperation * imageOperation;
                 imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:requestImageURL
                       imageProcessingBlock:^UIImage *(UIImage *image) {
                           return image;
                       } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                           [Utilities updateImageInfo:newDoc.image
                                            withImage:image
                                            asPreview:YES
                                          asThumbnail:YES
                                         preserveSize:YES];
                           
                           NSLog( @"Successfully downloaded image for ANNOTATION_DOC!" );
                           
                           localAnnotation.annotationDoc = newDoc;
                           newDoc.parentAnnotation = localAnnotation;
                           
                           [[DataController sharedController] saveContextWithMoc:tempContext];
                           
                           for( id<ServerCommsObserver>observer in _observers )
                               [observer newDocForImageAnnotation:annotation.key];
                           
                           _processingDocForImageAnnotOperation--;
                           
                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                           
                           // Don't save the doc in this case...We will try again later
                           [tempContext deleteObject:newDoc];
                           [tempContext processPendingChanges];

                           // @TODO: FINISH_SYNC
                           // @TODO: KEEP or REMOVE THIS?
                           for( id<ServerCommsObserver>observer in _observers )
                               [observer serverErrorOccurred:@"Could not download image. Please try again later."];
                           
                           _processingDocForImageAnnotOperation--;
                       }
                 ];
                 
                 _processingDocForImageAnnotOperation++;
                 [imageOperation start];
             }

             _processingDocForImageAnnotOperation--;
         }

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             _processingDocForImageAnnotOperation--;
         }
    ];
    
    _processingDocForImageAnnotOperation++;
    [_docForImageAnnotOperation start];
    return TRUE;
}

- (BOOL)getAnnotationsForDoc:(AnnotationDocument *)doc
{
    if( _processingAnnotationsForDocOperation )
    {
        NSLog( @"getAnnotationsForDoc is still processing..." );
        return FALSE;
    }
    
    NSString * path = [NSString stringWithFormat:@"/%@/getAnnotationsForDoc.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"key" : doc.key }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    _annotationsForDocOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSArray * items = [JSONresponse objectForKey:@"items"];
             
             if( !items )
             {
                 NSLog( @"Nothing new" );
             }
             else
             {
                 BOOL bPinAnnotationsUpdated = NO;
                 BOOL bDrawingAnnotationsUpdated = NO;
                 BOOL bNewConvoMessagesReceived = NO;
                 
                 NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                 tempContext.parentContext = [DataController sharedController].managedObjectContext;
                 
                 for( NSDictionary * kv in items )
                 {
                     // Check for the following:
                     //   type - the annotation type
                     //   status - NEW,UPDATED,DELETED
                     //   annotation - the actual annotation
                     
                     if( ![JSONUtility requiredField:@"type" exists:kv]       ||
                        ![JSONUtility requiredField:@"status" exists:kv]     ||
                        ![JSONUtility requiredField:@"object" exists:kv] )
                     {
                         NSLog( @"getAnnotationsForDoc - Error: Missing required fields." );
                     }
                     else
                     {
                         NSString * status =[kv objectForKey:@"status"];
                         NSString * type = [kv objectForKey:@"type"];
                         
                         if( [status isEqualToString:@"DELETED"] && ([type isEqualToString:@"DRAWING_ANNOTATION"] || [type isEqualToString:@"CONVO_ANNOTATION"]) )
                         {
                             NSString * key;
                             if( ![JSONUtility requiredField:@"key" exists:[kv objectForKey:@"object"]] )
                             {
                                 NSLog( @"getAnnotationsForDoc - Error: Could not get key for object." );
                             }
                             else
                             {
                                 key = [[kv objectForKey:@"object"] objectForKey:@"key"];
                                 
                                 if( [type isEqualToString:@"DRAWING_ANNOTATION"] )
                                 {
                                     DrawingAnnotation * annotation = [[DataController sharedController] drawingAnnotationForKey:key moc:tempContext];
                                     if( annotation )
                                     {
                                         [tempContext deleteObject:annotation];
                                         [tempContext processPendingChanges];
                                         [[DataController sharedController] saveContextWithMoc:tempContext];
                                         bDrawingAnnotationsUpdated = YES;
                                         [self sendSavedAcknowledgementForType:@"DRAWING_ANNOTATION" key:key];
                                     }
                                 }
                                 else if( [type isEqualToString:@"CONVO_ANNOTATION"] )
                                 {
                                     ConvoAnnotation * annotation = [[DataController sharedController] convoAnnotationForKey:key moc:tempContext];
                                     if( annotation )
                                     {
                                         [tempContext deleteObject:annotation];
                                         [tempContext processPendingChanges];
                                         [[DataController sharedController] saveContextWithMoc:tempContext];
                                         bPinAnnotationsUpdated = YES;
                                         [self sendSavedAcknowledgementForType:@"CONVO_ANNOTATION" key:key];
                                     }
                                 }
                                 else
                                 {
                                     NSLog( @"Unknown type = '%@' received with status = DELETED." , type );
                                 }
                             }
                         }
                         else if( [type isEqualToString:@"DRAWING_ANNOTATION"] )
                         {
                             // CREATED or UPDATED are both handled with this call
                             DrawingAnnotation * annotation = [JSONUtility drawingAnnotationFromJSON:[kv objectForKey:@"object"] moc:tempContext];
                             
                             if( annotation )
                             {
                                 [[DataController sharedController] saveContextWithMoc:tempContext];
                                 bDrawingAnnotationsUpdated = YES;
                                 [self sendSavedAcknowledgementForType:@"DRAWING_ANNOTATION" key:annotation.key];
                             }
                         }
                         else if( [type isEqualToString:@"IMAGE_ANNOTATION"] )
                         {
                             
                             // @TODO: TEST ME
                             // @TODO: FINISH_SYNC
                             // @TODO: TEST ME
                             
                             if( [status isEqualToString:@"CREATED"] )
                             {
                                 ImageAnnotation * annotation = [JSONUtility imageAnnotationFromJSON:[kv objectForKey:@"object"] moc:tempContext];
                                 
                                 if( annotation )
                                 {
                                     [[DataController sharedController] saveContextWithMoc:tempContext];
                                     bPinAnnotationsUpdated = YES;
                                     [self sendSavedAcknowledgementForType:@"IMAGE_ANNOTATION" key:annotation.key];
                                 }
                             }
                             else
                             {
                                 NSLog( @"Unknown status = '%@' received for type = '%@'" , status , type );
                             }
                         }
                         else if( [type isEqualToString:@"CONVO_ANNOTATION"] )
                         {
                             // @TODO: TEST ME
                             // @TODO: FINISH_SYNC
                             // @TODO: TEST ME
                             
                             if( [status isEqualToString:@"CREATED"] )
                             {
                                 ConvoAnnotation * annotation = [JSONUtility convoAnnotationFromJSON:[kv objectForKey:@"object"] moc:tempContext];
                                 
                                 if( annotation )
                                 {
                                     [[DataController sharedController] saveContextWithMoc:tempContext];
                                     bPinAnnotationsUpdated = YES;
                                     bNewConvoMessagesReceived = YES;
                                     [self sendSavedAcknowledgementForType:@"CONVO_ANNOTATION" key:annotation.key];
                                 }
                             }
                             else
                             {
                                 NSLog( @"Unknown status = '%@' received for type = '%@'" , status , type );
                             }
                         }
                         else if( [type isEqualToString:@"CONVO_PARTICIPANT"] )
                         {
                             if( [status isEqualToString:@"DELETED"] )
                             {
                                 if( ![JSONUtility requiredField:@"participantEmail" exists:[kv objectForKey:@"object"]] ||
                                    ![JSONUtility requiredField:@"convoAnnotationKey" exists:[kv objectForKey:@"object"]] )
                                 {
                                     NSLog( @"getAnnotationsForDoc - Error: Could not get key processing delete for CONVO_PARTICIPANT." );
                                 }
                                 else
                                 {
                                     NSString * participantEmail = [[kv objectForKey:@"object"] objectForKey:@"participantEmail"];
                                     NSString * convoAnnotationKey = [[kv objectForKey:@"object"] objectForKey:@"convoAnnotationKey"];
                                     
                                     ContxtContact * contact = [[DataController sharedController] contactWithEmail:participantEmail moc:tempContext];
                                     ConvoAnnotation * annotation = [[DataController sharedController] convoAnnotationForKey:convoAnnotationKey moc:tempContext];
                                     
                                     if( !contact )
                                     {
                                         NSLog( @"Could not find associated contact for email '%@'." , participantEmail );
                                     }
                                     else if( !annotation )
                                     {
                                         NSLog( @"Could not find associated convoAnnotation for key '%@'." , convoAnnotationKey );
                                     }
                                     else
                                     {
                                         if( annotation.convoThread )
                                         {
                                             [contact removeParentConvoThreadObject:annotation.convoThread];
                                             [annotation.convoThread removeParticipantsObject:contact];
                                             
                                             [self sendSavedAcknowledgementForType:@"PARTICIPANT_EMAIL+CONVO_ANNOTATION_KEY" key:[NSString stringWithFormat:@"%@+%@",participantEmail,annotation.key]];
                                         }
                                         
                                         [[DataController sharedController] saveContextWithMoc:tempContext];

                                         // NOTE: No need to delete contxt contact if not more parent threads, because it's likely they will share other annotations with specified user
                                     }
                                 }
                             }
                             else if( [status isEqualToString:@"CREATED"] )
                             {
                                 if( ![JSONUtility requiredField:@"contxtContact" exists:[kv objectForKey:@"object"]] ||
                                    ![JSONUtility requiredField:@"convoAnnotationKey" exists:[kv objectForKey:@"object"]] )
                                 {
                                     NSLog( @"getAnnotationsForDoc - Error: Could not get key processing create for CONVO_PARTICIPANT." );
                                 }
                                 else
                                 {
                                     NSString * convoAnnotationKey = [[kv objectForKey:@"object"] objectForKey:@"convoAnnotationKey"];
                                     
                                     ContxtContact * contact;
                                     
                                     if( ![[DataController sharedController] contxtContactForKey:[[[kv objectForKey:@"object"] objectForKey:@"contxtContact"] objectForKey:@"key"] moc:tempContext] )
                                     {
                                         contact = [JSONUtility contxtContactFromJSON:[[kv objectForKey:@"object"] objectForKey:@"contxtContact"] moc:tempContext];
                                     }
                                     else
                                     {
                                         contact = [[DataController sharedController] contactWithEmail:[[[kv objectForKey:@"object"] objectForKey:@"contxtContact"] objectForKey:@"email"] moc:tempContext];
                                     }
                                     
                                     ConvoAnnotation * annotation = [[DataController sharedController] convoAnnotationForKey:convoAnnotationKey moc:tempContext];
                                     
                                     if( !contact )
                                     {
                                         NSLog( @"Could find or create contact for key." );
                                     }
                                     else if( !annotation )
                                     {
                                         NSLog( @"Could not find associated convoAnnotation for key '%@'." , convoAnnotationKey );
                                     }
                                     else
                                     {
                                         if( annotation.convoThread )
                                         {
                                             [annotation.convoThread addParticipantsObject:contact];
                                             [contact addParentConvoThreadObject:annotation.convoThread];
                                         }
                                         
                                         [[DataController sharedController] saveContextWithMoc:tempContext];
                                         [self sendSavedAcknowledgementForType:@"PARTICIPANT_EMAIL+CONVO_ANNOTATION_KEY" key:[NSString stringWithFormat:@"%@+%@",contact.email,annotation.key]];
                                     }
                                 }
                             }
                             else
                             {
                                 NSLog( @"Unknown status = '%@' for type = '%@'." , status , type );
                             }
                         }
                         else if( [type isEqualToString:@"CONVO_MESSAGE"] )
                         {
                             if( [status isEqualToString:@"CREATED"] )
                             {
                                 ConversationMessage * message = [JSONUtility convoMessageFromJSON:[kv objectForKey:@"object"] moc:tempContext];
                                 
                                 if( !message )
                                     NSLog( @"Couldn't create the new message..." );
                                 else
                                 {
                                     message.unread = [NSNumber numberWithBool:YES];
                                     [[DataController sharedController] saveContextWithMoc:tempContext];
                                     bNewConvoMessagesReceived = YES;
                                     [self sendSavedAcknowledgementForType:@"CONVO_MESSAGE" key:message.key];
                                 }
                             }
                             else
                             {
                                 NSLog( @"Unknown status = '%@' for type = '%@'." , status , type );
                             }
                         }
                         else
                         {
                             NSLog( @"Unknown type = '%@' and/or status = '%@'." , type , status );
                         }
                         
                         
                     }
                 }
                 
                 
                 // If added or deleted ConvoThread, update pin view
                 // If added or updated or deleted DrawingAnnotation, update drawing annotations view
                 // If added ConvoMessages, update messages icon in navigation bar
                 
                 for( id<ServerCommsObserver> observer in _observers )
                 {
                     if( bPinAnnotationsUpdated )
                         [observer shouldRefreshPinAnnotations];
                     
                     if( bDrawingAnnotationsUpdated )
                         [observer shouldRefreshDrawingAnnotations];
                     
                     if( bNewConvoMessagesReceived )
                         [observer shouldUpdateConvoMessageList];
                 }

             } // end of if( !items )
             
             _processingAnnotationsForDocOperation--;
         } // end of success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             _processingAnnotationsForDocOperation--;
         }
    ];

    _processingAnnotationsForDocOperation++;
    [_annotationsForDocOperation start];
    return TRUE;
}


#pragma mark - Sharing Operations

- (BOOL)shareAnnotationDoc:(AnnotationDocument *)doc withEmailList:(NSArray *)emailList
{
    if( !emailList || emailList.count <= 0 )
    {
        for( id<ServerCommsObserver> observer in _observers )
            [observer sharedAnnotationDoc:doc.key success:NO message:@"Email list cannot be empty."];
        
        return FALSE;
    }
    
    NSString * key = doc.key;
    
    NSString * path = [NSString stringWithFormat:@"/%@/share.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"type" : @"ANNOTATION_DOC" }];
    [allParams addEntriesFromDictionary:@{ @"key" : key }];
    [allParams addEntriesFromDictionary:@{ @"email_list" : emailList }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             
             NSLog( @"json: %@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
             
             NSString * status = [JSONresponse objectForKey:@"status"];
             
             if( [[status lowercaseString] isEqualToString:@"success"] )
             {
                 for( id<ServerCommsObserver> observer in _observers )
                     [observer sharedAnnotationDoc:key success:YES message:nil];
             }
             else
             {
                 for( id<ServerCommsObserver> observer in _observers )
                     [observer sharedAnnotationDoc:key success:NO message:[JSONresponse objectForKey:@"message"]];
             }
             
         } // end of success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             
             for( id<ServerCommsObserver> observer in _observers )
                 [observer sharedAnnotationDoc:key success:NO message:@"Could not share at this time. Please try again later."];
         }
    ];
    
    [operation start];
    return TRUE;
}

- (BOOL)shareImageAnnotation:(ImageAnnotation *)annotation withEmails:(NSArray *)emailList
{
    if( !emailList || emailList.count <= 0 )
    {
        for( id<ServerCommsObserver> observer in _observers )
            [observer sharedImageAnnotation:annotation.key success:NO message:@"Email list cannot be empty."];
        
        return FALSE;
    }
    
    NSString * key = annotation.key;
    
    NSString * path = [NSString stringWithFormat:@"/%@/share.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"type" : @"IMAGE_ANNOTATION" }];
    [allParams addEntriesFromDictionary:@{ @"key" : annotation.key }];
    [allParams addEntriesFromDictionary:@{ @"email_list" : emailList }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSLog( @"json: %@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
             
             NSString * status = [JSONresponse objectForKey:@"status"];
             
             if( [[status lowercaseString] isEqualToString:@"success"] )
             {
                 for( id<ServerCommsObserver> observer in _observers )
                     [observer sharedImageAnnotation:key success:YES message:nil];
             }
             else
             {
                 for( id<ServerCommsObserver> observer in _observers )
                     [observer sharedImageAnnotation:key success:NO message:[JSONresponse objectForKey:@"message"]];
             }
             
         } // end of success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             
             for( id<ServerCommsObserver> observer in _observers )
                 [observer sharedImageAnnotation:key success:NO message:@"Could not share at this time. Please try again later."];
         }
    ];
    
    [operation start];
    return TRUE;
}

- (void)processPendingChanges
{
    if( _processingChanges )
    {
        NSLog( @"Changes are currently being processed. Additional changes will be processed later." );
        return;
    }
    
    NSMutableArray * changedObjects = [[NSMutableArray alloc] init];
    
    [changedObjects addObjectsFromArray:[[DataController sharedController] getContxtContactsWithStatusPending]];
    [changedObjects addObjectsFromArray:[[DataController sharedController] getAnnotationDocsWithStatusPending]];
    [changedObjects addObjectsFromArray:[[DataController sharedController] getAnnotationsWithStatusPending]];
    [changedObjects addObjectsFromArray:[[DataController sharedController] getConvoMessagesWithStatusPending]];
    
    for( Object * object in changedObjects )
    {
        if( [object isKindOfClass:[ContxtContact class]] )
        {
            ContxtContact * contact = (ContxtContact *)object;
            NSDictionary * json = [NSDictionary dictionaryFromJSONstring:contact.pendingChangeJSON];
            NSMutableArray * threadKeys;
            
            if( json && [json containsKey:@"convoThreadKey"] && [json objectForKey:@"convoThreadKey"] )
                threadKeys = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"convoThreadKey"]];
            
            if( !threadKeys )
                continue;
            
            if( [contact.pendingChangeStatus intValue] == OBJ_CHANGE_TYPE_ADD )
            {
                for( NSString * key in threadKeys )
                    [self addParticipants:@[contact.email] forConvoThreadKey:key];
            }
            else if( [contact.pendingChangeStatus intValue] == OBJ_CHANGE_TYPE_DELETE )
            {
                for( NSString * key in threadKeys )
                    [self removeParticipants:@[contact.email] forConvoThreadKey:key];
            }
        }
        else if( [object isKindOfClass:[AnnotationDocument class]] )
        {
            [self saveAnnotationDoc:(AnnotationDocument *)object];
        }
        else if( [object isKindOfClass:[Annotation class]] )
        {
            [self saveAnnotation:(Annotation *)object];
        }
        else if( [object isKindOfClass:[ConversationMessage class]] )
        {
            [self saveConvoMessage:(ConversationMessage *)object];
        }
    }
}


#pragma mark - Delete Methods

- (void)processPendingDeletes
{
    if( _processingDeletes )
        return;
    
    NSArray * list = [[DataController sharedController] getAllObjectsWithStatus:OBJ_STATUS_DELETE];
    
    for( Object * obj in list )
        [self deleteObject:obj];
}

- (BOOL)deleteObject:(Object *)obj
{
    if( !obj )
        return FALSE;
    
    NSString * type;
    
    if( [obj isKindOfClass:[AnnotationDocument class]] )
        type = @"ANNOTATION_DOC";
    else if( [obj isKindOfClass:[ConvoAnnotation class]] )
        type = @"CONVO_ANNOTATION";
    else if( [obj isKindOfClass:[ImageAnnotation class]] )
        type = @"IMAGE_ANNOTATION";
    else if( [obj isKindOfClass:[DrawingAnnotation class]] )
        type = @"DRAWING_ANNOTATION";
    else
    {
        NSLog( @"Cannot delete object. Unsupported type." );
        return FALSE;
    }
    
    _processingDeletes++;
    
    NSString * path = [NSString stringWithFormat:@"/%@/delete.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"type" : type }];
    [allParams addEntriesFromDictionary:@{ @"key" : obj.key }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempContext.parentContext = [DataController sharedController].managedObjectContext;
    
    Object * localObject = [[DataController sharedController] objectForKey:obj.key moc:tempContext];
    if( !localObject )
        return FALSE;
    
    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             NSLog( @"request: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
             
             _processingDeletes--;
             
             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSString * status = [JSONresponse objectForKey:@"status"];
             
             if( [[status lowercaseString] isEqualToString:@"success"] )
             {
                 NSLog( @"Deleted %@. Request body: \n%@" , type , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
                 
                 [tempContext deleteObject:localObject];
                 [tempContext processPendingChanges];
                 [[DataController sharedController] saveContextWithMoc:tempContext];
             }
             else
             {
                 if( [JSON containsKey:@"message"] )
                     NSLog( @"Error deleting object of type %@ with key: %@ - Message: %@" , type , obj.key , [JSON objectForKey:@"message"] );
             }
         } // end of success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {

             _processingDeletes--;
             
             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             NSLog( @"request: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
         }
    ];
    
    [operation start];
    return TRUE;
}



- (BOOL)addParticipants:(NSArray *)participantEmails forConvoThreadKey:(NSString *)threadKey
{
    return [self performAddRemoveAction:[NSNumber numberWithInt:OBJ_CHANGE_TYPE_ADD] participants:participantEmails convoThreadKey:threadKey];
}

- (BOOL)removeParticipants:(NSArray *)participantEmails forConvoThreadKey:(NSString *)threadKey
{
    return [self performAddRemoveAction:[NSNumber numberWithInt:OBJ_CHANGE_TYPE_DELETE] participants:participantEmails convoThreadKey:threadKey];
} 

- (BOOL)performAddRemoveAction:(NSNumber *)objChangeType participants:(NSArray *)participantEmails convoThreadKey:(NSString *)threadKey
{
    NSString * path;
    
    if( [objChangeType intValue] == OBJ_CHANGE_TYPE_ADD )
        path = [NSString stringWithFormat:@"/%@/addParticipants.php",_path];
    else if( [objChangeType intValue] == OBJ_CHANGE_TYPE_DELETE )
        path = [NSString stringWithFormat:@"/%@/removeParticipants.php",_path];
    else
        return FALSE;
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"type" : @"CONVO_THREAD" }];
    [allParams addEntriesFromDictionary:@{ @"key" : threadKey }];
    [allParams addEntriesFromDictionary:@{ @"email_list" : participantEmails }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSString * status = [JSONresponse objectForKey:@"status"];
             NSLog( @"request: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
             
             NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
             tempContext.parentContext = [DataController sharedController].managedObjectContext;
             
             if( [[status lowercaseString] isEqualToString:@"success"] )
             {
                 NSLog( @"%@ed participants." , objChangeType );
                 
                 for( NSString * email in participantEmails )
                 {
                     ContxtContact * contact = [[DataController sharedController] contactWithEmail:email moc:tempContext];
                     
                     if( contact )
                     {
                         NSString * keyLabel = @"convoThreadKey";
                         NSMutableDictionary * json = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryFromJSONstring:contact.pendingChangeJSON]];
                         
                         if( json && [json containsKey:keyLabel] && [json objectForKey:keyLabel] && [[json objectForKey:keyLabel] isKindOfClass:[NSArray class]] )
                         {
                             NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[json objectForKey:keyLabel]];
                             if( [array containsObject:threadKey] )
                             {
                                 [array removeObject:threadKey];
                                 [json setObject:array forKey:keyLabel];
                                 contact.pendingChangeJSON = [json toJSONstring];
                             }
                         }

                         contact.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
                         contact.pendingChangeStatus = [NSNumber numberWithInt:OBJ_CHANGE_TYPE_NONE];
                     }
                 }
                 
                 [tempContext processPendingChanges];
                 [[DataController sharedController] saveContextWithMoc:tempContext];
             }
             else
             {
                 NSLog( @"Could not %@ participants." , objChangeType );
                 
                 if( [JSON containsKey:@"message"] )
                     NSLog( @"Error: %@" , [JSON objectForKey:@"message"] );
                 
                 for( NSString * email in participantEmails )
                 {
                     ContxtContact * contact = [[DataController sharedController] contactWithEmail:email moc:tempContext];
                     
                     if( contact )
                     {
                         NSString * keyLabel = @"convoThreadKey";
                         NSMutableDictionary * json = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryFromJSONstring:contact.pendingChangeJSON]];
                         
                         if( !json )
                             json = [[NSMutableDictionary alloc] init];

                         if( ![json containsKey:keyLabel] || ![json objectForKey:keyLabel] )
                         {
                             [json setObject:@[threadKey] forKey:keyLabel];
                         }
                         else
                         {
                             NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[json objectForKey:keyLabel]];
                             [array addObject:threadKey];
                             [json setObject:array forKey:keyLabel];
                         }
                         
                         contact.status = [NSNumber numberWithInt:OBJ_STATUS_PENDING];
                         contact.pendingChangeStatus = objChangeType;
                         contact.pendingChangeJSON = [json toJSONstring];
                     }
                 }
                 
                 [tempContext processPendingChanges];
                 [[DataController sharedController] saveContextWithMoc:tempContext];
             }
         } // end of success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             NSLog( @"request: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
             
             NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
             tempContext.parentContext = [DataController sharedController].managedObjectContext;
             
             for( NSString * email in participantEmails )
             {
                 ContxtContact * contact = [[DataController sharedController] contactWithEmail:email moc:tempContext];
                 
                 if( contact )
                 {
                     NSString * keyLabel = @"convoThreadKey";
                     NSMutableDictionary * json = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryFromJSONstring:contact.pendingChangeJSON]];
                     
                     if( !json )
                         json = [[NSMutableDictionary alloc] init];
                     
                     if( ![json containsKey:keyLabel] || ![json objectForKey:keyLabel] )
                     {
                         [json setObject:@[threadKey] forKey:keyLabel];
                     }
                     else
                     {
                         NSArray * array = @[ [[json objectForKey:keyLabel] allObjects] , threadKey];
                         [json setObject:array forKey:keyLabel];
                     }
                     
                     contact.status = [NSNumber numberWithInt:OBJ_STATUS_PENDING];
                     contact.pendingChangeStatus = objChangeType;
                     contact.pendingChangeJSON = [json toJSONstring];
                 }
             }
             
             [tempContext processPendingChanges];
             [[DataController sharedController] saveContextWithMoc:tempContext];
         }
    ];
    
    [operation start];
    return TRUE;
}

#pragma mark - Save Operations

- (BOOL)saveAnnotation:(Annotation *)annotation
{
    DrawingAnnotation * drawingAnnotation;
    
    if( [annotation isKindOfClass:[ImageAnnotation class]] )
        return [self saveImageAnnotation:(ImageAnnotation *)annotation];
    else if( [annotation isKindOfClass:[ConvoAnnotation class]] )
        return [self saveConvoAnnotation:(ConvoAnnotation *)annotation];
    else if( [annotation isKindOfClass:[DrawingAnnotation class]] )
        drawingAnnotation = (DrawingAnnotation *)annotation;
    else
        return FALSE;

    if( !drawingAnnotation )
        return FALSE;
    
    NSString * path = [NSString stringWithFormat:@"/%@/save.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"type" : @"DRAWING_ANNOTATION" }];
    [allParams addEntriesFromDictionary:@{ @"object" : [JSONUtility drawingAnnotationToJSON:((DrawingAnnotation *)annotation) cascade:YES] }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];

    NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempContext.parentContext = [DataController sharedController].managedObjectContext;
    
    DrawingAnnotation * localAnnotation = [[DataController sharedController] drawingAnnotationForKey:annotation.key moc:tempContext];
    if( !localAnnotation )
        return FALSE;

    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             _processingChanges--;
             
             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSString * status = [JSONresponse objectForKey:@"status"];
             
             if( [[status lowercaseString] isEqualToString:@"success"] )
             {
                 NSLog( @"Saved DRAWING_ANNOTATION. Request body: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
                 
                 localAnnotation.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
                 [[DataController sharedController] saveContextWithMoc:tempContext];
             }
             else
             {
                 if( [JSON containsKey:@"message"] )
                     NSLog( @"Error: %@" , [JSON objectForKey:@"message"] );
             }
         } // end of success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             _processingChanges--;
             
             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             NSLog( @"request: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
         }
    ];
    
    _processingChanges++;
    [operation start];
    return TRUE;
}

- (BOOL)saveImageAnnotation:(ImageAnnotation *)annotation
{
    NSString * path = [NSString stringWithFormat:@"/%@/save.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"type" : @"IMAGE_ANNOTATION" }];
    [allParams addEntriesFromDictionary:@{ @"object" : [JSONUtility imageAnnotationToJSON:((ImageAnnotation *)annotation) cascade:YES] }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempContext.parentContext = [DataController sharedController].managedObjectContext;
    
    ImageAnnotation * localAnnotation = [[DataController sharedController] imageAnnotationForKey:annotation.key moc:tempContext];
    if( !localAnnotation )
        return FALSE;

    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             _processingChanges--;

             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSString * status = [JSONresponse objectForKey:@"status"];
             
             if( [[status lowercaseString] isEqualToString:@"success"] )
             {
                 NSLog( @"Saved IMAGE_ANNOTATION. Request body: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
                 
                 localAnnotation.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
                 [[DataController sharedController] saveContextWithMoc:tempContext];
                 
                 [self uploadImageForImageInfoKey:localAnnotation.annotationDoc.image.key];
             }
             else
             {
                 if( [JSON containsKey:@"message"] )
                     NSLog( @"Error: %@" , [JSON objectForKey:@"message"] );
             }
         } // end of success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             _processingChanges--;

             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             NSLog( @"request: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
         }
    ];
    
    _processingChanges++;
    [operation start];
    return TRUE;
}

- (BOOL)saveConvoAnnotation:(ConvoAnnotation *)annotation
{
    NSString * path = [NSString stringWithFormat:@"/%@/save.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"type" : @"CONVO_ANNOTATION" }];
    [allParams addEntriesFromDictionary:@{ @"object" : [JSONUtility convoAnnotationToJSON:((ConvoAnnotation *)annotation) cascade:YES] }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempContext.parentContext = [DataController sharedController].managedObjectContext;
    
    ConvoAnnotation * localAnnotation = [[DataController sharedController] convoAnnotationForKey:annotation.key moc:tempContext];
    if( !localAnnotation )
        return FALSE;
    
    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             _processingChanges--;

             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSString * status = [JSONresponse objectForKey:@"status"];
             
             if( [[status lowercaseString] isEqualToString:@"success"] )
             {
                 NSLog( @"Saved CONVO_ANNOTATION. Request body: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
                 
                 localAnnotation.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
                 [[DataController sharedController] saveContextWithMoc:tempContext];
                 
                 for( ConversationMessage * message in localAnnotation.convoThread.convoMessages )
                 {
                     if( message.image && [message.image.status intValue] == OBJ_STATUS_PENDING )
                         [self uploadImageForImageInfoKey:message.image.key];
                 }
             }
             else
             {
                 if( [JSON containsKey:@"message"] )
                     NSLog( @"Error: %@" , [JSON objectForKey:@"message"] );
             }
         } // end of success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             _processingChanges--;

             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             NSLog( @"request: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
         }
    ];
    
    _processingChanges++;
    [operation start];
    return TRUE;
}

- (BOOL)uploadImageForImageInfoKey:(NSString *)key
{
    NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempContext.parentContext = [DataController sharedController].managedObjectContext;
    
    ImageInfo * imageInfo = [[DataController sharedController] imageInfoForKey:key moc:tempContext];
    
    if( !imageInfo )
        return FALSE;
    
    NSData *imageData = [NSData dataWithContentsOfFile:imageInfo.path];
    NSString * mimeType = [NSString stringWithFormat:@"image/%@", imageInfo.extension];
    NSString * filename = [NSString stringWithFormat:@"%@.%@", imageInfo.filename , imageInfo.extension];
    
    NSString * path = [NSString stringWithFormat:@"/%@/uploadImage.php",_path];
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];

    NSURLRequest *request = [[DataController sharedController].httpClient multipartFormRequestWithMethod:@"POST"
                                                                                                    path:path
                                                                                              parameters:allParams
                                                                               constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                                                                                   [formData appendPartWithFileData:imageData name:@"image" fileName:filename mimeType:mimeType];
                                                                               }];
    
    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSString * status = [JSONresponse objectForKey:@"status"];
             
             if( [[status lowercaseString] isEqualToString:@"success"] )
             {
                 NSLog( @"Uploaded image. Request body: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
                 
                 imageInfo.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
                 [[DataController sharedController] saveContextWithMoc:tempContext];
             }
             else
             {
                 if( [JSON containsKey:@"message"] )
                     NSLog( @"Error: %@" , [JSON objectForKey:@"message"] );
             }
         }

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             NSLog( @"JSON: \n%@" , JSON );
             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
         }
    ];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [operation start];
    return TRUE;
}

- (BOOL)saveAnnotationDoc:(AnnotationDocument *)doc
{
    NSString * path = [NSString stringWithFormat:@"/%@/save.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"type" : @"ANNOTATION_DOC" }];
    [allParams addEntriesFromDictionary:@{ @"object" : [JSONUtility annotationDocToJSON:doc cascade:YES] }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempContext.parentContext = [DataController sharedController].managedObjectContext;
    
    AnnotationDocument * localDoc = [[DataController sharedController] annotationDocumentForKey:doc.key moc:tempContext];
    if( !localDoc )
        return FALSE;
    
    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             _processingChanges--;

             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSString * status = [JSONresponse objectForKey:@"status"];
             
             if( [[status lowercaseString] isEqualToString:@"success"] )
             {
                 NSLog( @"Saved ANNOTATION_DOC. Request body: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
                 
                 localDoc.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
                 [[DataController sharedController] saveContextWithMoc:tempContext];
                 
                 [self uploadImageForImageInfoKey:localDoc.image.key];
             }
             else
             {
                 if( [JSON containsKey:@"message"] )
                     NSLog( @"Error: %@" , [JSON objectForKey:@"message"] );
             }
         } // end of success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             _processingChanges--;

             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             NSLog( @"request: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
         }
    ];
    
    _processingChanges++;
    [operation start];
    return TRUE;
}

- (BOOL)saveConvoMessage:(ConversationMessage *)message
{
    NSString * path = [NSString stringWithFormat:@"/%@/save.php",_path];
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:[DataController sharedController].credParams];
    [allParams addEntriesFromDictionary:@{ @"type" : @"CONVO_MESSAGE" }];
    [allParams addEntriesFromDictionary:@{ @"object" : [JSONUtility convoMessageToJSON:message cascade:YES] }];
    
    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:path
                                                                                         parameters:allParams];
    
    NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempContext.parentContext = [DataController sharedController].managedObjectContext;
    
    ConversationMessage * localMessage = [[DataController sharedController] convoMessageForKey:message.key moc:tempContext];
    if( !localMessage )
        return FALSE;
    
    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             _processingChanges--;

             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSString * status = [JSONresponse objectForKey:@"status"];
             
             if( [[status lowercaseString] isEqualToString:@"success"] )
             {
                 NSLog( @"Saved CONVO_MESSAGE. Request body: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
                 
                 localMessage.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
                 [[DataController sharedController] saveContextWithMoc:tempContext];
                 
                 if( localMessage.image )
                     [self uploadImageForImageInfoKey:localMessage.image.key];
             }
             else
             {
                 if( [JSON containsKey:@"message"] )
                     NSLog( @"Error: %@" , [JSON objectForKey:@"message"] );
             }
         } // end of success

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             _processingChanges--;

             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             NSLog( @"request: \n%@" , [[NSString alloc] initWithData:request.HTTPBody encoding:4] );
         }
    ];
    
    _processingChanges++;
    [operation start];
    return TRUE;
}


#pragma mark - Singleton

// Initialize the singleton instance if needed and return
+ (ServerComms *)sharedComms
{
	if( !sharedComms )
		sharedComms = [[ServerComms alloc] init];
    
	return sharedComms;
}


#pragma mark - ServerCommsObservable Methods

-(void)addObserver:(id<ServerCommsObserver>)observer
{
	if( nil == _observers )
		_observers = [[NSMutableArray alloc] init];
	
	if( ![_observers containsObject:observer] )
		[_observers addObject:observer];
}

-(void)removeObserver:(id<ServerCommsObserver>)observer
{
	if( nil != _observers && [_observers containsObject:observer])
		[_observers removeObject:observer];
}



@end
