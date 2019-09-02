//
//  AdvertiseView.m
//  yangsheng
//
//  Created by Macx on 17/7/7.
//  Copyright © 2017年 jam. All rights reserved.
//

#import "AdvertiseView.h"

@interface ZZPageControl : UIView

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIColor *pageIndicatorTintColor;
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;

@end

CGFloat ZZPageControlDotWidth = 5;
CGFloat ZZPageControlDotMargin = 5;

@implementation ZZPageControl

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    CGRect rre = self.frame;
    if (numberOfPages > 1) {
        rre.size = CGSizeMake((numberOfPages * 2 - 1) * ZZPageControlDotMargin, ZZPageControlDotWidth);
        self.frame = rre;
    }
    [self drawDots];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (currentPage < 0) {
        currentPage = 0;
    } else if (currentPage >= self.numberOfPages) {
        currentPage = self.numberOfPages - 1;
    }
    _currentPage = currentPage;
    [self drawDots];
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    [self drawDots];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    [self drawDots];
}

- (void)drawDots {
    self.layer.sublayers = nil;
    CGSize defaultSize = CGSizeMake(ZZPageControlDotWidth, ZZPageControlDotWidth);
    CGSize currentSize = CGSizeMake(ZZPageControlDotWidth * 2 + ZZPageControlDotMargin, ZZPageControlDotWidth);
    CGFloat cornerRadius = 2.5;
    CGFloat currentMaxX = -ZZPageControlDotMargin;
    for (NSInteger index = 0; index < self.numberOfPages; index++) {
        CGRect rect = CGRectZero;
        BOOL isCurrent = index == self.currentPage;
        rect.size = (isCurrent) ? currentSize : defaultSize;
        rect.origin = CGPointMake((currentMaxX + ZZPageControlDotMargin), 0);
        currentMaxX = CGRectGetMaxX(rect);
        
        CALayer *layer = [CALayer layer];
        layer.frame = rect;
        layer.masksToBounds = YES;
        layer.cornerRadius = cornerRadius;
        layer.backgroundColor = [((isCurrent) ? self.currentPageIndicatorTintColor : self.pageIndicatorTintColor) CGColor];
        [self.layer addSublayer:layer];
    }
}

@end

@interface AdvertiseCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) AdvertiseViewSelectionHandler selectionHandler;

@end

@implementation AdvertiseCell

- (instancetype)init {
    self = [super init];
    self.clipsToBounds = YES;
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
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor colorWithHue:(arc4random() % 256) / 200.5 saturation:0.5 brightness:0.5 alpha:1];
        [self insertSubview:_imageView atIndex:0];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightMedium];
//        _titleLabel.backgroundColor = [UIColor colorWithHue:(arc4random() % 256) / 200.5 saturation:1 brightness:1 alpha:1];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:13]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:25]];
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
//    self.titleLabel.frame = CGRectMake(10, 10, 100, 20);
}

@end

CGFloat advertiseViewAutoScrollTime = 3.0;

@interface AdvertiseView()<UIScrollViewDelegate> {
    NSTimer *_timer;
    UIScrollView *_scroll;
    ZZPageControl *_pageControl;
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
    
    [_timer invalidate];
    if (self.isOnlyOne == NO) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:advertiseViewAutoScrollTime target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:advertiseViewAutoScrollTime]];
    }
    
    _scroll = [[UIScrollView alloc] init];
    
    _scroll.scrollsToTop = NO;
    _scroll.pagingEnabled = YES;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.bounces = NO;
    _scroll.backgroundColor = [UIColor yellowColor];
    if (self.isOnlyOne == NO) {
        _scroll.delegate = self;
    }
    
    [self addSubview:_scroll];
    
    for (int i = 0; i < _contentCount; i++) {
        AdvertiseCell *cell = [[AdvertiseCell alloc] init];
        cell.tag = i;
        if (contentRequest) {
            contentRequest(cell, i);
        }
        cell.selectionHandler = selection;
        [_scroll addSubview:cell];
    }
    
    _pageControl = [[ZZPageControl alloc] init];
    _pageControl.numberOfPages = _contentCount;
    _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.5];
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:_pageControl];
    
    if (_contentCount <= 1) {
        _pageControl.hidden = YES;
    }
    
    [self layoutIfNeeded];
}

- (void)scrollToPage:(NSInteger)page {
    //    NSLog(@"to %d",page);
    CGFloat offx = _scroll.frame.size.width * (page + 1);
    [_scroll setContentOffset:CGPointMake(offx, 0) animated:YES];
    
    //    pageControl.currentPage = page;
}

- (UIView *)mySubviewWithTag:(NSInteger)tag {
    for (UIView *view in _scroll.subviews) {
        if (view.tag == tag) {
            return view;
        }
    }
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentPage = [self currentPage];
    _pageControl.currentPage = currentPage;
    
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
        for (UIView *view in _scroll.subviews) {
            NSInteger index = (view.tag + 1);
            view.frame = CGRectMake(index * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:advertiseViewAutoScrollTime]];
}

- (NSInteger)currentPage {
    // fake offset
    NSInteger pa = (_scroll.contentOffset.x / _scroll.frame.size.width) - 1;
    return pa;
}

- (NSInteger)numbersOfPage {
    return _contentCount;
}

- (void)scrollToNextPage {
    NSInteger curr = [self currentPage];
    [self scrollToPage:curr + 1];
}

- (void)dealloc {
    _scroll.delegate = nil;
    [_timer invalidate];
    NSLog(@"adver deal");
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _scroll.frame = self.bounds;
    _scroll.contentSize = self.isOnlyOne ? self.bounds.size : CGSizeMake((2 + _contentCount) * self.bounds.size.width, self.bounds.size.height);
    CGRect pageFrame = _pageControl.frame;
    pageFrame.origin = CGPointMake(25, self.bounds.size.height - pageFrame.size.height - 30);
    _pageControl.frame = pageFrame;
    for (UIView *view in _scroll.subviews) {
        NSInteger index = self.isOnlyOne ? view.tag : (view.tag + 1);
        view.frame = CGRectMake(index * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        [view layoutIfNeeded];
    }
    if (self.isOnlyOne == NO) {
        _scroll.contentOffset = CGPointMake(self.bounds.size.width, 0);
    }
}

@end
