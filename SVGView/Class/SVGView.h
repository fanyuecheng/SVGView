//
//  SVGView.h
//  SVGView
//
//  Created by Fancy on 2023/8/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WKWebView;
@interface SVGView : UIView

@property (nonatomic, strong, readonly) WKWebView *webView;
@property (nonatomic, assign, readonly) CGSize    size;
@property (nonatomic, copy,   readonly) NSString  *content;
@property (nonatomic, strong, readonly) UIImage   *image;

- (void)setSVGWithURL:(NSURL *)url;
- (void)setSVGWithName:(NSString *)name;
- (void)setSVGWithContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
