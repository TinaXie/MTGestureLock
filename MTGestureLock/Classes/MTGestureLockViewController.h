//
//  MTGestureLockViewController.h
//  MTGestureLock
//
//  Created by xiejc on 2018/12/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,MTUnlockType) {
    MTUnlockTypeCreatePsw, // 创建手势密码
    MTUnlockTypeValidatePsw, // 校验手势密码
    MTUnlockTypeChangePsw,  // 修改密码
};


@class MTGestureLockViewController;

@protocol MTGesutureLockDelegate <NSObject>

- (void)gestureLockViewControllerClickOtherAccount:(MTGestureLockViewController *)viewController ;

- (void)gestureLockViewControllerClickForgetPassword:(MTGestureLockViewController *)viewController;


@end

@interface MTGestureLockViewController : UIViewController


/**
 保存手势密码
 */
+ (void)saveGesturesPassword:(NSString *)gesturePassword;

/**
 删除手势密码
 */
+ (void)deleteGesturesPassword;

/**
 获取手势密码

 @return 手势密码
 */
+ (NSString *)getGesturesPassword;


- (instancetype)initWithUnlockType:(MTUnlockType)unlockType delegate:(id<MTGesutureLockDelegate>)delegate name:(NSString *)name avatarImage:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
