//
//  BigPictureCell.m
//  OCADV
//
//  Created by MrChen on 2018/12/3.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYBigPictureCell.h"

@interface HYBigPictureCell ()

@end

@implementation HYBigPictureCell

/**
 * 添加第一张图片
 */
- (void)addImageView1
{
    self.imageView1 = [self createImageView:0];
    [self setImageView:@"image1.jpg" imageView:self.imageView1];
    [self addImageView:self.imageView1 animated:YES];
}

/**
 * 添加第二张图片
 */
- (void)addImageView2
{
    self.imageView2 = [self createImageView:1];
    [self setImageView:@"image2.jpg" imageView:self.imageView2];
    [self addImageView:self.imageView2 animated:YES];
}

/**
 * 添加第三张图片
 */
- (void)addImageView3
{
    self.imageView3 = [self createImageView:2];
    [self setImageView:@"image3.jpg" imageView:self.imageView3];
    [self addImageView:self.imageView3 animated:YES];
}

/**
 * 创建ImageView
 */
- (UIImageView *)createImageView:(NSInteger)index
{
    CGFloat margin = 10.0;
    CGFloat y = 5.0;
    CGFloat w = ScWidth/3;
    CGFloat x = (w + margin) * index;
    CGFloat h = 60;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, w, h)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    return imageView;
}

/**
 * 添加imageView
 */
- (void)addImageView:(UIImageView *)imageView animated:(BOOL)animated
{
    if (animated) {
        [UIView transitionWithView:imageView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.contentView addSubview:imageView];
        } completion:nil];
    }else {
        [self.contentView addSubview:imageView];
    }
}

/**
 * 设置图片
 */
-(void)setImageView:(NSString *)imageName imageView:(UIImageView *)imageView
{
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    //    UIImage *image = [UIImage imageNamed:imageName];
    imageView.image = image;
}

@end
