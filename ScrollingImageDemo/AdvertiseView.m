//
//  AdvertiseView.m
//  yangsheng
//
//  Created by Macx on 17/7/7.
//  Copyright © 2017年 jam. All rights reserved.
//

#import "AdvertiseView.h"

@interface AdvertiseCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation AdvertiseCell

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithHue:(arc4random() % 256) / 200.5 saturation:1 brightness:1 alpha:1];
        [self insertSubview:_imageView atIndex:0];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor colorWithHue:(arc4random() % 256) / 200.5 saturation:1 brightness:1 alpha:1];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.titleLabel.frame = CGRectMake(10, 10, 100, 20);
}

@end

const CGFloat advertiseViewAutoScrollTime = 2.0;

@interface AdvertiseView()<UIScrollViewDelegate> {
    NSTimer *timer;
    UIScrollView *scroll;
    UIPageControl *pageControl;
    NSInteger _contentCount;
}

@end

@implementation AdvertiseView

+ (instancetype)defaultAdvertiseView {
    AdvertiseView *a = [[AdvertiseView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width * 0.45)];
    a.backgroundColor = [UIColor lightGrayColor];
    return a;
}

- (void)setShowingAdvertiseCount:(NSInteger)count contentRequest:(AdvertiseViewContentRequestHandler)contentRequest selection:(AdvertiseViewSelectionHandler)selection {
    _contentCount = count;
    
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:advertiseViewAutoScrollTime target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
        [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:advertiseViewAutoScrollTime]];
    }
    
    NSArray *subs = [self subviews];
    for (UIView *vi in subs) {
        [vi removeFromSuperview];
    }
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    
    scroll.scrollsToTop = NO;
    scroll.pagingEnabled = YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.delegate = self;
    
    [self addSubview:scroll];
    
    for (int i = 0; i < _contentCount; i++) {
        AdvertiseCell *cell = [[AdvertiseCell alloc] init];
        cell.tag = i;
        if (contentRequest) {
            contentRequest(cell, i);
        }
        [scroll addSubview:cell];
    }
    
    scroll.contentSize = CGSizeMake(w * _contentCount, h);
    scroll.contentOffset = CGPointMake(0, 0);
    
    [self scrollToPage:0];
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = _contentCount;
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.center = CGPointMake(w / 2, h - 20);
    [self addSubview:pageControl];
    
    if (_contentCount <= 1) {
        pageControl.hidden = YES;
    }
}

- (void)scrollToPage:(NSInteger)page {
    //    NSLog(@"to %d",page);
    if (page >= _contentCount) {
        page = 0;
    }
    CGFloat offx = scroll.frame.size.width * page;
    [scroll setContentOffset:CGPointMake(offx, 0) animated:YES];
    
    //    pageControl.currentPage = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    pageControl.currentPage = [self currentPage];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [timer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:advertiseViewAutoScrollTime]];
}

- (NSInteger)currentPage {
    return (NSInteger)(scroll.contentOffset.x / scroll.frame.size.width);
}

- (NSInteger)numbersOfPage {
    return _contentCount;
}

- (void)scrollToNextPage {
    NSInteger curr = [self currentPage];
    [self scrollToPage:curr + 1];
}

- (void)dealloc {
    scroll.delegate = nil;
    [timer invalidate];
    NSLog(@"adver deal");
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    scroll.frame = self.bounds;
    pageControl.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height - 20);
    for (UIView *view in scroll.subviews) {
        view.frame = CGRectMake(view.tag * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
//        [view layoutIfNeeded];
    }
}

@end
