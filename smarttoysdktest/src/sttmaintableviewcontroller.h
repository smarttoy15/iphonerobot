//
//  STTMainTableViewController.h
//  smarttoysdktest
//
//  Created by newma on 4/2/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STTMainTableViewController : UITableViewController {
    NSDictionary* m_testSiuts;
}
@property (strong, nonatomic) IBOutlet UITableView *tblTestSuits;

@end
