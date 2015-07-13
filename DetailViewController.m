//
//  DetailViewController.m
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 7..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#import "DetailViewController.h"
#import <AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "WriteViewController.h"
#import "CommentListViewController.h"

@interface DetailViewController ()

- (void)getDetail;
- (void)didReceiveRefresh:(NSNotification *)notification;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"상세";
    
    [_commentField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_commentField.layer setBorderWidth:1.0];
    
    [_commentButton.layer setBorderColor:[[[UIColor blueColor] colorWithAlphaComponent:0.3] CGColor]];
    [_commentButton.layer setBorderWidth:1.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveRefresh:)
                                                 name:@"refreshPost"
                                               object:nil];
    
    [self getDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender {
    if ([segue.identifier isEqualToString:@"goModifyView"]) {
        WriteViewController *targetViewController = (WriteViewController *)segue.destinationViewController;
        
        targetViewController.targetId = _targetId;
    } else if ([segue.identifier isEqual:@"goCommentListView"]) {
        CommentListViewController *targetViewController = (CommentListViewController *)segue.destinationViewController;
        
        targetViewController.postId = _targetId;
    }
}

#pragma mark - private methods
- (void)getDetail {
    if ([NSNumber numberWithInteger:_targetId] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"잘못된 접급입니다."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"확인", nil];
        //FIXME: tag 추가
        [alert show];
        
        return;
    }
    
    SHOW_INDICATOR;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *uri = [NSString stringWithFormat:@"/post/%ld", _targetId];
    NSString *url = CONNECT_STRING(uri);
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CHECK_RESULT(responseObject);
        
        NSDictionary *data = [responseObject objectForKey:@"data"];
        
        self.titleField.text = [data objectForKey:@"title"];
        self.contentField.text = [data objectForKey:@"content"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error!");
    }];
    
    HIDE_INDICATOR;
}

- (void)didReceiveRefresh:(NSNotification *)notification {
    [self getDetail];
}

- (IBAction)goModifyView:(id)sender {
    [self performSegueWithIdentifier:@"goModifyView" sender:self];
}

- (IBAction)saveComment:(id)sender {
    NSError *error;
    NSString *commentText = _commentField.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s\\n]" options:NSRegularExpressionCaseInsensitive error:&error];
    
    if ([regex stringByReplacingMatchesInString:commentText options:0 range:NSMakeRange(0, commentText.length) withTemplate:@""].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"댓글을 입력하여 주세요."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"확인", nil];
        
        alert.tag = ALERT_EMPTY_TITLE;
        
        [alert show];
        
        return;
    }
}

- (IBAction)goCommentList:(id)sender {
    [self performSegueWithIdentifier:@"goCommentListView" sender:self];
}
@end
