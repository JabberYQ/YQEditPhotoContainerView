//
//  NO_5_10.m
//  YQEditPhotoContainerView
//
//  Created by 俞琦 on 2017/7/26.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "NO_5_10.h"
#import "YQEditPhotoContainerView.h"
#import "YQPhotoPickerManager.h"

@interface NO_5_10 ()
@property (nonatomic, weak) YQEditPhotoContainerView *cv;
@end

@implementation NO_5_10

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak typeof(self) ws = self;
    YQEditPhotoContainerView *cv = [[YQEditPhotoContainerView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 150)];
    cv.totalCount = 10; // 如果要设置totalCount和colCount的话，务必要totalCount先设置，因为frame在colCount的set方法中计算，否则会数组越界而奔溃！
    cv.colCount = 5;
    cv.addImageBlock = ^(NSInteger photoCount){
        [ws addImage];
    };
    [self.view addSubview:cv];
    self.cv = cv;
}


- (void)addImage
{
    __weak typeof(self) ws = self;
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"选择一个方式" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[YQPhotoPickerManager shareManager] requestAlbumWithViewController:self success:^(UIImage *image) {
            [ws.cv addImageArray:@[image, image, image]];
        } unauthorized:^{
            
        } willAlert:YES];
        
    }];
    
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[YQPhotoPickerManager shareManager] requestCameraWithViewController:self Success:^(UIImage *image) {
            [ws.cv addImage:image];
        } unauthorized:^{
            
        } willAlert:YES];
        
    }];
    
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertC addAction:action1];
    [alertC addAction:action2];
    [alertC addAction:action3];
    [self presentViewController:alertC animated:YES completion:nil];
}

@end
