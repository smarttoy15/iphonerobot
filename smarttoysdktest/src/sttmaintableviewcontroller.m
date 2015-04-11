//
//  STTMainTableViewController.m
//  smarttoysdktest
//
//  Created by newma on 4/2/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import "sttmaintableviewcontroller.h"
#import "discovery/sttdevicediscover.h"
#import "socket/sttsocketviewcontroller.h"

@interface STTMainTableViewController () {
    NSArray* m_category;
}

@end

@implementation STTMainTableViewController
/*
- (IBAction)unwindDone:(UIStoryboardSegue*)segue {
    
}
*/
- (void)viewDidLoad {
    [super viewDidLoad];
    if (!m_testSiuts) {
        m_testSiuts = @{
                    @"tcp socket test":@"socket",
                    @"udp socket test":@"socket",
                    @"device discovery test":@"discover",
                    };
    }

    if (!m_category) {
        m_category = m_testSiuts.allKeys;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    m_category = nil;
    m_testSiuts = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return m_category ? [m_category count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* name = [m_category objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:name];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:name];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* test = [m_category objectAtIndex:indexPath.row];
    NSString* identify = [m_testSiuts objectForKey:test];
    if (identify && identify.length > 0) {
        [self performSegueWithIdentifier:identify sender:self];
    } else {
        NSLog(@"error, the segue is not configure correctly");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqual:@"socket"]) {
        NSIndexPath* indexPath = [self.tblTestSuits indexPathForSelectedRow];
        NSString* title = [m_category objectAtIndex:indexPath.row];
        
        STTSocketViewController* controller = segue.destinationViewController;
        if ([title containsString:@"tcp socket"]) {
            controller.isTCP = YES;
        } else {
            controller.isTCP = NO;
        }
    }
}

@end
