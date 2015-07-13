//
//  CommentListViewController.m
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 9..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#import "CommentListViewController.h"
#import "Constants.h"
#import "CommentWriteViewController.h"
#import <AFNetworking.h>

@interface CommentListViewController ()

- (void)getList;
- (void)refreshList:(NSNotification *)notification;

@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshList:)
                                                 name:@"refreshCommentList"
                                               object:nil];
    
    _dataProvider = [[NSMutableArray alloc] init];
    
    [self getList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"commentCell"];
    }
    
    if (_dataProvider.count > 0) {
        NSDictionary *data = [_dataProvider objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [data objectForKey:@"content"];
        
        NSNumber *num = [data objectForKey:@"createdAt"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:([num longValue] / 1000)];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        
        NSString *formattedDate = [formatter stringFromDate:date];
        NSLog(@"stamp : %ld", [num longValue]);
        NSLog(@"date : %@", formattedDate);
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.detailTextLabel.text = formattedDate;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [_dataProvider objectAtIndex:indexPath.row];
    
    _deletedId = [(NSNumber *)[data objectForKey:@"id"] integerValue];
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
        NSString *uri = [NSString stringWithFormat:@"/comment/%ld", _deletedId];
        NSString *url = CONNECT_STRING(uri);
        
        __block NSIndexPath *targetIndexPath = _deletedIndexPath;
        
        [manager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [_dataProvider removeObjectAtIndex:targetIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:targetIndexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"삭제중 오류가 발생하였습니다."
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"확인", nil];
            
            [alert show];
            
            [self.tableView setEditing:NO animated:YES];
            
            return;
        }];
    } else {
        [self.tableView setEditing:NO animated:YES];
    }
    
    _deletedIndexPath = nil;
    _deletedId = 0;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"goCommentWriteView"]) {
        CommentWriteViewController *targetViewController = (CommentWriteViewController *)segue.destinationViewController;
        
        targetViewController.postId = _postId;
    }
}

#pragma mark - private methods
- (void)getList {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = CONNECT_STRING(@"/comment");
    NSDictionary *data = @{@"postId": [NSNumber numberWithInteger:_postId]};
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:url parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
            
            [self.tableView reloadData];
        }
        
        HIDE_INDICATOR;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@", error);
        
        HIDE_INDICATOR;
    }];
}

- (void)refreshList:(NSNotification *)notification {
    [self getList];
}

- (IBAction)goCommentWrite:(id)sender {
    [self performSegueWithIdentifier:@"goCommentWriteView" sender:self];
}
@end
