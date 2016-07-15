//
//  BQPlainFlowLayout.h
//  CollectionView 头部悬停
//
//  Created by 时彬强 on 16/7/15.
//  Copyright © 2016年 QQLS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BQPlainFlowLayout : UICollectionViewFlowLayout

/** 导航栏偏移量 */
@property (nonatomic, assign) CGFloat topOffsetY;
/** 是否考虑 footerView 的影响, 即同一个分组下 headerView 碰到 footerView 就不再悬停 */
@property (nonatomic, assign, getter=isFooterViewEffect) BOOL footerViewEffect;

@end
