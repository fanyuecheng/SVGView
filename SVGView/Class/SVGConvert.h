//
//  SVGConvert.h
//  SVGView
//
//  Created by Fancy on 2024/6/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
 
@interface SVGConvert : NSObject

+ (instancetype)sharedInstance;

- (void)convertWithDatas:(NSArray<NSData *> *)dataArray
               completed:(void (^)(NSArray *imageArray, NSError *error))completed;

@end

NS_ASSUME_NONNULL_END
