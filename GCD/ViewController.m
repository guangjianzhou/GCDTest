//
//  ViewController.m
//  GCD
//
//  Created by zhougj on 15/7/1.
//  Copyright (c) 2015年 iiseeuu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self testGroup];
//    [self testSeriQueue];
    [self testBingxing];
    
}

//串行
//总共时间：等于各个队列只和
- (void)testSeriQueue
{
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t serilQueue = dispatch_queue_create("com.quains.myQueue", 0);
    dispatch_async(serilQueue, ^{
        
        NSString *urlAsString = @"http://pica.nipic.com/2007-11-09/2007119124513598_2.jpg";
        NSURL *url = [NSURL URLWithString:urlAsString];
        
        NSError *downloadError = nil;
        
        NSData *imageData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:nil error:&downloadError];
        
        if (downloadError == nil && imageData != nil) {
            NSLog(@"下载图片1");
        }
        else if(downloadError != nil){
            NSLog(@"error happened = %@", downloadError);
        }
        else{
            NSLog(@"No data download");
        }
    });
    
    dispatch_async(serilQueue, ^{
        sleep(3);
        NSLog(@"下载图片2");
    });
    
    dispatch_async(serilQueue, ^{
        sleep(5);
        NSLog(@"下载图片3");
    });
    
    dispatch_async(serilQueue, ^{
        [weakSelf checkNetStatus:^(BOOL isCan) {
            NSLog(@"4队列完成");
        }];
    });
    
    dispatch_async(serilQueue, ^{
        NSLog(@"完成");
    });
    
}

//分组
//总共时间:最长的那个时间
- (void)testGroup
{
    dispatch_queue_t checkQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t queueGroup = dispatch_group_create();
    __weak typeof(self) weakSelf = self;
    dispatch_group_async(queueGroup, checkQueue, ^{
        [weakSelf checkNetStatus:^(BOOL isCan) {
            NSLog(@"1队列完成");
        }];
    });
    
    dispatch_group_async(queueGroup, checkQueue, ^{
        sleep(1);
        NSLog(@"2队列完成");
    });
    dispatch_group_async(queueGroup, checkQueue, ^{
        NSLog(@"3队列完成");
    });
    
    dispatch_group_notify(queueGroup, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"全部完成");
    });
}

//并行实现串行
- (void)testBingxing
{
    __weak typeof(self) weakSelf = self;
    //新建一个队列
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //加入队列
    dispatch_async(concurrentQueue, ^{
        __block UIImage *image = nil;
        
        //1.先去网上下载图片
        dispatch_sync(concurrentQueue, ^{
            NSString *urlAsString = @"http://avatar.csdn.net/B/2/2/1_u010013695.jpg";
            NSURL *url = [NSURL URLWithString:urlAsString];
            
            NSError *downloadError = nil;
            
            NSData *imageData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:nil error:&downloadError];
            
            if (downloadError == nil && imageData != nil) {
                image = [UIImage imageWithData:imageData];
            }
            else if(downloadError != nil){
                NSLog(@"error happened = %@", downloadError);
            }
            else{
                NSLog(@"No data download");
            }
            NSLog(@"1=============");
        });
        
        dispatch_sync(concurrentQueue, ^{
            [weakSelf checkNetStatus:^(BOOL isCan) {
               NSLog(@"2=============");
            }];

        });
        
        dispatch_sync(concurrentQueue, ^{
            sleep(4);
            NSLog(@"3=============");
        });
        
        //2.在主线程展示到界面里
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"全部完成");
            if (image != nil) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
                [imageView setImage:image];
                
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                [self.view addSubview:imageView];
            }
            else{
                NSLog(@"image isn't downloaded, nothing to display");
            }
        });
    });

}


- (void)checkNetStatus:(void (^)(BOOL))block
{
    dispatch_queue_t queue = dispatch_queue_create("zenny_chen_firstQueue", nil);
    dispatch_async(queue, ^{
        sleep(10);
        block(YES);
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
