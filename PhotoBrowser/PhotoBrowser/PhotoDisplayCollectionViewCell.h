//
//  PhotoDisplayCollectionViewCell.h
//  InspectionSystem
//
//  Created by 上海昊沧 on 2017/1/18.
//  Copyright © 2017年 上海昊沧. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDisplayCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *showImgV;
@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,assign) BOOL canEdit;
@property (nonatomic,assign) BOOL isAdd;

@end
