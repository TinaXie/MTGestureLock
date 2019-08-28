//
//  MTTouchIDLockViewController.m
//  MTGestureLock
//
//  Created by xiejc on 2018/12/14.
//
//  TouchID & FaceID解锁
//

#import "MTTouchIDLockViewController.h"
#import "UIImage+MTGesture.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface MTTouchIDLockViewController ()

@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
//取消
@property (nonatomic, strong) UIButton *cancelBtn;


@end

@implementation MTTouchIDLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
    [self authenticateUser];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat cancelBtnW = 60.0;
    CGFloat cancelBtnH = 40.0;
    CGFloat cancelBtnX = self.view.frame.size.width - cancelBtnW - 10.0;
    CGFloat cancelBtnY = 24.0 + 5.0;
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(cancelBtnX, cancelBtnY, cancelBtnW, cancelBtnH);
    [self.cancelBtn addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:self.cancelBtn];
    
    CGFloat descLabelX = 10.0;
    CGFloat descLabelY = self.view.frame.size.height * 0.5;
    CGFloat descLabelW = self.view.frame.size.width - descLabelX * 2;
    CGFloat descLabelH = 20.0;
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(descLabelX, descLabelY, descLabelW, descLabelH)];
    self.descLabel.font = [UIFont systemFontOfSize:12.0];
    self.descLabel.textColor = [UIColor blueColor];
    self.descLabel.text = @"点击屏幕输入密码验证";
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.descLabel];
    
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(authenticateUser)];
    [self.view addGestureRecognizer:self.tapGesture];
}

/**
 退出
 
 @param sender 按钮
 */
- (IBAction)clickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


// 验证指纹
- (void)authenticateUser {
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"验证失败";
    
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        NSLog(@"支持TouchID/FaceID识别");
        [self gotToEvaluate:context];
    } else {
        NSLog(@"不支持TouchID/FaceID识别!!!\nerror:%@", error.localizedDescription);
        self.descLabel.text = @"不支持TouchID/FaceID识别";
        switch (error.code) {
            case LAErrorBiometryNotAvailable:
            {
                NSLog(@"生物技术硬件不支持");
            }
                break;
            case LAErrorBiometryNotEnrolled:
            {
                NSLog(@"生物技术没有设置");
            }
                break;
            case LAErrorBiometryLockout:
            {
                NSLog(@"生物技术被锁了");
            }
                break;
                
            default:
            {
                NSLog(@"生物技术失败：%@", error.localizedDescription);
            }
                break;
        }
    }
}


/**
 进行验证解锁

 @param context 解锁对象
 */
- (void)gotToEvaluate:(LAContext *)context {
    static NSInteger errorCount = 3;

    NSString *typeString = @"";
    if (@available(iOS 11.0, *)) {
        switch (context.biometryType) {
            case LABiometryTypeTouchID:
                typeString = @"指纹";
                break;
            case LABiometryTypeFaceID:
                typeString = @"面部";
                break;
            default:
                break;
        }
    } else {
        typeString = @"指纹";
    }
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:[NSString stringWithFormat:@"请输入%@解锁", typeString] reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"解锁验证成功");
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.descLabel.text = @"验证成功！！";
            });
        }else{
            NSLog(@"解锁验证失败：%@",error.localizedDescription);
            errorCount--;
            if (errorCount <= 0) {
                NSLog(@"解锁验证失败次数用完！");
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.descLabel.text = @"请返回，重新验证";
                    [self.tapGesture removeTarget:self action:@selector(authenticateUser)];
                });
                return;
            }
        
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.descLabel.text = [NSString stringWithFormat:@"剩余%ld验证机会 点击屏幕进行验证", (long)errorCount];
            });
        
            switch (error.code) {
                case LAErrorSystemCancel:
                {
                    //系统取消授权(例如其他APP切入)
                    NSLog(@"系统取消授权，如其他APP切入");
                    break;
                }
                case LAErrorUserCancel:
                {
                    //用户取消授权
                    NSLog(@"用户取消验证");
                    break;
                }
                case LAErrorAuthenticationFailed:
                {
                    //授权失败
                    NSLog(@"授权失败");
                    break;
                }
                case LAErrorPasscodeNotSet:
                {
                    //系统未设置密码
                    NSLog(@"解锁系统未设置密码");
                    break;
                }
                case LAErrorTouchIDNotAvailable:
                {
                    //设备解锁不可用，例如未打开
                    NSLog(@"解锁设备功能不可用，例如未打开");
                    break;
                }
                case LAErrorTouchIDNotEnrolled:
                {
                    //设备解锁不可用，用户未录入
                    NSLog(@"解锁设备功能不可用，用户未录入");
                    break;
                }
                case LAErrorUserFallback:
                {
                    //用户选择输入密码
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSLog(@"用户选择输入密码，切换主线程处理");
                    });
                    
                    break;
                }
                default:
                {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        NSLog(@"其他情况，切换主线程处理");
                    }];
                    break;
                }
            }
        }
    }];
}

@end
