//
//  PhotoDisplayCollectionViewCell.m
//  InspectionSystem
//
//  Created by 上海昊沧 on 2017/1/18.
//  Copyright © 2017年 上海昊沧. All rights reserved.
//

#import "PhotoDisplayCollectionViewCell.h"

@implementation PhotoDisplayCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _showImgV = [UIImageView new];
        //_showImgV.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_showImgV];
//        [_showImgV mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(UIEdgeInsetsMake(5, 5, 5, 5));
//        }];
        
        _deleteBtn = [UIButton new];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"删除图片"] forState:UIControlStateNormal];
        _deleteBtn.hidden = YES;
        [self.contentView addSubview:_deleteBtn];
//        [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(0);
//            make.top.mas_equalTo(0);
//            make.width.mas_equalTo(15);
//            make.height.mas_equalTo(15);
//        }];
        
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressGR.minimumPressDuration = 1.0f;
        [self.contentView addGestureRecognizer:longPressGR];
    }
    return self;
}

//长按显示出删除按钮
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(!_canEdit || _isAdd)
        return;
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        for(UIView *view in [gestureRecognizer.view subviews])
        {
            if([view isKindOfClass:[UIButton class]])
                view.hidden = !view.hidden;
        }
    }
}
@end
