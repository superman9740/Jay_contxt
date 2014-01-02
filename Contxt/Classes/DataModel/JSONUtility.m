//
//  JSONUtility.m
//  Contxt
//
//  Created by Chad Morris on 8/12/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "JSONUtility.h"
#import "Utilities.h"
#import <Foundation/NSJSONSerialization.h>

#import "DataController.h"

#import "NSDictionary+Contains.h"



// @TODO: --NOTE: When a user deletes an annotation document...
//                The SERVER should not delete if request is not from the owner.
//                Otherwise, it's ok for the user to delete from their app.



@interface JSONUtility()

+ (BOOL)annotation:(Annotation *)obj FromJSON:(NSDictionary *)json;
+ (BOOL)annotation:(Annotation *)obj FromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc;

+ (NSDictionary *)annotationToJSON:(Annotation *)obj cascade:(BOOL)cascade;
+ (NSString *)valueOrEmptyString:(NSString *)obj;

@end

@implementation JSONUtility


#pragma mark - Validation Helper Methods

+ (BOOL)isValidJSONObject:(id)json
{
    if( ![NSJSONSerialization isValidJSONObject:json] )
        return NO;
    
    NSError* error;
    NSDictionary * dict = (NSDictionary *)json;
    
    if( error )
    {
        NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
        return NO;
    }
    
    if( !dict || dict.count <= 0 )
    {
        NSLog( @"error getting contents of json." );
        return NO;
    }
    
    return YES;
}

+ (BOOL)requiredField:(NSString *)field exists:(id)json
{
    if( ![((NSDictionary *)json) containsKey:field] )
    {
        NSLog( @"Required field `%@` is missing from JSON object." , field );
        return NO;
    }
    else if( ![((NSDictionary *)json) objectForKey:field] )
    {
        NSLog( @"Object for required field `%@` is null" , field );
        return NO;
    }
    
    return YES;
}

+ (NSString *)valueOrEmptyString:(NSString *)str
{
    if( !str )
        return @"";
    else
        return str;
}


#pragma mark - Conversions

+ (AnnotationDocument *)annotationDocFromJSON:(NSDictionary *)json
{
    return [JSONUtility annotationDocFromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (AnnotationDocument *)annotationDocFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
//    NSSet *annotations;
//    ImageInfo *image;
//    ImageAnnotation *parentAnnotation;
//    Project *parentProject;

    if( ![self isValidJSONObject:json] )
        return nil;
    
    if( ![self requiredField:@"type"                 exists:json]        ||
        ![[json objectForKey:@"type"] isEqualToString:@"ANNOTATION_DOC"] ||
        ![self requiredField:@"key"                  exists:json]        ||
        (![self requiredField:@"imageInfo"        exists:json]
          && ![self requiredField:@"imageInfoKey" exists:json])          )
    {
        return nil;
    }
    
    AnnotationDocument * doc;
    doc = [[DataController sharedController] annotationDocumentForKey:[json objectForKey:@"key"] moc:moc];
    
    if( !doc )
        doc = [[DataController sharedController] newAnnotationDocumentWithMOC:moc];
    
    doc.key = [json objectForKey:@"key"];
    doc.isShared = [NSNumber numberWithBool:YES];

    if( [json objectForKey:@"parentAnnotationKey"] )
    {
        ImageAnnotation * imgAnnotation = [[DataController sharedController] imageAnnotationForKey:[json objectForKey:@"parentAnnotationKey"] moc:moc];
        
        if( !imgAnnotation )
            return nil;
        else
        {
            imgAnnotation.annotationDoc = doc;
            doc.parentAnnotation = imgAnnotation;
        }
    }
    else
    {
        doc.parentProject = [[DataController sharedController] untitledProjectWithMOC:moc];
        [doc.parentProject addAnnotationDocsObject:doc];
    }
    
    ImageInfo * imageInfo;
    if( [json objectForKey:@"imageInfo"] )
    {
        imageInfo = [JSONUtility imageInfoFromJSON:[json objectForKey:@"imageInfo"] moc:moc];
    }
    else if( [json objectForKey:@"imageInfoKey"] )
    {
        imageInfo = [[DataController sharedController] imageInfoForKey:[json objectForKey:@"imageInfoKey"] moc:moc];
    }
    
    if( imageInfo )
    {
        imageInfo.parentAnnotationDocument = doc;
        doc.image = imageInfo;
    }
    
    NSArray * list = (NSArray *)[json objectForKey:@"annotations"];
    
    if( list && list.count > 0 )
    {
        for( int i = 0 ; i < list.count ; i++ )
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)[list objectAtIndex:i]];
            
            Annotation * annotation;
            
            if( [[dict objectForKey:@"type"] isEqualToString:@"IMAGE_ANNOTATION"] )
                annotation = (Annotation *)[JSONUtility imageAnnotationFromJSON:dict moc:moc];
            else if( [[dict objectForKey:@"type"] isEqualToString:@"CONVO_ANNOTATION"] )
                annotation = (Annotation *)[JSONUtility convoAnnotationFromJSON:dict moc:moc];
            else if( [[dict objectForKey:@"type"] isEqualToString:@"DRAWING_ANNOTATION"] )
                annotation = (Annotation *)[JSONUtility drawingAnnotationFromJSON:dict moc:moc];
            
            if( annotation )
            {
                [doc addAnnotationsObject:annotation];
                annotation.parentAnnotationDocument = doc;
            }
        }
    }
    else
    {
        // Try by keys
        NSArray * keyDicts = (NSArray *)[json objectForKey:@"annotationKeys"];
        
        if( keyDicts && keyDicts.count > 0 )
        {
            for( int i = 0 ; i < keyDicts.count ; i++ )
            {
                NSDictionary * keyDict = (NSDictionary *)[keyDicts objectAtIndex:i];
                
                if( keyDict && keyDict.count > 0 )
                {
                    Annotation * annotation;
                    
                    if( [[keyDict objectForKey:@"type"] isEqualToString:@"IMAGE_ANNOTATION"] )
                        annotation = [[DataController sharedController] imageAnnotationForKey:[keyDict objectForKey:@"key"] moc:moc];
                    if( [[keyDict objectForKey:@"type"] isEqualToString:@"CONVO_ANNOTATION"] )
                        annotation = [[DataController sharedController] convoAnnotationForKey:[keyDict objectForKey:@"key"] moc:moc];
                    if( [[keyDict objectForKey:@"type"] isEqualToString:@"DRAWING_ANNOTATION"] )
                        annotation = [[DataController sharedController] drawingAnnotationForKey:[keyDict objectForKey:@"key"] moc:moc];
                    
                    if( annotation )
                    {
                        [doc addAnnotationsObject:annotation];
                        annotation.parentAnnotationDocument = doc;
                    }
                }
            }
        }
    }
    
    doc.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
    
    return doc;
}

+ (NSDictionary *)annotationDocToJSON:(AnnotationDocument *)obj cascade:(BOOL)cascade;
{
//    NSSet *annotations;
//    ImageInfo *image;
//    ImageAnnotation *parentAnnotation;
//    Project *parentProject;
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"ANNOTATION_DOC"        , @"type"
                                    , obj.key                  , @"key"
                                    , obj.parentAnnotation.key , [JSONUtility valueOrEmptyString:@"parentAnnotationKey"]
                                    //, obj.parentProject.key    , [JSONUtility valueOrEmptyString:@"parentProjectKey"]
                                    , nil];
    
    NSMutableArray * annotations = [[NSMutableArray alloc] initWithCapacity:[obj.annotations count]];

    if( cascade )
    {
        for( Annotation * annotation in [obj.annotations allObjects] )
        {
            if( [annotation isKindOfClass:[ConvoAnnotation class]] )
                [annotations addObject:[JSONUtility convoAnnotationToJSON:(ConvoAnnotation *)annotation cascade:cascade]];
            else if( [annotation isKindOfClass:[ImageAnnotation class]] )
                [annotations addObject:[JSONUtility imageAnnotationToJSON:(ImageAnnotation *)annotation cascade:cascade]];
            else if( [annotation isKindOfClass:[DrawingAnnotation class]] )
                [annotations addObject:[JSONUtility drawingAnnotationToJSON:(DrawingAnnotation *)annotation cascade:cascade]];
        }

        [params setObject:annotations forKey:@"annotations"];
        [params setObject:[JSONUtility imageInfoToJSON:obj.image cascade:cascade] forKey:@"imageInfo"];
    }
    else
    {
        for( Annotation * annotation in [obj.annotations allObjects] )
        {
            NSString * type;
            
            if( [annotation isKindOfClass:[ImageAnnotation class]] )
                type = @"IMAGE_ANNOTATION";
            else if( [annotation isKindOfClass:[ConvoAnnotation class]] )
                type = @"CONVO_ANNOTATION";
            else if( [annotation isKindOfClass:[DrawingAnnotation class]] )
                type = @"DRAWING_ANNOTATION";
            
            if( type && type.length > 0 )
            {
                [annotations addObject:[NSDictionary dictionaryWithObjectsAndKeys: annotation.key
                                                                                 , @"key"
                                                                                 , type
                                                                                 , @"type"
                                                                                 , nil]];
            }
        }
        
        [params setObject:annotations forKey:@"annotationKeys"];
        [params setObject:obj.image.key forKey:@"imageInfoKey"];
    }
    
    return params;
}

// NOT IMPLEMENTED - PROBABLY NOT NEEDED
+ (AnnotationDetails *)annotationDetailsFromJSON:(NSDictionary *)json
{
    return [JSONUtility annotationDetailsFromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (AnnotationDetails *)annotationDetailsFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
    NSAssert( FALSE , @"Implement me..." );
    
    if( ![self isValidJSONObject:json] )
        return nil;
    
    if( ![self requiredField:@"type"                exists:json] ||
        ![self requiredField:@"key"                 exists:json] ||
        ![self requiredField:@"dateCreated"         exists:json] ||
        ![self requiredField:@"owner"               exists:json] ||
        ![self requiredField:@"parentAnnotationKey" exists:json] ||
        ([[json objectForKey:@"dateCreated"] length] != 19)       )
    {
        return nil;
    }

    AnnotationDetails * obj;
    obj = [[DataController sharedController] annotationDetailsForKey:[json objectForKey:@"key"] moc:moc];
    
    if( !obj )
        obj = [[DataController sharedController] newAnnotationDetailsWithMOC:moc];

    obj.key = [json objectForKey:@"key"];


    obj.key = [json objectForKey:@"key"];
    obj.dateCreated = [Utilities dateFromDbString:[json objectForKey:@"dateCreated"]];
    obj.owner = [json objectForKey:@"owner"];
    
    if( [json objectForKey:@"parentAnnotationKey"] )
    {
/*        Annotation * annot = [[DataController sharedController] annotationForKey:[json objectForKey:@"parentAnnotationKey"]];
        
        if( annot )
        {
            obj.parentAnnotation = annot;
            annot.details = obj;
        } */
    }
    
    obj.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
    return obj;
}

// PROBABLY NOT NEEDED
+ (NSDictionary *)annotationDetailsToJSON:(AnnotationDetails *)obj cascade:(BOOL)cascade;
{
//    NSDate * dateCreated;
//    NSDate * dateUpdated;
//    NSString * owner;
//    Annotation *parentAnnotation;
    
    if( !obj )
        return @{ };
    
    NSString * sDateCreated = [Utilities dateToDbDateString:obj.dateCreated];
    
    if( !obj.dateUpdated )
        obj.dateUpdated = obj.dateCreated;
    
    NSString * sDateUpdated = [Utilities dateToDbDateString:obj.dateUpdated];
    
    return @{ @"type":@"ANNOTATION_DETAILS"
            , @"key":obj.key
            , @"dateCreated":sDateCreated
            , @"dateUpdated":sDateUpdated
            , @"parentAnnotationKey":obj.parentAnnotation.key
            };
}

+ (CGPoint)pointFromJSON:(NSDictionary *)json
{
    CGPoint invalidPoint = CGPointMake( -999.999 , -999.999 );
    
    if( ![self isValidJSONObject:json] )
        return invalidPoint;
    
    if( ![self requiredField:@"x" exists:json] ||
       ![self requiredField:@"y" exists:json] )
    {
        return invalidPoint;
    }
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber * x = [f numberFromString:[json objectForKey:@"x"]];
    NSNumber * y = [f numberFromString:[json objectForKey:@"y"]];
    
    if( x && y )
    {
        return CGPointMake( [x floatValue] , [y floatValue] );
    }
    
    return invalidPoint;
}

+ (AnnotationPoint *)annotationPointFromJSON:(NSDictionary *)json
{
    return [JSONUtility annotationPointFromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (AnnotationPoint *)annotationPointFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
    CGPoint pt = [JSONUtility pointFromJSON:json];
    
    if( pt.x == -999.999 && pt.y == -999.999 )
        return nil;
    
    AnnotationPoint * point = [[DataController sharedController] newAnnotationPointWithMOC:moc];
    point.x = [NSNumber numberWithFloat:(float)pt.x];
    point.y = [NSNumber numberWithFloat:(float)pt.y];
    
    return point;
}

+ (NSDictionary *)annotationPointToJSON:(AnnotationPoint *)obj cascade:(BOOL)cascade;
{
    return @{ @"x":[obj.x stringValue] , @"y":[obj.y stringValue] };
}

+ (CGSize)sizeFromJSON:(NSDictionary *)json
{
    CGSize invalidPoint = CGSizeMake( -999.999 , -999.999 );
    
    if( ![self isValidJSONObject:json] )
        return invalidPoint;
    
    if( ![self requiredField:@"width" exists:json] ||
       ![self requiredField:@"height" exists:json] )
    {
        return invalidPoint;
    }
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber * w = [f numberFromString:[json objectForKey:@"width"]];
    NSNumber * h = [f numberFromString:[json objectForKey:@"height"]];
    
    if( w && h )
    {
        return CGSizeMake( [w floatValue] , [h floatValue] );
    }
    
    return invalidPoint;
}

+ (AnnotationSize *)annotationSizeFromJSON:(NSDictionary *)json
{
    return [JSONUtility annotationSizeFromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (AnnotationSize *)annotationSizeFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
    CGSize size = [JSONUtility sizeFromJSON:json];
    
    if( size.width == -999.999 && size.height == -999.999 )
        return nil;
    
    AnnotationSize * aSize = [[DataController sharedController] newAnnotationSizeWithMOC:moc];
    aSize.width = [NSNumber numberWithFloat:size.width];
    aSize.height = [NSNumber numberWithFloat:size.height];
    
    return aSize;
}

+ (NSDictionary *)annotationSizeToJSON:(AnnotationSize *)obj cascade:(BOOL)cascade;
{
    return @{ @"width":[obj.width stringValue] , @"height":[obj.height stringValue] };
}

+ (ContxtContact *)contxtContactFromJSON:(NSDictionary *)json
{
    return [JSONUtility contxtContactFromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (ContxtContact *)contxtContactFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
    if( ![self isValidJSONObject:json] )
        return nil;
    
    if( ![self requiredField:@"type"  exists:json] ||
        ![self requiredField:@"key"   exists:json] ||
        ![self requiredField:@"email" exists:json] )
        return nil;
    
    ContxtContact * contact;
    contact = [[DataController sharedController] contxtContactForKey:[json objectForKey:@"key"] moc:moc];
    
    if( !contact )
        contact = [[DataController sharedController] newContxtContactWithMOC:moc];

    contact.key = [json objectForKey:@"key"];
    contact.email = (NSString *)[json objectForKey:@"email"];
    contact.firstName = [JSONUtility valueOrEmptyString:(NSString *)[json objectForKey:@"firstName"]];
    contact.lastName = [JSONUtility valueOrEmptyString:(NSString *)[json objectForKey:@"lastName"]];
    
    NSArray * parentThreadKeys = (NSArray *)[json objectForKey:@"parentConvoThreadKeys"];
    
    for( NSString * key in parentThreadKeys )
    {
        ConversationThread * thread = [[DataController sharedController] convoThreadForKey:key moc:moc];
        
        if( !thread )
            continue;
  
        [contact addParentConvoThreadObject:thread];
        [thread addParticipantsObject:contact];
    }

    contact.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
    return contact;
}

+ (NSDictionary *)contxtContactToJSON:(ContxtContact *)obj cascade:(BOOL)cascade;
{
    //    NSString * email;
    //    NSString * firstName;
    //    NSString * lastName;
    //    NSSet *parentConvoThread;
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      obj.key , @"key"
                                    , obj.email , @"email"
                                    , [JSONUtility valueOrEmptyString:obj.firstName] , @"firstName"
                                    , [JSONUtility valueOrEmptyString:obj.lastName] , @"lastName"
                                    , nil];
    
    NSMutableArray * parentKeys = [[NSMutableArray alloc] init];
    
    for( ConversationThread * thread in [obj.parentConvoThread allObjects] )
        [parentKeys addObject:thread.key];
    
    [params setObject:parentKeys forKey:@"parentConvoThreadKeys"];
    
    return params;
}

+ (BOOL)annotation:(Annotation *)obj FromJSON:(NSDictionary *)json
{
    return [JSONUtility annotation:obj FromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (BOOL)annotation:(Annotation *)obj FromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
    if( ![self isValidJSONObject:json] )
        return FALSE;
    
    if( ![self requiredField:@"key"                    exists:json] ||
        ![self requiredField:@"dateCreated"            exists:json] ||
        ![self requiredField:@"dateUpdated"            exists:json] ||
        ![self requiredField:@"owner"                  exists:json] ||
        ![self requiredField:@"anchorPoint"            exists:json] ||
//        ![self requiredField:@"anchorPointCenter"      exists:json] ||
        ![self requiredField:@"parentAnnotationDocKey" exists:json] ||
        ([[json objectForKey:@"dateCreated"] length] != 19)         ||
        ([[json objectForKey:@"dateUpdated"] length] != 19)
       )
    {
        return FALSE;
    }
    
    obj.key = [json objectForKey:@"key"];
    
    obj.dateCreated = [Utilities dateFromDbString:[json objectForKey:@"dateCreated"]];
    
    if( ![json objectForKey:@"dateUpdated"] || [[json objectForKey:@"dateUpdated"] isEqualToString:@""] )
        obj.dateUpdated = obj.dateCreated;
    else
        obj.dateUpdated = [Utilities dateFromDbString:[json objectForKey:@"dateUpdated"]];

    obj.owner = [json objectForKey:@"owner"];

    if( !obj.anchorPoint )
        obj.anchorPoint = [JSONUtility annotationPointFromJSON:[json objectForKey:@"anchorPoint"] moc:moc];
    else
    {
        CGPoint point = [JSONUtility pointFromJSON:[json objectForKey:@"anchorPoint"]];
        obj.anchorPoint.x = [NSNumber numberWithFloat:point.x];
        obj.anchorPoint.y = [NSNumber numberWithFloat:point.y];
    }
    
    if( [json objectForKey:@"parentAnnotationDocKey"] && ((NSString *)[json objectForKey:@"parentAnnotationDocKey"]).length > 0 )
    {
        AnnotationDocument * doc = [[DataController sharedController] annotationDocumentForKey:[json objectForKey:@"parentAnnotationDocKey"] moc:moc];
        
        if( doc )
        {
            obj.parentAnnotationDocument = doc;
            [doc addAnnotationsObject:obj];
        }
        else
        {
            return FALSE;
        }
    }
    else
    {
        return FALSE;
    }
    
    
    // @NOTE: I don't think this is needed anymore.
    
    /*
    if( [json containsKey:@"details"] && [json objectForKey:@"details"] )
    {
        obj.details = [JSONUtility annotationDetailsFromJSON:[json objectForKey:@"details"]];
    }
    else if( [json containsKey:@"detailsKey"] && [json objectForKey:@"detailsKey"] )
    {
        AnnotationDetails * details = [[DataController sharedController] annotationDetailsForKey:[json objectForKey:@"detailsKey"]];
        
        if( details )
            obj.details = details;
    }
     */

    obj.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
    return TRUE;
}

+ (NSDictionary *)annotationToJSON:(Annotation *)obj cascade:(BOOL)cascade
{
//    NSDate * dateCreated;
//    AnnotationPoint *anchorPoint;
//    AnnotationPoint *anchorPointCenter;
//    AnnotationDetails *details;
//    AnnotationDocument *parentAnnotationDocument;
    
    NSString * sDateCreated = [Utilities dateToDbDateString:obj.dateCreated];
    NSString * sDateUpdated = [Utilities dateToDbDateString:obj.dateUpdated];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    // NOTE: 'type' is not needed here because this is an abstract parent class
                                      obj.key      , @"key"
                                    , sDateCreated , @"dateCreated"
                                    , sDateUpdated , @"dateUpdated"
                                    , obj.owner    , @"owner"
                                    , [JSONUtility annotationPointToJSON:obj.anchorPoint cascade:cascade] , @"anchorPoint"
//                                    , [JSONUtility annotationPointToJSON:obj.anchorPointCenter cascade:cascade] , @"anchorPointCenter"
                                    , obj.parentAnnotationDocument.key , @"parentAnnotationDocKey"
                                    , nil];

    if( cascade )
        [params setObject:[JSONUtility annotationDetailsToJSON:obj.details cascade:cascade] forKey:@"details"];
    else
        [params setObject:obj.details.key forKey:@"detailsKey"];
    
    return params;
    
}

+ (ConvoAnnotation *)convoAnnotationFromJSON:(NSDictionary *)json
{
    return [JSONUtility convoAnnotationFromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (ConvoAnnotation *)convoAnnotationFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
    if( ![self isValidJSONObject:json] )
        return nil;
    
    if( ![self requiredField:@"type"           exists:json]  ||
//        (![self requiredField:@"convoThread"   exists:json]  &&
//        ![self requiredField:@"convoThreadKey" exists:json]) ||
        ![[json objectForKey:@"type"] isEqualToString:@"CONVO_ANNOTATION"] )
    {
        return nil;
    }
    
    ConvoAnnotation * annotation;
    annotation = [[DataController sharedController] convoAnnotationForKey:[json objectForKey:@"key"] moc:moc];
    
    if( !annotation )
        annotation = [[DataController sharedController] newConvoAnnotationWithMOC:moc];

    if( ![JSONUtility annotation:annotation FromJSON:json moc:moc] )
        return nil;

    ConversationThread * thread;
    if( [json objectForKey:@"convoThread"] )
    {
        thread = [JSONUtility convoThreadFromJSON:[json objectForKey:@"convoThread"] moc:moc];
    }
    else if( [json objectForKey:@"convoThreadKey"] )
    {
        thread = [[DataController sharedController] convoThreadForKey:[json objectForKey:@"convoThreadKey"] moc:moc];
    }

    if( thread )
    {
        annotation.convoThread = thread;
        thread.parentAnnotation = annotation;
    }

    return annotation;
}

+ (NSDictionary *)convoAnnotationToJSON:(ConvoAnnotation *)obj cascade:(BOOL)cascade;
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[JSONUtility annotationToJSON:obj cascade:cascade]];
    [params setObject:@"CONVO_ANNOTATION" forKey:@"type"];
    
    if( cascade )
        [params setObject:[JSONUtility convoThreadToJSON:obj.convoThread cascade:cascade] forKey:@"convoThread"];
    else
        [params setObject:obj.convoThread.key forKey:@"convoThreadKey"];
    
    return params;
}

+ (DrawingAnnotation *)drawingAnnotationFromJSON:(NSDictionary *)json
{
    return [JSONUtility drawingAnnotationFromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (DrawingAnnotation *)drawingAnnotationFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
    if( ![self isValidJSONObject:json] )
        return nil;
    
    if( ![self requiredField:@"type"        exists:json] ||
        ![self requiredField:@"color"       exists:json] ||
        ![self requiredField:@"drawingType" exists:json] ||
        ![self requiredField:@"size"        exists:json] )
    {
        return nil;
    }
    
    DrawingAnnotation * annotation;
    
    if( [json objectForKey:@"key"] )
        annotation = [[DataController sharedController] drawingAnnotationForKey:[json objectForKey:@"key"] moc:moc];
    
    if( !annotation )
    {
        // Create new one
        annotation = [[DataController sharedController] newDrawingAnnotationWithMOC:moc];
        [[DataController sharedController] saveContextWithMoc:moc];
    }
    
    if( [json objectForKey:@"key"] )
        annotation.key = [json objectForKey:@"key"];

    
    if( [json containsKey:@"customPoints"] && annotation.customPoints )
    {
        NSOrderedSet * set = [annotation removeAllCustomPointsObjects];
        for( AnnotationPoint * pt in set )
        {
            // @TODO: WHICH IS IT?
            // @TODO: FINISH_SYNC
            [moc deleteObject:pt];
        }
        [moc processPendingChanges];
        [[DataController sharedController] saveContextWithMoc:moc];
    }
        
    if( ![JSONUtility annotation:annotation FromJSON:json moc:moc] )
        return nil;
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    annotation.color       = [NSNumber numberWithInt:[[json objectForKey:@"color"] intValue]];
    annotation.drawingType = [NSNumber numberWithInt:[[json objectForKey:@"drawingType"] intValue]];
    
    CGSize size = [JSONUtility sizeFromJSON:[json objectForKey:@"size"]];
    annotation.size.width = [NSNumber numberWithFloat:size.width];
    annotation.size.height = [NSNumber numberWithFloat:size.height];
    
    if( [json containsKey:@"text"] )
        annotation.text = [json objectForKey:@"text"];
    
    if( [json containsKey:@"fontSize"] )
        annotation.fontSize = [NSNumber numberWithFloat:[[json objectForKey:@"fontSize"] floatValue]];
    else
        annotation.fontSize = [NSNumber numberWithFloat:0.f];
    
    if( [json containsKey:@"customPoints"] )
    {
        NSArray * points = (NSArray *)[json objectForKey:@"customPoints"];
        
        for( int i = 0 ; i < points.count ; i++ )
        {
            AnnotationPoint * point = [JSONUtility annotationPointFromJSON:[points objectAtIndex:i] moc:moc];
            
            if( point )
                [annotation addCustomPointsObject:point];
        }
    }
    
    return annotation;
}

+ (NSDictionary *)drawingAnnotationToJSON:(DrawingAnnotation *)obj cascade:(BOOL)cascade;
{
//    NSNumber * anchorLocation;
//    NSNumber * color;
//    NSNumber * drawingType;
//    AnnotationSize *size;
//    NSString * text;
//    NSOrderedSet *customPoints;
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[JSONUtility annotationToJSON:obj cascade:cascade]];
    [params setObject:@"DRAWING_ANNOTATION" forKey:@"type"];
    [params setObject:[obj.color stringValue] forKey:@"color"];
    [params setObject:[obj.drawingType stringValue] forKey:@"drawingType"];
    [params setObject:[JSONUtility annotationSizeToJSON:obj.size cascade:cascade] forKey:@"size"];
    [params setObject:[JSONUtility valueOrEmptyString:obj.text] forKey:@"text"];
    [params setObject:[obj.fontSize stringValue] forKey:@"fontSize"];
    
    if( obj.customPoints && obj.customPoints.count > 0 )
    {
        NSMutableArray * points = [[NSMutableArray alloc] init];
        
        for( int i = 0 ; i < obj.customPoints.count ; i++ )
        {
            [points addObject:[JSONUtility annotationPointToJSON:[obj.customPoints objectAtIndex:i] cascade:cascade]];
        }
        
        if( points.count )
            [params setObject:points forKey:@"customPoints"];
    }

    return params;
}

+ (ImageAnnotation *)imageAnnotationFromJSON:(NSDictionary *)json
{
    return [JSONUtility imageAnnotationFromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (ImageAnnotation *)imageAnnotationFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
    if( ![self isValidJSONObject:json] )
        return nil;
    
    if( ![self requiredField:@"type"             exists:json] ||
//        ![self requiredField:@"annotationDoc"    exists:json] ||
//        ![self requiredField:@"annotationDocKey" exists:json] ||
        ![[json objectForKey:@"type"] isEqualToString:@"IMAGE_ANNOTATION"] )
    {
        return nil;
    }
    
    ImageAnnotation * annotation;
    annotation = [[DataController sharedController] imageAnnotationForKey:[json objectForKey:@"key"] moc:moc];
    
    if( !annotation )
        annotation = [[DataController sharedController] newImageAnnotationWithMOC:moc];
    
    if( ![JSONUtility annotation:annotation FromJSON:json moc:moc] )
        return nil;
    
    AnnotationDocument * doc;
    if( [json objectForKey:@"annotationDoc"] )
    {
        doc = [JSONUtility annotationDocFromJSON:[json objectForKey:@"annotationDoc"] moc:moc];
    }
    else if( [json objectForKey:@"annotationDocKey"] )
    {
        doc = [[DataController sharedController] annotationDocumentForKey:@"annotationDocKey" moc:moc];
    }
    
    annotation.source = SOURCE_TYPE_CLOUD;
    
    return annotation;
}

+ (NSDictionary *)imageAnnotationToJSON:(ImageAnnotation *)obj cascade:(BOOL)cascade;
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[JSONUtility annotationToJSON:obj cascade:cascade]];
    [params setObject:@"IMAGE_ANNOTATION" forKey:@"type"];
    [params setObject:obj.annotationDoc.key forKey:@"annotationDocKey"];
    
    return params;
}

+ (ConversationMessage *)convoMessageFromJSON:(NSDictionary *)json
{
    return [JSONUtility convoMessageFromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (ConversationMessage *)convoMessageFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
    if( ![self isValidJSONObject:json] )
        return nil;
    
    if( ![self requiredField:@"type"                 exists:json]       ||
        ![self requiredField:@"key"                  exists:json]       ||
        ![self requiredField:@"dateCreated"          exists:json]       ||
        ![self requiredField:@"owner"                exists:json]       ||
        ![self requiredField:@"parentConvoThreadKey" exists:json]       ||
        (![self requiredField:@"text"               exists:json]
            && ![self requiredField:@"imageInfo"    exists:json]
            && ![self requiredField:@"imageInfoKey" exists:json])       ||
        ![[json objectForKey:@"type"] isEqualToString:@"CONVO_MESSAGE"] ||
        ([[json objectForKey:@"dateCreated"] length] != 19)             )
    {
        return nil;
    }

    ConversationMessage * msg;
    msg = [[DataController sharedController] convoMessageForKey:[json objectForKey:@"key"] moc:moc];
    
    if( !msg )
        msg = [[DataController sharedController] newConversationMessageWithMOC:moc];

    msg.key = [json objectForKey:@"key"];
    msg.dateCreated = [Utilities dateFromDbString:[json objectForKey:@"dateCreated"]];
    msg.owner = [json objectForKey:@"owner"];
    msg.text = [JSONUtility valueOrEmptyString:[json objectForKey:@"text"]];
    msg.unread = [NSNumber numberWithInt:0];
    
    ImageInfo * imageInfo;
    if( [[json allKeys] containsObject:@"imageInfo"] )
    {
        imageInfo = [JSONUtility imageInfoFromJSON:[json objectForKey:@"imageInfo"] moc:moc];
    }
    else if( [[json allKeys] containsObject:@"imageInfoKey"] )
    {
        imageInfo = [[DataController sharedController] imageInfoForKey:[json objectForKey:@"imageInfoKey"] moc:moc];
        
        if( !imageInfo )
        {
            msg.imageInfoKey = [json objectForKey:@"imageInfoKey"];

            if( [json containsKey:@"imageInfoExt"] )
                msg.imageInfoExt = [json objectForKey:@"imageInfoExt"];
        }
    }
    
    if( imageInfo )
    {
        msg.image = imageInfo;
        imageInfo.parentConversationMessage = msg;
    }
    
    
    if( [[json allKeys] containsObject:@"parentConvoThreadKey"] )
    {
        ConversationThread * thread = [[DataController sharedController] convoThreadForKey:[json objectForKey:@"parentConvoThreadKey"] moc:moc];

        if( thread )
        {
            msg.parentConvoThread = thread;
            [thread addConvoMessagesObject:msg];
        }
        else
        {
            // Can't find a thread to associate with, so delete it where it was created, which is the privateMOC
            
            [moc deleteObject:msg];
            [moc processPendingChanges];
            [[DataController sharedController] saveContextWithMoc:moc];
            return nil;
        }
    }

    msg.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
    return msg;
}

+ (NSDictionary *)convoMessageToJSON:(ConversationMessage *)obj cascade:(BOOL)cascade;
{
//    NSDate * dateCreated;
//    NSString * owner;
//    NSString * text;
//    NSNumber * unread;
//    ImageInfo *image;
//    ConversationThread *parentConvoThread;

    NSString * sDate = [Utilities dateToDbDateString:obj.dateCreated];
    
    NSDictionary * someParams = @{
                                    @"type":@"CONVO_MESSAGE"
                                  , @"key":obj.key
                                  , @"dateCreated":sDate
                                  , @"owner":obj.owner
                                  , @"text":[JSONUtility valueOrEmptyString:obj.text]
                                  , @"unread":[obj.unread stringValue]
                                  , @"parentConvoThreadKey":obj.parentConvoThread.key
                              };
    
    NSMutableDictionary * params;
    params = [NSMutableDictionary dictionaryWithDictionary:someParams];

    if( obj.image )
    {
        if( cascade )
            [params setObject:[JSONUtility imageInfoToJSON:obj.image cascade:cascade] forKey:@"imageInfo"];
        else
            [params setObject:obj.image.key forKey:@"imageInfoKey"];
    }
    
    return params;
}

+ (ConversationThread *)convoThreadFromJSON:(NSDictionary *)json
{
    return [JSONUtility convoThreadFromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (ConversationThread *)convoThreadFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
    if( ![self isValidJSONObject:json] )
        return nil;
    
    if( ![self requiredField:@"type"                exists:json]       ||
        ![self requiredField:@"key"                 exists:json]       ||
        ![self requiredField:@"dateCreated"         exists:json]       ||
        ![self requiredField:@"owner"               exists:json]       ||
        ![self requiredField:@"parentAnnotationKey" exists:json]       ||
        (![self requiredField:@"participants"           exists:json]
            && ![self requiredField:@"participantKeys" exists:json])   ||
        ![[json objectForKey:@"type"] isEqualToString:@"CONVO_THREAD"] ||
        ([[json objectForKey:@"dateCreated"] length] != 19)            )
    {
        return nil;
    }

    ConversationThread * thread;
    thread = [[DataController sharedController] convoThreadForKey:[json objectForKey:@"key"] moc:moc];
    
    if( !thread )
        thread = [[DataController sharedController] newConversationThreadWithMOC:moc];
    
    thread.key = [json objectForKey:@"key"];
    thread.dateCreated = [Utilities dateFromDbString:[json objectForKey:@"dateCreated"]];
    thread.owner = [json objectForKey:@"owner"];
    thread.unread = [NSNumber numberWithInt:0]; // @TODO: Should this be 1 instead of 0?
    
    // Parent ConvoAnnotation
    ConvoAnnotation * annotation = [[DataController sharedController] convoAnnotationForKey:[json objectForKey:@"parentAnnotationKey"] moc:moc];
    if( annotation )
    {
        annotation.convoThread = thread;
        thread.parentAnnotation = annotation;
    }
    else
    {
        [moc deleteObject:thread];
        [moc processPendingChanges];
        [[DataController sharedController] saveContextWithMoc:moc];
        return nil;
    }

    
    // MESSAGES
    NSArray * messageList = (NSArray *)[json objectForKey:@"convo_messages"];
    
    if( messageList && messageList.count > 0 )
    {
        for( int i = 0 ; i < messageList.count ; i++ )
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)[messageList objectAtIndex:i]];
            
            ConversationMessage * message = [JSONUtility convoMessageFromJSON:dict moc:moc];
            
            if( message )
            {
                [thread addConvoMessagesObject:message];
                message.parentConvoThread = thread;
            }
        }
    }
    else
    {
        // Try by keys
        NSArray * messageKeys = (NSArray *)[json objectForKey:@"convoMessageKeys"];
        
        if( messageKeys && messageKeys.count > 0 )
        {
            for( int i = 0 ; i < messageKeys.count ; i++ )
            {
                NSString * key = (NSString *)[messageKeys objectAtIndex:i];
                
                if( key && key.length > 0 )
                {
                    ConversationMessage * message = [[DataController sharedController] convoMessageForKey:key moc:moc];
                    
                    if( message )
                    {
                        [thread addConvoMessagesObject:message];
                        message.parentConvoThread = thread;
                    }
                }
            }
        }
    }
    
    
    // PARTICIPANTS
    NSArray * participantList = (NSArray *)[json objectForKey:@"participants"];

    if( participantList && participantList.count > 0 )
    {
        for( int i = 0 ; i < participantList.count ; i++ )
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)[participantList objectAtIndex:i]];
            
            ContxtContact * contact = [JSONUtility contxtContactFromJSON:dict moc:moc];
            
            if( contact )
            {
                [thread addParticipantsObject:contact];
                [contact addParentConvoThreadObject:thread];
            }
        }
    }
    else
    {
        // Try by keys
        NSArray * participantKeys = (NSArray *)[json objectForKey:@"participantKeys"];
        
        if( participantKeys )
        {
            for( int i = 0 ; i < participantKeys.count ; i++ )
            {
                NSString * key = (NSString *)[participantKeys objectAtIndex:i];
                
                if( key && key.length > 0 )
                {
                    ContxtContact * contact = [[DataController sharedController] contxtContactForKey:key moc:moc];
                    
                    if( contact )
                    {
                        [thread addParticipantsObject:contact];
                        [contact addParentConvoThreadObject:thread];
                    }
                }
            }
        }
    }

    thread.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
    return thread;
}

+ (NSDictionary *)convoThreadToJSON:(ConversationThread *)obj cascade:(BOOL)cascade;
{
//    NSDate * dateCreated;
//    NSString * details;
//    NSString * owner;
//    NSString * title;
//    NSNumber * unread;
//    NSSet *convoMessages;
//    ConvoAnnotation *parentAnnotation;
//    NSSet *participants;

    NSString * sDate = [Utilities dateToDbDateString:obj.dateCreated];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"CONVO_THREAD"               , @"type"
                                    , obj.key                       , @"key"
                                    , sDate                         , @"dateCreated"
                                    , obj.owner                     , @"owner"
                                    , [obj.unread stringValue]      , @"unread"
                                    , obj.parentAnnotation.key      , @"parentAnnotationKey"
                                    , [JSONUtility valueOrEmptyString:obj.title] , @"title"
                                    , nil];

    NSMutableArray * items = [[NSMutableArray alloc] initWithCapacity:[obj.convoMessages count]];

    if( cascade )
    {
        for( ConversationMessage * message in [obj.convoMessages allObjects] )
            [items addObject:[JSONUtility convoMessageToJSON:message cascade:cascade]];
        
        if( items.count > 0 )
            [params setObject:items forKey:@"convo_messages"];
        
        [items removeAllObjects];
        
        for( ContxtContact * contact in [obj.participants allObjects] )
            [items addObject:[JSONUtility contxtContactToJSON:contact cascade:cascade]];
        
        if( items.count > 0 )
            [params setObject:items forKey:@"participants"];
    }
    else
    {
        for( ConversationMessage * message in [obj.convoMessages allObjects] )
            [items addObject:message.key];
        
        if( items.count > 0 )
            [params setObject:items forKey:@"convoMessageKeys"];

        [items removeAllObjects];
        
        for( ContxtContact * contact in [obj.participants allObjects] )
            [items addObject:contact.key];
        
        if( items.count > 0 )
            [params setObject:items forKey:@"participantKeys"];
    }
    
    return params;
}

+ (ImageInfo *)imageInfoFromJSON:(NSDictionary *)json
{
    return [JSONUtility imageInfoFromJSON:json moc:[DataController sharedController].privateMOC];
}

+ (ImageInfo *)imageInfoFromJSON:(NSDictionary *)json moc:(NSManagedObjectContext *)moc
{
    if( ![self isValidJSONObject:json] )
        return nil;
    
    if( ![self requiredField:@"type"        exists:json]       ||
        ![self requiredField:@"key"         exists:json]       ||
        ![self requiredField:@"dateCreated" exists:json]       ||
        ![self requiredField:@"owner"       exists:json]       ||
        ![self requiredField:@"filename"    exists:json]       ||
        ![self requiredField:@"extension"   exists:json]       ||
//        ![self requiredField:@"path"        exists:json]       ||
//        ![self requiredField:@"previewPath" exists:json]       ||
//        ![self requiredField:@"thumbPath"   exists:json]       ||
//        (![self requiredField:@"parentAnnotationDocKey"    exists:json]
//          && ![self requiredField:@"parentConvoMessageKey" exists:json]) ||
        ![[json objectForKey:@"type"] isEqualToString:@"IMAGE_INFO"]     ||
        ([[json objectForKey:@"dateCreated"] length] != 19)              )
    {
        return nil;
    }
    
    ImageInfo * info;
    info = [[DataController sharedController] imageInfoForKey:[json objectForKey:@"key"] moc:moc];
    
    if( !info )
        info = [[DataController sharedController] newImageInfoWithMOC:moc];

    info.key         = [json objectForKey:@"key"];
    info.owner       = [json objectForKey:@"owner"];
    info.filename    = [json objectForKey:@"filename"];
    info.extension   = [json objectForKey:@"extension"];
//    info.path        = [json objectForKey:@"path"];
//    info.previewPath = [json objectForKey:@"previewPath"];
//    info.thumbPath   = [json objectForKey:@"thumbPath"];
    info.dateCreated = [Utilities dateFromDbString:[json objectForKey:@"dateCreated"]];
    
    if( [json objectForKey:@"parentAnnotationDocKey"] )
    {
        AnnotationDocument * doc = [[DataController sharedController] annotationDocumentForKey:[json objectForKey:@"parentAnnotationDocKey"] moc:moc];
        
        if( doc )
        {
            info.parentAnnotationDocument = doc;
            doc.image = info;
        }
    }
    else if( [json objectForKey:@"parentConvoMessageKey"] )
    {
        ConversationMessage * msg = [[DataController sharedController] convoMessageForKey:[json objectForKey:@"parentConvoMessageKey"] moc:moc];
        
        if( msg )
        {
            info.parentConversationMessage = msg;
            msg.image = info;
        }
    }
    else
    {
        // Orphaned ImageInfo
        
        [moc deleteObject:info];
        [moc processPendingChanges];
        [[DataController sharedController] saveContextWithMoc:moc];
        return nil;
    }
    
    info.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
    return info;
}

+ (NSDictionary *)imageInfoToJSON:(ImageInfo *)obj cascade:(BOOL)cascade;
{
//    NSDate * dateCreated;
//    NSString * extension;
//    NSString * filename;
//    NSString * owner;
//    NSString * path;
//    NSString * previewPath;
//    NSString * thumbPath;
//    AnnotationDocument *parentAnnotationDocument;
//    ConversationMessage *parentConversationMessage;
//    Project *parentProject;

    NSString * sDate = [Utilities dateToDbDateString:obj.dateCreated];
    
    NSDictionary * params = @{
                                   @"type":        @"IMAGE_INFO"
                                 , @"key":         obj.key
                                 , @"dateCreated": sDate
                                 , @"extension":   obj.extension
                                 , @"filename":    obj.filename
                                 , @"owner":       obj.owner
                                 , @"path":        obj.path
                                 , @"previewPath":           [JSONUtility valueOrEmptyString:obj.previewPath]
                                 , @"thumbPath":             [JSONUtility valueOrEmptyString:obj.thumbPath]
                                 , @"parentAnnotationDocKey":[JSONUtility valueOrEmptyString:obj.parentAnnotationDocument.key]
                                 , @"parentConvoMessageKey": [JSONUtility valueOrEmptyString:obj.parentConversationMessage.key]
                                 , @"parentProjectKey":      [JSONUtility valueOrEmptyString:obj.parentProject.key]
                            };
    
    return params;
}

+ (NSDictionary *)loginCredsToJSON:(LoginCreds *)obj cascade:(BOOL)cascade;
{
    return @{ @"type":@"LOGIN_CREDS"
            , @"key":     [JSONUtility valueOrEmptyString:obj.key]
            , @"username":[JSONUtility valueOrEmptyString:obj.username]
            , @"password":[JSONUtility valueOrEmptyString:obj.password]
            };
}


@end
