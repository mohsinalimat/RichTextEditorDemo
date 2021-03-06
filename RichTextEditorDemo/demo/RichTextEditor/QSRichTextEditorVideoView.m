//
//  QSRichTextEditorVideoView.m
//  RichTextEditorDemo
//
//  Created by Xuzixiang on 2017/12/25.
//  Copyright © 2017年 frankxzx. All rights reserved.
//

#import "QSRichTextEditorVideoView.h"
#import <QMUIKit/QMUIKit.h>

@interface QSRichTextEditorVideoView()

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) QMUIButton *closeButton;
@property(nonatomic, strong) QMUIButton *playButton;
@property(nonatomic, strong) UIView *maskView;

@end

@implementation QSRichTextEditorVideoView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        self.closeButton = [[QMUIButton alloc]initWithImage:UIImageMake(@"edit_close") title:nil];
        [self.closeButton addTarget:self action:@selector(deleteVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        self.playButton = [[QMUIButton alloc]initWithImage:UIImageMake(@"edit_video_play") title:nil];
        [self.playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        self.imageView = [[UIImageView alloc]init];
        self.imageView.image = [UIImage qmui_imageWithColor:[UIColor qmui_randomColor]];
        [self addSubview:self.imageView];
        
        self.maskView = [[UIView alloc]init];
        self.maskView.backgroundColor = UIColorMask;
        [self addSubview:self.maskView];
        [self addSubview:self.playButton];
        [self addSubview:self.closeButton];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat margin = 20;
    self.maskView.frame = self.bounds;
    self.imageView.frame = self.bounds;
    self.closeButton.frame = CGRectMake(self.qmui_width - margin - 44, margin, 44, 44);
    self.playButton.frame = CGRectMake((self.qmui_width - 56)/2, (self.qmui_height - 56)/2, 56, 56);
}

-(void)deleteVideo:(id)sender {
    if ([self.actionDelegate respondsToSelector:@selector(editorViewDeleteVideo:attachment:)]) {
        NSAssert(self.attachment, @"初始化 videoAttchement 时需要赋值 attchemnt");
        [self.actionDelegate editorViewDeleteVideo:sender attachment:self.attachment];
    }
}

-(void)playVideo:(id)sender {
    if ([self.actionDelegate respondsToSelector:@selector(editorViewPlayVideo:attachment:)]) {
        NSAssert(self.attachment, @"初始化 videoAttchement 时需要赋值 attchemnt");
        [self.actionDelegate editorViewPlayVideo:sender attachment:self.attachment];
    }
}

-(void)setAttachment:(DTVideoTextAttachment *)attachment {
    _attachment = attachment;
//    self.imageView
}

@end
