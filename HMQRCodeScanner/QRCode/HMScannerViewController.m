//
//  HMScannerViewController.m
//  HMQRCodeScanner
//
//  Created by 刘凡 on 16/1/2.
//  Copyright © 2016年 itheima. All rights reserved.
//

#import "HMScannerViewController.h"
#import "HMScanerCardViewController.h"
#import "HMScannerBorder.h"
#import "HMScannerMaskView.h"
#import "HMScanner.h"
#import <AVFoundation/AVFoundation.h>

/// 控件间距
#define kControlMargin  32.0
/// 相册图片最大尺寸
#define kImageMaxSize   CGSizeMake(1000, 1000)

@interface HMScannerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
/// 名片字符串
@property (nonatomic) NSString *cardName;
/// 头像图片
@property (nonatomic) UIImage *avatar;
@property (nonatomic, strong) UIButton *cardButton;
@property (nonatomic, strong) UIButton *flashLightButton;

/// 完成回调
@property (nonatomic, copy) void (^completionCallBack)(NSString *);
@end

@implementation HMScannerViewController {
    /// 扫描框
    HMScannerBorder *scannerBorder;
    /// 扫描器
    HMScanner *scanner;
    /// 提示标签
    UILabel *tipLabel;
}

- (instancetype)initWithCardName:(NSString *)cardName avatar:(UIImage *)avatar completion:(void (^)(NSString *))completion {
    self = [super init];
    if (self) {
        self.cardName = cardName;
        self.avatar = avatar;
        self.completionCallBack = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    
    // 实例化扫描器
    __weak typeof(self) weakSelf = self;
    scanner = [HMScanner scanerWithView:self.view scanFrame:scannerBorder.frame completion:^(NSString *stringValue) {
        // 完成回调
        weakSelf.completionCallBack(stringValue);
        
        // 关闭
        [weakSelf clickCloseButton];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [scannerBorder startScannerAnimating];
    [scanner startScan];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [scannerBorder stopScannerAnimating];
    [scanner stopScan];
}


#pragma mark - 监听方法
/// 点击关闭按钮
- (void)clickCloseButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// 点击相册按钮
- (void)clickAlbumButton {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        tipLabel.text = @"无法访问相册";
        
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.view.backgroundColor = [UIColor whiteColor];
    picker.delegate = self;
    
    [self showDetailViewController:picker sender:nil];
}

/// 点击名片按钮
- (void)clickCardButton {
    HMScanerCardViewController *vc = [[HMScanerCardViewController alloc] initWithCardName:self.cardName avatar:self.avatar];
    
    [self showViewController:vc sender:nil];
}

- (void)modifyFlashLight:(UIButton *)sender {
    [sender setSelected:[self modifyFlashLight]];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [self resizeImage:info[UIImagePickerControllerOriginalImage]];
    
    // 扫描图像
    [HMScanner scaneImage:image completion:^(NSArray *values) {
        
        if (values.count > 0) {
            self.completionCallBack(values.firstObject);
            [self dismissViewControllerAnimated:NO completion:^{
                [self clickCloseButton];
            }];
        } else {
            tipLabel.text = @"没有识别到二维码，请选择其他照片";
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image {
    
    if (image.size.width < kImageMaxSize.width && image.size.height < kImageMaxSize.height) {
        return image;
    }
    
    CGFloat xScale = kImageMaxSize.width / image.size.width;
    CGFloat yScale = kImageMaxSize.height / image.size.height;
    CGFloat scale = MIN(xScale, yScale);
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

#pragma mark - 设置界面
- (void)prepareUI {
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self prepareNavigationBar];
    [self prepareScanerBorder];
    [self prepareOtherControls];
}

/// 准备提示标签和名片按钮
- (void)prepareOtherControls {
    
    // 1> 提示标签
    tipLabel = [[UILabel alloc] init];
    
    tipLabel.text = @"将二维码/条码放入框中，即可自动扫描";
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    
    [tipLabel sizeToFit];
    tipLabel.center = CGPointMake(scannerBorder.center.x, CGRectGetMaxY(scannerBorder.frame) + kControlMargin);
    
    [self.view addSubview:tipLabel];
    
    // 2> 名片按钮
    self.cardButton = [[UIButton alloc] init];
    
    [self.cardButton setTitle:@"我的名片" forState:UIControlStateNormal];
    self.cardButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.cardButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
    
    [self.cardButton sizeToFit];
    self.cardButton.center = CGPointMake(tipLabel.center.x, CGRectGetMaxY(tipLabel.frame) + kControlMargin);
    
    [self.view addSubview:self.cardButton];
    [self.cardButton addTarget:self action:@selector(clickCardButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.flashLightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flashLightButton setFrame:CGRectMake((scannerBorder.frame.size.width-40)/2, scannerBorder.frame.size.height-60, 40, 40)];
    [self.flashLightButton setImage:[self imageWithName:@"flashlight-off" bundle:@"HMScanner"]
                      forState:UIControlStateNormal];
    [self.flashLightButton setImage:[self imageWithName:@"flashlight-on" bundle:@"HMScanner"] forState:UIControlStateSelected];
    [scannerBorder addSubview:self.flashLightButton];
    [self.flashLightButton addTarget:self action:@selector(modifyFlashLight:) forControlEvents:UIControlEventTouchUpInside];
    [self.cardButton setHidden:self.hideCardButton];
    [self.flashLightButton setHidden:self.hideLightButton];
}

/// 准备扫描框
- (void)prepareScanerBorder {
    
    CGFloat width = self.view.bounds.size.width - 80;
    scannerBorder = [[HMScannerBorder alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    
    scannerBorder.center = self.view.center;
    scannerBorder.tintColor = self.navigationController.navigationBar.tintColor;
    
    [self.view addSubview:scannerBorder];
    
    HMScannerMaskView *maskView = [HMScannerMaskView maskViewWithFrame:self.view.bounds cropRect:scannerBorder.frame];
    [self.view insertSubview:maskView atIndex:0];
}

/// 准备导航栏
- (void)prepareNavigationBar {
    // 1> 背景颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    // 2> 标题
    self.title = @"扫一扫";
    
    // 3> 左右按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(clickCloseButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(clickAlbumButton)];
}

#pragma mark - 封装处理

- (UIImage *)imageWithName:(NSString *)imageName bundle:(NSString *)bundleName {
    ///https://github.com/20120608/QM_HMQRCodeScanner
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:bundleName withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    NSString *fileName = [NSString stringWithFormat:@"%@@2x", imageName];
    NSString *path = [imageBundle pathForResource:fileName ofType:@"png"];
    return [[UIImage imageWithContentsOfFile:path] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (BOOL)modifyFlashLight {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //修改前必须先锁定
    [device lockForConfiguration:nil];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    BOOL isopen = false;
    if ([device hasFlash]) {
        if (device.flashMode == AVCaptureFlashModeOff) {
            device.flashMode = AVCaptureFlashModeOn;
            device.torchMode = AVCaptureTorchModeOn;
            isopen = true;
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeOff;
            device.torchMode = AVCaptureTorchModeOff;
            isopen = false;
        }
    }
    [device unlockForConfiguration];
    return isopen;
}


@end
