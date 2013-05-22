//
//  FirstViewController.h
//  CortexDemo
//
//  Created by Pim Nijdam on 4/16/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FallDetectionTabViewController : UIViewController

- (IBAction) toggleSwitch: (id) sender;

@property (nonatomic, retain) IBOutlet UITextView* logText;
@property (nonatomic, retain) IBOutlet UISwitch* demoSwitch;
@property (nonatomic, retain) IBOutlet UISwitch* useInactivitySwitch;


@end
