//
//  PhotoDisplayView.h
//  InspectionSystem
//
//  Created by 上海昊沧 on 2017/1/18.
//  Copyright © 2017年 上海昊沧. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DNImagePickerController.h"

@class PhotoDisplayView;

@protocol PhotoDisplayViewDelegate <NSObject>

@optional
- (void)photoDisplayView:(PhotoDisplayView *)photoDisplayView didAddPhotos:(NSArray*)photoImages;
- (void)photoDisplayView:(PhotoDisplayView *)photoDisplayView didDeletePhotoAtIndex:(NSInteger)index;

@end

@interface PhotoDisplayView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate
    //,DNImagePickerControllerDelegate
    >
{
    UICollectionView *collectionView_;
    UIImage *addImage_;            //添加图片
    NSMutableArray *imageArray_;
}
@property (nonatomic,weak) id<PhotoDisplayViewDelegate> delegate;
@property (nonatomic,assign) NSInteger lineCount; //横排数量
@property (nonatomic,assign) BOOL canEdit;
@property (nonatomic,assign) BOOL isPosition; //回原位置
@property (nonatomic,assign) NSInteger maxImageCount;  //可添加的最多图片数
@property (nonatomic,strong,readonly) NSArray*imageArr;
@property (nonatomic,assign) BOOL isRadius; //是否圆角

-(void)insertImages:(NSArray*)images; //添加图片
-(void)removeAllImage;
@end
