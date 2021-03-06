//
//  AppDelegate.h
//  Terrainial
//
//  Created by student on 5/28/16.
//  Copyright © 2016 Terrainial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic,assign) BOOL disableRotation;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

