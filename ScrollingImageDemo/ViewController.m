//
//  ViewController.m
//  ScrollingImageDemo
//
//  Created by zjj on 2019/8/30.
//  Copyright © 2019年 zjj. All rights reserved.
//

#import "ViewController.h"
#import "AdvertiseView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AdvertiseView *ad = [[AdvertiseView alloc] initWithFrame:CGRectMake(40, 40, 200, 140)];
    [ad setShowingAdvertiseCount:4 contentRequest:^(AdvertiseCell *cell, NSInteger index) {
        cell.title = @(index).stringValue;
    } selection:^(AdvertiseView *adView, NSInteger index) {
        
    }];
    [self.view addSubview:ad];
}


@end
