//
//  SleepTimeEstimateViewController.h
//  CortexDemo
//
//  Created by Joris Janssen on 19/01/15.
//  Copyright (c) 2015 Sense Observation Systems BV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SleepTimeEstimateViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITextView* logText;
- (IBAction) addSleepPoint: (id) sender;
- (IBAction) add4hoursofSleepPoints: (id) sender;
@end
