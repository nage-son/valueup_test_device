//
//  ViewController.h
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 7..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    @private
    NSMutableArray *_dataProvider;
    
    NSInteger _selectedId;
    NSInteger _deleteId;
    NSIndexPath *_deletedIndexPath;
}

@property (weak, nonatomic) IBOutlet UITableView *listTableView;
- (IBAction)goWriteMode:(id)sender;
- (IBAction)refresh:(id)sender;

@end

