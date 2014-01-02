// Taken from: http://vladimir.zardina.org/2010/03/serializing-archivingunarchiving-an-nsmanagedobject-graph/
// Adapted by: https://gist.github.com/pkclsoft/4958148
// 

@interface NSManagedObject (Serialization)

- (NSDictionary*) toDictionary;

- (void) populateFromDictionary:(NSDictionary*)dict;

+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                             inContext:(NSManagedObjectContext*)context;

@end