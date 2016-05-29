//
//  Utils.h
//  CronkiteVR
//
//  Created by student on 4/1/16.
//  Copyright © 2016 NMIL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CNDefinitions.h"

@interface Utils : NSObject

+(UIAlertController *)alertWithTitle:(NSString *)title message:(NSString *)messageString cancelButton:(NSString *)cancelBtnTitle;

@end
