//
//  AdvertiseView.h
//  yangsheng
//
//  Created by Macx on 17/7/7.
//  Copyright © 2017年 jam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvertiseCell : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;

@end

@class AdvertiseView;

typedef void (^AdvertiseViewContentRequestHandler)(AdvertiseCell *cell, NSInteger index);
typedef void (^AdvertiseViewSelectionHandler)(AdvertiseCell *cell, NSInteger index);

@interface AdvertiseView : UIView

- (void)setShowingAdvertiseCount:(NSInteger)count contentRequest:(AdvertiseViewContentRequestHandler)contentRequest selection:(AdvertiseViewSelectionHandler)selection;

@end
