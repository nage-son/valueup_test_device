//
//  WriteViewController.m
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 7..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#import "WriteViewController.h"
#import <AFNetworking.h>
#import "Constants.h"

@interface WriteViewController ()

@end

@implementation WriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_titleField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_titleField.layer setBorderWidth:1.0];
    
    [_contentField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_contentField.layer setBorderWidth:1.0];
    
    if (_targetId > 0) {
        //TODO: 데이터 호출
        NSLog(@"modify target id : %ld", _targetId);
        
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self.titleField becomeFirstResponder];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(nonnull UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case ALERT_EMPTY_TITLE:
            [self.titleField becomeFirstResponder];
            break;
            
        case ALERT_EMPTY_CONTENT:
            [self.contentField becomeFirstResponder];
            break;
            
        case ALERT_WRITE_COMPLETE:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil];
            break;
            
        case ALERT_MODIFY_COMPLETE:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPost" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil];
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    NSError *error;
    NSString *titleText = self.titleField.text;
    NSString *contentText = self.contentField.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s\\n]" options:NSRegularExpressionCaseInsensitive error:&error];
    
    if ([regex stringByReplacingMatchesInString:titleText options:0 range:NSMakeRange(0, titleText.length) withTemplate:@""].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"제목을 입력하여 주세요."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"확인", nil];
        
        alert.tag = ALERT_EMPTY_TITLE;
        
        [alert show];
        
        return;
    }
    
    if ([regex stringByReplacingMatchesInString:contentText options:0 range:NSMakeRange(0, contentText.length) withTemplate:@""].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"내용을 입력하여 주세요."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"확인", nil];
        
        alert.tag = ALERT_EMPTY_CONTENT;
        
        [alert show];
        
        return;
    }
    
    SHOW_INDICATOR;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url;
    NSDictionary *data;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if (_targetId == 0) {
        url = CONNECT_STRING(@"/post");
        data = @{@"title":titleText, @"content":contentText};
        
        [manager POST:url parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *message;
            int status = ALERT_WRITE_COMPLETE;
            
            if ([RESULT_OK isEqualToString:[responseObject objectForKey:@"result"]]) {
                message = @"등록되었습니다.";
            } else {
                message = MESSAGE_SERVER_ERROR;
                status = ALERT_WRITE_FAIL;
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"확인", nil];
            
            alert.tag = status;
            
            [alert show];
            
            return;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:MESSAGE_SERVER_ERROR
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"확인", nil];
            
            alert.tag = ALERT_WRITE_FAIL;
            
            [alert show];
            
            return;
        }];
    } else {
        NSString *uri = [NSString stringWithFormat:@"/post/%ld", _targetId];
        url = CONNECT_STRING(uri);
        data = @{@"title":titleText, @"content":contentText, @"id":[NSNumber numberWithInteger:_targetId]};
        
        [manager PUT:url parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *message;
            int status = ALERT_MODIFY_COMPLETE;
            
            if ([RESULT_OK isEqualToString:[responseObject objectForKey:@"result"]]) {
                message = @"수정되었습니다.";
            } else {
                message = MESSAGE_SERVER_ERROR;
                status = ALERT_MODIFY_FAIL;
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"확인", nil];
            
            alert.tag = status;
            
            [alert show];
            
            return;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:MESSAGE_SERVER_ERROR
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"확인", nil];
            
            alert.tag = ALERT_MODIFY_FAIL;
            
            [alert show];
            
            return;
        }];
    }
    
    HIDE_INDICATOR;
}
@end
