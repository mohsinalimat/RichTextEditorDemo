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
#import "QSRichTextImageCaptionCell.h"

@interface QSRichTextController () <QSRichTextWordCellDelegate, QSRichTextImageViewDelegate, QSRichTextVideoViewDelegate>

@property(nonatomic, strong) QSRichTextViewModel *viewModel;
@property(nonatomic, strong) NSIndexPath *currentEditingIndexPath;

@end

@implementation QSRichTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    QSRichTextModel *titleModel = [[QSRichTextModel alloc]initWithCellType:QSRichTextCellTypeTitle];
    QSRichTextModel *coverModel = [[QSRichTextModel alloc]initWithCellType:QSRichTextCellTypeCover];
    QSRichTextModel *bodyModel = [[QSRichTextModel alloc]initWithCellType:QSRichTextCellTypeText];
    
    [self.viewModel addNewLinesWithModels:@[coverModel, titleModel, bodyModel]];
    
    QSRichTextWordCell *titleTextCell = (QSRichTextWordCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [titleTextCell becomeFirstResponder];
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
            [((QSRichTextWordCell *)cell) setBodyTextStyleWithPlaceholder:self.viewModel.isBodyEmpty];
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
            break;
            
        case QSRichTextCellTypeTitle:
            ((QSRichTextTitleCell *)cell).qs_delegate = self;
            break;
            
        case QSRichTextCellTypeTextBlock:
            ((QSRichTextTitleCell *)cell).qs_delegate = self;
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
        case QSRichTextCellTypeTextBlock: {
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

-(void)qsTextViewDidChange:(YYTextView *)textView {
    NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:textView];
    QSRichTextModel *model = self.viewModel.models[indexPath.row];
    model.attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
    self.currentEditingIndexPath = indexPath;
}

- (void)qsTextFieldDeleteBackward:(QSRichTextView *)textView {
    
    NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:textView];
    NSInteger index = indexPath.row;
    //第一行不清空
    if (self.models[index].cellType == QSRichTextCellTypeTitle) {
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
    [self.viewModel updateLayoutAtIndexPath:self.currentEditingIndexPath withCellheight: newHeight];
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
        [self.viewModel addNewLine:QSRichTextCellTypeImageCaption];
        model.captionModel = self.viewModel.models[indexPath.row+1];
    }
    [self.viewModel becomeActiveWithModel:model];
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

-(void)formatDidToggleBold {
    QSRichTextView *textView = [UIResponder currentFirstResponder];
    NSMutableAttributedString *text = textView.attributedText.mutableCopy;
    YYTextRange *yyRange = (YYTextRange *)textView.selectedTextRange;
    NSRange selectRange = [yyRange asRange];
    
    //长按切换字体属性
    if (selectRange.length) {
        if (selectRange.location + selectRange.length <= textView.attributedText.length) {
            [text yy_setFont:UIFontBoldMake(16) range:selectRange];
        }

//            if (self.selectRange.location + self.selectRange.length <= self.yyTextView.attributedText.length) {
//                [text setAttributes:@{NSFontAttributeName:YYTextViewFont} range:self.selectRange];
//            }
//        }
        //记录光标位置
        __block NSInteger lastCurPosition = textView.selectedRange.location;
        dispatch_async(dispatch_get_main_queue(), ^{
            lastCurPosition += selectRange.length;
            textView.attributedText = text;
            textView.selectedRange = NSMakeRange(lastCurPosition, 0);
            [textView scrollRangeToVisible:selectRange];
        });
    }
}

-(void)formatDidToggleBlockquote {
    [self.viewModel addNewLine:QSRichTextCellTypeTextBlock];
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

@end
