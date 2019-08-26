//
//  QWPhotoAssets.m
//  TeacherTool
//
//  Created by 555 on 2017/9/14.
//  Copyright © 2017年 61Park. All rights reserved.
//

#import "QWPhotoAssets.h"

@interface QWPhotoAssets()

@property (strong,nonatomic) ALAsset *asset;
@property (strong,nonatomic) NSURL *photoUrl;
@property (strong,nonatomic) UIImage *image;

@end

@implementation QWPhotoAssets
@synthesize thumbImage,compressionImage,originImage,fullResolutionImage;

- (instancetype)initWithObj:(id)obj {
    if(self = [super init]) {
        if([obj isKindOfClass:[UIImage class]])
            _image = (UIImage *)obj;
        else if ([obj isKindOfClass:[NSURL class]])
            _photoUrl = (NSURL*)obj;
        else if ([obj isKindOfClass:[NSString class]])
            _photoUrl = [NSURL URLWithString:obj];
        else if ([obj isKindOfClass:[ALAsset class]])
            _asset = (ALAsset*)obj;
    }
    return self;
}

- (UIImage *)thumbImage{
    if(!thumbImage) {
        if(_asset) {
            //在ios9上，用thumbnail方法取得的缩略图显示出来不清晰，所以用aspectRatioThumbnail
            if ([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending) {
                thumbImage = [UIImage imageWithCGImage:[self.asset aspectRatioThumbnail]];
            } else {
                thumbImage = [UIImage imageWithCGImage:[self.asset thumbnail]];
            }
        }
        else if (_photoUrl)
            thumbImage = [UIImage imageNamed:@"failed"];
        else if (_image)
            thumbImage = _image;
    }
    return thumbImage;
}
- (NSURL *)photoUrl {
    return _photoUrl;
}
- (UIImage *)compressionImage{
    if(!compressionImage && _asset) {
        compressionImage = [UIImage imageWithData:UIImageJPEGRepresentation(self.originImage, 0.1)];
    }
    return compressionImage;
}

- (UIImage *)originImage{
    if(!originImage) {
        if(_asset)
            originImage = [UIImage imageWithCGImage:[[self.asset defaultRepresentation] fullScreenImage]];
        else if (_photoUrl)
            originImage = [UIImage imageNamed:@"failed"];
        else if (_image)
            originImage = _image;
    }
    return originImage;
}

- (UIImage *)fullResolutionImage{
    if(!fullResolutionImage && _asset) {
        ALAssetRepresentation *rep = [self.asset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        fullResolutionImage = [UIImage imageWithCGImage:iref scale:[rep scale] orientation:(UIImageOrientation)[rep orientation]];
    }
    return fullResolutionImage;
}

- (BOOL)isVideoType{
    NSString *type = [self.asset valueForProperty:ALAssetPropertyType];
    //媒体类型是视频
    return [type isEqualToString:ALAssetTypeVideo];
}

- (NSURL *)assetURL{
    return [[self.asset defaultRepresentation] url];
}

@end
