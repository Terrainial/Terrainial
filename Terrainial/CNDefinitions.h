//
//  CNDefinitions.h
//  CronkiteVR
//
//  Created by student on 3/29/16.
//  Copyright © 2016 NMIL. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BASEURL @"http://vr.jmc.asu.edu"
#define CRONKITENEWS_URL [NSString stringWithFormat:@"%@/cronkitenews/json/cronkitenewsvr.json",BASEURL]

#define NAVIGATION_BAR_COLOR [UIColor colorWithRed:176.0/255.0 green:237.0/255.0 blue:181.0/255.0 alpha:1.0]
//#define NAVIGATION_BAR_COLOR [UIColor colorWithRed:12.0/255.0 green:32.0/255.0 blue:135.0/255.0 alpha:1.0]
#define NAVIGATION_BAR_SHADOW_COLOR [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]
#define NAVIGATION_BAR_FONT [UIFont fontWithName:@"Raleway-ExtraBold" size:21.0]

#define COLOR1 (id)[[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f] CGColor]
#define COLOR2 (id)[[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f] CGColor]

#define CANCEL_TITLE @"Cancel"
#define OK_TITLE @"OK"

//http://vr.jmc.asu.edu/cronkitenews/json/cronkitenewsvr.json