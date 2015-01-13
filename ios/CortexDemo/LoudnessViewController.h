//
//  LoudnessViewController.h
//  CortexDemo
//
//  Created by Joris Janssen on 12/01/15.
//  Copyright (c) 2015 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoudnessViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITextView* logText;
- (IBAction) fastForward: (id) sender;

@end
