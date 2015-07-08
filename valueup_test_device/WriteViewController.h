//
//  WriteViewController.h
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 7..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALERT_EMPTY_TITLE 1000
#define ALERT_EMPTY_CONTENT 1001
#define ALERT_WRITE_COMPLETE 1002
#define ALERT_WRITE_FAIL 1003
#define ALERT_MODIFY_COMPLETE 1004
#define ALERT_MODIFY_FAIL 1005

@interface WriteViewController : UIViewController<UIAlertViewDelegate> {
    @private
    
}

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *contentField;
@property (assign, nonatomic) NSInteger targetId;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
