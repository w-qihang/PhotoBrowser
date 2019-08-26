//
//  PhotoBrowserView.h
//  InspectionSystem
//
//  Created by 上海昊沧 on 2017/1/17.
//  Copyright © 2017年 上海昊沧. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIView* (^PhotoDisplayBlock)(NSInteger index);

@interface PhotoBrowserView : UIWindow <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,strong) NSArray *photoArr;

+ (instancetype)showWithPhotoArray:(NSArray *)photoArray;
//显示时带动画效果
+ (instancetype)showWithPhotoArray:(NSArray *)photoArray animationViewWithBlock:(PhotoDisplayBlock)block;
@end
