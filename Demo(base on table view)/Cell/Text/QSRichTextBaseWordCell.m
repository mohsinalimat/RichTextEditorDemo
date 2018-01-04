//
//  QSRichTextBaseWordCell.m
//  Demo(base on table view)
//
//  Created by Xuzixiang on 2018/1/4.
//  Copyright © 2018年 frankxzx. All rights reserved.
//

#import "QSRichTextBaseWordCell.h"
#import "QSRichTextMoreView.h"
#import "QSRichTextAttributes.h"

@interface QSRichTextBaseWordCell () <YYTextViewDelegate, QSRichTextEditorFormat>

@property(nonatomic, strong, readwrite) QSRichTextView * textView;

@end

@implementation QSRichTextBaseWordCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeUI];
    }
    return self;
}

-(void)makeUI {
    [self.contentView addSubview:self.textView];
    self.textView.textContainerInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.textView.scrollEnabled = NO;
    self.textView.typingAttributes = [QSRichTextAttributes defaultAttributes];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat contentLabelWidth = self.contentView.qmui_width;
    CGSize textViewSize = [self.textView sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
    CGFloat textCellHeight = textViewSize.height;
    textCellHeight = MAX(50, textCellHeight);
    self.textView.frame = CGRectFlatMake(0, 0, contentLabelWidth, textCellHeight);
}

-(CGSize)sizeThatFits:(CGSize)size {
    
    CGSize resultSize = CGSizeMake(size.width, 0);
    CGFloat resultHeight = 0;
    CGSize contentSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(self.textView.bounds), CGFLOAT_MAX)];
    resultHeight += contentSize.height;
    resultSize.height = resultHeight;
    return resultSize;
}

- (void)renderRichText:(NSAttributedString *)text {
    
    self.textView.attributedText = text;
    self.textView.textAlignment = NSTextAlignmentLeft;
    [self setNeedsLayout];
}

- (NSAttributedString *)attributeStringWithString:(NSString *)textString lineHeight:(CGFloat)lineHeight {
    if (!textString.qmui_trim && textString.qmui_trim.length <= 0) return nil;
    NSAttributedString *attriString = [[NSAttributedString alloc] initWithString:textString attributes:@{NSParagraphStyleAttributeName:[NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:lineHeight lineBreakMode:NSLineBreakByTruncatingTail]}];
    return attriString;
}

-(QSRichTextView *)textView {
    if (!_textView) {
        _textView = [QSRichTextView new];
        _textView.scrollEnabled = NO;
        _textView.delegate = self;
    }
    return _textView;
}

-(void)setQs_delegate:(id<QSRichTextWordCellDelegate>)qs_delegate {
    self.textView.qs_delegate = qs_delegate;
    _qs_delegate = qs_delegate;
}

#pragma mark -
#pragma mark YYTextViewDelegate
-(void)textViewDidChange:(YYTextView *)textView {
    if (self.qs_delegate && [self.qs_delegate respondsToSelector:@selector(qsTextViewDidChange:)]) {
        [self.qs_delegate qsTextViewDidChange:(QSRichTextView *)textView];
    }
    [self handleTextChanged:self.textView];
}

- (void)handleTextChanged:(id)sender {
    
    QSRichTextView *textView = nil;
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        id object = ((NSNotification *)sender).object;
        if (object == self) {
            textView = (QSRichTextView *)object;
        }
    } else if ([sender isKindOfClass:[QSRichTextView class]]) {
        textView = (QSRichTextView *)sender;
    }
    
    if (textView) {
        
        CGFloat resultHeight = [textView sizeThatFits:CGSizeMake(CGRectGetWidth(self.textView.bounds), CGFLOAT_MAX)].height;
        CGFloat oldValue = CGRectGetHeight(self.contentView.bounds);
        
        NSLog(@"handleTextDidChange, text = %@, resultHeight = %f old value = %f", textView.text, resultHeight, oldValue);
        
        // 通知delegate去更新textView的高度
        if ([textView.qs_delegate respondsToSelector:@selector(qsTextView:newHeightAfterTextChanged:)] && resultHeight != oldValue) {
            [textView.qs_delegate qsTextView:self.textView newHeightAfterTextChanged:resultHeight];
        }
    }
}

#pragma mark -
#pragma mark QSRichTextEditorFormat

//当前设置了三种默认字体的样式
-(void)formatDidSelectTextStyle:(QSRichEditorTextStyle)style {
    [self.qs_delegate formatDidSelectTextStyle:style];
}

//加粗
- (void)formatDidToggleBold {
    [self.qs_delegate formatDidToggleBold];
}

//斜体
- (void)formatDidToggleItalic {
    [self.qs_delegate formatDidToggleItalic];
}

//中划线
- (void)formatDidToggleStrikethrough {
    [self.qs_delegate formatDidToggleStrikethrough];
}

//对齐
- (void)formatDidChangeTextAlignment:(NSTextAlignment)alignment {
    [self.qs_delegate formatDidChangeTextAlignment:alignment];
}

//设置序列样式
- (void)toggleListType:(QSRichTextListStyleType)listType {
    [self.qs_delegate toggleListType:listType];
}

-(void)formatDidToggleBlockquote {
    [self.qs_delegate formatDidToggleBlockquote];
}

//设置超链接
- (void)insertHyperlink:(QSRichTextHyperlink *)hyperlink {
    [self.qs_delegate insertHyperlink:hyperlink];
}

-(void)insertVideo {
    [self.qs_delegate insertVideo];
}

-(void)insertSeperator {
    [self.qs_delegate insertSeperator];
}

-(void)insertPhoto {
    [self.qs_delegate insertPhoto];
}

-(BOOL)becomeFirstResponder {
    if (self.textView) {
        [self.textView becomeFirstResponder];
        return YES;
    }
    return NO;
}

@end
