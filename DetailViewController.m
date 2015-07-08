//
//  DetailViewController.m
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 7..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#import "DetailViewController.h"
#import <AFNetworking.h>
#import "Constants.h"
#import "WriteViewController.h"

@interface DetailViewController ()

- (void)getDetail;
- (void)didReceiveRefresh:(NSNotification *)notification;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"상세";
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender {
    if ([segue.identifier isEqualToString:@"goModifyView"]) {
        WriteViewController *targetViewController = (WriteViewController *)segue.destinationViewController;
        
        targetViewController.targetId = _targetId;
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
@end
