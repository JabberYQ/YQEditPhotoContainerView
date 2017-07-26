//
//  YQEditPhotoContainerView.m
//  YQImageExhibition
//
//  Created by 俞琦 on 2017/7/25.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "YQEditPhotoContainerView.h"

@interface UIView (YQAdd)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@end
@implementation UIView (YQAdd)
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return  self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return  self.frame.size.height;
}
@end

static const NSTimeInterval kDurationTime = 0.3; // 动画持续时间
static const CGFloat kSelButtonWidth = 40;       // 选择按钮宽度

typedef void (^SelectDoneBlock)(NSArray *selArray);

@interface YQImageBannerView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, copy) SelectDoneBlock selectDoneBlock;
@property (nonatomic, strong) NSArray *photoArray; // 图片数组
@property (nonatomic, strong) NSMutableArray *selArray;
@property (nonatomic, weak) UILabel *numLabel;
@property (nonatomic, assign) NSInteger currentIndex;

- (instancetype)initWithPhotoArray:(NSArray *)photoArray currentIndex:(NSInteger)currentIndex;
- (void)show;
@end

@implementation YQImageBannerView

- (instancetype)initWithPhotoArray:(NSArray *)photoArray currentIndex:(NSInteger)currentIndex
{
    self = [super init];
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    self.photoArray = photoArray;
    self.currentIndex = currentIndex;
    self.alpha = 0.1;
    [self setupView];
    return self;
}

- (void)setupView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.bounds;
    scrollView.contentSize = CGSizeMake(self.width * self.photoArray.count, self.height);
    scrollView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.contentOffset = CGPointMake(self.width * self.currentIndex, 0);
    scrollView.delegate = self;
    [self addSubview:scrollView];

    for (int i = 0; i < self.photoArray.count; i++) {
        //创建ImageView
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = self.photoArray[i];
        [scrollView addSubview:imageView];
        
        //设置frame
        imageView.y = 0;
        imageView.width = scrollView.width;
        imageView.height = scrollView.height;
        imageView.x = i * imageView.width;
        
        //放钩子
        UIButton *selButton = [[UIButton alloc] init];
        [selButton setImage:[UIImage imageNamed:@"imageView_selected"] forState:UIControlStateNormal];
        [selButton setImage:[UIImage imageNamed:@"imageView_unselected"] forState:UIControlStateSelected];
        selButton.frame = CGRectMake(imageView.width - kSelButtonWidth - 10, 20, kSelButtonWidth, kSelButtonWidth);
        [selButton addTarget:self action:@selector(selButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:selButton];
    }
    
    UILabel *numLabel = [UILabel new];
    numLabel.text = [NSString stringWithFormat:@"%ld / %ld", self.currentIndex + 1, self.photoArray.count];
    numLabel.frame = CGRectMake(0, 20, self.width, 30);
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.font = [UIFont systemFontOfSize:14];
    numLabel.textColor = [UIColor whiteColor];
    [self addSubview:numLabel];
    self.numLabel = numLabel;

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTap)];
    tap.delegate = self;
    [scrollView addGestureRecognizer:tap];
}

- (void)show
{
    [UIView animateWithDuration:kDurationTime animations:^{
        self.alpha = 1;
    }];
}

- (void)selButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    UIView *imageView = sender.superview;
    int index = (imageView.x / imageView.width);
    self.selArray[index] = @(!sender.selected); // 保存选择状态
}

- (void)scrollViewTap
{
    if (self.selectDoneBlock) self.selectDoneBlock(self.selArray);
    
    [UIView animateWithDuration:kDurationTime animations:^{
        self.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (NSMutableArray *)selArray
{
    if (_selArray == nil) {
        _selArray = [NSMutableArray array];
        for (int i = 0; i < self.photoArray.count; i++) {
            [_selArray addObject:@1];
        }
    }
    return _selArray;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = (scrollView.contentOffset.x + self.width/2) / self.width + 1; 
    self.numLabel.text = [NSString stringWithFormat:@"%d / %ld", page, self.photoArray.count];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    return YES;
}

@end

static const CGFloat kDelButtonWidth = 35; // 按钮实际的宽度
static const CGFloat kDelButtonMargin = 0; // 与父视图的间隙
static const CGFloat kDelButtonSurfaceWidth = 20; // 表面的宽度 也就是圆的直径
static const CGFloat kDelButtonLineLength = 10; // 线的长度

@interface YQImageView : UIImageView
@property (nonatomic, weak) id target;
- (instancetype)initWithFrame:(CGRect)frame withTarget:(id)target;
@end
@implementation YQImageView
- (instancetype)initWithFrame:(CGRect)frame withTarget:(id)target
{
    if (self = [super initWithFrame:frame]) {
        self.target = target;
        self.userInteractionEnabled = YES;
        
        self.layer.cornerRadius = 3;
        self.clipsToBounds = YES;
    
        [self addDelButton];
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.target action:@selector(imageViewTap:)];
#pragma clang diagnostic pop
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)addDelButton
{
    UIButton *delButton = [[UIButton alloc] init];
    // 把delButton放大点便于点击，但绘制小点
    delButton.frame = CGRectMake(self.width - kDelButtonWidth - kDelButtonMargin, kDelButtonMargin, kDelButtonWidth, kDelButtonWidth);
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    [delButton addTarget:self.target action:@selector(delButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
    [self addSubview:delButton];
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.strokeColor = [UIColor colorWithRed:18/255.0f green:193/255.0f blue:232/255.0f alpha:1.0f].CGColor;
    circleLayer.lineCap = kCALineCapRound;
    circleLayer.lineJoin = kCALineJoinRound;
    circleLayer.lineWidth = 3;
    circleLayer.frame = delButton.bounds;
    circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((kDelButtonWidth - kDelButtonSurfaceWidth)/2, (kDelButtonWidth - kDelButtonSurfaceWidth)/2, kDelButtonSurfaceWidth, kDelButtonSurfaceWidth)].CGPath;
    [delButton.layer addSublayer:circleLayer];
    
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake((kDelButtonWidth - kDelButtonLineLength)/2, delButton.width/2)];
    [linePath addLineToPoint:CGPointMake(delButton.width - (kDelButtonWidth - kDelButtonLineLength)/2, delButton.width/2)];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.strokeColor = [UIColor colorWithRed:18/255.0f green:193/255.0f blue:232/255.0f alpha:1.0f].CGColor;
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.lineJoin = kCALineJoinRound;
    lineLayer.lineWidth = 3;
    lineLayer.frame = delButton.bounds;
    lineLayer.path = linePath.CGPath;
    [delButton.layer addSublayer:lineLayer];
}
@end

@interface YQEditPhotoContainerView()
@property (nonatomic, strong) NSMutableArray *imageViewFrameArr;
@property (nonatomic, strong) NSMutableArray *imageViewArr;
@property (nonatomic, weak) UIButton *bigAddButton;
@property (nonatomic, weak) UIButton *smallAddButton;
@end

static const CGFloat kBigButtonMAXWidth = 160; // 最大的宽度
static const CGFloat kImageViewMargin = 10; // 照片这件的缝隙

@implementation YQEditPhotoContainerView
{
    CGFloat _imageViewH; // 图片的宽度
    CGFloat _imageViewW;
}

#pragma mark - overwrite
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        self.totalCount = 9; // 默认9
        self.colCount = 3;   // 默认3
        self.hiddenBigAddButton = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat WIDTH = self.width;
    CGFloat HEIGHT = self.height;
    
    if (self.imageArray.count < self.totalCount ) {
        NSValue *rectValue = self.imageViewFrameArr[self.imageArray.count];
        CGRect buttonRect = [rectValue CGRectValue];
        self.smallAddButton.frame = buttonRect;
    }
    
    CGFloat minLen = MIN(WIDTH, HEIGHT); //长或者宽取小，判断kBigButtonMAXWidth会不会超出范围
    if (minLen < kBigButtonMAXWidth) { // 超出了，就选小的
        self.bigAddButton.frame = CGRectMake((WIDTH - minLen)/2 + kImageViewMargin, (HEIGHT - minLen)/2 +kImageViewMargin, minLen - 2 *kImageViewMargin, minLen - 2*kImageViewMargin);
    } else {
        self.bigAddButton.frame = CGRectMake((WIDTH - kBigButtonMAXWidth)/2, (HEIGHT - kBigButtonMAXWidth)/2, kBigButtonMAXWidth, kBigButtonMAXWidth);
    }
    
    [self judgeButtonHidden]; // 判断按钮的隐藏
    
    if (self.imageViewArr.count == 0) return;
    
    int count = 0;
    for (YQImageView *imageView in self.imageViewArr) {
        imageView.frame = [((NSValue *)self.imageViewFrameArr[count ++]) CGRectValue];
    }
}

#warning 如果totalCount和colCount都要设置的话，务必要totalCount先设置，因为frame在colCount的set方法中计算，否则会数组越界而奔溃！
// 在这里计算出各个图片的frame
- (void)setColCount:(NSInteger)colCount
{
    _colCount = colCount;
    
    CGFloat WIDTH = self.width;
    
    _imageViewW = (WIDTH - ((colCount + 1) * kImageViewMargin))/colCount;
    _imageViewH = _imageViewW;
    
    // 需把默认的frame删除
    [self.imageViewFrameArr removeAllObjects];
    
    for (int i = 0; i < self.totalCount; i++) {
        
        int curRow = i / colCount;
        int curCol = i % colCount;
        
        CGFloat x = kImageViewMargin + (kImageViewMargin + _imageViewW) * curCol;
        CGFloat y = kImageViewMargin + (kImageViewMargin + _imageViewH) * curRow;
        
        CGRect imageViewRect = CGRectMake(x, y, _imageViewW, _imageViewH);
        NSValue *value = [NSValue valueWithCGRect:imageViewRect];
        [self.imageViewFrameArr addObject:value];
    }
}

#pragma mark - privite
- (void)setupView
{
    self.backgroundColor = [UIColor grayColor];
    
    UIButton *bigAddButton = [[UIButton alloc] init];
    [bigAddButton setImage:[UIImage imageNamed:@"big_addPhoto"] forState:UIControlStateNormal];
    [bigAddButton addTarget:self action:@selector(addPhotoBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:bigAddButton];
    self.bigAddButton = bigAddButton;
    
    UIButton *smallAddButton = [[UIButton alloc] init];
    [smallAddButton setImage:[UIImage imageNamed:@"small_addPhoto"] forState:UIControlStateNormal];
    [smallAddButton addTarget:self action:@selector(addPhotoBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    smallAddButton.hidden = YES;
    [self addSubview:smallAddButton];
    self.smallAddButton = smallAddButton;
}

- (void)addPhotoBtnDidClick
{
    if (self.addImageBlock) {
        self.addImageBlock(self.imageArray.count);
    }
}

// 判断添加图片按钮隐藏与否
- (void)judgeButtonHidden
{
    if (self.hiddenBigAddButton == YES) { // 大按钮隐藏
        self.bigAddButton.hidden = YES;
        if (self.imageArray.count == self.totalCount) { // 添加后刚好满，那么都隐藏
            self.smallAddButton.hidden = YES;
        } else if (self.imageArray.count == 0) { // 小的隐藏 大的不隐藏
            self.smallAddButton.hidden = NO;
        } else { // 大的隐藏 小的不隐藏
            self.smallAddButton.hidden = NO;
        }
    } else {
        if (self.imageArray.count == self.totalCount) { // 添加后刚好满，那么都隐藏
            self.bigAddButton.hidden = YES;
            self.smallAddButton.hidden = YES;
        } else if (self.imageArray.count == 0) { // 小的隐藏 大的不隐藏
            self.bigAddButton.hidden = NO;
            self.smallAddButton.hidden = YES;
        } else { // 大的隐藏 小的不隐藏
            self.bigAddButton.hidden = YES;
            self.smallAddButton.hidden = NO;
        }
    }
}

- (void)delButtonDidClick:(UIButton *)button
{
    YQImageView *imageView = (YQImageView *)button.superview;
    int i = 0;
    
    for (YQImageView *iv in self.imageViewArr) {
        if (iv == imageView) {
            [imageView removeFromSuperview];
            [self.imageViewArr removeObjectAtIndex:i];
            [self.imageArray removeObjectAtIndex:i];
            imageView = nil;
            break;
        }
        i ++;
    }
}

- (void)delImageViewWithIndex:(NSInteger)index
{
    UIImageView *imageView = self.imageViewArr[index];
    [self.imageViewArr removeObjectAtIndex:index];
    [self.imageArray removeObjectAtIndex:index];
    [imageView removeFromSuperview];
    imageView = nil;
}

- (void)imageViewTap:(UITapGestureRecognizer *)tap
{
    YQImageView *imageView = (YQImageView *)tap.view;
    int index = 0;
    
    for (YQImageView *iv in self.imageViewArr) {
        if (iv == imageView) {
            break;
        }
        index ++;
    }

    YQImageBannerView *banner = [[YQImageBannerView alloc] initWithPhotoArray:self.imageArray currentIndex:index];
    [[UIApplication sharedApplication].keyWindow addSubview:banner];
    [banner show];
    __weak typeof(self) ws = self;
    banner.selectDoneBlock = ^(NSArray *selArray){
        // 需要反着删过来，不然会数组越界
        for (int i = [[NSString stringWithFormat:@"%ld", selArray.count] intValue] - 1; i>=0; i--) {
            NSNumber *selNum = selArray[i];
            if ([selNum isEqualToNumber:@0]) {
                [ws delImageViewWithIndex:i];
            }
        }
    };
}

#pragma mark - public
- (void)addImage:(UIImage *)image
{
    if (self.imageArray.count >= self.totalCount) return; // 如果当前的照片数大于或者等于最多的
    
    [self.imageArray addObject:image]; // 添加image
    
    YQImageView *imageView = [[YQImageView alloc] initWithFrame:CGRectMake(0, 0, _imageViewW, _imageViewH) withTarget:self];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    
    [self.imageViewArr addObject:imageView];
}

- (void)addImageArray:(NSArray *)imageArray
{
    for (UIImage *image in imageArray) {
        if ([image isKindOfClass:[UIImage class]]) {
            [self addImage:image];
        }
    }
}

- (NSArray *)getImageArray
{
    return self.imageArray;
}

#pragma mark - lazy
- (NSMutableArray *)imageArray
{
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (NSMutableArray *)imageViewFrameArr
{
    if (_imageViewFrameArr == nil) {
        _imageViewFrameArr = [NSMutableArray array];
    }
    return _imageViewFrameArr;
}

- (NSMutableArray *)imageViewArr
{
    if (_imageViewArr == nil) {
        _imageViewArr = [NSMutableArray array];
    }
    return _imageViewArr;
}

@end
