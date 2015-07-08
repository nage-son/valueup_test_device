//
//  ViewController.m
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 7..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import "Constants.h"
#import "DetailViewController.h"

@interface ViewController ()

- (void)getList;
- (void)didReceiveRefresh:(NSNotification *)notification;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"목록";
    
    [self.listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
    
    _dataProvider = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveRefresh:)
                                                 name:@"refreshList"
                                               object:nil];
    
    [self getList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender {
    if ([segue.identifier isEqualToString:@"goDetailView"]) {
        DetailViewController *targetViewController = (DetailViewController *)[segue destinationViewController];
        
        targetViewController.targetId = _selectedId;
    }
}

#pragma mark - private methods
- (void)getList {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = CONNECT_STRING(@"/post/list");
    
    NSLog(@"url : %@", url);
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        CHECK_RESULT(responseObject);
        NSArray *dataList = [responseObject objectForKey:@"data"];
        
        if (dataList == nil || dataList.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"데이터가 없습니다."
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"확인", nil];
            
            [alert show];
        } else {
            [_dataProvider removeAllObjects];
            [_dataProvider addObjectsFromArray:dataList];
            
            [self.listTableView reloadData];
        }
        
        HIDE_INDICATOR;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@", error);
        
        HIDE_INDICATOR;
    }];
}

- (void)didReceiveRefresh:(NSNotification *)notification {
    [self refresh:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *data = [_dataProvider objectAtIndex:indexPath.row];
    
    _selectedId = [(NSString *)[data objectForKey:@"id"] intValue];
    
    NSLog(@"selected id : %ld", _selectedId);
    
    [self performSegueWithIdentifier:@"goDetailView" sender:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataProvider.count;
}

- (UITableViewCell*)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.listTableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    if (_dataProvider.count > 0) {
        NSDictionary *data = [_dataProvider objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [data objectForKey:@"title"];
    }
    
    return cell;
}

- (BOOL)tableView:(nonnull UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(nonnull UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *data = [_dataProvider objectAtIndex:indexPath.row];
    
    _deleteId = [(NSNumber *)[data objectForKey:@"id"] integerValue];
    _deletedIndexPath = indexPath;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"삭제하시겠습니까?"
                                                   delegate:self
                                          cancelButtonTitle:@"취소"
                                          otherButtonTitles:@"삭제", nil];
    
    alert.tag = 333;
    
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(nonnull UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *uri = [NSString stringWithFormat:@"/post/%ld", _deleteId];
        NSString *url = CONNECT_STRING(uri);
        
        __block NSIndexPath *targetIndexPath = _deletedIndexPath;
        
        [manager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"indexPath row : %ld", targetIndexPath.row);
            
            [_dataProvider removeObjectAtIndex:targetIndexPath.row];
            [self.listTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:targetIndexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"삭제중 오류가 발생하였습니다."
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"확인", nil];
            
            [alert show];
            
            [self.listTableView setEditing:NO animated:YES];
            
            return;
        }];
    } else {
        [self.listTableView setEditing:NO animated:YES];
    }
    
    _deletedIndexPath = nil;
    _deleteId = 0;
}

#pragma mark - IBActions

- (IBAction)goWriteMode:(id)sender {
    [self performSegueWithIdentifier:@"goWriteView" sender:self];
}

- (IBAction)refresh:(id)sender {
    SHOW_INDICATOR;
    
    [self getList];
}
@end
