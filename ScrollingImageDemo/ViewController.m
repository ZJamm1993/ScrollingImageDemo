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

@property (weak, nonatomic) IBOutlet AdvertiseView *adview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.adview setShowingAdvertiseCount:4 contentRequest:^(AdvertiseCell *cell, NSInteger index) {
        if (index == 0 || index == 2) {
            cell.title = @"First Line";
        } else {
            cell.title = @"First\nSecond Line";
        }
        cell.title = [NSString stringWithFormat:@"%@: %@", @(index).stringValue, cell.title];
    } selection:^(id adView, NSInteger index) {
        NSLog(@"%@", adView);
    }];
}


@end
