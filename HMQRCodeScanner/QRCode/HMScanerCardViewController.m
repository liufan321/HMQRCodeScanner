//
//  HMScanerCardViewController.m
//  HMQRCodeScanner
//
//  Created by 刘凡 on 16/1/3.
//  Copyright © 2016年 itheima. All rights reserved.
//

#import "HMScanerCardViewController.h"
#import "HMScanner.h"

@interface HMScanerCardViewController()
/// 名片字符串
@property (nonatomic) NSString *cardName;
/// 头像图片
@property (nonatomic) UIImage *avatar;
@end

@implementation HMScanerCardViewController {
    UIImageView *cardImageView;
    UIBarButtonItem *downloadButton;
}

#pragma mark - 构造函数
- (instancetype)initWithCardName:(NSString *)cardName avatar:(UIImage *)avatar {
    self = [super init];
    if (self) {
        self.cardName = cardName;
        self.avatar = avatar;
    }
    return self;
}

#pragma mark - 设置界面
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self prepareNavigationBar];
    
    CGFloat width = self.view.bounds.size.width - 80;
    cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    cardImageView.center = self.view.center;
    
    [self.view addSubview:cardImageView];
    
    [HMScanner qrImageWithString:self.cardName avatar:self.avatar completion:^(UIImage *image) {
        cardImageView.image = image;
    }];
}

/// 准备导航栏
- (void)prepareNavigationBar {
    // 1> 背景图片
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    // 2> 标题
    self.title = @"我的名片";
    
    // 3> 加个下载图片按钮
    downloadButton = [[UIBarButtonItem alloc]initWithTitle:@"下载" style:UIBarButtonItemStyleBordered target:self action:@selector(downloadImage)];
    self.navigationItem.rightBarButtonItem = downloadButton;
}

// 下载图片到用户相册
-(void)downloadImage {
    UIImageWriteToSavedPhotosAlbum(cardImageView.image, self, nil, nil);
    [downloadButton setTitle:@"已下载"];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

@end
