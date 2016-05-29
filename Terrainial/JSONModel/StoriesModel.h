//
//  StoriesModel.h
//  CronkiteVR
//
//  Created by student on 3/29/16.
//  Copyright © 2016 NMIL. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "StoryModel.h"

@interface StoriesModel : JSONModel

@property(nonatomic,strong) NSArray<StoryModel> *articles;

@end
