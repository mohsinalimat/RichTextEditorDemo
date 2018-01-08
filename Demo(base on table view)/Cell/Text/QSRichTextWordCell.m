//
//  QSRichTextWordCell.m
//  Demo(base on table view)
//
//  Created by Xuzixiang on 2017/12/29.
//  Copyright © 2017年 frankxzx. All rights reserved.
//

#import "QSRichTextWordCell.h"
#import "QSRichTextMoreView.h"
#import "QSRichTextAttributes.h"

@interface QSRichTextWordCell () <YYTextViewDelegate, QSRichTextEditorFormat>

@end

@implementation QSRichTextWordCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeUI];
    }
    return self;
}

-(void)makeUI {
    [super makeUI];
    self.textView.typingAttributes = [QSRichTextAttributes defaultAttributes];
}

//-(void)richTextEditorOpenMoreView {
//    NSInteger wordCount = [self.textView.attributedText yy_plainTextForRange:self.textView.attributedText.yy_rangeOfAll].length;
//    [self.toolBar setupTextCountItemWithCount:wordCount];
//    self.textView.inputView = self.editorMoreView;
//    [self.textView reloadInputViews];
//}
//
//-(void)richTextEditorCloseMoreView {
//    [self.toolBar initEditorBarItems];
//    self.textView.inputView = nil;
//    [self.textView reloadInputViews];
//}

- (void)setBodyTextStyleWithPlaceholder:(BOOL)isFirstLine {
    self.textView.placeholderTextColor = UIColorGrayLighten;
    self.textView.placeholderFont = UIFontMake(16);
    self.textView.placeholderText = isFirstLine ? @"请输入正文" : nil;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.textView.attributedText = nil;
    self.textView.placeholderText = nil;
}

-(BOOL)becomeFirstResponder {
    [self.toolBar initEditorBarItems];
    return [super becomeFirstResponder];
}

-(QSRichTextBar *)toolBar {
    return (QSRichTextBar *)self.textView.inputAccessoryView;
}

@end