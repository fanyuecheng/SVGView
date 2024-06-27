//
//  ViewController.m
//  SVGView
//
//  Created by Fancy on 2023/8/9.
//

#import "ViewController.h"
#import "SVGView.h"
#import "SVGConvert.h"

@interface ViewController ()

@property (nonatomic, strong) SVGConvert *convert;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SVGView *web = [[SVGView alloc] init];
    [web setSVGWithName:@"mintendoo"];
    [web sizeToFit];
    CGFloat w = CGRectGetWidth(self.view.bounds);
    web.frame = CGRectMake(0, 0, w, w / (web.frame.size.width / web.frame.size.height));
    web.center = self.view.center;
    web.layer.borderWidth = 1;
    web.layer.borderColor = UIColor.redColor.CGColor;
    
    [self.view addSubview:web];
    
    SVGConvert *convert = [SVGConvert sharedInstance];
    NSURL *url = [NSBundle.mainBundle URLForResource:@"mintendoo" withExtension:@"svg"];
    [convert convertWithDatas:@[[NSData dataWithContentsOfURL:url]]
                    completed:^(NSArray * _Nonnull imageArray, NSError * _Nonnull error) {
        NSLog(@"%@", imageArray);
    }];
}


@end
