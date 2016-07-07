//
//  NSOprationController.m
//  TryGrandCenterDispatch
//
//  Created by Liu on 16/7/7.
//  Copyright © 2016年 Liu. All rights reserved.
//

#import "NSOprationController.h"

@interface NSOprationController ()

@end

@implementation NSOprationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //NSOperation 用来封装任务对象
    //NSOperationQueue 任务队列对象
    //NSOperation只是一个抽象类,不能直接封装任务,可以使用其两个子类:NSInvocationOperation和NSBlockOperation来封装任务,使用start方法启动任务
    //它会默认在当前队列同步执行,默认在当前线程执行
    
    //NSInvocationOperation
    NSInvocationOperation *iop = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(testIop:) object:@1];
    [iop start];
    
    //NSBlockOperation
    NSBlockOperation *bop = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"def--%@",[NSThread currentThread]);
    }];
    //这个方法添加的任务后,bop中任务会在当前线程和其他线程并发执行
    //NOTE：addExecutionBlock 方法必须在 start() 方法之前执行，否则就会报错：
    [bop addExecutionBlock:^{
        NSLog(@"ghi--%@",[NSThread currentThread]);
//        [NSThread sleepForTimeInterval:1];
    }];
    [bop start];
    
    /*
     2016-07-07 10:27:33.608 TryGrandCenterDispatch[5453:277247] abc:1--<NSThread: 0x7fe441c05a40>{number = 1, name = main}
     2016-07-07 10:27:33.609 TryGrandCenterDispatch[5453:277247] def--<NSThread: 0x7fe441c05a40>{number = 1, name = main}
     2016-07-07 10:27:33.609 TryGrandCenterDispatch[5453:277423] ghi--<NSThread: 0x7fe441d54d10>{number = 4, name = (null)}
     */
    
    //自定义
    /*
     除了上面的两种 Operation 以外，我们还可以自定义 Operation。自定义 Operation 需要继承 NSOperation 类，并实现其 main() 方法，因为在调用 start() 方法的时候，内部会调用 main() 方法完成相关逻辑。所以如果以上的两个类无法满足你的欲望的时候，你就需要自定义了。你想要实现什么功能都可以写在里面。除此之外，你还需要实现 cancel() 在内的各种方法。所以这个功能提供给高级玩家，我在这里就不说了，等我需要用到时在研究它，到时候可能会再做更新。
     
     文／伯恩的遗产（简书作者）
     原文链接：http://www.jianshu.com/p/0b0d9b1f1f19
     著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。
     */
    
    //创建队列
    //上面说的这些是默认同步执行,即使有addExecutionBlock这个方法,也是在当前线程和其他线程执行,也就是说,会阻塞当前线程.这时就是使用NSOperationQueue了,而且,按类型的话一共就两种类型:主队列,其他队列.
    //只要添加到队列中,就会自动启动任务的start()方法.
    //主队列,添加到主队列的任务都会一个接着一个排队在主线程处理.
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    /*
     因为主队列比较特殊，所以会单独有一个类方法来获得主队列。那么通过初始化产生的队列就是其他队列了，因为只有这两种队列，除了主队列，其他队列就不需要名字了。
     
     注意：其他队列的任务会在其他线程并行执行。
     */
    
    //1.创建一个其他队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //2.创建NSBlockOperation对象
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@", [NSThread currentThread]);
    }];
    
    //3.添加多个Block
    for (NSInteger i = 0; i < 5; i++) {
        [operation addExecutionBlock:^{
            NSLog(@"第%ld次：%@", i, [NSThread currentThread]);
        }];
    }
    
    //4.队列添加任务
    [queue addOperation:operation];
    [queue addOperationWithBlock:^{
        //...
    }];
    
    
    
    
    /*三种多线程实现方式,NSThread,NSOperation,GCD
     该评价选自http://blog.csdn.net/charles91/article/details/50542940;
     
     三种方式的优缺点介绍:
     1）NSThread
     优点：NSThread 比其他两个轻量级
     缺点：需要自己管理线程的生命周期，线程同步。线程同步对数据的加锁会有一定的系统开销
     
     2）Cocoa  NSOperation
     优点:不需要关心线程管理， 数据同步的事情，可以把精力放在自己需要执行的操作上。
     Cocoa operation相关的类是NSOperation, NSOperationQueue.
     NSOperation是个抽象类,使用它必须用它的子类，可以实现它或者使用它定义好的两个子类: NSInvocationOperation和NSBlockOperation.
     创建NSOperation子类的对象，把对象添加到NSOperationQueue队列里执行。
     
     3) GCD(全优点)
     Grand Central dispatch(GCD)是Apple开发的一个多核编程的解决方案。在iOS4.0开始之后才能使用。GCD是一个替代NSThread, NSOperationQueue,NSInvocationOperation等技术的很高效强大的技术。
     */
    
    // Do any additional setup after loading the view.
}

- (void)testIop:(id)sender {
    NSLog(@"abc:%@--%@",sender,[NSThread currentThread]);
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
