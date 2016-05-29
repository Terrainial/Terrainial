//
//  CNDataAccess.m
//  CronkiteVR
//
//  Created by student on 3/29/16.
//  Copyright © 2016 NMIL. All rights reserved.
//

#import "CNDataAccess.h"
#import "AppDelegate.h"
#import "NSDictionary+dictionaryWithObject.h"
#import "Utils.h"

@implementation CNDataAccess

static CNDataAccess *sharedInstance = nil;

+ (id)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void) releaseSharedInstance
{
    sharedInstance = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        sharedInstance = self;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        managedObjectContext = appDelegate.managedObjectContext;
    }
    
    return self;
}

-(void)getCurrentCronkiteNewsInURL:(NSURL *)url
                  success:(void (^)(StoriesModel *stories))success
                           failure:(void (^)(NSError *error))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:dict options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",myString);
    
        [self deleteAllStories];
        StoriesModel* stories = [[StoriesModel alloc] initWithString:myString error:&err];
        
        for (StoryModel *model in stories.articles) {
            [self addStory:model];
        }
        
        success(stories);
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        failure(error);
    }];
}

+(BOOL)isParameterAvailableForClass:(id)object forParameter:(NSString *)key
{
    NSDictionary *parameterDictionary = [NSDictionary dictionaryWithPropertiesOfObject:object];
    
    for (NSString *parameters in parameterDictionary) {
        if ([parameters isEqualToString:key]) {
            return YES;
        }
    }
    
    return NO;
}

-(id)moveValues:(id)fromClass intoClass:(id)toClass
{
    NSDictionary *totalParameters = [NSDictionary dictionaryWithPropertiesOfObject:toClass];
    
    for (NSString *parameters in totalParameters) {
        if ([CNDataAccess isParameterAvailableForClass:fromClass forParameter:parameters]) {
            [toClass setValue:[fromClass valueForKey:parameters] forKey:parameters];
        }
        
        else
        {
            if([parameters isKindOfClass:[NSString class]])
            {
                [toClass setValue:[NSDate date] forKey:parameters];
            }
        }
    }
    
    return toClass;
}

- (Story *) getStoryForId:(NSString *)storyId
{
    NSError *error = nil;
    NSEntityDescription *finder = [NSEntityDescription entityForName:@"Story"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:finder];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"articleID == %@",storyId]];
    
    // Fetch the ConfigParams entity from the Data store
    Story *story = (Story *)[managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ((error != nil) )
    {
        if ([error localizedDescription]!=nil && ![[error localizedDescription] isEqualToString:@""]) {
            [Utils alertWithTitle:@"Database Error" message:error.localizedDescription cancelButton:OK_TITLE];
            return nil;
        }
    }
    
    return story;
}

- (NSArray *) getStoriesArray
{
    NSError *error = nil;
    NSEntityDescription *finder = [NSEntityDescription entityForName:@"Story"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:finder];
    
    // Fetch the ConfigParams entity from the Data store
    NSArray *storyResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ((error != nil) )
    {
        if ([error localizedDescription]!=nil && ![[error localizedDescription] isEqualToString:@""]) {
            [Utils alertWithTitle:@"Database Error" message:error.localizedDescription cancelButton:OK_TITLE];
            return nil;
        }
    }
    
    return storyResults;
}

- (Story *) addStory:( StoryModel *)ObjStory
{
    NSError *error = nil;
    
    Story *story = (Story *)[NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:managedObjectContext];
    
    story=[self moveValues:ObjStory intoClass:story];
    
    [managedObjectContext save:&error];
    
    if (error != nil){
        
        if ([error localizedDescription]!=nil && ![[error localizedDescription] isEqualToString:@""]) {
            NSLog(@"%@", [error localizedDescription]);
            [Utils alertWithTitle:@"Database Error" message:error.localizedDescription cancelButton:OK_TITLE];
            return nil;
        }
        
    }
    return story;
}


- (Story *) updateStory:(StoryModel *)storyObject forId:(NSString *) storyId
{
    NSError *error = nil;
    NSEntityDescription *storyReq = [NSEntityDescription entityForName:@"Story"
                                                inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:storyReq];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"articleID == %@", [storyObject articleID]]];
    
    // Fetch the ConfigParams entity from the Data store
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    Story *storyInput;
    
    if ([results count] > 0)
        storyInput = [results objectAtIndex:0];
    else
        storyInput = [NSEntityDescription insertNewObjectForEntityForName:@"Story"
                                                   inManagedObjectContext:managedObjectContext];
    
    
    storyInput=[self moveValues:storyObject intoClass:storyInput];
    
    [managedObjectContext save:&error];
    
    if (error != nil){
        
        if ([error localizedDescription]!=nil && ![[error localizedDescription] isEqualToString:@""]) {
            NSLog(@"%@", [error localizedDescription]);
            
            [Utils alertWithTitle:@"Database Error" message:error.localizedDescription cancelButton:OK_TITLE];
            return nil;
        }
    }
    
    return storyInput;
}


- (void) deleteStoryForId:(NSString *)storyId
{
    NSError *error = nil;
    NSEntityDescription *assignmentReq = [NSEntityDescription entityForName:@"Story"
                                                     inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:assignmentReq];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"articleID == %@", storyId]];
    
    // Fetch the ConfigParams entity from the Data store
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *product in results)
        [managedObjectContext deleteObject:product];
    
    [managedObjectContext save:&error];
    
    if (error != nil){
        if ([error localizedDescription]!=nil && ![[error localizedDescription] isEqualToString:@""]) {
            NSLog(@"%@", [error localizedDescription]);
            
            [Utils alertWithTitle:@"Database Error" message:error.localizedDescription cancelButton:OK_TITLE];
        }
    }
    
}


- (void) deleteAllStories
{
    NSError *error = nil;
    NSEntityDescription *assignmentReq = [NSEntityDescription entityForName:@"Story"
                                                     inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:assignmentReq];
    //    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", storyId]];
    
    // Fetch the ConfigParams entity from the Data store
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *product in results)
        [managedObjectContext deleteObject:product];
    
    [managedObjectContext save:&error];
    
    if (error != nil){
        if ([error localizedDescription]!=nil && ![[error localizedDescription] isEqualToString:@""]) {
            NSLog(@"%@", [error localizedDescription]);
            
            [Utils alertWithTitle:@"Database Error" message:error.localizedDescription cancelButton:OK_TITLE];
        }
    }
    
}

@end
