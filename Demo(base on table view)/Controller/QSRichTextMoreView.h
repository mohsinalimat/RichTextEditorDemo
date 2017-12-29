//
//  QSRichTextMoreView.h
//  Demo(base on table view)
//
//  Created by Xuzixiang on 2017/12/29.
//  Copyright © 2017年 frankxzx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>
#import "QSRichTextEditorAction.h"

@interface QSRichTextMoreView : UIView

@property (weak, nonatomic) id<QSRichTextEditorAction> actionDelegate;

@end