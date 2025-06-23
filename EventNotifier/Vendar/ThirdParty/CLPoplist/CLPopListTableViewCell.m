//
//  CLPopListTableViewCell.m
//  Clamour
//
//  Created by Atchu on 1/14/15.
//  Copyright (c) 2015 Clamour. All rights reserved.
//

#import "CLPopListTableViewCell.h"

@implementation CLPopListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectOffset(self.imageView.frame, 0, 0);
    self.textLabel.frame = CGRectOffset(self.textLabel.frame, 0, 0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
