//
//  DataCoverageTestViewController.h
//  CortexDemo
//
//  Created by Frehun Demissie on 02/02/15.
//  Copyright (c) 2015 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DataCoverageTestViewController : UIViewController


@property (nonatomic, retain) IBOutlet UITextView *summaryText;
- (IBAction) testDataCoverage: (id) sender;

@end
