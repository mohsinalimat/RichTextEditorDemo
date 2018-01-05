//
//  QSRichTextWordCell.h
//  Demo(base on table view)
//
//  Created by Xuzixiang on 2017/12/29.
//  Copyright © 2017年 frankxzx. All rights reserved.
//

#import "QSRichTextBaseWordCell.h"

@interface QSRichTextWordCell : QSRichTextBaseWordCell

@property(nonatomic, strong, readonly) QSRichTextBar *toolBar;
- (void)setBodyTextStyleWithPlaceholder:(BOOL)isFirstLine;

@end
