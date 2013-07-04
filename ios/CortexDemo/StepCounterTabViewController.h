//
//  StepCounterTabViewController.h
//  CortexDemo
//
//  Created by Pim Nijdam on 7/1/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepCounterTabViewController : UIViewController
- (IBAction) resetStepCount: (id) sender;
- (IBAction) setSensitivity:(UISlider *)sensitivitySlider;

@property (nonatomic, retain) IBOutlet UITextView* logText;
@property (nonatomic, retain) IBOutlet UISlider* sensitivitySlider;
@end
