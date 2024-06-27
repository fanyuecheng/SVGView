//
//  SVGConvert.m
//  SVGView
//
//  Created by Fancy on 2024/6/27.
//

#import "SVGConvert.h"
#import <WebKit/WebKit.h>

@interface SVGConvert () <WKNavigationDelegate>
 
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy)   NSString  *convertJavaScript;
@property (nonatomic, copy)   void (^completedBlock)(NSArray *imageArray, NSError *error);

@end

@implementation SVGConvert

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SVGConvert *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)convertWithDatas:(NSArray <NSData *> *)dataArray
               completed:(void (^)(NSArray *imageArray, NSError *error))completed {
    self.completedBlock = completed;
    NSString *html = [self htmlStringWithDatas:dataArray];
    [self.webView loadHTMLString:html baseURL:nil];
}

#pragma mark - Private Method
- (NSString *)htmlStringWithDatas:(NSArray<NSData *> *)dataArray {
    NSMutableString *html = [NSMutableString stringWithString:@" \
    <html>\
    <head>\
    </head>\
    <body>"];
    for (NSData *data in dataArray) {
        NSString *base64 = [data base64EncodedStringWithOptions:kNilOptions];
        [html appendFormat:@"\
         <img src='data:image/svg+xml;base64,%@'>\
         ", base64];
    }
    [html appendString:@"\
     </body>\
     </html>\
    "];
    return html.copy;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:WKWebViewConfiguration.new];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (NSString *)convertJavaScript {
    if (!_convertJavaScript) {
        _convertJavaScript = @"\
           function imagePNGData() {\
              var imageArray = document.getElementsByTagName('img');\
              var pngArray = new Array();\
              for (var index =0; index < imageArray.length; index++) {\
                  var image = imageArray[index];\
                  var canvas = document.createElement('canvas');\
                  canvas.width = image.width;\
                  canvas.height = image.height;\
                  var context = canvas.getContext('2d');\
                  context.drawImage(image, 0, 0);\
                  pngArray.push(canvas.toDataURL('image/png'))\
              }\
              return pngArray;\
           }\
           imagePNGData()";
    }
    return _convertJavaScript;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    __weak typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:self.convertJavaScript
                   completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            !strongSelf.completedBlock ? : strongSelf.completedBlock(nil, error);
            return;
        }
        if (!result || ![result isKindOfClass:NSArray.class]) {
            !strongSelf.completedBlock ? : strongSelf.completedBlock(nil, [NSError errorWithDomain:@"none result" code:0 userInfo:nil]);
            return;
        }
        NSString *pngPrefix = @"data:image/png;base64,";
        NSMutableArray <UIImage *> *imageArray = [NSMutableArray array];
        for (NSString *base64 in result) {
            if ([base64 hasPrefix:pngPrefix]) {
                NSString *base64String = [base64 stringByReplacingCharactersInRange:NSMakeRange(0, pngPrefix.length) withString:@""];
                NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:kNilOptions];
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    [imageArray addObject:image];
                }
            }
        }
        !strongSelf.completedBlock ? : strongSelf.completedBlock(imageArray, nil);
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    !self.completedBlock ? : self.completedBlock(nil, error);
}

@end
