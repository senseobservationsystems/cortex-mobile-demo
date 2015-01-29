//
//  MainViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 7/2/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "MainViewController.h"
#import "RegisterUserView.h"
#import <SensePlatform/CSSensePlatform.h>
#import <SensePlatform/CSSettings.h>

@interface MainViewController ()

@end

@implementation MainViewController {
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
    //Initialize alert views
    notLoggedInAlert = [[UIAlertView alloc] initWithTitle:@"Not logged in yet" message:@"You haven't logged in yet. Logging in allows you to store, view and share your data through CommonSense." delegate:self cancelButtonTitle:@"Don't login" otherButtonTitles:@"Login with an existing account",@"Register a new account",nil];
    notLoggedInAlert.alertViewStyle = UIAlertViewStyleDefault;
    
    loginAlert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Username and password?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login",nil];
    loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    failedToLoginAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Couldn't login" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
    NSString* username = [[CSSettings sharedSettings] getSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingUsername];
    NSLog(@"Username %@", username);
    if (username == nil || username.length == 0)
        [notLoggedInAlert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        //save settings
        [[CSSettings sharedSettings] setLogin:user withPassword:password];
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
