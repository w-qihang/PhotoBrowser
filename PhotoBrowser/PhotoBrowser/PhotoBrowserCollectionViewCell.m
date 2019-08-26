//
//  PhotoBrowserCollectionViewCell.m
//  InspectionSystem
//
//  Created by 上海昊沧 on 2017/1/20.
//  Copyright © 2017年 上海昊沧. All rights reserved.
//

#import "PhotoBrowserCollectionViewCell.h"

@implementation PhotoBrowserCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height )];
        //设置是否显示滑动条
        //_scroll.showsHorizontalScrollIndicator=NO;
        //_scroll.showsVerticalScrollIndicator=NO;
        
        //放大缩小时会有反弹
        _scroll.bouncesZoom = NO;
        //缩放的最大最小值
        _scroll.minimumZoomScale = 1;
        _scroll.maximumZoomScale = 4;
        _scroll.delegate = self;
        _scroll.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self.contentView addSubview:_scroll];
        
        _imgV = [[UIImageView alloc]init];
        _imgV.clipsToBounds = YES;
        _imgV.contentMode = UIViewContentModeScaleAspectFill;
        _imgV.userInteractionEnabled = YES;
        [_scroll addSubview:_imgV];
        
        //双击手势
        UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleClick:)];
        [doubleTap setNumberOfTapsRequired:2];
        [_imgV addGestureRecognizer:doubleTap];
    }
    return self;
}

- (void)doubleClick:(UITapGestureRecognizer*)recognizer
{
    if (!_isZoom) {
        //newScale = _scroll.zoomScale *2.0;
        [_scroll setZoomScale:2 animated:YES];
    }
    else{
        //newScale = _scroll.zoomScale *0.0;
        [_scroll setZoomScale:1 animated:YES];
    }
    //    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[recognizer locationInView:recognizer.view]];
    //    [_scroll zoomToRect:zoomRect animated:YES];
    _isZoom = !_isZoom;
}
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height =_scroll.frame.size.height / scale;
    zoomRect.size.width  =_scroll.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height /2.0);
    return zoomRect;
}
#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imgV;
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //当捏或移动时，需要对center重新定义以达到正确显示未知
    CGFloat xcenter = scrollView.center.x,ycenter = scrollView.center.y;
    NSLog(@"adjust position,x:%f,y:%f",scrollView.contentSize.width,scrollView.contentSize.height);
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width?scrollView.contentSize.width/2 :xcenter;
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ?scrollView.contentSize.height/2 : ycenter;
    [_imgV setCenter:CGPointMake(xcenter, ycenter)];
}


@end
