//
//  MTViewController.m
//  MTGestureLock
//
//  Created by xiejc on 12/12/2018.
//  Copyright (c) 2018 xiejc. All rights reserved.
//

#import "MTViewController.h"
#import "MTGestureLockViewController.h"
#import "MTTouchIDLockViewController.h"

@interface MTViewController ()
<UITableViewDataSource, UITableViewDelegate, MTGesutureLockDelegate>

@property (nonatomic, strong) NSArray *titleList;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation MTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleList = @[@"创建手势密码", @"校验手势密码", @"删除手势密码", @"修改手势密码", @"指纹登录"];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"GestureCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self.titleList objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            //创建
            MTGestureLockViewController *lockVC = [[MTGestureLockViewController alloc] initWithUnlockType:MTUnlockTypeCreatePsw delegate:self name:@"Tom and Jack" avatarImage:[UIImage imageNamed:@"1"]];
            [self presentViewController:lockVC animated:YES completion:nil];

        }
            break;
        case 1:
        {
            // 校验手势密码
            NSString *gesturePWD = [MTGestureLockViewController getGesturesPassword];
            if (gesturePWD && gesturePWD.length > 0) {
                MTGestureLockViewController *lockVC = [[MTGestureLockViewController alloc] initWithUnlockType:MTUnlockTypeValidatePsw delegate:self name:@"Tom and Jack" avatarImage:[UIImage imageNamed:@"1"]];
                [self presentViewController:lockVC animated:YES completion:nil];
            } else {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"还没有设置手势密码" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                [alertVC addAction:alertAction];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        }
            break;
        case 2:
        {
            //删除手势
            NSString *gesturePWD = [MTGestureLockViewController getGesturesPassword];
            if (gesturePWD && gesturePWD.length > 0) {
                [MTGestureLockViewController deleteGesturesPassword];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"删除成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                [alertVC addAction:alertAction];
                [self presentViewController:alertVC animated:YES completion:nil];
            } else {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"还没有设置手势密码" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                [alertVC addAction:alertAction];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        }
            break;
        case 3:
        {
            //修改手势密码
            NSString *gesturePWD = [MTGestureLockViewController getGesturesPassword];
            if (gesturePWD && gesturePWD.length > 0) {
                MTGestureLockViewController *lockVC = [[MTGestureLockViewController alloc] initWithUnlockType:MTUnlockTypeChangePsw delegate:self name:@"Tom and Jack" avatarImage:[UIImage imageNamed:@"1"]];
                [self presentViewController:lockVC animated:YES completion:nil];
            } else {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"还没有设置手势密码" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                [alertVC addAction:alertAction];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        }
            break;
            
        case 4:
        {
            //指纹登录
            MTTouchIDLockViewController *lockVC = [[MTTouchIDLockViewController alloc] init];
            [self presentViewController:lockVC animated:YES completion:nil];
        }
            break;
        default:
            
            break;
    }
}


- (void)gestureLockViewControllerClickOtherAccount:(MTGestureLockViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)gestureLockViewControllerClickForgetPassword:(MTGestureLockViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
