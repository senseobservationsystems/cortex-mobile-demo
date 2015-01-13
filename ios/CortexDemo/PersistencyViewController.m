//
//  PersistencyViewController.m
//  CortexDemo
//
//  Created by Joris Janssen on 12/01/15.
//  Copyright (c) 2015 Sense Observation Systems BV. All rights reserved.
//

#import "PersistencyViewController.h"
#import "Cortex/Cortex.h"
#import "Cortex/CSSensePlatform.h"

@interface PersistencyViewController ()

@end

@implementation PersistencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//fills up the database to about 110mb and to see if it can handle gowing over the limit
- (IBAction) testDatabaseFillUp:(id)sender {
    
    //Fill up like crazy so that we have some decently sized db
    int totalPoints = 110000;
    
    [[self logText] setText:  [[[self logText] text] stringByAppendingString:[NSString stringWithFormat:@"Starting filling up database ... current free space on device: %lli mb\n", [[self getFreeSpaceOnDisk] longLongValue]/(1000*1000)]]];
    
    for( int i = 0; i < totalPoints; i++) { // add totalPoints points
        
        NSString* value = [NSString stringWithFormat:@"Point %i",i];
        
        //put one datapoint in the database
        [CSSensePlatform addDataPointForSensor:@"dummySensor" displayName:@"dummyDisplayName" description:@"dummyDescription" dataType:@"dummyDataType" stringValue:value timestamp:[NSDate date]];
        
        if( i%10000 == 0) {
            
            [[self logText] setText:  [[[self logText] text] stringByAppendingString:[NSString stringWithFormat:@"Another 10.000 points added, total: %d, free space: %lli\n", i, [[self getFreeSpaceOnDisk] longLongValue]/(1000*1000)]]];
        }
    }
    
    [[self logText] setText:  [[[self logText] text] stringByAppendingString:[NSString stringWithFormat:@"Done adding %d points without problems :) Free space %lli mb\n", totalPoints, [[self getFreeSpaceOnDisk] longLongValue]/(1000*1000) ]]];

    //NSLog(@"Number of rows: %li", [storage getNumberOfRowsInTable:@"data"]);
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark Helper functions

/*
 * Returns the number of bytes of free space on the disk
 */

- (NSNumber *) getFreeSpaceOnDisk {
    NSError *error = nil;
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    
    NSDictionary *fileSystemAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:docDirectory error:&error];
    //NSLog(@"Free space on file system: %@ bytes", [fileSystemAttributes objectForKey:NSFileSystemFreeSize]);
    
    return [fileSystemAttributes objectForKey:NSFileSystemFreeSize];
}

@end
