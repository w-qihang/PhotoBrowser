//
//  QWPhotoAssets.h
//  TeacherTool
//
//  Created by 555 on 2017/9/14.
//  Copyright © 2017年 61Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface QWPhotoAssets : NSObject

@property (nonatomic,strong,readonly) UIImage *originImage;
@property (nonatomic,strong,readonly) UIImage *thumbImage;
@property (nonatomic,strong,readonly) UIImage *compressionImage;
@property (nonatomic,strong,readonly) UIImage *fullResolutionImage;

- (NSURL *)photoUrl;
/**
 *  缩略图
 */
- (UIImage *)thumbImage;
/**
 *  压缩原图
 */
- (UIImage *)compressionImage;
/**
 *  原图
 */
- (UIImage *)originImage;
/**
 *  高清原图
 */
- (UIImage *)fullResolutionImage;


/**
 *  获取是否是视频类型, Default = false
 */
@property (assign,nonatomic) BOOL isVideoType;
/**
 *  获取相册的URL
 */
- (NSURL *)assetURL;

- (instancetype)initWithObj:(id)obj;

@end
