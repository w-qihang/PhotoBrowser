//
//  PhotoBrowserView.m
//  InspectionSystem
//
//  Created by 上海昊沧 on 2017/1/17.
//  Copyright © 2017年 上海昊沧. All rights reserved.
//

#import "PhotoBrowserView.h"
#import "PhotoBrowserCollectionViewCell.h"
#import "QWPhotoAssets.h"

static PhotoBrowserView *sharedInstance = nil;

@interface PhotoBrowserView() <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    CGFloat lastContentOffsetX;
    
    BOOL isBegin;
    UIImage *currentImage;
    
    UIViewController *vc_;
}
@property (nonatomic,copy) PhotoDisplayBlock photoBlock;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIPageControl *pageControl;

@end
@implementation PhotoBrowserView

+ (instancetype)show
{
    if(!sharedInstance) {
        sharedInstance = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
        sharedInstance.backgroundColor = [UIColor colorWithRed:77 green:77 blue:77 alpha:0.6];
        sharedInstance.windowLevel = UIWindowLevelAlert;
        [sharedInstance makeKeyAndVisible];
    }
    return sharedInstance;
}
+ (instancetype)showWithPhotoArray:(NSArray *)photoArray {
    PhotoBrowserView *instance = [self show];
    instance.photoArr = photoArray;
    return instance;
}
+ (instancetype)showWithPhotoArray:(NSArray *)photoArray animationViewWithBlock:(PhotoDisplayBlock)block {
    PhotoBrowserView *instance = [self show];
    instance.photoArr = photoArray;
    instance.photoBlock = block;
    return instance;
}
//- (void)setImageArray:(NSArray *)imageArray imageIndex:(NSInteger)imageIndex imagePhotoBlock:(UIView* (^)(NSInteger))photoBlock
//{
//    imageArray_ = imageArray;
//    _currentPage = imageIndex;
//    photoBlock_ = photoBlock;
//
//    //table滚动到指定位置
//    [collectionView_ setContentOffset:CGPointMake(SCREEN_W*_currentPage,0) animated:NO];
//
//    if (imageArray_.count == 1) {
//        pageControl.hidden = YES;
//    }
//
//}
- (void)dismiss
{
    [sharedInstance resignKeyWindow];
    sharedInstance = nil;
}
- (void)layoutSubviews {
    self.collectionView.frame = self.bounds;
    self.pageControl.frame = CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 20);
    [self bringSubviewToFront:_pageControl];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    self.pageControl.currentPage = _currentPage;
    [self.collectionView setContentOffset:CGPointMake(SCREEN_W*_currentPage,0) animated:NO];
    lastContentOffsetX = _collectionView.contentOffset.x;
}
- (void)setPhotoArr:(NSArray *)photoArr {
    self.pageControl.numberOfPages = photoArr.count;
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for(NSObject*obj in photoArr) {
        if([obj isKindOfClass:[QWPhotoAssets class]])
           [arr addObject:obj];
        else {
            QWPhotoAssets *asset = [[QWPhotoAssets alloc]initWithObj:obj];
            [arr addObject:asset];
        }
    }
    _photoArr = arr;
    self.collectionView.contentSize = CGSizeMake(SCREEN_W*_photoArr.count, SCREEN_H);
}
- (UICollectionView *)collectionView {
    if(!_collectionView) {
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init]; // 自定义的布局对象
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        [self addSubview:_collectionView];
        // 注册cell、sectionHeader、sectionFooter
        [_collectionView registerClass:[PhotoBrowserCollectionViewCell class] forCellWithReuseIdentifier:@"photoBrowserCollectionViewCell"];
    }
    return _collectionView;
}
- (UIPageControl *)pageControl {
    if(!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

#pragma mark - UIScrollViewDelegate

//滑动松手如果跳到不同的页面，预先加载图片
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    QWPhotoAssets *asset = nil;
    //如果滑动松开手后回滚动到不同的页面
    if (targetContentOffset->x != lastContentOffsetX) {
        //向左
        if (lastContentOffsetX > _collectionView.contentOffset.x) {
            asset = _photoArr[_currentPage-1];
        }
        //向右
        else if (lastContentOffsetX < _collectionView.contentOffset.x) {
            asset = _photoArr[_currentPage+1];
        }
        
        //获得image
        if(asset) {
            dispatch_queue_t queue = dispatch_queue_create("BeginDecelerating", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                [asset originImage];
            });
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
   
    int page = (int)_collectionView.contentOffset.x/SCREEN_W;
    [_pageControl setCurrentPage:page];
    _currentPage = page;
    
    lastContentOffsetX = scrollView.contentOffset.x;
}
//根据上一次的滑动方向，加载下一张图
- (void)loadNextImageWithDirect:(int)direct {
    if (direct == -1 && self.currentPage < self.photoArr.count - 1){
//        if (!((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage + 1]).photoImage) {
//            LGPhotoAssets *asset = ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage + 1]).asset;
//            ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage + 1]).photoImage = [asset originImage];
//        }
    } else if(direct == 1 && self.currentPage > 0){
//        if (!((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).photoImage) {
//            LGPhotoAssets *asset = ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).asset;
//            ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).photoImage = [asset originImage];
//        }
    } else ;
}

#pragma mark ---- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photoArr.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"photoBrowserCollectionViewCell";
    PhotoBrowserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    cell.imgV.image = nil;
    cell.scroll.zoomScale = 1;
    cell.isZoom = NO;
    cell.imgV.tag = indexPath.row;
    //获取图片
    QWPhotoAssets *asset = _photoArr[indexPath.row];
    UIImage *image = asset.originImage;
    
    cell.imgV.image = image;
    CGSize imageSize = CGSizeMake(SCREEN_W/2, SCREEN_W/2/image.size.width*image.size.height);
    cell.scroll.contentSize = imageSize;
    if(indexPath.row == _currentPage && !isBegin)
    {
        isBegin = YES;
        if(_photoBlock) //带动画显示图片
        {
            UIView *view = _photoBlock(_currentPage);
            cell.imgV.frame = [self convertRect:view.frame fromView:view.superview];
            [UIView animateWithDuration:0.5 animations:^{
                cell.imgV.frame = CGRectMake(SCREEN_W/2-imageSize.width/2, SCREEN_H/2-imageSize.height/2, imageSize.width, imageSize.height);
            }];
        }
        else {
            cell.imgV.frame = CGRectMake(SCREEN_W/2, SCREEN_H/2, 1, 1);
            [UIView animateWithDuration:0.5 animations:^{
                cell.imgV.frame = CGRectMake(SCREEN_W/2-imageSize.width/2, SCREEN_H/2-imageSize.height/2, imageSize.width, imageSize.height);
            }];
        }
    }
    else
        cell.imgV.frame = CGRectMake(SCREEN_W/2-imageSize.width/2, SCREEN_H/2-imageSize.height/2, imageSize.width, imageSize.height);
    
    //网络图片url
//    if([asset photoUrl]) {
//        [cell.imgV sd_setImageWithURL:[asset photoUrl]];
//    }
    
    //让图片居中,并铺满屏幕
    CGFloat xcenter = cell.scroll.center.x,ycenter = cell.scroll.center.y;
    xcenter = cell.scroll.contentSize.width > cell.scroll.frame.size.width?cell.scroll.contentSize.width/2 :xcenter;
    ycenter = cell.scroll.contentSize.height > cell.scroll.frame.size.height ?cell.scroll.contentSize.height/2 : ycenter;
    [cell.imgV setCenter:CGPointMake(xcenter, ycenter)];
    
    //单击手势
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleClick:)];
    [singleTap setNumberOfTapsRequired:1];
    [cell.imgV addGestureRecognizer:singleTap];
    //双击手势
    UITapGestureRecognizer* doubleTap =  cell.imgV.gestureRecognizers[0];
    
    //只有当没有检测到doubleTap 或者 检测doubleTap失败，singleTapGestureRecognizer才有效
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    //长按手势
    UILongPressGestureRecognizer *longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTap:)];
    [cell.imgV addGestureRecognizer:longTapGestureRecognizer];
    
    return cell;
}



#pragma mark ---- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}
#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){SCREEN_W,SCREEN_H};
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (void)singleClick:(UITapGestureRecognizer*)recognizer
{
    if(_photoBlock) {
        UIImageView *imageView = (UIImageView*)[recognizer view];
        UIScrollView *scroll = (UIScrollView*)imageView.superview;
        [UIView animateWithDuration:0.5 animations:^{
            scroll.contentSize = CGSizeZero;
            UIView *view = _photoBlock(_currentPage);
            imageView.frame = [self convertRect:view.frame fromView:view.superview];
        }completion:^(BOOL finish){
            if(finish)
                [self dismiss];
        }];
    }
    else
        [UIView animateWithDuration:0.5 animations:^{
            UIImageView *imageView = (UIImageView*)[recognizer view];
            imageView.frame = CGRectMake(SCREEN_W/2, SCREEN_H/2, 1, 1);
        }completion:^(BOOL finish){
            if(finish)
                [self dismiss];
        }];
}

-(void)longTap:(UIGestureRecognizer*)gestureRecognizer{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        UIImageView *clickImage = (UIImageView*)gestureRecognizer.view;
//        longTapIndex = clickImage.tag;
//        ImageModel *model = self.imageModelArray[clickImage.tag];
        
//        if (model.imageUrl && model.imageUrl.length) { //网络图片的保存，转发
//            //识别图中二维码
//            CGImageRef imageToDecode = clickImage.image.CGImage;
//            ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
//            ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
//            NSError *error = nil;
//            ZXDecodeHints *hints = [ZXDecodeHints hints];
//            ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
//            ZXResult *result = [reader decode:bitmap hints:hints error:&error];
//            if (result) {
//                model.codeResult = result.text;
                
//                UIActionSheet *actsheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到相册",@"转发",@"识别图中二维码",nil];
//                [actsheet showInView:self];
//            }else{
//                UIActionSheet *actsheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到相册",@"转发",nil];
//                [actsheet showInView:self];
 //           }
 //       }
    }
}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonInde
//{
//    ImageModel *model = self.imageModelArray[longTapIndex];
//    if (buttonIndex == 0)
//    {
//        [self.view showTipText:@"正在保存" show:YES];
//        ImageTableViewCell *cell = (ImageTableViewCell *)[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:longTapIndex inSection:0]];
//        UIImageWriteToSavedPhotosAlbum(cell.image.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil) ;
//    }else if (buttonIndex == 1)
//    {
        //        MessageModel *message = [[MessageModel alloc]init];
        //        message.type = MessageTypeImg;
        //        message.data = @"图片";
        //        if (model.fromCode && model.fromCode.length) {
        //            message.fromcode = model.fromCode;
        //        }else{
        //            message.fromcode = @"MessagePicture"; //此处转发需要通过这个值来获取图片
        //        }
        //        message.extra = model.imageUrl;
        //        message.localpath = [model.imageUrl stringByReplacingOccurrencesOfString:@"/" withString:@""];
        //
        //        TranSendWuliuListViewController *pv = [[TranSendWuliuListViewController alloc]init];
        //        pv.model = message;
        //        pv.delegate = self;
        //        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:pv];
        //        [self presentViewController:nav animated:YES completion:nil];
//    }else if (buttonIndex == 2)
//    {
//        if (model.codeResult && [model.codeResult length]) {
//            [self dismissViewControllerAnimated:NO completion:nil];
//            [self showresult:model.codeResult];
//        }
//    }
//}

//-(void)showresult:(NSString *)text{
//    if(self.delegate && [self.delegate respondsToSelector:@selector(showCodeResult:)])
//    {[self.delegate showCodeResult:text];}
    //    if ([text hasPrefix:@"http://m.sijibao.com?u="]) {
    //        UserInfomationViewController * userVC = [[UserInfomationViewController alloc] init] ;
    //        userVC.userCode = [text substringFromIndex:23];
    //        userVC.hidesBottomBarWhenPushed = YES;
    //        [_nav pushViewController:userVC animated:YES];
    //    }else if ([text hasPrefix:@"http://m.sijibao.com?c="]) {
    //        sjb_ComanyDetailViewController *pv = [[sjb_ComanyDetailViewController alloc]init];
    //        pv.CompanyCode = [text substringFromIndex:23];
    //        [_nav pushViewController:pv animated:YES];
    //    }else if ([text hasPrefix:@"http://"]){
    //        WapViewController *wapV = [[WapViewController alloc]init];
    //        wapV.title = @"二维码结果";
    //        wapV.url = text;
    //        [_nav pushViewController:wapV animated:YES];
    //    }else{
    //        QRTextResultViewController *wapV = [[QRTextResultViewController alloc]init];
    //        wapV.result = text;
    //        [_nav pushViewController:wapV animated:YES];
    //    }
//}

//-(void)passResult:(BOOL)success{
//    [self.view showProgressWithText:success?@"转发成功":@"转发失败"];
//}


//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    [self.view showTipText:@"正在保存中..." show:NO];
//    if (error != NULL) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"保存失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//    }else{
//        [self.view showProgressWithText:@"保存成功！"];
//    }
//}
@end
