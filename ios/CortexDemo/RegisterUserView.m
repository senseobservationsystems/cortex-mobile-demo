//
//  RegisterUserView.m
//  CortexDemo
//
//  Created by Pim Nijdam on 7/2/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "RegisterUserView.h"

#import "RegisterUserView.h"
#import <Cortex/CSSensePlatform.h>

@interface RegisterUserView ()

@end

@implementation RegisterUserView {
    UITextField* usernameField;
    UITextField* emailField;
    UITextField* passwordField;
    UITextField* password2Field;
    UIActivityIndicatorView* activityIndicatorView;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.scrollEnabled = NO;
        
        //init fields
        usernameField=[[UITextField alloc]initWithFrame:CGRectMake(115, 10, 185, 25)];
        usernameField.autoresizingMask=0;
        usernameField.autoresizesSubviews=YES;
        [usernameField setBorderStyle:UITextBorderStyleNone];
        [usernameField setPlaceholder:@"Required"];
        [usernameField setTextAlignment:UITextAlignmentRight];
        usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        passwordField=[[UITextField alloc]initWithFrame:CGRectMake(115, 10, 185, 25)];
        passwordField.autoresizingMask=0;
        passwordField.autoresizesSubviews=YES;
        [passwordField setBorderStyle:UITextBorderStyleNone];
        [passwordField setPlaceholder:@"Required"];
        [passwordField setTextAlignment:UITextAlignmentRight];
        passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        passwordField.secureTextEntry = YES;
        passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        password2Field=[[UITextField alloc]initWithFrame:CGRectMake(115, 10, 185, 25)];
        password2Field.autoresizingMask=0;
        password2Field.autoresizesSubviews=YES;
        [password2Field setBorderStyle:UITextBorderStyleNone];
        [password2Field setPlaceholder:@"Required"];
        [password2Field setTextAlignment:UITextAlignmentRight];
        password2Field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        password2Field.secureTextEntry = YES;
        password2Field.autocorrectionType = UITextAutocorrectionTypeNo;
        
        emailField=[[UITextField alloc]initWithFrame:CGRectMake(80, 10, 220, 25)];
        emailField.autoresizingMask=0;
        emailField.autoresizesSubviews=YES;
        [emailField setBorderStyle:UITextBorderStyleNone];
        [emailField setPlaceholder:@"Required"];
        [emailField setTextAlignment:UITextAlignmentRight];
        emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [emailField setKeyboardType:UIKeyboardTypeEmailAddress];
        emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        //Add buttons
        UIButton* registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        registerButton.frame = CGRectMake(230,200, 80, 40);
        [registerButton setTitle:@"Register" forState:UIControlStateNormal];
        [registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:registerButton];
        
        UIButton* cancelButtion = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButtion.frame = CGRectMake(10,200, 80, 40);
        [cancelButtion setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButtion addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelButtion];
        
        //activity indicator
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicatorView setColor:[UIColor blackColor]];
        activityIndicatorView.hidesWhenStopped = YES;
        activityIndicatorView.center = self.view.center;
        [self.view addSubview:activityIndicatorView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [indexPath indexAtPosition:1];
    NSString *CellIdentifier = [NSString stringWithFormat:@"field%i", index];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        if (index == 0) {
            cell.textLabel.text = @"Username:";
            [cell addSubview:usernameField];
        } else if (index == 1) {
            cell.textLabel.text = @"Email:";
            [cell addSubview:emailField];
        } if (index == 2) {
            cell.textLabel.text = @"Password:";
            [cell addSubview:passwordField];
        } if (index == 3) {
            cell.textLabel.text = @"Password:";
            [cell addSubview:password2Field];
        }
    }
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void) registerAction {
    //check if all required fields are filled in
    if ([usernameField.text length] == 0 || [emailField.text length] == 0 || [passwordField.text length] == 0 || [password2Field.text length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed to register." message:@"Fill in all required fields." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //check if email correct
    if ([self NSStringIsValidEmail:emailField.text] == NO) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed to register." message:@"Fill in a valid email address." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //check if passwords match
    if ([passwordField.text isEqualToString:password2Field.text] == NO) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed to register." message:@"Passwords don't match." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //register
    
    //show activity indicator
    [activityIndicatorView startAnimating];
    [self.view bringSubviewToFront:activityIndicatorView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //register new user
    NSString* error = nil;
    BOOL succes = [CSSensePlatform registerUser:usernameField.text withPassword:passwordField.text withEmail:emailField.text];
    
    //hide activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [activityIndicatorView stopAnimating];
    
    //Alert on failure
    if (!succes) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed to register" message:error delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //succeeded, dismiss this view
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void) cancelAction {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end