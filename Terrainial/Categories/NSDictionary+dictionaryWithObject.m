//
//  NSDictionary+dictionaryWithObject.m
//
//  This category helps retrieving all the parameters declared in a NSObject class

#import "NSDictionary+dictionaryWithObject.h"
#import <objc/runtime.h>

@implementation NSDictionary (dictionaryWithObject)

// TO CONVERT AN OBJECT INTO A DICTIONARY...
+(NSDictionary *)dictionaryWithPropertiesOfObject:(id)_object
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    
    // TO GET ALL THE PROPERTIES FROM THE OBJECT RECIEVED (NO OF ATTRIBUTES IS STORED IN THE COUNT VARIABLE)...
    unsigned count;
    objc_property_t *property = class_copyPropertyList([_object class], &count);
    
    for (int i = 0; i < count; i++)
    {
        // GETTING EACH AND EVERY ATTRIBUTE AND SETTING IT IN DICTIONARY...
        NSString *key = [NSString stringWithUTF8String:property_getName(property[i])];
        [dictionary setObject:key forKey:key];
    }
    
    free(property);
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end
