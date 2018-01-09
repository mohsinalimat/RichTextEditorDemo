//
//  QSRichTextViewModel.m
//  Demo(base on table view)
//
//  Created by Xuzixiang on 2017/12/29.
//  Copyright © 2017年 frankxzx. All rights reserved.
//

#import "QSRichTextViewModel.h"
#import "QSRichTextController.h"
#import "QSRichTextWordCell.h"

@interface QSRichTextViewModel()

@property(nonatomic, strong) NSMutableArray <QSRichTextModel *>* models;

@end

@implementation QSRichTextViewModel

-(void)addImageCaptionWithImageModel:(QSRichTextModel *)model {
    NSInteger index = [self.models indexOfObject:model];
    QSRichTextModel *captionModel = [[QSRichTextModel alloc]initWithCellType:QSRichTextCellTypeImageCaption];
    [self.models insertObject:captionModel atIndex:index+1];
    UITableView *tableView = self.viewController.tableView;
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
}

//当插入图片，图片注释，视频，分隔符，代码块时默认添加空的一行
-(void)addNewLine:(QSRichTextCellType)cellType {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.models.count - 1 inSection:0];
    QSRichTextModel *model = [[QSRichTextModel alloc]initWithCellType:cellType];
    QSRichTextModel *emptyLine = [[QSRichTextModel alloc]initWithCellType:QSRichTextCellTypeText];
    
    //正常插两行
    void (^addNewLineWithEmptyTextLine)(void) = ^{
         [self addNewLinesWithModels:@[model, emptyLine]];
    };
    
    //当上一行文本行 还没来得及输入内容时，直接将其替换
    void (^replaceLastLineWithEmptyTextLineAtIndexPath)(NSIndexPath *) = ^(NSIndexPath *indexPath) {
        [self replaceLinesWithModel:model atIndexPath:indexPath];
        [self addNewLinesWithModels:@[emptyLine] atBeginIndexPath:indexPath];
    };
    
    void (^replaceLastLineWithEmptyTextLine)(void) = ^{
        replaceLastLineWithEmptyTextLineAtIndexPath(indexPath);
    };
    
    switch (cellType) {
        case QSRichTextCellTypeImage:
        case QSRichTextCellTypeVideo:
        case QSRichTextCellTypeImageCaption:
        {
            if ([self isLastLineEmpty]) {
                replaceLastLineWithEmptyTextLine();
            } else {
                addNewLineWithEmptyTextLine();
            }
            //新生成的 textView 响应, 光标位置移动
            [self becomeActiveWithModel:emptyLine];
            [self.tableView qmui_scrollToBottom];
            break;
        }
            
        case QSRichTextCellTypeSeparator:
        {
            //上方已经有分割线，则不进行响应
            if ([self isLastLineEmpty]) { return; }
            addNewLineWithEmptyTextLine();
            [self becomeActiveWithModel:emptyLine];
            break;
        }
            
        case QSRichTextCellTypeTextBlock:
        {
            QSRichTextView *textView = self.viewController.currentTextView;
            if (textView) {
              NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:textView];
              QSRichTextModel *currentModel = self.models[indexPath.row];
                switch (currentModel.cellType) {
                    case QSRichTextCellTypeText:
                        currentModel.cellType = QSRichTextCellTypeTextBlock;
                        break;
                    case QSRichTextCellTypeTextBlock:
                        currentModel.cellType = QSRichTextCellTypeText;
                        break;
                    default:
                        break;
                }
                
                [self updateCellAtIndexPath:indexPath];
                [self becomeActiveWithModel:currentModel];
            }
            break;
        }
            
        case QSRichTextCellTypeCodeBlock:
        {
            QSRichTextView *textView = self.viewController.currentTextView;
            if (textView) {
                NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:textView];
                QSRichTextModel *currentModel = self.models[indexPath.row];
                switch (currentModel.cellType) {
                    case QSRichTextCellTypeText:
                        currentModel.cellType = QSRichTextCellTypeCodeBlock;
                        break;
                    case QSRichTextCellTypeCodeBlock:
                        currentModel.cellType = QSRichTextCellTypeText;
                        break;
                    default:
                        break;
                }
                
                [self updateCellAtIndexPath:indexPath];
                [self becomeActiveWithModel:currentModel];
            }
            break;
        }
            
        case QSRichTextCellTypeListCellNone:
        case QSRichTextCellTypeListCellNumber:
        case QSRichTextCellTypeListCellCircle:
        {
            QSRichTextView *textView = self.viewController.currentTextView;
            if (textView) {
                NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:textView];
                QSRichTextModel *currentModel = self.models[indexPath.row];
                currentModel.cellType = cellType;
                [self updateCellAtIndexPath:indexPath];
                [self becomeActiveWithModel:currentModel];
            }
            break;
        }
                
        case QSRichTextCellTypeText:
        case QSRichTextCellTypeTitle:
        case QSRichTextCellTypeCover:
            [self addNewLinesWithModels:@[model]];
        break;
    }
}

//在最后插入新的行
-(void)addNewLinesWithModels:(NSArray <QSRichTextModel *>*) models {
    //最后一行索引
    NSInteger count = self.models.count;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
    [self addNewLinesWithModels:models atBeginIndexPath:indexPath];
}

//在指定的索引插入新的行
-(void)addNewLinesWithModels:(NSArray <QSRichTextModel *>*) models atBeginIndexPath:(NSIndexPath *)indexPath {
    NSArray <NSIndexPath *>*indexPaths = [self insertIndexPathsAtIndexPath:indexPath count:models.count];
    [self.models addObjectsFromArray:models];
    UITableView *tableView = self.viewController.tableView;
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
}

//更新 cell 高度
-(void)updateLayoutAtIndexPath:(NSIndexPath *)indexPath withCellheight:(CGFloat)newHeight {
    if (!indexPath) { return; }
    QSRichTextModel *model = self.models[indexPath.row];
    model.cellHeight = newHeight;
    UITableView *tableView = self.viewController.tableView;
    [tableView.qmui_indexPathHeightCache invalidateHeightAtIndexPath:indexPath];
    [UIView setAnimationsEnabled:NO];
    [tableView beginUpdates];
    [tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
}

-(void)replaceLinesWithModel:(QSRichTextModel *)model atIndexPath:(NSIndexPath *)indexPath {
    [self.models replaceObjectAtIndex:indexPath.row withObject:model];
    [self updateCellAtIndexPath:indexPath];
}

-(void)updateCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableView *tableView = self.viewController.tableView;
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
}

//删除图片时 连带删除注释
-(void)removeLineAtIndexPath:(NSIndexPath *)indexPath {
    [self removeLinesAtIndexPaths:@[indexPath]];
}

-(void)removeLineWithModel:(QSRichTextModel *)model {
    
    NSInteger index = [self.models indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:index+1 inSection:0];
    
    if (model.cellType == QSRichTextCellTypeImage && model != self.models.lastObject) {
        if (self.models[index+1].cellType == QSRichTextCellTypeImageCaption) {
             [self removeLinesAtIndexPaths:@[previousIndexPath, indexPath]];
            return;
        }
    }
    
    if (model.cellType == QSRichTextCellTypeImage ) {
        model.captionModel = nil;
    }
    [self removeLineAtIndexPath:indexPath];
}

-(void)removeLinesAtIndexPaths:(NSArray <NSIndexPath *>*)indexPaths {
    
    NSMutableArray <QSRichTextModel *>* models = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        [models addObject:self.models[indexPath.row]];
    }
    
    [self.models removeObjectsInArray:models];
    UITableView *tableView = self.viewController.tableView;
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
}

-(void)becomeActiveWithModel:(QSRichTextModel *)model {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.models indexOfObject:model] inSection:0];
    [self becomeActiveAtIndexPath:indexPath];
}

-(void)becomeActiveLastLine {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.models.count - 1 inSection:0];
    [self becomeActiveAtIndexPath:indexPath];
}

-(void)becomeActiveAtIndexPath:(NSIndexPath *)indexPath {
    QSRichTextWordCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textView.inputAccessoryView = self.viewController.toolBar;
    cell.textView.selectedRange = NSMakeRange(cell.textView.attributedText.length, 0);
    [cell becomeFirstResponder];
}

-(NSArray<QSRichTextModel *> *)models {
    if (!_models) {
        _models = [NSMutableArray array];
    }
    return _models;
}

-(UITableView *)tableView {
    return self.viewController.tableView;;
}

-(BOOL)isLastLineEmpty {
    NSInteger lastLineIndex = self.models.count - 1;
    if (lastLineIndex < 2) {
        return NO;
    }
    QSRichTextModel *model = self.models[lastLineIndex];
    if (model.cellType != QSRichTextCellTypeText) {
        return NO;
    }
    return model.attributedString.length == 0;
}

-(NSArray <NSIndexPath *>*)insertIndexPathsAtIndexPath:(NSIndexPath *)indexPath
                                                 count:(NSInteger)count {
    NSMutableArray <NSIndexPath *>*indexPaths = [NSMutableArray array];
    for (int i = 1; i <= count; i++) {
        NSIndexPath *newVal = [NSIndexPath indexPathForRow:indexPath.row+i inSection:indexPath.section];
        [indexPaths addObject:newVal];
    }
    return indexPaths;
}

@end
