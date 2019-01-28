//
//  HYVideoThumbnailImageListController.m
//  OCADV
//
//  Created by MrChen on 2019/1/20.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYVideoThumbnailListController.h"
#import "HYVideoThumbnailListCell.h"

@interface HYVideoThumbnailListController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>

// 图片列表
@property (nonatomic, strong) UITableView *tableView;

// 要选择的时间间隔列表
@property (nonatomic, strong) NSArray *timeIntevals;

// 主背景视图
@property (nonatomic, strong) UIView *mainBgView;

// 时间选择器背景视图
@property (nonatomic, strong) UIView *pickerBgView;

// 时间间隔选择器
@property (nonatomic, strong) UIPickerView *timePickerView;

// 选中的pickerView行号
@property (nonatomic, assign) NSInteger selectedPickerRow;

@end

@implementation HYVideoThumbnailListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadTitle];
    [self setRightItem];
    [self createSubviews];
    
    // 加载可选的时间间隔
    [self loadTimeIntervals];
    
    // 加载缩略图
    if (self.model.thumbnails.count == 0) {
        [self loadThumbnails];
    }
}

#pragma mark - lazy loading
/**
 * 图片列表
 */
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

#pragma mark - custom method
/**
 * 刷新标题 显示图片总共多少张
 */
- (void)reloadTitle
{
    self.title = [NSString stringWithFormat:@"视频预览(%lu/%lu)",(unsigned long)self.model.thumbnails.count,(unsigned long)self.model.thumbnailTimes.count];
}

/**
 * 设置筛选按钮
 */
- (void)setRightItem
{
    UIButton *filterBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [filterBtn setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [filterBtn addTarget:self action:@selector(filterClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:filterBtn];
}

/**
 * 创建子视图
 */
- (void)createSubviews
{
    // 添加列表视图
    [self.view addSubview:self.tableView];
    
    // 主背景视图
    self.mainBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScWidth, ScHeight)];
    self.mainBgView.alpha = 0.0;
    self.mainBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.navigationController.view addSubview:self.mainBgView];
    // 添加点击取消手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBgView)];
    [self.mainBgView addGestureRecognizer:tap];
    
    
    // 创建时间选择背景视图
    self.pickerBgView = [[UIView alloc]initWithFrame:CGRectMake(0, ScHeight, ScWidth, 250.0)];
    self.pickerBgView.backgroundColor = ColorWithRGB(255, 240, 245);
    [self.mainBgView addSubview:self.pickerBgView];
    
    // 标题
    UILabel *pickTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5.0, ScWidth, 20.0)];
    pickTitleLabel.textColor = ColorWithRGB(169, 169, 169);
    pickTitleLabel.textAlignment = NSTextAlignmentCenter;
    pickTitleLabel.font = [UIFont systemFontOfSize:14.0];
    pickTitleLabel.text = @"请选择缩略图间隔时间";
    [self.pickerBgView addSubview:pickTitleLabel];
    
    // 确定按钮
    CGFloat commitW = 60.0;
    CGFloat commitH = 30.0;
    CGFloat commitX = ScWidth - commitW - 5.0;
    UIButton *commitBtn = [[UIButton alloc]initWithFrame:CGRectMake(commitX, 0, commitW, commitH)];
    [commitBtn setTitleColor:ColorMain forState:UIControlStateNormal];
    commitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [commitBtn setTitle:@"确定" forState:UIControlStateNormal];
    [commitBtn addTarget:self action:@selector(commitClick) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerBgView addSubview:commitBtn];
    
    // pickerView
    CGFloat pickerY = 30.0;
    CGFloat pickerH = CGRectGetHeight(self.pickerBgView.frame) - pickerY;
    self.timePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, pickerY, ScWidth, pickerH)];
    self.timePickerView.delegate = self;
    self.timePickerView.dataSource = self;
    [self.pickerBgView addSubview:self.timePickerView];
}

/**
 * 显示筛选视图
 */
- (void)showPickerView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.mainBgView.alpha = 1.0;
        self.pickerBgView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.pickerBgView.frame));
    }completion:^(BOOL finished) {
        [self.timePickerView selectRow:self.selectedPickerRow inComponent:0 animated:YES];
    }];
}

/**
 * 隐藏筛选视图
 */
- (void)hiddenPickerView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.mainBgView.alpha = 0.0;
        self.pickerBgView.transform = CGAffineTransformIdentity;
    }];
}
#pragma mark - click action
/**
 * 选择缩略图间隔时间 重新刷新tableview
 */
- (void)filterClick
{
    [self showPickerView];
}

/**
 * 确定按钮点击
 */
- (void)commitClick
{
    [self hiddenPickerView];
    
    // 记录选中的行
    __weak typeof(self) weakSelf = self;
    self.selectedPickerRow = [self.timePickerView selectedRowInComponent:0];
    int seconds = [self.timeIntevals[self.selectedPickerRow] intValue];
    self.model.thumbnailTimeInterval = seconds;
    self.model.loadThumbnailTimesBlock = ^{
        // 刷新列表
        [weakSelf reloadTitle];
        [weakSelf.model.thumbnails removeAllObjects];
        [weakSelf.tableView reloadData];
        
        // 重新请求数据
        [weakSelf loadThumbnails];
    };
}

/**
 * 点击背景取消筛选
 */
- (void)tapBgView
{
    [self hiddenPickerView];
}

#pragma mark - netRequest
/**
 * 加载缩略图
 */
- (void)loadThumbnails
{
    __weak typeof(self) weakSelf = self;
    [self.model loadVideoAllThumbnailsComplete:^(UIImage * _Nonnull responseImage, int time) {
        NSInteger rowIndex = [weakSelf.model.thumbnailTimes indexOfObject:[NSNumber numberWithInt:time]];
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf reloadTitle];
    }];
}

/**
 * 加载可选的时间间隔
 */
- (void)loadTimeIntervals
{
    // 最大的时间间隔
    NSInteger maxTimeInterval = self.model.totalDuration/10;
    maxTimeInterval = maxTimeInterval <= 1 ? 2 : maxTimeInterval;
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (int i = 1; i < maxTimeInterval; i++) {
        NSNumber *time = [NSNumber numberWithInt:i];
        [arrM addObject:time];
    }
    self.timeIntevals = [arrM copy];
    self.selectedPickerRow = [self.timeIntevals indexOfObject:@(self.model.thumbnailTimeInterval)];
    if (self.selectedPickerRow == NSNotFound) {
        self.selectedPickerRow = 0;
    }
    [self.timePickerView reloadAllComponents];
}

#pragma mark - UITableViewDataSource
// row number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.thumbnailTimes.count;
}

// cell define code
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuserId = @"reuserId";
    HYVideoThumbnailListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[HYVideoThumbnailListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
        cell.model = self.model;
    }
    
    NSLog(@"当前缩略图时间:%@",self.model.thumbnailTimes);
    NSLog(@"当前缩略图:%@",self.model.thumbnails);
    NSNumber *time = self.model.thumbnailTimes[indexPath.row];
    UIImage *image = self.model.thumbnails[time];
    if (image) {
        [cell stopLoading];
    }else {
        [cell startLoading];
    }
    cell.thumbnailImageView.image = image;
    cell.videoLengthLabel.text = [NSDate timeFormat:time.intValue];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.model.naturalSize.height;
}

#pragma mark - UITableViewDelegate
// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.timeIntevals.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    if (label == nil) {
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScWidth, 30.0)];
        label.textColor = ColorLightGray;
        label.font = [UIFont systemFontOfSize:16.0];
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    int time = [self.timeIntevals[row] intValue];
    int hour = time/3600;
    int minute = (time%3600)/60;
    int second = time%60;
    NSString *str = @"";
    if (hour > 0) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%d小时",hour]];
    }
    if (minute > 0) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%d分钟",minute]];
    }
    if (second > 0) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%d秒",second]];
    }
    label.text = str;
    
    return label;
}

@end
