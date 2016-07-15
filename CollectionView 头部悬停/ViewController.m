//
//  ViewController.m
//  CollectionView 头部悬停
//
//  Created by 时彬强 on 16/7/15.
//  Copyright © 2016年 QQLS. All rights reserved.
//

#import "ViewController.h"

#import "BQPlainFlowLayout.h"
#import "HeaderFooterView.h"

#define kCellReuseID @"UICollectionViewCell"
#define kHeaderReuseID @"Header"
#define kFooterReuseID @"Footer"

@interface ViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation ViewController

- (instancetype)init {
    
    if (self = [super init]) {
        BQPlainFlowLayout *layout = [[BQPlainFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(100, 100);
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.topOffsetY = 64.0f;
//        layout.footerViewEffect = YES;
        self = [super initWithCollectionViewLayout:layout];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellReuseID];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HeaderFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseID];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HeaderFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterReuseID];
}

#pragma mark - UICollectionView dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 10;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HeaderFooterView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderReuseID forIndexPath:indexPath];
        header.backgroundColor = [UIColor redColor];
        header.content = [NSString stringWithFormat:@"第%li个分区的header", indexPath.section];
        return header;
    } else {
        HeaderFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kFooterReuseID forIndexPath:indexPath];
        footer.backgroundColor = [UIColor greenColor];
        footer.content = [NSString stringWithFormat:@"第%li个分区的footer", indexPath.section];
        return footer;
    }
}

#pragma mark - UICollectionView delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(0, 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return CGSizeMake(0, 20);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
