//
//  SVGView.m
//  SVGView
//
//  Created by Fancy on 2023/8/9.
//

#import "SVGView.h"
#import <WebKit/WebKit.h>

@interface SVGView () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView              *webView;
@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@property (nonatomic, assign) CGSize   size;
@property (nonatomic, copy)   NSString *content;
@property (nonatomic, strong) UIImage  *image;

@end
 
@implementation SVGView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    [self addSubview:self.webView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.webView.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (CGSizeEqualToSize(self.size, CGSizeZero)) {
        return [super sizeThatFits:size];
    }
    return self.size;
}

#pragma mark - Method
- (void)setSVGWithURL:(NSURL *)url {
    NSString *content = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:url] encoding:NSUTF8StringEncoding];
    [self setSVGWithContent:content];
}

- (void)setSVGWithName:(NSString *)name {
    NSURL *url = [NSBundle.mainBundle URLForResource:name withExtension:@"svg"];
    [self setSVGWithURL:url];
}

- (void)setSVGWithContent:(NSString *)content {
    NSString *html = [[self placeholderHTMLString] stringByReplacingOccurrencesOfString:@"SVGSTRING" withString:content];
    self.content = [content copy];
    [self.webView loadHTMLString:html baseURL:nil];
}

#pragma mark - Privite Method
- (NSString *)placeholderHTMLString {
    return @"<!DOCTYPE html>\
    <html>\
        <style>\
            html,\
            svg {\
                position: fixed;\
                right: 0px;\
                left: 0px;\
                top: 0px;\
                width: calc(100% - 100px);\
                height: calc(100% - 100px);\
                margin-top: auto;\
                margin-bottom: auto;\
                margin-left: auto;\
                margin-right: auto;\
            }\
        </style>\
        \
        <head>\
            <meta name='viewport' content='initial-scale=0.1, minimum-scale=0.1, maximum-scale=4.0, user-scalable=yes'>\
        </head>\
        \
        <body>\
            SVGSTRING\
        </body>\
        \
    </html>";
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    WKSnapshotConfiguration *configuration = [[WKSnapshotConfiguration alloc] init];
    __weak __typeof(self)weakSelf = self;
    [webView takeSnapshotWithConfiguration:configuration completionHandler:^(UIImage * _Nullable snapshotImage, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.image = snapshotImage;
    }];
}

#pragma mark - Get
- (WKWebViewConfiguration *)configuration {
    if (!_configuration) {
        _configuration = [[WKWebViewConfiguration alloc] init];
    }
    return _configuration;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.configuration];
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _webView.scrollView.userInteractionEnabled = NO;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

#pragma mark - Set
- (void)setContent:(NSString *)content {
    _content = content;
      
    NSString *pattern = @"(?<=viewBox=\").*?(?=\")";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:content options:0 range:NSMakeRange(0, content.length)];
    if (result) {
        NSString *viewBox = [content substringWithRange:result.range];
        NSArray *value = [viewBox componentsSeparatedByString:@" "];
        
        if (value.count == 4) {
            self.size = CGSizeMake([value[2] floatValue], [value[3] floatValue]);
        }
    }
}

@end

