//
//  QSRichTextController.m
//  Demo(base on table view)
//
//  Created by Xuzixiang on 2017/12/29.
//  Copyright © 2017年 frankxzx. All rights reserved.
//

#import "QSRichTextController.h"
#import "QSRichTextViewModel.h"
#import "QSRichTextWordCell.h"
#import "QSRichTextImageCell.h"
#import "QSRichTextVideoCell.h"
#import "QSRichTextSeparatorCell.h"
#import "QSRichTextAddCoverCell.h"
#import "QSRichTextBar.h"
#import "QSRichTextTitleCell.h"
#import "QSRichTextBlockCell.h"
#import "QSRichTextImageCaptionCell.h"
#import "QSRichTextAttributes.h"
#import "QSTextFieldsViewController.h"
#import "QSRichTextListCell.h"

@interface QSRichTextController () <QSRichTextWordCellDelegate, QSRichTextImageViewDelegate, QSRichTextVideoViewDelegate>

@property(nonatomic, strong) QSRichTextViewModel *viewModel;

@end

@implementation QSRichTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    QSRichTextModel *titleModel = [[QSRichTextModel alloc]initWithCellType:QSRichTextCellTypeTitle];
    QSRichTextModel *coverModel = [[QSRichTextModel alloc]initWithCellType:QSRichTextCellTypeCover];
    QSRichTextModel *bodyModel = [[QSRichTextModel alloc]initWithCellType:QSRichTextCellTypeText];
    
    [self.viewModel addNewLinesWithModels:@[coverModel, titleModel, bodyModel]];
    [self.viewModel becomeActiveWithModel:bodyModel];
}

-(UITableViewCell *)qmui_tableView:(UITableView *)tableView cellWithIdentifier:(NSString *)identifier {
    
    QSRichTextCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        Class cellClass = NSClassFromString(identifier);
        cell = [((QSRichTextCell *)[cellClass alloc])initForTableView:tableView withReuseIdentifier:identifier];
    }
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QSRichTextModel *model = self.models[indexPath.row];
    QSRichTextCell *cell = [self qmui_tableView:tableView cellWithIdentifier:model.reuseID];
    
    switch (model.cellType) {
        case QSRichTextCellTypeText:
            ((QSRichTextWordCell *)cell).qs_delegate = self;
            [((QSRichTextWordCell *)cell) setBodyTextStyleWithPlaceholder:indexPath.row == 2];
            ((QSRichTextWordCell *)cell).textView.attributedText = model.attributedString;
            break;
        
        case QSRichTextCellTypeImage:
            ((QSRichTextImageCell *)cell).attchmentImage = [UIImage qmui_imageWithColor:[UIColor qmui_randomColor] size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT / 4) cornerRadius:0];
            ((QSRichTextImageCell *)cell).attchmentImageView.actionDelegate = self;
            break;
        
        case QSRichTextCellTypeVideo:
            ((QSRichTextVideoCell *)cell).thumbnailImage = [UIImage qmui_imageWithColor:[UIColor qmui_randomColor] size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT / 4) cornerRadius:0];
            ((QSRichTextVideoCell *)cell).videoView.actionDelegate = self;
            break;
            
        case QSRichTextCellTypeImageCaption:
            ((QSRichTextImageCaptionCell *)cell).qs_delegate = self;
            ((QSRichTextBlockCell *)cell).textView.attributedText = model.attributedString;
            break;
            
        case QSRichTextCellTypeTitle:
            ((QSRichTextTitleCell *)cell).qs_delegate = self;
            ((QSRichTextTitleCell *)cell).textView.attributedText = model.attributedString;
            break;
            
        case QSRichTextCellTypeTextBlock:
            ((QSRichTextBlockCell *)cell).qs_delegate = self;
            ((QSRichTextBlockCell *)cell).textView.attributedText = model.attributedString;
            break;
            
        case QSRichTextCellTypeListCellCircle:
        case QSRichTextCellTypeListCellNumber:
        case QSRichTextCellTypeListCellNone:
            ((QSRichTextListCell *)cell).qs_delegate = self;
            ((QSRichTextListCell *)cell).textView.attributedText = model.attributedString;
            if (model.prefixRanges) {
                ((QSRichTextListCell *)cell).prefixRanges = model.prefixRanges.mutableCopy;
            }
            [((QSRichTextListCell *)cell) updateListTypeStyle];
            break;
            
        case QSRichTextCellTypeCover:
        case QSRichTextCellTypeSeparator:
            break;
    }
    
    return  cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QSRichTextModel *model = self.models[indexPath.row];
    switch (model.cellType) {
        case QSRichTextCellTypeTitle:
        case QSRichTextCellTypeText:
        case QSRichTextCellTypeImageCaption:
        case QSRichTextCellTypeTextBlock:
        case QSRichTextCellTypeListCellNone:
        case QSRichTextCellTypeListCellNumber:
        case QSRichTextCellTypeListCellCircle: {
            CGFloat textCellHeight = model.cellHeight;
            textCellHeight = MAX(50, textCellHeight);
            return textCellHeight;
        }
        case QSRichTextCellTypeImage:
            return [self.tableView qmui_heightForCellWithIdentifier:model.reuseID cacheByIndexPath:indexPath configuration:^(id cell) {
                ((QSRichTextImageCell *)cell).attchmentImage = [UIImage qmui_imageWithColor:[UIColor qmui_randomColor] size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT / 4) cornerRadius:0];
            }];
            
        case QSRichTextCellTypeVideo:
            return [self.tableView qmui_heightForCellWithIdentifier:model.reuseID cacheByIndexPath:indexPath configuration:^(id cell) {
                ((QSRichTextVideoCell *)cell).thumbnailImage = [UIImage qmui_imageWithColor:[UIColor qmui_randomColor] size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT / 4) cornerRadius:0];
            }];
            
        case QSRichTextCellTypeSeparator:
            return 1;
            
        case QSRichTextCellTypeCover:
            return 120;
    }
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSIndexPath *currentTextViewIndexPath = [self.tableView qmui_indexPathForRowAtView:self.currentTextView];
//    if ([currentTextViewIndexPath isEqual:indexPath]) {
//        self.currentTextView.inputAccessoryView = ((QSRichTextWordCell *)[self.tableView cellForRowAtIndexPath:indexPath]).toolBar;
//        [self.currentTextView reloadInputViews];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSIndexPath *currentTextViewIndexPath = [self.tableView qmui_indexPathForRowAtView:self.currentTextView];
//    if ([currentTextViewIndexPath isEqual:indexPath]) {
//        self.currentTextView.inputAccessoryView = nil;
//        [self.currentTextView reloadInputViews];
//    }
//}

-(QSRichTextBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[QSRichTextBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        _toolBar.formatDelegate = self;
    }
    return _toolBar;
}

-(QSRichTextViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[QSRichTextViewModel alloc]init];
        _viewModel.viewController = self;
    }
    return _viewModel;
}

-(NSArray <QSRichTextModel *>*)models {
    return self.viewModel.models;
}

#pragma mark -
#pragma mark QSRichTextWordCellDelegate

-(void)qsTextViewDidChangeText:(QSRichTextView *)textView {
    NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:textView];
    QSRichTextModel *model = self.viewModel.models[indexPath.row];
    model.attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
    self.currentTextView = textView;
    
    if (model.cellType == QSRichTextCellTypeListCellNone||
        model.cellType == QSRichTextCellTypeListCellCircle ||
        model.cellType == QSRichTextCellTypeListCellNumber) {
        QSRichTextListCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        model.prefixRanges = cell.prefixRanges.mutableCopy;
    }
}

-(void)qsTextViewDidChanege:(QSRichTextView *)textView selectedRange:(NSRange)selectedRange {
    self.currentTextView = textView;
}

-(BOOL)qsTextView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:textView];
    QSRichTextModel *model = self.models[indexPath.row];
    if (model.cellType == QSRichTextCellTypeText) {
        return YES;
    }
    if ([text isEqualToString:@"\n"]) {
        NSString *string = [textView.text substringFromIndex:textView.text.length-1];
        if ([string isEqualToString:@"\n"]) {
            textView.text = [textView.text qmui_trimLineBreakCharacter];
            QSRichTextModel *emptyLine = [[QSRichTextModel alloc]initWithCellType:QSRichTextCellTypeText];
            [self.viewModel addNewLinesWithModels:@[emptyLine]];
            [self.viewModel becomeActiveWithModel:emptyLine];
            return NO;
        }
    }
    return YES;
}

- (void)qsTextFieldDeleteBackward:(QSRichTextView *)textView {
    
    NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:textView];
    NSInteger index = indexPath.row;
    //前三行不清空
    if (index < 3) {
        return;
    }
    if (index > 0 && self.models[index-1].cellType == QSRichTextCellTypeImage) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:index - 1 inSection:0];
        [self.viewModel removeLinesAtIndexPaths:@[previousIndexPath, indexPath]];
    } else {
        [self.viewModel removeLineAtIndexPath:indexPath];
    }
}

-(void)qsTextView:(QSRichTextView *)textView newHeightAfterTextChanged:(CGFloat)newHeight {
    NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:textView];
    [self.viewModel updateLayoutAtIndexPath:indexPath withCellheight: newHeight];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark -
#pragma mark QSRichTextImageViewDelegate
-(void)editorViewDeleteImage:(QSRichTextImageView *)imageView {
    NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:imageView];
    QSRichTextModel *model = self.viewModel.models[indexPath.row];
    [self.viewModel removeLineWithModel:model];
}

-(void)editorViewEditImage:(QSRichTextImageView *)imageView {
    
}

-(void)editorViewCaptionImage:(QSRichTextImageView *)imageView {
    NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:imageView];
    QSRichTextModel *model = self.viewModel.models[indexPath.row];
    if (model.captionModel) {
        //TODO: 响应已插入的图片注释
        return;
    } else {
        //关联一下
        [self.viewModel addImageCaptionWithImageModel:model];
        model.captionModel = self.viewModel.models[indexPath.row+1];
    }
    [self.viewModel becomeActiveWithModel:model.captionModel];
}

-(void)editorViewReplaceImage:(QSRichTextImageView *)imageView {
    
}

#pragma mark -
#pragma mark QSRichTextVideoViewDelegate
-(void)editorViewPlayVideo:(QSRichTextVideoView *)sender {
    
}

-(void)editorViewDeleteVideo:(QSRichTextVideoView *)sender {
    NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:sender];
    [self.viewModel removeLineAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark QSRichTextEditorFormat

-(void)formatTextBlock:(void (^)(NSMutableAttributedString *attributedText, NSRange range))block {
    QSRichTextView *textView = self.currentTextView;
    NSMutableAttributedString *text = textView.attributedText.mutableCopy;
    YYTextRange *yyRange = (YYTextRange *)textView.selectedTextRange;
    NSRange selectRange = [yyRange asRange];
    
    if (selectRange.length) {
        if (selectRange.location + selectRange.length <= textView.attributedText.length) {
            block(text, selectRange);
        }
        
        //记录光标位置
        __block NSInteger lastCurPosition = textView.selectedRange.location;
        dispatch_async(dispatch_get_main_queue(), ^{
            lastCurPosition += selectRange.length;
            textView.attributedText = text;
            textView.selectedTextRange = [YYTextRange rangeWithRange:NSMakeRange(lastCurPosition, 0)];
            [textView scrollRangeToVisible:selectRange];
        });
    }
}

-(void)formatDidToggleBold {
    [self formatTextBlock:^(NSMutableAttributedString *attributedText, NSRange range) {
        [attributedText yy_setFont:UIFontBoldMake(16) range:range];
    }];
}

-(void)formatDidToggleItalic {
    [self formatTextBlock:^(NSMutableAttributedString *attributedText, NSRange range) {
        [attributedText yy_setTextGlyphTransform:YYTextCGAffineTransformMakeSkew(-0.3, 0) range:range];
    }];
}

-(void)formatDidToggleStrikethrough {
    [self formatTextBlock:^(NSMutableAttributedString *attributedText, NSRange range) {
        YYTextDecoration *decoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle width:@1 color:UIColorBlack];
        [attributedText yy_setTextStrikethrough:decoration range:range];
    }];
}

-(void)formatDidSelectTextStyle:(QSRichEditorTextStyle)style {
    QSRichEditorFontStyle *fontStyle = [[QSRichEditorFontStyle alloc]initWithStyle:style];
    //如果没有选中的 range 全局修改输入的样式
    if (self.currentTextView.selectedRange.length < 1) {
        [QSRichTextAttributes setQSRichTextStyle:fontStyle];
        [self.currentTextView updateTextStyle];
    } else {
        [self formatTextBlock:^(NSMutableAttributedString *attributedText, NSRange range) {
            [attributedText yy_setFont:fontStyle.font range:range];
            [attributedText yy_setColor:fontStyle.textColor range:range];
        }];
    }
}

-(void)formatDidChangeTextAlignment:(NSTextAlignment)alignment {
    
    //当前整个一行 对齐方式 修改
    QSRichTextView *textView = self.currentTextView;
    NSMutableAttributedString *attributedText = textView.attributedText.mutableCopy;
    YYTextRange *yyRange = (YYTextRange *)textView.selectedTextRange;
    NSRange selectRange = [yyRange asRange];
    
    NSArray *subStrings = [attributedText.string componentsSeparatedByString:@"\n"];
    NSRange lineRange = NSMakeRange(0, 0);
    for (NSString *subString in subStrings) {
        lineRange = [attributedText.string rangeOfString:subString];
        if (NSLocationInRange(selectRange.location, lineRange)) {
            break;
        }
    }
    
    NSMutableParagraphStyle *paragraphStyle = [attributedText.yy_paragraphStyle mutableCopy];
    paragraphStyle.alignment = alignment;
    [attributedText yy_setParagraphStyle:paragraphStyle range:lineRange];
        
    //记录光标位置
    __block NSInteger lastCurPosition = textView.selectedRange.location;
    dispatch_async(dispatch_get_main_queue(), ^{
        lastCurPosition += selectRange.length;
        textView.attributedText = attributedText;
        textView.selectedRange = NSMakeRange(lastCurPosition, 0);
        [textView scrollRangeToVisible:selectRange];
    });
}

-(void)formatDidToggleBlockquote {
    [self.viewModel addNewLine:QSRichTextCellTypeTextBlock];
}

-(void)formatDidToggleListStyle:(QSRichTextListStyleType)listType {
    
    QSRichTextCellType cellType;
    switch (listType) {
        case QSRichTextListTypeNone:
            cellType = QSRichTextCellTypeListCellNone;
            break;
        case QSRichTextListTypeDecimal:
            cellType = QSRichTextCellTypeListCellNumber;
            break;
        case QSRichTextListTypeCircle:
            cellType = QSRichTextCellTypeListCellCircle;
            break;
    }
    [self.viewModel addNewLine:cellType];
}

-(void)insertSeperator {
    [self.viewModel addNewLine:QSRichTextCellTypeSeparator];
}

-(void)insertVideo {
    [self.viewModel addNewLine:QSRichTextCellTypeVideo];
}

-(void)insertPhoto {
    [self.viewModel addNewLine:QSRichTextCellTypeImage];
}

-(void)richTextEditorCloseMoreView {
    [self.currentTextView.inputAccessoryView initEditorBarItems];
    self.currentTextView.inputView = nil;
    [self.currentTextView reloadInputViews];
}

@end
