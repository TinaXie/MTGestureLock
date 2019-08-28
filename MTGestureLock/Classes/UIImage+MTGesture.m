//
//  UIImage+MTGesture.m
//  MTGestureLock
//
//  Created by xiejc on 2018/12/13.
//

#import "UIImage+MTGesture.h"
#import "MTGestureUtils.h"

@implementation UIImage (MTGesture)

+ (UIImage *)mtg_imageNamed:(NSString *)name {
    NSBundle *bundle = [MTGestureUtils sdkBundle];
    UIImage *img = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    return img;
}

- (UIImage *)stretchImg {
    CGFloat top = 0; // 顶端盖高度
    CGFloat bottom = 0 ; // 底端盖高度
    CGFloat left = 0; // 左端盖宽度
    CGFloat right = 0; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    UIImage *newImg = [self resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    return newImg;
}

@end
