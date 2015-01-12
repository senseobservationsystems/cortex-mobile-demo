//
//  SettingsViewController.h
//  CortexDemo
//
//  Created by Pim Nijdam on 12/9/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

- (IBAction) toggleRealtimeUpload:(id)sender;
- (IBAction) toggleSenseEnabled:(id)sender;

- (IBAction) loginClicked:(id)sender;
- (IBAction) registerClicked:(id)sender;

@property (nonatomic, retain) IBOutlet UISwitch* realtimeUploadSwitch;
@property (nonatomic, retain) IBOutlet UISwitch* senseEnabledSwitch;

@property (nonatomic, retain) IBOutlet UILabel* loginStateLobel;
@property (nonatomic, retain) IBOutlet UIButton* loginButton;
@property (nonatomic, retain) IBOutlet UIButton* registerButton;

@end
