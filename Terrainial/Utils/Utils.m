//
//  Utils.m
//  CronkiteVR
//
//  Created by student on 4/1/16.
//  Copyright © 2016 NMIL. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(UIAlertController *)alertWithTitle:(NSString *)title message:(NSString *)messageString cancelButton:(NSString *)cancelBtnTitle
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messageString preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:cancelBtnTitle
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    
//    UIAlertAction *okAction = [UIAlertAction
//                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction *action)
//                               {
//                                   NSLog(@"OK action");
//                               }];
    
    [alertController addAction:cancelAction];
//    [alertController addAction:okAction];
    
    return alertController;
    
}

@end
