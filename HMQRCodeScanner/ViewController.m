//
//  ViewController.m
//  HMQRCodeScanner
//
//  Created by 刘凡 on 16/1/2.
//  Copyright © 2016年 itheima. All rights reserved.
//

#import "ViewController.h"
#import "HMScannerController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *scanResultLabel;
@end

@implementation ViewController

- (IBAction)clickScanButton:(id)sender {
    
    NSString *cardName = @"天涯刀哥 - 傅红雪";
    UIImage *avatar = [UIImage imageNamed:@"avatar"];
    
    HMScannerController *scanner = [HMScannerController scannerWithCardName:cardName avatar:avatar completion:^(NSString *stringValue) {
        
        self.scanResultLabel.text = stringValue;
    }];
    
    [scanner setTitleColor:[UIColor whiteColor] tintColor:[UIColor greenColor]];
    
    [self showDetailViewController:scanner sender:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *cardName = @"天涯刀哥 - 傅红雪";
    UIImage *avatar = [UIImage imageNamed:@"avatar"];
    
    [HMScannerController cardImageWithCardName:cardName avatar:avatar scale:0.2 completion:^(UIImage *image) {
        self.imageView.image = image;
    }];
}

@end
