//
//  ViewController.m
//  CDPReplayDemo
//
//  Created by CDP on 2017/3/20.
//  Copyright © 2017年 CDP. All rights reserved.
//

#import "ViewController.h"


#import "CDPReplay.h"


@interface ViewController () <CDPReplayDelegate,UITableViewDataSource> {
    UIButton *_startBt;
    UIButton *_endBt;
    
    NSMutableArray *_dataArr;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    //创建数据
    [self createData];
    
    //创建UI
    [self createUI];
    
    //设置代理(可选)
    [CDPReplay sharedReplay].delegate=self;
}

#pragma mark - 创建数据和UI
//创建数据
-(void)createData{
    _dataArr=[[NSMutableArray alloc] init];
    
    for (NSInteger i=0;i<130;i++) {
        NSString *str=[NSString stringWithFormat:@"CDPReplay测试数据%ld",(long)i];
        [_dataArr addObject:str];
    }
}
//创建UI
-(void)createUI{
    UITableView *tableView=[[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    tableView.showsHorizontalScrollIndicator=NO;
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor=[UIColor whiteColor];
    tableView.dataSource=self;
    [self.view addSubview:tableView];
    
    _startBt=[[UIButton alloc] initWithFrame:CGRectMake(0,100,80,50)];
    _startBt.backgroundColor=[UIColor redColor];
    [_startBt setTitle:@"开始录制" forState:UIControlStateNormal];
    _startBt.titleLabel.font=[UIFont systemFontOfSize:14];
    [_startBt addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startBt];
    
    _endBt=[[UIButton alloc] initWithFrame:CGRectMake(0,200,80,50)];
    _endBt.backgroundColor=[UIColor redColor];
    [_endBt setTitle:@"结束录制" forState:UIControlStateNormal];
    _endBt.titleLabel.font=[UIFont systemFontOfSize:14];
    [_endBt addTarget:self action:@selector(end) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_endBt];
}
#pragma mark - tableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text=(indexPath.row<_dataArr.count)?_dataArr[indexPath.row]:@"妈卖批...";
    
    return cell;
}
#pragma mark - 点击事件
//开始录制
-(void)start{
    [[CDPReplay sharedReplay] startRecord];
    
    [_startBt setTitle:@"初始化中" forState:UIControlStateNormal];
}
//结束录制
-(void)end{
    [[CDPReplay sharedReplay] stopRecordAndShowVideoPreviewController:YES];
    
    [_startBt setTitle:@"开始录制" forState:UIControlStateNormal];
}
#pragma mark - CDPReplayDelegate代理
/**
 *  开始录制回调
 */
-(void)replayRecordStart{
    NSLog(@"~~~~开始录制");
    [_startBt setTitle:@"正在录制" forState:UIControlStateNormal];
}

/**
 *  录制结束或错误回调
 */
-(void)replayRecordFinishWithVC:(RPPreviewViewController *)previewViewController errorInfo:(NSString *)errorInfo{
    
    NSLog(@"~~~~录制结束~~~错误信息(正常则无错误):%@",errorInfo);
    
}
/**
 *  保存到系统相册成功回调
 */
-(void)saveSuccess{
    NSLog(@"~~~~保存到系统相册成功");
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
