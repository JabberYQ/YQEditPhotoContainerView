//
//  YQEditPhotoContainerView.h
//  YQImageExhibition
//
//  Created by 俞琦 on 2017/7/25.
//  Copyright © 2017年 俞琦. All rights reserved.
//  这是一个可以加减照片的照片容器

#import <UIKit/UIKit.h>

typedef void (^AddImageBlock)(NSInteger photoCount);

@interface YQEditPhotoContainerView : UIView
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
@end
