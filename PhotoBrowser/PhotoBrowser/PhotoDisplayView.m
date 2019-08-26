//
//  PhotoDisplayView.m
//  InspectionSystem
//
//  Created by 上海昊沧 on 2017/1/18.
//  Copyright © 2017年 上海昊沧. All rights reserved.
//

#import "PhotoDisplayView.h"
#import "PhotoDisplayCollectionViewCell.h"
#import "PhotoBrowserView.h"
#import <AVFoundation/AVFoundation.h>
#import "QWPhotoAssets.h"

@implementation PhotoDisplayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        
        imageArray_ = [[NSMutableArray alloc]init];
        _maxImageCount = 4;
        _lineCount = 4;
        _isPosition = YES;
        addImage_ = [UIImage imageNamed:@"添加图片"];
        
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init]; // 自定义的布局对象
        collectionView_ = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:collectionViewLayout];
        collectionView_.backgroundColor = [UIColor clearColor];
        collectionView_.dataSource = self;
        collectionView_.delegate = self;
        collectionView_.scrollEnabled = NO;
        [self addSubview:collectionView_];
//        [collectionView_ mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
//        }];
        
        // 注册cell、sectionHeader、sectionFooter
        [collectionView_ registerClass:[PhotoDisplayCollectionViewCell class] forCellWithReuseIdentifier:@"photoDisplayCollectionViewCell"];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    collectionView_.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}
- (void)setLineCount:(NSInteger)lineCount
{
    if(lineCount <= 0)
        return;
    _lineCount = lineCount;
    
    [collectionView_ reloadData];
}

- (void)setMaxImageCount:(NSInteger)maxImageCount
{
    if(maxImageCount<0)
        return;
    _maxImageCount = maxImageCount;
    
    if(![imageArray_ containsObject:addImage_] && _canEdit && imageArray_.count<_maxImageCount)
        [imageArray_ addObject:addImage_];
    //最多图片数变少,删掉后面的图片
    else if (imageArray_.count>_maxImageCount)
    {
        while (imageArray_.count > _maxImageCount) {
            [imageArray_ removeLastObject];
        }
    }
    [collectionView_ reloadData];
}

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
    
    if(_canEdit && ![imageArray_ containsObject:addImage_] && imageArray_.count<_maxImageCount)
       [imageArray_ addObject:addImage_];
    else if(!_canEdit && [imageArray_ containsObject:addImage_])
        [imageArray_ removeObject:addImage_];
    [collectionView_ reloadData];
}

- (void)setIsRadius:(BOOL)isRadius {
    _isRadius = isRadius;
    [collectionView_ reloadData];
}

-(void)insertImages:(NSArray *)images
{
    for(NSObject *image in images) {
        //图片达到最大数量
        if(![imageArray_ containsObject:addImage_] && imageArray_.count == _maxImageCount)
            break;
        if([imageArray_ containsObject:addImage_])
            [imageArray_ removeObject:addImage_];
        
        [imageArray_ addObject:[[QWPhotoAssets alloc] initWithObj:image]];
    }
    if(_canEdit && imageArray_.count<_maxImageCount)
        [imageArray_ addObject:addImage_];
    [collectionView_ reloadData];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(photoDisplayView:didAddPhotos:)])
        [self.delegate photoDisplayView:self didAddPhotos:nil];
}
-(void)removeAllImage
{
    [imageArray_ removeAllObjects];
    if(_canEdit && _maxImageCount)
        [imageArray_ addObject:addImage_];
    [collectionView_ reloadData];
}

- (void)removeImage:(UIButton *)btn
{
    [imageArray_ removeObjectAtIndex:(btn.tag-1000)];
    if(![imageArray_ containsObject:addImage_])
    {
        [imageArray_ addObject:addImage_];
    }
    [collectionView_ reloadData];
    if(self.delegate && [self.delegate respondsToSelector:@selector(photoDisplayView:didDeletePhotoAtIndex:)])
        [self.delegate photoDisplayView:self didDeletePhotoAtIndex:btn.tag-1000];
}
- (NSArray*)imageArr
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for(NSObject *obj in imageArray_)
    {
        if([obj isKindOfClass:[UIImage class]] && obj != addImage_)
            [arr addObject:obj];
        else if ([obj isKindOfClass:[QWPhotoAssets class]]) {
            QWPhotoAssets *asset = (QWPhotoAssets *)obj;
            [arr addObject:[asset compressionImage]];
        }
        
    }
    return arr;
}
//点击添加图片
-(void)clickAddImage:(NSIndexPath *)indexPath
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover){
        UIView *cell = [collectionView_ cellForItemAtIndexPath:indexPath];
        popover.sourceView = cell;
        popover.sourceRect = cell.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){}];
    UIAlertAction* fromPhotoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
//            DNImagePickerController *imagePicker = [[DNImagePickerController alloc] init];
//            imagePicker.maxSelectedImageCount = self.maxImageCount>30 ? 30 : self.maxImageCount;
//            imagePicker.imagePickerDelegate = self;
//            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePicker animated:YES completion:nil];
        }
    }];
    UIAlertAction* fromCameraAction = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault                                                             handler:^(UIAlertAction * action) {
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                //[SVProgressHUD showErrorWithStatus:@"相机权限受限"];
                return;
            }
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            //imagePicker.allowsEditing = NO;
            imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePicker animated:YES completion:nil];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:fromCameraAction];
    //[alertController addAction:fromPictrueAction];
    [alertController addAction:fromPhotoAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *fullImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self insertImages:@[fullImage]];
    }];
    
}
#pragma mark - 照片多选的代理方法

//- (void)dnImagePickerController:(DNImagePickerController *)imagePicker sendImages:(NSArray<DNAsset *> *)imageAssets isFullImage:(BOOL)fullImage {
//
//    [imagePicker dismissViewControllerAnimated:YES completion:^{
//        NSMutableArray *arr = [NSMutableArray new];
//
//        for (DNAsset *imageAsset in imageAssets) {
//            [arr addObject:imageAsset.asset];
//        }
//        [self insertImages:arr];
//    }];
//
//}
//- (void)dnImagePickerControllerDidCancel:(DNImagePickerController *)imagePicker {
//
//    [imagePicker dismissViewControllerAnimated:YES completion:^{
//
//    }];
//}


#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imageArray_.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"photoDisplayCollectionViewCell";
    PhotoDisplayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.canEdit = _canEdit;
    //判断是不是添加图片的cell
    if(_canEdit && indexPath.row == imageArray_.count-1 && [imageArray_ containsObject:addImage_])
        cell.isAdd = YES;
    else
        cell.isAdd = NO;
    
    cell.deleteBtn.hidden = YES;
    cell.deleteBtn.tag = indexPath.row+1000;
    [cell.deleteBtn addTarget:self action:@selector(removeImage:) forControlEvents:UIControlEventTouchUpInside];
    
    //获取图片
    QWPhotoAssets *asset = imageArray_[indexPath.row];
    if([asset isKindOfClass:[UIImage class]]) {
        cell.showImgV.image = (UIImage *)asset;
        return cell;
    }
    
    cell.showImgV.image = asset.thumbImage;
    //cell.userInteractionEnabled = YES;
    if(asset.photoUrl) {
        //[cell.showImgV sd_setImageWithURL:asset.photoUrl];
    }
    
    //是否圆角
    if(self.isRadius) {
        cell.showImgV.layer.cornerRadius = 3;
        cell.showImgV.layer.masksToBounds = YES;
    }
    else {
        cell.showImgV.layer.cornerRadius = 0;
        cell.showImgV.layer.masksToBounds = NO;
    }
    return cell;
}

#pragma mark ---- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_canEdit && indexPath.row == imageArray_.count-1 && [imageArray_ containsObject:addImage_])
    {
        //点击添加图片
        [self clickAddImage:indexPath];
        return;
    }
    //点击放大图片
    NSMutableArray *imageArr = [NSMutableArray arrayWithArray:imageArray_];
    if([imageArr containsObject:addImage_])
        [imageArr removeObject:addImage_];

    if(_isPosition) {
        
        PhotoBrowserView *view = [PhotoBrowserView showWithPhotoArray:imageArr animationViewWithBlock:^UIView *(NSInteger index) {
            PhotoDisplayCollectionViewCell *cell = (PhotoDisplayCollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            return cell.showImgV;
        }];
        view.currentPage = indexPath.row;
    }
    else {
        [PhotoBrowserView showWithPhotoArray:imageArr];
    }

}


#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (collectionView.frame.size.width)/_lineCount;
    return (CGSize){width,width};
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

@end
