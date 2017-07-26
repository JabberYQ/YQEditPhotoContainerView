# YQEditPhotoContainerView
用于呈现选择的图片的容器

# 代码与效果图：
## a 默认情况
```
    __weak typeof(self) ws = self;
    YQEditPhotoContainerView *cv = [[YQEditPhotoContainerView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    cv.addImageBlock = ^(NSInteger photoCount){
        [ws addImage];
    };
    [self.view addSubview:cv];
```
![NORMAL.gif](http://upload-images.jianshu.io/upload_images/2312304-c8804a1a4d41d454.gif?imageMogr2/auto-orient/strip)

## b 隐藏大按钮
```
    __weak typeof(self) ws = self;
    YQEditPhotoContainerView *cv = [[YQEditPhotoContainerView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    cv.hiddenBigAddButton = YES;
    cv.addImageBlock = ^(NSInteger photoCount){
        [ws addImage];
    };
    [self.view addSubview:cv];
```

![YES_3_9.gif](http://upload-images.jianshu.io/upload_images/2312304-f45816b5ae20a6e3.gif?imageMogr2/auto-orient/strip)


## c 五列 十张
```
    __weak typeof(self) ws = self;
    YQEditPhotoContainerView *cv = [[YQEditPhotoContainerView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 150)];
    cv.totalCount = 10; // 如果要设置totalCount和colCount的话，务必要totalCount先设置，因为frame在colCount的set方法中计算，否则会数组越界而奔溃！
    cv.colCount = 5;
    cv.addImageBlock = ^(NSInteger photoCount){
        [ws addImage];
    };
    [self.view addSubview:cv];
```

![NO_5_10.gif](http://upload-images.jianshu.io/upload_images/2312304-cab66c5f25e74c11.gif?imageMogr2/auto-orient/strip)

# 使用简介
使用起来很简单，只需要通过`` - (instancetype)initWithFrame:(CGRect)frame``方法初始化后添加到控制器的view中就搞定了。通过设置`` addImageBlock``来设置点击添加图片按钮后的操作。

# 公开属性和方法
```
@property (nonatomic, strong) NSMutableArray *imageArray;              ///<  照片数组
@property (nonatomic, assign) NSInteger colCount;                      ///<  有多少列 默认3
@property (nonatomic, assign) NSInteger totalCount;                    ///<  总个数 默认9
@property (nonatomic, assign) BOOL hiddenBigAddButton;                 ///<  隐藏大的添加图片按钮 默认NO
@property (nonatomic, copy) AddImageBlock addImageBlock;               ///<  添加照片block

/**
 添加一张照片
 
 @param image 添加的照片

 */
- (void)addImage:(UIImage *)image;


/**
 添加几张照片
 
 @param imageArray 添加的照片
 
 */
- (void)addImageArray:(NSArray *)imageArray;


/**
 获得当前的照片数组
 
 */
- (NSArray *)getImageArray;
```

# 主要思路
在重写初始化的方法中设置好属性的默认值以及添加初始化按钮。并在``- (void)setColCount:(NSInteger)colCount``方法中通过列数和总数计算出各个imageView的frame并加入到imageViewFrameArr数组中。
每添加一张照片，就初始化一个imageView，每删除一张图片，就把imageView移除父视图。
最后重写`` - (void)layoutSubviews``，在该方法中拿到imageViewFrameArr数组，设置各个imageView和按钮的frame。同时也判断大小按钮是否需要隐藏。

# 注意
其中需要注意的是，如果totalCount和colCount都要设置的话，务必要totalCount先设置，因为imageview的frame是在colCount的set方法中计算的，否则会数组越界而奔溃！

# 博客地址
简书：[自造小轮子：图片展示器](http://www.jianshu.com/p/381945dadf2b)
