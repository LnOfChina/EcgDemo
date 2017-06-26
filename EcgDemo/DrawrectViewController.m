//
//  DrawrectViewController.m
//  XinEBao
//
//  Created by LeMo-test on 17/2/10.
//  Copyright © 2017年 Lemo. All rights reserved.
//
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self //弱引用

#import "DrawrectViewController.h"
#import "HeartLive.h"
#import "BLEServer.h"
#import "UIView+Extension.h"
#import "JRToast.h"
@interface DrawrectViewController ()<BLEServerDelegate>
{
    NSTimer *timer;
    //剩余时间进度条
    UIProgressView  *progressView;
    CGFloat progressValue;

    CGFloat reduceIndex;
    NSInteger duration;
    
    CGFloat xCoordinateInMoniter;
    CGPoint targetPointToAdd;
    CGFloat postxCoordinateInMoniter;
    CGPoint postTargetPointToAdd;

    
}

@property (nonatomic,strong)UIScrollView *ecgScrollView;

@property (nonatomic , strong) NSMutableData *postTheData;

@property (nonatomic,strong)NSString *ecgDataUrl;

//绘制心电图
@property (nonatomic , strong) HeartLive *translationMoniterView;

@property(nonatomic,strong)PointContainer *transContainer;


@property(nonatomic,strong)NSMutableArray *postArray;

//连接好蓝牙后心电图绘制View
@property(nonatomic,strong)UIView *drawEcgView;
//蓝牙连接View
@property(nonatomic,strong)UIView *connectBluTeethView;
/**
 显示剩余时间label
 */
@property(nonatomic,strong)UILabel  *timeLabel;


@property (strong,nonatomic)BLEServer * defaultBLEServer;


@property(nonatomic,strong)UIImageView  *iconImg;

@property(nonatomic,strong)UILabel  *tipLabel;


@property (nonatomic ,strong)dispatch_source_t timer;//  注意:此处应该使用强引用 strong


@end

@implementation DrawrectViewController

#pragma mark LazyLoad


-(PointContainer *)transContainer
{
    if (!_transContainer) {
        _transContainer = [PointContainer sharedContainer];
    }
    return _transContainer;
}

-(UIScrollView *)ecgScrollView
{
    if (!_ecgScrollView) {
        _ecgScrollView = [[UIScrollView alloc]initWithFrame:(CGRectMake(0, 10+3+10+30+20+20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-10-3-10-30-20-20-60))];
        _ecgScrollView.contentSize = self.translationMoniterView.size;
        _ecgScrollView.bounces = NO;
        _ecgScrollView.contentOffset = CGPointMake(0, 0);
    }
    return _ecgScrollView;
}

-(NSMutableData *)postTheData
{
    if (!_postTheData) {
        _postTheData = [NSMutableData new];
    }
    return _postTheData;
}
-(UIImageView *)iconImg
{
    if (!_iconImg) {
        _iconImg = [[UIImageView alloc]init];
//        _iconImg.backgroundColor = kAppThemeColor;
        _iconImg.layer.masksToBounds = YES;
        _iconImg.contentMode = UIViewContentModeScaleAspectFill;
        _iconImg.image = [UIImage imageNamed:@"监测稳定icon"];
        [self.drawEcgView addSubview:_iconImg];
    }
    return _iconImg;
}
-(UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.textColor = [UIColor blackColor];
        _tipLabel.text = @"监测仪已稳定";
        _tipLabel.font = [UIFont systemFontOfSize:18];
        [self.drawEcgView addSubview:_tipLabel];
    }
    return _tipLabel;
}
-(NSMutableArray *)postArray
{
    if (!_postArray ) {
        _postArray = [NSMutableArray new];
    }
    return _postArray;
}

-(UIView *)connectBluTeethView
{
    if (!_connectBluTeethView) {
        _connectBluTeethView    = [[UIView alloc]initWithFrame:self.view.bounds];
        _connectBluTeethView.backgroundColor = [UIColor lightGrayColor];
    }
    return _connectBluTeethView;
}

-(UIView *)drawEcgView
{
    if (!_drawEcgView) {
        _drawEcgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _drawEcgView.backgroundColor = [UIColor lightGrayColor];
        [_drawEcgView addSubview:self.translationMoniterView];
    }
    return _drawEcgView;
}

-(HeartLive *)translationMoniterView
{
    if (!_translationMoniterView) {
        _translationMoniterView = [[HeartLive alloc] init];

        _translationMoniterView.frame =CGRectMake(0, 10+3+10+30+20+20, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-10-3-10-30-20-20-60);
        _translationMoniterView.startIndex = 0;


    }
    return _translationMoniterView;
}



-(UILabel *)timeLabel
{
    if (!_timeLabel ) {
        _timeLabel = [[UILabel alloc]initWithFrame:(CGRectMake([UIScreen mainScreen].bounds.size.width/2-100/2, 30+20, 100, 30))];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor darkTextColor ];
        _timeLabel.text = [NSString stringWithFormat:@"%ld秒剩余",duration];
        _timeLabel.font = [UIFont systemFontOfSize:18];
    }
    return _timeLabel;
}


#pragma mark self.view

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
   
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"心电图";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    xCoordinateInMoniter = 0.0f;
    postxCoordinateInMoniter = 0.0f;

/***************************     蓝牙相关       ************************************/
    
    
    self.defaultBLEServer = [BLEServer defaultBLEServer];
    self.defaultBLEServer.delegate = self;
    
    
/***************************     蓝牙相关       ************************************/
    
    
    [self.dataSource removeAllObjects];
    [self.postArray removeAllObjects];
    
/***************************     绘制心电图相关       ************************************/

    

    
    //  连接到蓝牙后开始绘制,加载绘制心电图View
    [self.view addSubview:self.drawEcgView];
    [self.drawEcgView addSubview:self.timeLabel];
    
    
    //剩余时间定时器
    [self createReduceTime];
    //添加进度条
    [self addSubViewS];
/***************************     绘制心电图相关       ************************************/

}

/***************************     蓝牙相关       ************************************/

-(void)didDisconnect
{
    
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ( duration!=0) {
            [timer invalidate];
            timer = nil;
            weakSelf.translationMoniterView.x = 0;
            [JRToast showWithText:@"连接已断开"];
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }
    });
}

#pragma mark 读取数据
-(void)didReadvalue
{
    WS(weakSelf);
    //接收到数据进行格式处理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *d = [[NSData alloc]init];
        d = weakSelf.defaultBLEServer.selectCharacteristic.value;
    
        [weakSelf.dataSource addObject:d];

        Byte *bytes = (Byte *)[d bytes];
    
        
        [weakSelf.postTheData appendData:d];
        
        NSString *shortString;
        for (int i = 0; i<d.length/2; i++) {
            
                shortString  = [NSString stringWithFormat:@"%d",(short)(((bytes [i*2+1] & 0xff) << 8) | (bytes [i*2] & 0xff))];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    [weakSelf timerTranslationFun:shortString];
                    
                });
            
           

        }
        
    });

        
}


/***************************     蓝牙相关       ************************************/




/***************************     绘制心电图相关       ************************************/

-(void)addSubViewS
{
    progressView= [[UIProgressView alloc]initWithFrame:(CGRectMake(40, 10+20+10, [UIScreen mainScreen].bounds.size.width-80, 3))];
    progressView.progressTintColor = [UIColor orangeColor];
    progressView.progressViewStyle = UIProgressViewStyleDefault;
    [self.drawEcgView addSubview:progressView];

    self.iconImg.x = ( [UIScreen mainScreen].bounds.size.width-170)/2;
    self.iconImg.y = self.drawEcgView.height-15-30;
    self.iconImg.size = CGSizeMake(30, 30);
    self.tipLabel.size = CGSizeMake(130, 30);
    self.tipLabel.y = self.drawEcgView.height-15-30;
    self.tipLabel.x = self.iconImg.x+30+10;
    
}
#pragma mark 定时器
-(void)createReduceTime
{
   timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop  mainRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
    
    
    
    
    
    
    //创建显示进度条的定时器
    
    //0.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t progressTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(progressTimer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);

    dispatch_source_set_event_handler(progressTimer, ^{
        progressValue = progressValue+1.0000/(reduceIndex*10);

        dispatch_async(dispatch_get_main_queue(), ^{
            progressView.progress = progressValue;

        });

        
//        NSLog(@"GCD-----%@",[NSThread currentThread]);
    });
  
    dispatch_resume(progressTimer);

    self.timer = progressTimer;
    
}


-(void)timerAction:(NSTimer *)sender
{
    duration = duration-1;
    self.timeLabel.text = [NSString stringWithFormat:@"%ld秒剩余",duration];
    if (duration == 0) {
        [self.defaultBLEServer disConnect];
        
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark 绘图
//平移方式绘制
- (void)timerTranslationFun:(NSString *)string
{
    WS(weakSelf);
    
        [weakSelf.transContainer addPointAsTranslationChangeform:[weakSelf bubbleTranslationPoint:string]];

dispatch_async(dispatch_get_main_queue(), ^{
    
    [weakSelf.translationMoniterView fireDrawingWithPoints:[weakSelf.transContainer translationPointContainer] pointsCount:[weakSelf.transContainer numberOfTranslationElements]];
});


}
- (CGPoint)bubbleTranslationPoint:(NSString *)string
{
    
    WS(weakSelf);
    xCoordinateInMoniter = xCoordinateInMoniter+0.63;
    
    targetPointToAdd= (CGPoint){xCoordinateInMoniter,(0.5f+145.13*([string floatValue]-3420.0f)/(2000.0f*self.translationMoniterView.height))*self.translationMoniterView.height-50};
    dispatch_async(dispatch_get_main_queue(), ^{

    if (xCoordinateInMoniter >=  [UIScreen mainScreen].bounds.size.width-1) {

        self.translationMoniterView.x = self.translationMoniterView.x-0.63;
        
        weakSelf.translationMoniterView.width+=0.63;
    }
    
      });

    return targetPointToAdd;

}
/***************************     绘制心电图相关       ************************************/



-(void)dealloc
{
    [timer invalidate];
    timer = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
