//
//  CNDataAccess.h
//  CronkiteVR
//
//  Created by student on 3/29/16.
//  Copyright © 2016 NMIL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreData/CoreData.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#include "CNDefinitions.h"
#import "StoriesModel.h"
#import "Story.h"
#import "Story+CoreDataProperties.h"

@interface CNDataAccess : NSObject
{
    NSManagedObjectContext *managedObjectContext;
}

+ (CNDataAccess *) sharedInstance;
+ (void) releaseSharedInstance;
- (id)init;

-(void)getCurrentCronkiteNewsInURL:(NSURL *)url
                           success:(void (^)(StoriesModel *stories))success
                           failure:(void (^)(NSError *error))failure;

+(BOOL)isParameterAvailableForClass:(id)object forParameter:(NSString *)key;

-(id)moveValues:(id)fromClass intoClass:(id)toClass;
- (Story *) getStoryForId:(NSString *)storyId;
- (NSArray *) getStoriesArray;
- (Story *) addStory:( StoryModel *)ObjStory;
- (Story *) updateStory:(StoryModel *)storyObject forId:(NSString *) storyId;
- (void) deleteStoryForId:(NSString *)storyId;
- (void) deleteAllStories;


@end
