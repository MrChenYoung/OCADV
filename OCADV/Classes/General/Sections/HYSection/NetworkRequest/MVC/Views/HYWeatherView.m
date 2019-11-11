//
//  HYWeatherView.m
//  OCADV
//
//  Created by MrChen on 2019/3/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYWeatherView.h"

@interface HYWeatherView ()

// 选择城市按钮
@property (nonatomic, strong) UIButton *selectCityBtn;

// 箭头图标
@property (nonatomic, strong) UIImageView *arrowImageView;

// 结果显示框
@property (nonatomic, weak) UITextView *resultTextView;

@end

@implementation HYWeatherView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, ScWidth, 0);
        
        // 添加子视图
        [self setupViews];
    }
    return self;
}

#pragma mark - 设置子view
- (void)setupViews
{
    CGFloat padding = 10.0;
    // 基本POST/GET请求label
    UILabel *baseUseLAbel = [self createModuleTitleLabelOrigin:CGPointMake(padding, padding) text:@"基本POST/GET请求(天气查询)"];
    [self addSubview:baseUseLAbel];
    
    // 城市选择按钮
    UIButton *selectCityBtn = [[UIButton alloc]initWithFrame:CGRectMake(padding, CGRectGetMaxY(baseUseLAbel.frame) + padding * 0.5, ScWidth - padding * 2.0, 30)];
    selectCityBtn.layer.cornerRadius = 3;
    selectCityBtn.layer.borderWidth = 0.5;
    selectCityBtn.layer.borderColor = ColorLightGray.CGColor;
    [selectCityBtn addTarget:self action:@selector(selectCityBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:selectCityBtn];
    self.selectCityBtn = selectCityBtn;
    
    // 箭头图标
    CGFloat arrowImageW = 20.0;
    CGFloat arrowImageH = 20.0;
    CGFloat arrowImageX = CGRectGetWidth(selectCityBtn.frame) - arrowImageW - 10.0;
    CGFloat arrowImageY = (CGRectGetHeight(selectCityBtn.frame) - arrowImageH) * 0.5;
    UIImageView *arrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(arrowImageX, arrowImageY, arrowImageW, arrowImageH)];
    UIImage *downArrImage = [UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e601", 20, ColorWithRGB(0.55, 0.55, 0.55))];
    arrowImageView.image = downArrImage;
    [selectCityBtn addSubview:arrowImageView];
    self.arrowImageView = arrowImageView;
    
    // 按钮
    CGFloat lastMaxY = 0;
    NSArray *btnTitles = @[@"同步GET请求",@"同步POST请求",@"异步GET请求",@"异步POST请求"];
    for (int i = 0; i < btnTitles.count; i++) {
        HYButton *btn = [[HYButton alloc]init];
        btn.btnY = CGRectGetMaxY(selectCityBtn.frame) + padding + (CGRectGetHeight(btn.frame) + padding * 0.5) * i;
        btn.titleText = btnTitles[i];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1000 + i;
        [self addSubview:btn];
        lastMaxY = CGRectGetMaxY(btn.frame);
    }
    
    // 请求结果
    UITextView *resultTextView = [[UITextView alloc]initWithFrame:CGRectMake(padding, lastMaxY + padding, ScWidth - padding * 2.0, 120.0)];
    resultTextView.editable = NO;
    resultTextView.placeholder = @"查询结果";
    resultTextView.layer.cornerRadius = 3.0;
    resultTextView.layer.borderWidth = 0.5;
    resultTextView.layer.borderColor = ColorLightGray.CGColor;
    [self addSubview:resultTextView];
    self.resultTextView = resultTextView;
    
    self.viewHeight = CGRectGetMaxY(resultTextView.frame);
    
    // 城市列表
    self.cityListView = [[HYWeatherCityListView alloc]initWithFrame:CGRectMake(CGRectGetMinX(selectCityBtn.frame), CGRectGetMaxY(selectCityBtn.frame), CGRectGetWidth(selectCityBtn.frame), 0)];
    self.cityListView.maxHeight = self.viewHeight - CGRectGetMinY(self.cityListView.frame);
    __weak typeof(self) weakSelf = self;
    self.cityListView.selectCityChangedBlock = ^(NSString * _Nonnull provence, NSString * _Nonnull city, NSString * _Nonnull distribute, NSInteger index) {
        weakSelf.selectProvence = provence;
        weakSelf.selectCity = city;
        weakSelf.selectDistrict = distribute;
        if (weakSelf.selectCityChangedBlock) {
            weakSelf.selectCityChangedBlock(index);
        }
        
        [weakSelf updateArrowImageViewState];
    };
    [self addSubview:self.cityListView];
}

#pragma mark - setter
/**
 * 选中的省
 */
- (void)setSelectProvence:(NSString *)selectProvence
{
    _selectProvence = selectProvence;
    
    [self updateSelectCityBtnText];
}

/**
 * 选中的市
 */
- (void)setSelectCity:(NSString *)selectCity
{
    _selectCity = selectCity;
    
    [self updateSelectCityBtnText];
}

/**
 * 选中的区
 */
- (void)setSelectDistrict:(NSString *)selectDistrict
{
    _selectDistrict = selectDistrict;
    
    [self updateSelectCityBtnText];
}

#pragma mark - other
/**
 * 更新选择城市按钮文字
 */
- (void)updateSelectCityBtnText
{
    NSMutableArray *arrayM = [NSMutableArray array];
    if (self.selectProvence) {
        [arrayM addObject:self.selectProvence];
    }
    
    if (self.selectCity && ![self.selectProvence isEqualToString:self.selectCity]) {
        [arrayM addObject:self.selectCity];
    }
    
    if (self.selectDistrict && ![self.selectCity isEqualToString:self.selectDistrict]) {
        [arrayM addObject:self.selectDistrict];
    }
    
    [self.selectCityBtn setAttributedTitleWithStrings:[arrayM copy] colors:@[ColorDefaultText,ColorGrayText,ColorLightGrayText] fontSizes:@[@14,@12,@10]];
}

/**
 * 选择城市按钮点击
 */
- (void)selectCityBtnClick
{
    [self.cityListView updateShowStateComplete:^(BOOL isShow) {
        [self updateArrowImageViewState];
    }];
}

// 刷新箭头图标
- (void)updateArrowImageViewState
{
    UIImage *image = nil;
    if (self.cityListView.isShow) {
        image = [UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e600", 20, ColorWithRGB(0.55, 0.55, 0.55))];
    }else {
        image = [UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e601", 20, ColorWithRGB(0.55, 0.55, 0.55))];
    }
    self.arrowImageView.image = image;
}
@end
