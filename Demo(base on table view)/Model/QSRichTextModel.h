//
//  QSRichTextModel.h
//  Demo(base on table view)
//
//  Created by Xuzixiang on 2017/12/29.
//  Copyright © 2017年 frankxzx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSRichTextLayout.h"
#import "QSRichTextHtmlWriter.h"
#import <YYText/YYText.h>
#import "QSRichTextHyperlink.h"

extern NSString *const QSRichTextLinkAttributedName;

typedef NS_ENUM(NSInteger, QSRichTextCellType)
{
    QSRichTextCellTypeText = 0,
    QSRichTextCellTypeImage,
    QSRichTextCellTypeImageCaption,
    QSRichTextCellTypeVideo,
    QSRichTextCellTypeSeparator,
    QSRichTextCellTypeTitle,
    QSRichTextCellTypeCover,
    QSRichTextCellTypeTextBlock,
    QSRichTextCellTypeCodeBlock,
    QSRichTextCellTypeListCellCircle,
    QSRichTextCellTypeListCellNumber,
    QSRichTextCellTypeListCellNone,
};

@interface QSRichTextModel : NSObject <QSRichTextHtmlWriter>

@property(nonatomic, strong) NSMutableAttributedString *attributedString;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) QSRichTextLayout *layout;
@property(nonatomic, strong) NSMutableArray <YYTextRange *>*prefixRanges;
@property(nonatomic, copy) NSString *reuseID;
@property(nonatomic, assign) QSRichTextCellType cellType;
@property(nonatomic, assign) CGFloat cellHeight;
@property(nonatomic, weak) QSRichTextModel *captionModel;
@property(nonatomic, copy) NSString *uploadID;
@property(nonatomic, strong) NSData *uploadData;
@property(nonatomic, copy) UIImage *uploadImage;

-(instancetype)initWithCellType:(QSRichTextCellType)cellType;
-(UIImage *)uploadImage;

@end
