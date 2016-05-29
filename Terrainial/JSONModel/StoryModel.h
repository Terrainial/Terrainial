//
//  StoryModel.h
//  CronkiteVR
//
//  Created by student on 3/29/16.
//  Copyright © 2016 NMIL. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol StoryModel

@end

@interface StoryModel : JSONModel

@property(nonatomic,strong) NSString *articleID;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *byline;
@property(nonatomic,strong) NSString *longDescription;
@property(nonatomic,strong) NSString *imageURL;
@property(nonatomic,strong) NSString *videoURL;
@property BOOL featured;
@property(nonatomic,strong) NSString *duration;
@property(nonatomic,strong) NSString *videoSize;

@end
