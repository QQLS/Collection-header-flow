//
//  BQPlainFlowLayout.m
//  CollectionView 头部悬停
//
//  Created by 时彬强 on 16/7/15.
//  Copyright © 2016年 QQLS. All rights reserved.
//

#import "BQPlainFlowLayout.h"

@implementation BQPlainFlowLayout

#pragma mark - Initial
- (instancetype)init {
    
    if (self = [super init]) {
        [self p_initial];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    if (self = [super initWithCoder:coder]) {
        [self p_initial];
    }
    return self;
}

- (void)p_initial {
    self.topOffsetY = 64;
    self.footerViewEffect = NO;
}

#pragma mark - Override
/** 是否一滑动 collectionView 就进行重新布局, 调用 layoutAttributesForElementsInRect: 方法 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    // 获取当前显示区域的属性数组
    NSMutableArray *superAttributes = [super layoutAttributesForElementsInRect:rect].mutableCopy;
    // 创建存储索引的集合,保证唯一性
    NSMutableIndexSet *noneHeaderSection = [NSMutableIndexSet indexSet];
    // 获取当前屏幕中所有的 section 集合
    for (UICollectionViewLayoutAttributes *attributes in superAttributes) {
        // 如果当前的元素分类是一个 Item,将 Item 所在的 section 加入集合,重复的话会自动过滤
        // 因为有些 section 是 header 不在屏幕上,但是 cell 还在
        if (UICollectionElementCategoryCell == attributes.representedElementCategory) {
            [noneHeaderSection addIndex:attributes.indexPath.section];
        }
    }
    
    // 将当前屏幕中拥有的 header 的 section 从集合中移除
    // 得到一个当前屏幕中没有 header 的 section 集合
    // 正常情况下,随着手指往上移,header 脱离屏幕会被系统回收而 cell 尚在,也会触发该方法
    for (UICollectionViewLayoutAttributes *attributes in superAttributes) {
        // 如果当前的元素是一个 header,将 header 所在的 section 从集合中移除
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [noneHeaderSection removeIndex:attributes.indexPath.section];
        }
    }
    
    // 对没有 header 的 section 进行处理
    // 因为正常情况下 section 中的 header 会消失,只留下 section 中的  Item 显示
    // 但是由于要悬停处理,需要对这种情况下的 header 进行特殊处理
    // 因此需要将其考虑进去,将它们加进去进行接下来的处理
    [noneHeaderSection enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        // 取得当前 section 的第一个 Item 的 indexPath,第一项为 header
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        // 获取当前 section 下已经离开屏幕的 header 的 attributes
        UICollectionViewLayoutAttributes *headerAttributes = [super layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        // 如果当前 section 的 header 确实有因为离开屏幕而被系统回收,就将其添加进去进行特殊考虑
        if (headerAttributes) {
            [superAttributes addObject:headerAttributes];
        }
    }];
    
    // 重新考虑当前应该显示的 header
    // 改变 header 的 attributes 中的参数,使它可以在当前 section 还没完全离开屏幕的时候一直显示
    for (UICollectionViewLayoutAttributes *attributes in superAttributes) {
        // 只处理 header, 使最上面 section 的 header 悬停
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            // 获取当前 header 所在 section 的 Item 数量
            NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:attributes.indexPath.section];
            // 获取第一个 Item 和最后一个 Item 的 indexPath
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:attributes.indexPath.section];
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:MAX(0, numberOfItemsInSection - 1) inSection:attributes.indexPath.section];
            // 获取第一个 Item 和最后一个 Item 的 attributes
            UICollectionViewLayoutAttributes *firstItemAttributes = nil;
            UICollectionViewLayoutAttributes *lastItemAttributes = nil;
            if (numberOfItemsInSection != 0) { // 如果存在 Item,就获取第一个和最后一个 Item 的 attributes
                firstItemAttributes = [super layoutAttributesForItemAtIndexPath:firstIndexPath];
                lastItemAttributes = [super layoutAttributesForItemAtIndexPath:lastIndexPath];
            } else { // 如果不存在 Item 就模拟出一个 Item,放在 header 下面,高度为 0,同时还可以隔着 sectionInset 的 top
                firstItemAttributes = [[UICollectionViewLayoutAttributes alloc] init];
                firstItemAttributes.frame = CGRectMake(self.sectionInset.left, CGRectGetMaxY(attributes.frame) + self.sectionInset.top
                                                       , self.itemSize.width, 0);
                // 只有一个,是第一个也是最后一个
                lastItemAttributes = firstItemAttributes;
            }
            
            // 获取当前 header 的 frame
            CGRect headerFrame = attributes.frame;
            // 偏移量 = 当前偏移量 offset.y + 导航栏影响的偏移量 topOffsetY
            CGFloat offset = self.collectionView.contentOffset.y + self.topOffsetY;
            // header.y = firstItem.y - header.height - sctionInset.top
            CGFloat headerY = firstItemAttributes.frame.origin.y - headerFrame.size.height - self.sectionInset.top;
            // 哪个大取哪个,保证 header 悬停
            // 针对当前 header 都是 offset 更大,针对下一个 header 则会是 headerY 大,各自处理
            CGFloat headerShowY = MAX(offset, headerY);
            
            // 获取 header 消失点的 y 值
            // headerMissing.y = lastItem.maxY + sectionInset.bottom + (footer.height)? - header.height;
            CGFloat headerHiddenY = CGRectGetMaxY(lastItemAttributes.frame) + self.sectionInset.bottom - headerFrame.size.height;
            if (!self.footerViewEffect) {
                UICollectionViewLayoutAttributes *footerAttributes = [super layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:attributes.indexPath];
                headerHiddenY += footerAttributes.frame.size.height;
            }
            
            // 相对于显示点和消失点,应该取其最小的
            // 最开始是一直根据 headerShowY 来显示,但是到达最大点后 headerShowY 和 headerHiddenY 一样大
            // 但是后来 headerShowY 依然在增大,而应该将 header 消失在 headerHiddenY 处一直不动,不应该再进行变化
            // 这样当向下拉时可以从最后位置开始显示 section 的 header
            // 消失之后 headerShowY 是会一直大于 headerHiddenY 的
            headerFrame.origin.y = MIN(headerShowY, headerHiddenY);
            // 给 header 的 attributes 重新复制
            attributes.frame = headerFrame;
            
            // 如果按照正常情况下,header 离开屏幕被系统回收,而 header 的层次关系又与 Item 相等,如果不去理会,会出现 Item 覆盖 header 的情况
            // 打印出来的 Item 的 zIndex 数值为 0,header 和 footer 的 zIndex 是10,如果不进行调整就会出现 footer 覆盖 header 的问题
            attributes.zIndex += 1;
        }
    }
    
    // 转回不可变数组
    return superAttributes.copy;
}

@end
