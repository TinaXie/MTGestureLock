//
//  MTGesutureLockView.m
//  Expecta
//
//  Created by xiejc on 2018/12/12.
//

#import "MTGesutureLockView.h"
#import "UIImage+MTGesture.h"
#import "MTGestureUtils.h"

#define GestureLockCount 9


@interface MTGesutureLockView ()

@property (nonatomic, strong) NSMutableArray *selectedList;

//是否完成
@property(nonatomic, assign)BOOL finished;
//当前触摸点
@property (nonatomic, assign) CGPoint currentPoint;


@end

@implementation MTGesutureLockView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (NSMutableArray *)selectedList {
    if (_selectedList == nil) {
        _selectedList = [NSMutableArray array];
    }
    return _selectedList;
}

- (void)initSubViews {
    self.backgroundColor = [UIColor clearColor];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    for (NSInteger i=0; i<GestureLockCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.userInteractionEnabled = NO;
        btn.tag = i + 1;
        btn.imageView.contentMode = UIViewContentModeScaleToFill;
        [self resetButtonImage:btn];
        [self addSubview:btn];
    }
}

- (void)resetButtonImage:(UIButton *)btn {
    [btn setImage:[UIImage mtg_imageNamed:@"dot-gray"] forState:UIControlStateNormal];
    [btn setImage:[UIImage mtg_imageNamed:@"dot-orange"] forState:UIControlStateSelected];
}


- (void)pan:(UIPanGestureRecognizer *)pan {
    self.currentPoint = [pan locationInView:self];
    
    for (UIButton *button in self.subviews) {
        if (CGRectContainsPoint(button.frame, _currentPoint)) {
            if (button.selected == NO) {
                //点在按钮上
                button.selected = YES;//设置为选中
                [self.selectedList addObject:button];
            } else {
                
            }
        }
    }

    //重绘
    [self setNeedsDisplay];

    if (pan.state == UIGestureRecognizerStateEnded) {
        self.finished = YES;
    }
}

//清除
- (void)clearLockView {
    self.finished = NO;
    for (UIButton *btn in self.selectedList) {
        btn.selected = NO;
    }
    [self.selectedList removeAllObjects];
    [self setNeedsLayout];
}

//传递设置的手势密码
- (NSMutableString *)transferGestureResult {
    //创建可变字符串
    NSMutableString *result = [NSMutableString string];
    for (UIButton *btn in self.selectedList) {
        [result appendFormat:@"%ld", btn.tag - 1];
    }
    return result;
}

#pragma mark - 绘图

- (void)drawRect:(CGRect)rect {
    if (_selectedList.count == 0) {
        return;
    }

    // 把所有选中按钮中心点连线
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < self.selectedList.count; i ++) {
        UIButton *btn = self.selectedList[i];

        if (i == 0) {
            [path moveToPoint:btn.center]; // 设置起点
        } else {
            [path addLineToPoint:btn.center];
        }
    }
    
    if (self.finished) {
        //松开手指
        
        NSMutableString *pwd = [self transferGestureResult];
        [[UIColor colorWithRed:94.0/255.0 green:195.0/255.0 blue:49.0/255.0 alpha:0.8] set];
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockView:drawRectFinished:)]) {
            [self.delegate gestureLockView:self drawRectFinished:pwd];
        }
        
        [[UIColor clearColor] set];
    } else {
        [path addLineToPoint:self.currentPoint];
        [[UIColor orangeColor] set];
    }

    path.lineWidth = 6.0;
    path.lineJoinStyle= kCGLineCapRound;
    path.lineCapStyle = kCGLineCapRound;
    [path stroke];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger count = GestureLockCount;
    NSInteger cols = 3;
    CGFloat x = 0, y=0, w=0;
    
    if (SCreen_Width == 320.0) {
        w = 50.0;
    } else {
        w = 58.0;
    }
    
    CGFloat margin = (self.bounds.size.width - cols * w) / (cols + 1);
    CGFloat col = 0;
    CGFloat row = 0;
    
    for (NSInteger i=0; i<count; i++) {
        col = i % cols;
        row = i / cols;
    
        x = margin + (w + margin) * col;
        
        if (SCreen_Height == 480.0) {
            y = (w + margin) * row;
        } else {
            y = (w + margin) * row;
        }
        
        UIButton *btn = [self.subviews objectAtIndex:i];
        btn.frame = CGRectMake(x, y, w, w);
    }
}

@end
