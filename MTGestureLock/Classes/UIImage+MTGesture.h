//
//  UIImage+MTGesture.h
//  MTGestureLock
//
//  Created by xiejc on 2018/12/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MTGesture)

+ (UIImage *)mtg_imageNamed:(NSString *)name;

- (UIImage *)stretchImg;

@end

NS_ASSUME_NONNULL_END
