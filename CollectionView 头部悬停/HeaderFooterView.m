//
//  HeaderFooterView.m
//  CollectionView 头部悬停
//
//  Created by 时彬强 on 16/7/15.
//  Copyright © 2016年 QQLS. All rights reserved.
//

#import "HeaderFooterView.h"

@interface HeaderFooterView ()

/** 内容标签 */
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;

@end

@implementation HeaderFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setContent:(NSString *)content {
    
    _content = [content copy];
    
    self.contentLbl.text = content;
}

@end
