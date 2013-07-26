//
//  TimeActiveTabViewController.h
//  CortexDemo
//
//  Created by Pim Nijdam on 7/26/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeActiveTabViewController : UIViewController
- (IBAction) resetTimeActive: (id) sender;

@property (nonatomic, retain) IBOutlet UITextView* logText;
@end
