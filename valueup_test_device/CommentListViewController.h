//
//  CommentListViewController.h
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 9..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentListViewController : UITableViewController<UIAlertViewDelegate> {
    @private
    NSMutableArray *_dataProvider;
    NSInteger _deletedId;
    NSIndexPath *_deletedIndexPath;
}

@property (assign, nonatomic) NSInteger postId;

- (IBAction)goCommentWrite:(id)sender;
@end
