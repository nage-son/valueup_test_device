//
//  CommentWriteViewController.m
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 9..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#import "CommentWriteViewController.h"
#import "Constants.h"
#import <AFNetworking.h>

@interface CommentWriteViewController ()

@end

@implementation CommentWriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIAlertViewDelegate
- (void)alertView:(nonnull UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 3000) {
        [_commentField becomeFirstResponder];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCommentList" object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    NSError *error;
    NSString *commentText = _commentField.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s\\n]" options:NSRegularExpressionCaseInsensitive error:&error];
    
    if ([regex stringByReplacingMatchesInString:commentText options:0 range:NSMakeRange(0, commentText.length) withTemplate:@""].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"제목을 입력하여 주세요."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"확인", nil];
        
        alert.tag = 3000;
        [alert show];
        
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = CONNECT_STRING(@"/comment");
    NSDictionary *data = @{@"postId": [NSNumber numberWithInteger:_postId], @"content":commentText};
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:url parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *message;
        int status = 3001;
        
        if ([RESULT_OK isEqualToString:[responseObject objectForKey:@"result"]]) {
            message = @"등록되었습니다.";
        } else {
            message = MESSAGE_SERVER_ERROR;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"확인", nil];
        
        alert.tag = status;
        
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:MESSAGE_SERVER_ERROR
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"확인", nil];
        
        [alert show];
    }];
}
@end
