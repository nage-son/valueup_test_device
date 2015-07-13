//
//  DetailViewController.h
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 7..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (assign, nonatomic) NSInteger targetId;
@property (weak, nonatomic) IBOutlet UILabel *titleField;
@property (weak, nonatomic) IBOutlet UITextView *contentField;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UITextView *commentField;
- (IBAction)goModifyView:(id)sender;
- (IBAction)saveComment:(id)sender;
- (IBAction)goCommentList:(id)sender;
@end
