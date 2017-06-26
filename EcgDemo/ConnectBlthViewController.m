//
//  ConnectBlthViewController.m
//  XinEBao
//
//  Created by LeMo-test on 17/2/17.
//  Copyright © 2017年 Lemo. All rights reserved.
//
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self //弱饮用

#import "ConnectBlthViewController.h"
#import "DrawrectViewController.h"
#import "BLEServer.h"
#import "UIView+Extension.h"

@interface ConnectBlthViewController ()<BLEServerDelegate>
{
    NSTimer *timer;
    
    CGFloat size;
    BOOL shouldIncrease;
}


@property(nonatomic,strong)UIImageView *animationImg;

@property(nonatomic,strong)UILabel  *animationLabel;

@property(nonatomic,strong)UIImageView *statusImg;


@property(nonatomic,strong)UILabel  *statusLabel;

@property (strong,nonatomic)BLEServer * defaultBLEServer;

@end



@implementation ConnectBlthViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"蓝牙连接";
    size = 30;
    self.defaultBLEServer = [BLEServer defaultBLEServer];
    self.defaultBLEServer.delegate = self;
    [self.defaultBLEServer startScan];
    [self initSubViews];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSLog(@"----%ld",self.defaultBLEServer.myCenter.state);

   timer =  [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(animationAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
    
}

-(void)animationAction
{
    
        if (shouldIncrease == YES) {
            size = size+1;
            if ((int)size == 30) {
                shouldIncrease = NO;
            }
        }
        else
        {
            size = size-1;
            if ((int)size == 18) {
                shouldIncrease = YES;
            }
        }
        
    self.animationImg.size = CGSizeMake(size, size);
    self.animationImg.layer.cornerRadius = size/2;
    self.animationImg.layer.masksToBounds = YES;
    self.animationImg.centerY = self.animationLabel.centerY;
    self.animationImg.centerX = self.animationLabel.x-20-10;
}


#pragma mark -- bleserver delegate
-(void)didStopScan
{

    dispatch_async(dispatch_get_main_queue(), ^{
//        [JRToast showWithText:@"连接失败,请重新尝试"];
//        [weakSelf.navigationController popViewControllerAnimated:YES];
//        NSLog(@"连接失败");
//        self.textInfo.text = @"停止扫描";
    });
}

//发现对应的服务
-(void)didFoundPeripheral
{
   
    WS(weakSelf);
//    dispatch_async(dispatch_get_main_queue(), ^{
    
        for (PeriperalInfo *info in self.defaultBLEServer.discoveredPeripherals) {
            
//            NSLog(@"-设备名称--%@",info.localName);
            if ([info.localName isEqualToString:@"设备名称"]) {
                
                [weakSelf.defaultBLEServer connect:info withFinishCB:^(CBPeripheral *peripheral, BOOL status, NSError *error) {
                    
                    
                }];
                break;
            }
        }
        
        
        
}

-(void)didDisconnect
{
//    [SVProgressHUD dismissWithError:@"断开连接"];
    
}



//连接对应的特征
-(void)connectInfo
{
 
    for (CBService *service in self.defaultBLEServer.selectPeripheral.services) {
//        NSLog(@"设备的id:%@",service.UUID.UUIDString);
        if ([service.UUID.UUIDString isEqualToString:@"特征值"]) {
            [self.defaultBLEServer discoverService:service];
            
            break;
        }        
        
    }
    
}

//匹配到对应的特征值
-(void)didFoundEcgCheck
{
    
    WS(weakSelf);
        [weakSelf.defaultBLEServer stopScan];


        for (CBCharacteristic *ch in self.defaultBLEServer.discoveredSevice.characteristics) {


        if ([ch.UUID.UUIDString isEqualToString:@"对应的特征值"]) {
          
            dispatch_async(dispatch_get_main_queue(), ^{

            [weakSelf.view addSubview:weakSelf.statusLabel];
            [weakSelf.view addSubview:weakSelf.statusImg];
                
            [timer invalidate];
                
            DrawrectViewController *vc = [[DrawrectViewController alloc]init];
            vc.drawrectDuration= weakSelf.drawrectDuration;
            [weakSelf.navigationController pushViewController:vc animated:YES];
            [weakSelf.defaultBLEServer notifyValue:ch];
            [weakSelf.defaultBLEServer readValue:ch];
                
            });
            break;
        }

    }

}



#pragma mark lazyLoad

-(void)initSubViews
{
    self.animationLabel.size = CGSizeMake(100, 30);
    self.animationLabel.centerX = self.view.centerX+22.5;
    self.animationLabel.y = [UIScreen mainScreen].bounds.size.height-64-120-30;
    
    self.animationImg.centerX = self.animationLabel.x-15;
    self.animationImg.centerY = self.animationLabel.centerY;
    self.animationImg.size = CGSizeMake(size, size);
    
    self.statusLabel.size = CGSizeMake(100, 30);
    self.statusLabel.centerX =self.view.centerX;
    self.statusLabel.y = [UIScreen mainScreen].bounds.size.height-64-120-30-40;
    
    self.statusImg.centerX = self.statusLabel.x-15;
    self.statusImg.centerY = self.statusLabel.centerY;
    self.statusImg.size = CGSizeMake(size, size);

    

    

}


-(UIImageView *)animationImg
{
    if (!_animationImg) {
        _animationImg = [[UIImageView alloc]init];
        _animationImg.backgroundColor = [UIColor orangeColor];
        _animationImg.layer.masksToBounds = YES;
        _animationImg.layer.cornerRadius = size/2;
        [self.view addSubview:_animationImg];
    }
    return _animationImg;
    
}
-(UILabel *)animationLabel
{
    if (!_animationLabel) {
        _animationLabel = [[UILabel alloc]init];
        _animationLabel.text = @"等待监测仪...";
        _animationLabel.font = [UIFont systemFontOfSize:16];
        _animationLabel.textColor = [UIColor orangeColor];
        
        [self.view addSubview:_animationLabel];
    }
    return _animationLabel;
}
-(UIImageView *)statusImg
{
    if (!_statusImg) {
        _statusImg = [[UIImageView alloc]init];
        _statusImg.backgroundColor = [UIColor greenColor];
        _statusImg.layer.masksToBounds = YES;
        _statusImg.layer.cornerRadius = size/2;
//        [self.view addSubview:_statusImg];
    }
    return _statusImg;
}

-(UILabel *)statusLabel
{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc]init];
        _statusLabel.text = @"已连接到监测仪";
        _statusLabel.font = [UIFont systemFontOfSize:16];
        _statusLabel.textColor = [UIColor orangeColor];
        
//        [self.view addSubview:_statusLabel];
    }
    return _statusLabel;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    
    [timer invalidate];
    timer = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
