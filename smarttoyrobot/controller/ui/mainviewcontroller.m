/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript:
 
 Modified:
 */
#import "mainviewcontroller.h"

@interface mainViewController ()

@property NSMutableArray *robotList;

@end

@implementation mainViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.robotList = [[NSMutableArray alloc] init];
    [self.robotList addObject:@"test"];
    [self.robotList addObject:@"test2"];
    [self.robotList addObject:@"test3"];
    [self.tableView reloadData];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.robotList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrototypeCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *mtext = [self.robotList objectAtIndex:indexPath.row];
    UILabel *robotNameLabel = (UILabel *)[cell viewWithTag:100];
    robotNameLabel.text = mtext;
    
    return cell;
}


@end
