//
//  ViewController.m
//  TryGrandCenterDispatch
//
//  Created by Liu on 16/7/6.
//  Copyright © 2016年 Liu. All rights reserved.
//

#import "ViewController.h"
#import "NSOprationController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *goOprationController = [UIButton buttonWithType:UIButtonTypeCustom];
    goOprationController.frame = CGRectMake(100, 100, 100, 40);
    [goOprationController addTarget:self action:@selector(goOC) forControlEvents:UIControlEventTouchUpInside];
    goOprationController.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:goOprationController];
    
    //任务--队列--串行队列--并行队列--同步执行--异步执行
    
    //创建队列
    //dispatch_queue_create(a,b);
    //a=>是一个标识符,用于debug的时候调试使用,推荐使用"com.example.myqueue"方式来命名,可以为NULL
    //b=>是一个用于确定队列类型的参数,为DISPATCH_QUEUE_SERIAL或NULL的时候表示创建串行队列,当设置为DISPATCH_QUEUE_CONCURRENT时是并行队列
    //创建串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create(NULL, NULL);
    dispatch_queue_t serialQueue1 = dispatch_queue_create("com.test.serialqueue", DISPATCH_QUEUE_SERIAL);
    //创建并行队列
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.test.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    
    //特殊队列
    //主队列
    //主队列是一个串行队列,是和程序主线程关联的串行队列,在main() 函数调用之前这个队列便被自动创建了.
    dispatch_queue_t mainqueue = dispatch_get_main_queue();
    //全局队列
    //全局队列是并行队列
    //dispatch_get_global_queue(a,b)
    /*a=>是一个表示创建队列优先级,有 
         DISPATCH_QUEUE_PRIORITY_HIGH(2) 
         DISPATCH_QUEUE_PRIORITY_DEFAULT(0) 
         DISPATCH_QUEUE_PRIORITY_LOW (-2) 
         DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
         四个值可供选择
     */
    //b=>保留的参数,暂时没啥用,填0即可.
    dispatch_queue_t globalqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    
    
    //创建任务
    //创建同步任务
    dispatch_sync(serialQueue, ^{
        NSLog(@"serialQueue -- %@",[NSThread currentThread]);
    });
    dispatch_sync(serialQueue, ^{
        NSLog(@"1serialQueue -- %@",[NSThread currentThread]);
    });
    NSLog(@"out -- %@",[NSThread currentThread]);
 
//下面被注释掉的代码会引起死锁状态,同步执行(sync)会阻塞当前线程(主线程),block会添加到主队列(mainqueue)中,
//但是主队列中的任务会被提取到主线程中去执行,此时主线程已经被阻塞,就此,产生了死锁.
//    dispatch_sync(mainqueue, ^{
//        NSLog(@"main -- %@",[NSThread currentThread]);
//    });
//    NSLog(@"out1 -- %@",[NSThread currentThread]);
  
//下面被注释掉的代码也会引起死锁状态,任务(A)异步提交到串行队列中去,病不会堵塞当前线程(主线程),任务(block)开始执行,
//打印出第一行"serialQueue1 -- <NSThread: 0x7fad02426990>{number = 2, name = (null)}"后在当前线程中同步将另一个任务(B)提交到当前队列
//中,因为同步执行会堵塞当前线程,而当前队列是串行队列,如果队列中任务A不执行完成,那么B无法被从串行队列中去提取出来执行,
//如果B无法执行完,那么线程就一直被堵塞,任务A就永远无法完成,形成死锁.
//    dispatch_async(serialQueue1, ^{
//        NSLog(@"serialQueue1 -- %@",[NSThread currentThread]);
//        dispatch_sync(serialQueue1, ^{
//            NSLog(@"serialQueue1 in -- %@",[NSThread currentThread]);
//        });
//        NSLog(@"serialQueue1 out -- %@",[NSThread currentThread]);
//    });
    
    
    //队列组
    //队列组可以将多个队列添加到一个队列组里,这样做的好处是当队列组里所有队列的任务完成时,队列组会通过一个方法通知我们.
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, serialQueue, ^{
        for (NSInteger i = 0; i<3; i++) {
            NSLog(@"group1 -- %@",[NSThread currentThread]);
        }
    });
    dispatch_group_async(group, dispatch_get_main_queue(), ^{
        for (NSInteger i = 0; i<5; i++) {
            NSLog(@"group2 -- %@",[NSThread currentThread]);
        }
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (NSInteger i = 0; i<3; i++) {
            NSLog(@"group3 -- %@",[NSThread currentThread]);
        }
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"All task is finished!");
    });
    
    
    //dispatch_barrier_async(a,b)
    //a=>是一个队列,这个是重要的参数,只有当这个队列是通过dispat_queue_create()创建,且类型为DISPATCH_QUEUE_CONCURRENT时,
    //添加的任务会堵塞队列(注意,是堵塞队列,不是线程),在这之前添加到该队列的任务先执行,然后执行该任务,执行完成后取消堵塞,后续任务继续执行.
    //需要注意的是,不是说必须是并行队列,而是必须由dispatch_queue_create()创建的队列才会有这种效果,其他串行队列,
    //甚至dispatch_queue_get_global()得到的队列都不会有这个特效,会和普通的dispatch_async一样.
    //b=>添加到队列的任务
    //需要提到的是,dispatch_barrier_sync(a,b),用法和上面差不多,传入通过dispat_queue_create()创建,且类型为DISPATCH_QUEUE_CONCURRENT的队列时,会发生相同的堵塞,但是,它同样会堵塞线程,这就是不同之处.
    dispatch_queue_t barrierConcurrentQueue = dispatch_queue_create("com.liu.test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(barrierConcurrentQueue, ^{
        NSLog(@"barrier-before");
    });
    dispatch_barrier_async(barrierConcurrentQueue, ^{
        NSLog(@"barrier");
    });
    dispatch_async(barrierConcurrentQueue, ^{
        NSLog(@"barrier-after");
    });
    
    NSLog(@"barrier out");
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)goOC {
    NSOprationController *noc = [[NSOprationController alloc] init];
    [self presentViewController:noc animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
