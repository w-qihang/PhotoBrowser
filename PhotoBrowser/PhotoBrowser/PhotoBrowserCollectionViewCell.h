//
//  PhotoBrowserCollectionViewCell.h
//  InspectionSystem
//
//  Created by 上海昊沧 on 2017/1/20.
//  Copyright © 2017年 上海昊沧. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

@interface PhotoBrowserCollectionViewCell : UICollectionViewCell<UIScrollViewDelegate>

@property (nonatomic,strong) UIImageView *imgV;
@property (nonatomic,strong) UIScrollView *scroll;
@property (nonatomic,assign) BOOL isZoom;

@end
