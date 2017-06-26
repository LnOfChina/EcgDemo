//
//  ViewController.m
//  EcgDemo
//
//  Created by LeMo-test on 2017/6/26.
//  Copyright © 2017年 李宁. All rights reserved.
//

#import "ViewController.h"
#import "BLEServer.h"
#import "JRToast.h"
#import "ConnectBlthViewController.h"
@interface ViewController ()

@property (strong,nonatomic)BLEServer * defaultBLEServer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.defaultBLEServer = [BLEServer defaultBLEServer];
    [self.defaultBLEServer startScan];
    
    
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    
    btn.frame = CGRectMake(100, 100, 100, 40);
    
    [btn setTitle:@"开始测试" forState:(UIControlStateNormal)];
    
    [btn addTarget:self action:@selector(beginTestAction) forControlEvents:(UIControlEventTouchUpInside)];
    
    [btn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    
    [self.view addSubview:btn];
    
    
    
}
-(void)beginTestAction
{
    if (self.defaultBLEServer.myCenter.state ==4) {
        [JRToast showWithText:@"请先开启蓝牙再开始监测" duration:2.0f];
        return;
    }
    else
    {
        ConnectBlthViewController *vc = [[ConnectBlthViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        [UIApplication sharedApplication].delegate.window.rootViewController = nav;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
