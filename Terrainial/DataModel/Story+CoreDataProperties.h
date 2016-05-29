//
//  Story+CoreDataProperties.h
//  
//
//  Created by student on 5/28/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Story.h"

NS_ASSUME_NONNULL_BEGIN

@interface Story (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *articleID;
@property (nullable, nonatomic, retain) NSString *byline;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *duration;
@property (nullable, nonatomic, retain) NSNumber *featured;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSString *longDescription;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *videoSize;
@property (nullable, nonatomic, retain) NSString *videoURL;

@end

NS_ASSUME_NONNULL_END
