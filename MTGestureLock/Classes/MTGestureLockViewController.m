//
//  MTGestureLockViewController.m
//  MTGestureLock
//
//  Created by xiejc on 2018/12/12.
//

#import "MTGestureLockViewController.h"
#import "MTGesutureLockView.h"
#import "MTGestureLockIndicatorView.h"
#import "UIImage+MTGesture.h"

#define MTGesturePasswordKey @"MTGesturePasswordKey"
#define MinMTGesturePasswordCount 4
#define MinMTGesturePasswordCountDesc @"至少连接四个点，请重新输入"

#define MaxGesturePasswordErrorCount 5

@interface MTGestureLockViewController ()
<MTGesutureLockViewDelegate, UIAlertViewDelegate>


@property (nonatomic, assign) id<MTGesutureLockDelegate> delegate;
@property (nonatomic, assign) MTUnlockType unlockType;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *avatarImage;

// 创建的手势密码
@property (nonatomic, copy) NSString *lastGesturePsw;
// 修改密码时是否已经验证过现有密码
@property (nonatomic, assign) BOOL hasValiateSuccess;

//取消
@property (nonatomic, strong) UIButton *cancelBtn;
//头像
@property (nonatomic, strong) UIImageView *headIcon;
//姓名
@property (nonatomic, strong) UILabel *nameLabel;

// 提示栏
@property (nonatomic, strong) UILabel *statusLabel;
//手势缩略图
@property (nonatomic, strong) MTGestureLockIndicatorView *gestureIndicatorView;
//手势按钮图
@property (nonatomic, strong) MTGesutureLockView *gestureView;
//其他账户
@property (nonatomic, strong) UIButton *otherAccountBtn;
//忘记密码
@property (nonatomic, strong) UIButton *forgetPswBtn;
//重设密码
@property (nonatomic, strong) UIButton *resetPswBtn;


@end

@implementation MTGestureLockViewController

- (instancetype)initWithUnlockType:(MTUnlockType)unlockType delegate:(nonnull id<MTGesutureLockDelegate>)delegate name:(nonnull NSString *)name avatarImage:(UIImage * _Nullable)image {
    if (self = [super init]) {
        self.unlockType = unlockType;
        self.delegate = delegate;
        self.name = name;
        self.avatarImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];

    self.resetPswBtn.hidden = YES;
    
    switch (self.unlockType) {
        case MTUnlockTypeCreatePsw:
        {
            self.gestureIndicatorView.hidden = NO;
            self.otherAccountBtn.hidden = self.forgetPswBtn.hidden = YES;
        }
            break;
        case MTUnlockTypeValidatePsw:
        {
            self.gestureIndicatorView.hidden = YES;
            self.otherAccountBtn.hidden = self.forgetPswBtn.hidden = NO;
        }
            break;
        case MTUnlockTypeChangePsw:
        {
            self.gestureIndicatorView.hidden = YES;
            self.otherAccountBtn.hidden = self.forgetPswBtn.hidden = YES;
        }
            break;
        default:
            break;
    }
    
    [self clickResetGesturePassword:nil];
}

- (void)initView {
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
    
    CGFloat headIconW = 50.0;
    CGFloat headIconX = (self.view.frame.size.width - headIconW) * 0.5;
    CGFloat headIconY = CGRectGetMaxY(self.cancelBtn.frame);
    self.headIcon = [[UIImageView alloc] initWithFrame:CGRectMake(headIconX, headIconY, headIconW, headIconW)];
    self.headIcon.layer.cornerRadius = headIconW * 0.5;
    self.headIcon.clipsToBounds = YES;
    self.headIcon.backgroundColor = [UIColor clearColor];
    
    if (self.avatarImage) {
        self.headIcon.image = self.avatarImage;
    } else {
        self.headIcon.image = [UIImage mtg_imageNamed:@"gesture_headIcon"];
    }
    [self.view addSubview:self.headIcon];
    
    CGFloat nameLabelX = 10.0;
    CGFloat nameLabelY = CGRectGetMaxY(self.headIcon.frame) + 4.0;
    CGFloat nameLabelH = 14.0;
    CGFloat nameLabelW = self.view.frame.size.width - nameLabelX * 2.0;
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH)];
    self.nameLabel.textColor = [UIColor orangeColor];
    self.nameLabel.font = [UIFont systemFontOfSize:12.0];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.nameLabel];
    
    self.nameLabel.text = self.name;
    
    CGFloat indicatorViewW = 80.0;
    CGFloat indicatorViewX = (self.view.frame.size.width - indicatorViewW) * 0.5;
    CGFloat indicatorViewY = CGRectGetMaxY(self.nameLabel.frame) + 15.0;
    self.gestureIndicatorView = [[MTGestureLockIndicatorView alloc] initWithFrame:CGRectMake(indicatorViewX, indicatorViewY, indicatorViewW, indicatorViewW)];
    [self.view addSubview:self.gestureIndicatorView];
    
    CGFloat statusLabelX = nameLabelX;
    CGFloat statusLabelY = CGRectGetMaxY(self.gestureIndicatorView.frame) + 10.0;
    CGFloat statusLabelH = 14.0;
    CGFloat statusLabelW = self.view.frame.size.width - statusLabelX * 2.0;

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(statusLabelX, statusLabelY, statusLabelW, statusLabelH)];
    self.statusLabel.textColor = [UIColor redColor];
    self.statusLabel.font = [UIFont systemFontOfSize:12.0];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.text = @"请绘制手势密码";
    [self.view addSubview:self.statusLabel];
    
    CGFloat bottomViewH = 40.0;
    
    CGFloat gestureViewY = CGRectGetMaxY(self.statusLabel.frame) + 36.0;
    CGFloat gestureMaxH = self.view.frame.size.height - gestureViewY - bottomViewH;
    CGFloat gestureViewW = MIN(gestureMaxH, self.view.frame.size.width);
    CGFloat gestureViewX = (self.view.frame.size.width - gestureViewW) * 0.5;
    self.gestureView = [[MTGesutureLockView alloc] initWithFrame:CGRectMake(gestureViewX, gestureViewY, gestureViewW, gestureViewW)];
    self.gestureView.delegate = self;
    [self.view addSubview:self.gestureView];
    
    CGFloat otherAccountBtnX = 10.0;
    CGFloat otherAccountBtnW = (self.view.frame.size.width - otherAccountBtnX * 3) / 3.0;
    CGFloat otherAccountBtnH = 16.0;
    CGFloat otherAccountBtnY = self.view.frame.size.height - bottomViewH - otherAccountBtnH - 5.0;
    self.otherAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.otherAccountBtn.frame = CGRectMake(otherAccountBtnX, otherAccountBtnY, otherAccountBtnW, otherAccountBtnH);
    [self.otherAccountBtn addTarget:self action:@selector(clickOtherAccountLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.otherAccountBtn setTitle:@"其他账户" forState:UIControlStateNormal];
    [self.otherAccountBtn setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
    self.otherAccountBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.otherAccountBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.view addSubview:self.otherAccountBtn];
    
    CGFloat forgetPswBtnW = otherAccountBtnW;
    CGFloat forgetPswBtnX = self.view.frame.size.width - forgetPswBtnW - otherAccountBtnX;
    CGFloat forgetPswBtnY = otherAccountBtnY;
    CGFloat forgetPswBtnH = otherAccountBtnH;
    self.forgetPswBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.forgetPswBtn.frame = CGRectMake(forgetPswBtnX, forgetPswBtnY, forgetPswBtnW, forgetPswBtnH);
    self.forgetPswBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.forgetPswBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [self.forgetPswBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.forgetPswBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.forgetPswBtn addTarget:self action:@selector(clickForgetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.forgetPswBtn];
    
    CGFloat resetPswBtnW = otherAccountBtnW;
    CGFloat resetPswBtnX = (self.view.frame.size.width - resetPswBtnW) * 0.5;
    CGFloat resetPswBtnY = otherAccountBtnY;
    CGFloat resetPswBtnH = otherAccountBtnH;
    self.resetPswBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.resetPswBtn.frame = CGRectMake(resetPswBtnX, resetPswBtnY, resetPswBtnW, resetPswBtnH);
    self.resetPswBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.resetPswBtn setTitle:@"重新绘制" forState:UIControlStateNormal];
    [self.resetPswBtn setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
    self.resetPswBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.resetPswBtn addTarget:self action:@selector(clickResetGesturePassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetPswBtn];
}


/**
 创建手势密码保存
 
 @param gesturePassword 手势密码
 */
- (void)createGesturesPassword:(NSString *)gesturePassword {
    if (self.lastGesturePsw.length == 0) {
        if (gesturePassword.length < MinMTGesturePasswordCount) {
            self.statusLabel.text = MinMTGesturePasswordCountDesc;
            [self shakeAnimationForView:self.statusLabel];
            [self.gestureView clearLockView];
            return;
        }
        if (self.resetPswBtn.hidden) {
            self.resetPswBtn.hidden = NO;
        }
        
        self.lastGesturePsw = gesturePassword;
        [self.gestureIndicatorView setGesturePassword:gesturePassword];
        self.statusLabel.text = @"请再次绘制手势密码";
        [self.gestureView clearLockView];
        return;
    }
    
    if ([self.lastGesturePsw isEqualToString:gesturePassword]) {
        //绘制一致 保存手势密码
        [self dismissViewControllerAnimated:YES completion:^{
            [MTGestureLockViewController saveGesturesPassword:gesturePassword];
        }];
    } else {
        [self.gestureView clearLockView];
        self.statusLabel.text = @"与上一次绘制不一致，请重新绘制";
        [self shakeAnimationForView:self.statusLabel];
    }
}


/**
 验证手势密码
 
 @param gesturePassword 验证手势密码
 */
- (void)validateGesturesPassword:(NSString *)gesturePassword {
    static NSInteger errorCount = MaxGesturePasswordErrorCount;
    if ([gesturePassword isEqualToString:[MTGestureLockViewController getGesturesPassword]]) {
        [self dismissViewControllerAnimated:YES completion:^{
            errorCount = MaxGesturePasswordErrorCount;
        }];
    } else {
        errorCount--;

        //输错5次
        if (errorCount <= 0) {
            self.statusLabel.text = @"密码错误，无法继续输入";
            [self.gestureView clearLockView];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"手势密码已失效" message:@"请重新登陆" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertVC addAction:alertAction];
            [self presentViewController:alertVC animated:YES completion:nil];
            errorCount = 5;
            return;
        }
        
        [self.gestureView clearLockView];
        self.statusLabel.text = [NSString stringWithFormat:@"密码错误，还可以再输入%ld次", (long)errorCount];
        [self shakeAnimationForView:self.statusLabel];
    }
}

- (void)changeGesturesPassword:(NSString *)gesturePassword {
    if (self.hasValiateSuccess) {
        [self createGesturesPassword:gesturePassword];
        return;
    }

    static NSInteger changeErrorCount = MaxGesturePasswordErrorCount;
    if ([gesturePassword isEqualToString:[MTGestureLockViewController getGesturesPassword]]) {
        self.hasValiateSuccess = YES;
        
        self.gestureIndicatorView.hidden = NO;
        self.otherAccountBtn.hidden = self.forgetPswBtn.hidden = YES;

        [self.gestureView clearLockView];
        self.statusLabel.text = @"请设置新手势";
    } else {
        changeErrorCount--;
        
        //输错5次
        if (changeErrorCount <= 0) {
            self.statusLabel.text = @"密码错误，无法继续输入";
            [self.gestureView clearLockView];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"手势密码已失效" message:@"请重新登陆" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertVC addAction:alertAction];
            [self presentViewController:alertVC animated:YES completion:nil];
            changeErrorCount = 5;
            return;
        }
        
        [self.gestureView clearLockView];
        self.statusLabel.text = [NSString stringWithFormat:@"密码错误，还可以再输入%ld次", (long)changeErrorCount];
        [self shakeAnimationForView:self.statusLabel];
    }
}


/**
 抖动效果

 @param shakeView 抖动的view
 */
- (void)shakeAnimationForView:(UIView *)shakeView {
    CALayer *viewLayer = shakeView.layer;
    CGPoint position = viewLayer.position;
    CGPoint left = CGPointMake(position.x - 10, position.y);
    CGPoint right = CGPointMake(position.x + 10, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"postion"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:left]];
    [animation setToValue:[NSValue valueWithCGPoint:right]];
    [animation setAutoreverses:YES];
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    
    [viewLayer addAnimation:animation forKey:nil];
}


/**
 退出

 @param sender 按钮
 */
- (IBAction)clickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/**
 点击其他账号登陆按钮
 
 @param sender 按钮
 */
- (IBAction)clickOtherAccountLogin:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockViewControllerClickOtherAccount:)]) {
        [self.delegate gestureLockViewControllerClickOtherAccount:self];
    }
}

/**
 忘记密码
 
 @param sender 密码
 */
- (IBAction)clickForgetPassword:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockViewControllerClickForgetPassword:)]) {
        [self.delegate gestureLockViewControllerClickForgetPassword:self];
    }
}

/**
 点击重新绘制按钮
 
 @param sender 按钮
 */
- (IBAction)clickResetGesturePassword:(id)sender {
    NSLog(@"点击重新绘制");
    self.lastGesturePsw = nil;
    NSString *statusString = @"";
    if (self.unlockType == MTUnlockTypeChangePsw && !self.hasValiateSuccess) {
        statusString = @"请输入现有密码";
    } else {
        statusString = @"请绘制手势密码";
    }
    self.statusLabel.text = statusString;
    self.resetPswBtn.hidden = YES;
    [self.gestureIndicatorView setGesturePassword:@""];
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //重新登录
    NSLog(@"点击重新登录");
}

#pragma mark - MTGesutureLockViewDelegate

- (void)gestureLockView:(MTGesutureLockView *)lockView drawRectFinished:(NSMutableString *)gesturePassword {
    switch (self.unlockType) {
        case MTUnlockTypeCreatePsw:
        {
            [self createGesturesPassword:gesturePassword];
        }
            break;
        case MTUnlockTypeValidatePsw:
        {
            [self validateGesturesPassword:gesturePassword];
        }
            break;
        case MTUnlockTypeChangePsw:
        {
            [self changeGesturesPassword:gesturePassword];
        }
            break;
        default:
            break;
    }
}


/**
 删除手势密码
 */
+ (void)deleteGesturesPassword {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MTGesturePasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


/**
 保存手势密码
 */
+ (void)saveGesturesPassword:(NSString *)gesturePassword {
    if (gesturePassword == nil) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:gesturePassword forKey:MTGesturePasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getGesturesPassword {
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:MTGesturePasswordKey];
    return pwd;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


