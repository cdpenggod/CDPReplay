//
//  CDPReplay.m
//
//  Created by CDP on 16/11/9.
//  Copyright © 2016年 CDP. All rights reserved.
//

#import "CDPReplay.h"

#ifdef DEBUG
#    define CDPLog(fmt,...) NSLog(fmt,##__VA_ARGS__)
#else
#    define CDPLog(fmt,...) /* */
#endif


@interface CDPReplay () <RPPreviewViewControllerDelegate>

@end

@implementation CDPReplay

//单例化对象
+(instancetype)sharedReplay{
    static CDPReplay *replay=nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        replay=[[CDPReplay alloc] init];
    });
    return replay;
}
//是否正在录制
-(BOOL)isRecording{
    return [RPScreenRecorder sharedRecorder].recording;
}
#pragma mark - 开始/结束录制
//开始录制
-(void)startRecord{
    if ([RPScreenRecorder sharedRecorder].recording==YES) {
        CDPLog(@"CDPReplay:已经开始录制");
        return;
    }
    if ([self systemVersionOK]) {
        if ([[RPScreenRecorder sharedRecorder] isAvailable]) {
            CDPLog(@"CDPReplay:录制开始初始化");
            
            [[RPScreenRecorder sharedRecorder] startRecordingWithMicrophoneEnabled:YES handler:^(NSError *error){
                if (error) {
                    CDPLog(@"CDPReplay:开始录制error %@",error);
                    if ([_delegate respondsToSelector:@selector(replayRecordFinishWithVC:errorInfo:)]) {
                        [_delegate replayRecordFinishWithVC:nil errorInfo:[NSString stringWithFormat:@"CDPReplay:开始录制error %@",error]];
                    }
                }
                else{
                    CDPLog(@"CDPReplay:开始录制");
                    if ([_delegate respondsToSelector:@selector(replayRecordStart)]) {
                        [_delegate replayRecordStart];
                    }
                }
            }];
        }
        else {
            CDPLog(@"CDPReplay:环境不支持ReplayKit录制");
            if ([_delegate respondsToSelector:@selector(replayRecordFinishWithVC:errorInfo:)]) {
                [_delegate replayRecordFinishWithVC:nil errorInfo:@"CDPReplay:环境不支持ReplayKit录制"];
            }
        }
    }
    else{
        CDPLog(@"CDPReplay:系统版本需要是iOS9.0及以上才支持ReplayKit录制");
        if ([_delegate respondsToSelector:@selector(replayRecordFinishWithVC:errorInfo:)]) {
            [_delegate replayRecordFinishWithVC:nil errorInfo:@"CDPReplay:系统版本需要是iOS9.0及以上才支持ReplayKit录制"];
        }
    }
}
//结束录制
-(void)stopRecordAndShowVideoPreviewController:(BOOL)isShow{
    CDPLog(@"CDPReplay:正在结束录制");
    [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController *previewViewController, NSError *  error){
        if (error) {
            CDPLog(@"CDPReplay:结束录制error %@", error);
            if ([_delegate respondsToSelector:@selector(replayRecordFinishWithVC:errorInfo:)]) {
                [_delegate replayRecordFinishWithVC:nil errorInfo:[NSString stringWithFormat:@"CDPReplay:结束录制error %@",error]];
            }
        }
        else {
            CDPLog(@"CDPReplay:录制完成");
            if ([_delegate respondsToSelector:@selector(replayRecordFinishWithVC:errorInfo:)]) {
                [_delegate replayRecordFinishWithVC:previewViewController errorInfo:@""];
            }
            if (isShow) {
                [self showVideoPreviewController:previewViewController animation:YES];
            }
        }
    }];
}
#pragma mark - 显示/关闭视频预览页
//显示视频预览页面
-(void)showVideoPreviewController:(RPPreviewViewController *)previewController animation:(BOOL)animation {
    previewController.previewControllerDelegate=self;
    
    __weak UIViewController *rootVC=[self getRootVC];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rect = [UIScreen mainScreen].bounds;
        
        if (animation) {
            rect.origin.x+=rect.size.width;
            previewController.view.frame=rect;
            rect.origin.x-=rect.size.width;
            [UIView animateWithDuration:0.3 animations:^(){
                previewController.view.frame=rect;
            }];
        }
        else{
            previewController.view.frame=rect;
        }
        
        [rootVC.view addSubview:previewController.view];
        [rootVC addChildViewController:previewController];
    });
    
}
//关闭视频预览页面
-(void)hideVideoPreviewController:(RPPreviewViewController *)previewController animation:(BOOL)animation {
    previewController.previewControllerDelegate=nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rect = previewController.view.frame;
        
        if (animation) {
            rect.origin.x+=rect.size.width;
            [UIView animateWithDuration:0.3 animations:^(){
                previewController.view.frame=rect;
            }completion:^(BOOL finished){
                [previewController.view removeFromSuperview];
                [previewController removeFromParentViewController];
            }];
            
        }
        else{
            [previewController.view removeFromSuperview];
            [previewController removeFromParentViewController];
        }
    });
}
#pragma mark - 视频预览页回调
//关闭的回调
- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController {
    [self hideVideoPreviewController:previewController animation:YES];
}
//选择了某些功能的回调（如分享和保存）
- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes {    
    if ([activityTypes containsObject:@"com.apple.UIKit.activity.SaveToCameraRoll"]) {
        CDPLog(@"CDPReplay:保存到相册成功");
        if ([_delegate respondsToSelector:@selector(saveSuccess)]) {
            [_delegate saveSuccess];
        }
    }
    if ([activityTypes containsObject:@"com.apple.UIKit.activity.CopyToPasteboard"]) {
        CDPLog(@"CDPReplay:复制成功");
    }
}
#pragma mark - 其他方法
//判断对应系统版本是否支持ReplayKit
-(BOOL)systemVersionOK{
    if ([[UIDevice currentDevice].systemVersion floatValue]<9.0) {
        return NO;
    } else {
        return YES;
    }
}
//获取rootVC
-(UIViewController *)getRootVC{
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

@end
