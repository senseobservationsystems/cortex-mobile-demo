//
//  DebugTabViewController.h
//  CortexDemo
//
//  Created by Pim Nijdam on 5/2/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DebugTabViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITextView* logText;

- (IBAction) report:(id)sender;
- (IBAction) reportLog:(id)sender;
@end
