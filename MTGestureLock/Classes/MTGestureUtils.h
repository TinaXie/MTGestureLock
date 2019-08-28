//
//  MTGestureUtils.h
//  MTGestureLock
//
//  Created by xiejc on 2018/12/12.
//

#import <Foundation/Foundation.h>

#define SCreen_Width [UIScreen mainScreen].bounds.size.width
#define SCreen_Height [UIScreen mainScreen].bounds.size.height

NS_ASSUME_NONNULL_BEGIN

@interface MTGestureUtils : NSObject

+ (UIColor *)colorWithHexString: (NSString *)colorStr;

+ (NSBundle *)sdkBundle;

@end

NS_ASSUME_NONNULL_END
