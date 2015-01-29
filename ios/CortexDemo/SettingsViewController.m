//
//  SettingsViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 12/9/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "SettingsViewController.h"
#import <SensePlatform/CSSensePlatform.h>
#import <SensePlatform/CSSettings.h>
#import "RegisterUserView.h"


static NSString* realtimeUpload = @"2";
static NSString* nonRealtimeUpload = @"1800";

@implementation SettingsViewController {
    UIAlertView* loginAlert;
    UIAlertView* notLoggedInAlert;
    UIAlertView* failedToLoginAlert;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.realtimeUploadSwitch.on = [[[CSSettings sharedSettings] getSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingUploadInterval] isEqualToString:realtimeUpload];
    
    self.senseEnabledSwitch.on = [[[CSSettings sharedSettings] getSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingSenseEnabled] isEqualToString:kCSSettingYES];
    
    //Initialize alert views
    notLoggedInAlert = [[UIAlertView alloc] initWithTitle:@"Not logged in yet" message:@"You haven't logged in yet. Logging in allows you to store, view and share your data through CommonSense." delegate:self cancelButtonTitle:@"Don't login" otherButtonTitles:@"Login with an existing account",@"Register a new account",nil];
    notLoggedInAlert.alertViewStyle = UIAlertViewStyleDefault;
    
    loginAlert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Username and password?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login",nil];
    loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    failedToLoginAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Couldn't login" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
    NSString* username = [[CSSettings sharedSettings] getSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingUsername];
    bool loggedIn = username != nil && username.length > 0;
    [self.loginButton setTitle:loggedIn ? @"Logout" : @"Login" forState:UIControlStateNormal];
    if (loggedIn) {
        [self.loginStateLobel setText:[NSString stringWithFormat:@"Logged in as %@", username]];
    } else {
        [self.loginStateLobel setText:@"Not logged in"];
    }
}

- (void)didReceiveMemoryWarning

{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI events
- (IBAction) toggleRealtimeUpload:(id)sender {
    if (sender == self.realtimeUploadSwitch) {
        if (self.realtimeUploadSwitch.on) {
            [[CSSettings sharedSettings] setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingUploadInterval value:realtimeUpload];
        } else {
            [[CSSettings sharedSettings] setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingUploadInterval value:nonRealtimeUpload];
        }
    }
}

- (IBAction) toggleSenseEnabled:(id)sender {
    if (sender == self.senseEnabledSwitch) {
        if (self.senseEnabledSwitch.on) {
            [[CSSettings sharedSettings] setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingSenseEnabled value:kCSSettingYES];
        } else {
            [[CSSettings sharedSettings] setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingSenseEnabled value:kCSSettingYES];
        }
    }
}

- (IBAction) loginClicked:(id)sender {
    if ([self.loginButton.titleLabel.text isEqualToString:@"Logout"]) {
        [CSSensePlatform logout];
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        [self.loginStateLobel setText:@"Not logged in"];
    } else {
        [loginAlert show];
    }
}

- (IBAction) registerClicked:(id)sender {
    RegisterUserView* view = [[RegisterUserView alloc] initWithStyle:UITableViewStyleGrouped];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:view animated:YES completion:^(void){}];
}


- (void) performLoginWithUser:(NSString*) user andPassword:(NSString*) password {
    //show activity indicator
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    [self.view bringSubviewToFront:activityIndicator];
    [activityIndicator startAnimating];
    
    BOOL succes = NO;
    if (user != nil && password != nil) {
        succes = [CSSensePlatform loginWithUser:user andPassword:password];
    }
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
    
    //Alert on failure
    if (!succes) {
        [failedToLoginAlert show];
    } else {
        [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        [self.loginStateLobel setText:[NSString stringWithFormat:@"Logged in as %@", user]];
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == loginAlert) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1: {
                NSString* username = [alertView textFieldAtIndex:0].text;
                NSString* password = [alertView textFieldAtIndex:1].text;
                if (username == nil)
                    username = @"";
                if (password == nil)
                    password = @"";
                [self performLoginWithUser:username andPassword:password];
                
                break;
            }
        }
    } else if (alertView == notLoggedInAlert) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                [loginAlert show];
                break;
            case 2: {
                RegisterUserView* view = [[RegisterUserView alloc] initWithStyle:UITableViewStyleGrouped];
                self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:view animated:YES completion:^(void){}];
            }
        }
    } else if (alertView == failedToLoginAlert) {
        [loginAlert show];
    }
}


@end
