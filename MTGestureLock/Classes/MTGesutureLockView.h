//
//  MTGesutureLockView.h
//  Expecta
//
//  Created by xiejc on 2018/12/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MTGesutureLockView;

@protocol MTGesutureLockViewDelegate <NSObject>

- (void)gestureLockView:(MTGesutureLockView *)lockView drawRectFinished:(NSMutableString *)gesturePassword;

@end

@interface MTGesutureLockView : UIView

@property (nonatomic, assign) id<MTGesutureLockViewDelegate> delegate;


/**
 清除布局 重新开始
 */
- (void)clearLockView;


@end

NS_ASSUME_NONNULL_END
