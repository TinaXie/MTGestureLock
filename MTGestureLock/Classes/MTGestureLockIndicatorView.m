//
//  MTGestureLockIndicatorView.m
//  MTGestureLock
//
//  Created by xiejc on 2018/12/12.
//

#import "MTGestureLockIndicatorView.h"
#import "UIImage+MTGesture.h"


#define GestureLockCount 9


@interface MTGestureLockIndicatorView ()

@end

@implementation MTGestureLockIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    for (NSInteger i=0; i<GestureLockCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.userInteractionEnabled = NO;
        btn.tag = i + 1;
        [btn setImage:[UIImage mtg_imageNamed:@"dot-gray"] forState:UIControlStateNormal];
        [btn setImage:[UIImage mtg_imageNamed:@"dot-orange"] forState:UIControlStateSelected];
        [self addSubview:btn];
    }
}

- (void)setGesturePassword:(NSString *)gesturePassword {
    if (gesturePassword == nil || gesturePassword.length == 0) {
        for (UIButton *btn in self.subviews) {
            btn.selected = NO;
        }
        return;
    }
    
    for (NSInteger i=0; i<gesturePassword.length; i++) {
        NSString *indexStr = [gesturePassword substringWithRange:NSMakeRange(i, 1)];
        NSInteger index = indexStr.integerValue;
        UIButton *btn = [self.subviews objectAtIndex:index];
        btn.selected = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger count = GestureLockCount;
    NSInteger cols = 3;
    CGFloat x = 0, y=0;
    CGFloat w=9;
    
    CGFloat margin = (self.bounds.size.width - cols * w) / (cols + 1);
    CGFloat col = 0;
    CGFloat row = 0;
    
    for (NSInteger i=0; i<count; i++) {
        col = i % cols;
        row = i / cols;
        
        x = margin + (w + margin) * col;
        y = margin + (w + margin) * row;

        UIButton *btn = [self.subviews objectAtIndex:i];
        btn.frame = CGRectMake(x, y, w, w);
    }
}


@end
