//
//  CommentWriteViewController.h
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 9..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentWriteViewController : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (assign, nonatomic) NSInteger postId;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@end
