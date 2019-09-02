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
@property (nonatomic, copy) AdvertiseViewSelectionHandler selectionHandler;

@end

@implementation AdvertiseCell

- (instancetype)init {
    self = [super init];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)]];
    return self;
}

- (void)tapGesture {
    if (self.selectionHandler) {
        self.selectionHandler(self, self.tag);
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithHue:(arc4random() % 256) / 200.5 saturation:0.5 brightness:1 alpha:1];
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

const CGFloat advertiseViewAutoScrollTime = 3.0;

@interface AdvertiseView()<UIScrollViewDelegate> {
    NSTimer *timer;
    UIScrollView *scroll;
    UIPageControl *pageControl;
    NSInteger _contentCount;
}

@property (nonatomic, readonly) BOOL isOnlyOne;

@end

@implementation AdvertiseView

- (BOOL)isOnlyOne {
    return _contentCount <= 1;
}

- (void)setShowingAdvertiseCount:(NSInteger)count contentRequest:(AdvertiseViewContentRequestHandler)contentRequest selection:(AdvertiseViewSelectionHandler)selection {
    _contentCount = count;
    
    NSArray *subs = [self subviews];
    for (UIView *vi in subs) {
        [vi removeFromSuperview];
    }
    
    [timer invalidate];
    if (self.isOnlyOne == NO) {
        timer = [NSTimer scheduledTimerWithTimeInterval:advertiseViewAutoScrollTime target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
        [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:advertiseViewAutoScrollTime]];
    }
    
    scroll = [[UIScrollView alloc] init];
    
    scroll.scrollsToTop = NO;
    scroll.pagingEnabled = YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.bounces = NO;
    scroll.backgroundColor = [UIColor yellowColor];
    if (self.isOnlyOne == NO) {
        scroll.delegate = self;
    }
    
    [self addSubview:scroll];
    
    for (int i = 0; i < _contentCount; i++) {
        AdvertiseCell *cell = [[AdvertiseCell alloc] init];
        cell.tag = i;
        if (contentRequest) {
            contentRequest(cell, i);
        }
        cell.selectionHandler = selection;
        [scroll addSubview:cell];
    }
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = _contentCount;
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:pageControl];
    
    if (_contentCount <= 1) {
        pageControl.hidden = YES;
    }
}

- (void)scrollToPage:(NSInteger)page {
    //    NSLog(@"to %d",page);
    CGFloat offx = scroll.frame.size.width * (page + 1);
    [scroll setContentOffset:CGPointMake(offx, 0) animated:YES];
    
    //    pageControl.currentPage = page;
}

- (UIView *)mySubviewWithTag:(NSInteger)tag {
    for (UIView *view in scroll.subviews) {
        if (view.tag == tag) {
            return view;
        }
    }
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    pageControl.currentPage = [self currentPage];
    
    CGFloat offX = scrollView.contentOffset.x;
    CGFloat width = self.bounds.size.width;
    CGFloat minOffsetX = width;
    CGFloat maxOffsetX = (_contentCount) * width;
    // 实现循环滚动 _4 0 1 2 3 4 _0
    if (offX < minOffsetX) {
        // 把最后一个放在0;
        NSInteger tag = _contentCount - 1;
        UIView *viewWithLastTag = [self mySubviewWithTag:tag];
        CGRect frame = viewWithLastTag.frame;
        frame.origin.x = minOffsetX - width;
        viewWithLastTag.frame = frame;
        if (offX <= minOffsetX - width) {
            // 偷偷位移至最后
            frame.origin.x = (tag + 1) * width;
            viewWithLastTag.frame = frame;
            scrollView.contentOffset = CGPointMake(frame.origin.x, 0);
        }
    } else if (offX > maxOffsetX) {
        // 把第0个放在最后;
        NSInteger tag = 0;
        UIView *viewWithFirstTag = [self mySubviewWithTag:tag]; // fuck original viewWithTag which return self if tag == 0
        CGRect frame = viewWithFirstTag.frame;
        frame.origin.x = maxOffsetX + width;
        viewWithFirstTag.frame = frame;
        if (offX >= maxOffsetX + width) {
            // 偷偷偷位移至第0
            frame.origin.x = (tag + 1) * width;
            viewWithFirstTag.frame = frame;
            scrollView.contentOffset = CGPointMake(frame.origin.x, 0);
        }
    } else {
        for (UIView *view in scroll.subviews) {
            NSInteger index = (view.tag + 1);
            view.frame = CGRectMake(index * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [timer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:advertiseViewAutoScrollTime]];
}

- (NSInteger)currentPage {
    // fake offset
    return (NSInteger)(scroll.contentOffset.x / scroll.frame.size.width) - 1;
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
    scroll.contentSize = self.isOnlyOne ? self.bounds.size : CGSizeMake((2 + _contentCount) * self.bounds.size.width, self.bounds.size.height);
    pageControl.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height - 20);
    for (UIView *view in scroll.subviews) {
        NSInteger index = self.isOnlyOne ? view.tag : (view.tag + 1);
        view.frame = CGRectMake(index * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        [view layoutIfNeeded];
    }
    if (self.isOnlyOne == NO) {
        scroll.contentOffset = CGPointMake(self.bounds.size.width, 0);
    }
}

@end
