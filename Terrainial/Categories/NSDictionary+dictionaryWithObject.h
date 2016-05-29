//
//  NSDictionary+dictionaryWithObject.h
//
//  This category helps retrieving all the parameters declared in a NSObject class

#import <Foundation/Foundation.h>

@interface NSDictionary (dictionaryWithObject)

+(NSDictionary *)dictionaryWithPropertiesOfObject:(id)_object;

@end
