//
//  TableViewController.m
//  YQEditPhotoContainerView
//
//  Created by 俞琦 on 2017/7/26.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()
@property (nonatomic, strong) NSArray *array;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"主页";
    
    self.array = @[@"NORMAL", @"YES_3_9", @"NO_5_10"];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = self.array[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class vcClass = NSClassFromString(self.array[indexPath.row]);
    UIViewController *vc = (UIViewController *)[[vcClass alloc] init];
    vc.title = self.array[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
