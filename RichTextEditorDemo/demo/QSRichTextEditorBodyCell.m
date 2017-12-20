//
//  QSRichTextEditorBodyCell.m
//  RichTextEditorDemo
//
//  Created by Xuzixiang on 2017/12/8.
//  Copyright © 2017年 frankxzx. All rights reserved.
//

#import "QSRichTextEditorBodyCell.h"

@interface QSRichTextEditorBodyCell()

@property(nonatomic, assign) CGFloat updateCellHeight;

@end

@implementation QSRichTextEditorBodyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentViewDidLayout:) name:DTAttributedTextContentViewDidFinishLayoutNotification object:nil];
    }
    return self;
}

-(void)contentViewDidLayout:(NSNotification *)notification {
    [self.parentTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    NSValue *value = notification.userInfo[@"OptimalFrame"];
    if (value) {
        CGRect rect = value.CGRectValue;
        self.updateCellHeight = rect.size.height;
    }
}

- (void)initSubviews {
    [self.contentView addSubview:self.richEditor];
}

-(DTRichTextEditorView *)richEditor {
    if (!_richEditor) {
        _richEditor = [[DTRichTextEditorView alloc]init];
        _richEditor.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _richEditor.defaultFontSize = 16;
        _richEditor.attributedTextContentView.edgeInsets = UIEdgeInsetsMake(20, 18, 20, 18);
    }
    return _richEditor;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = CGSizeMake(size.width, 0);
    resultSize.height = MAX(self.updateCellHeight, [QSRichTextEditorBodyCell cellRect].size.height);
    return resultSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.richEditor.frame = self.contentView.bounds;
    self.richEditor.attributedTextContentView.frame = self.richEditor.bounds;
}

+(CGRect)cellRect {
    return CGRectMake(0, 0, SCREEN_WIDTH, 400);
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
