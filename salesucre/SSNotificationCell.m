//
//  SSNotificationCell.m
//  salesucre
//
//  Created by Haitham Reda on 5/22/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSNotificationCell.h"
#import "UIColor+Helpers.h"

@implementation SSNotificationCell

@synthesize notification = _notification;
@synthesize defaultFont;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.backgroundColor = [UIColor UIColorFromHex:0xf8f4ed];
        self.defaultFont = [UIFont fontWithName:THEME_FONT_GESTA size:14.0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNotification:(SSNotification *)notification
{
    _notification = notification;
    self.textLabel.font = self.defaultFont;
    self.textLabel.text = notification.content;
//    self.detailTextLabel.text = _post.text;
//    [self.imageView setImageWithURL:[NSURL URLWithString:_post.user.avatarImageURLString] placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
    
    [self setNeedsLayout];
}

+ (CGFloat)heightForCellWithNotificaction:(SSNotification *)notification
{
    CGSize sizeToFit = [notification.content sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(220.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    return fmaxf(70.0f, sizeToFit.height + 45.0f);
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(70.0f, 10.0f, 240.0f, 20.0f);
    
    CGRect detailTextLabelFrame = CGRectOffset(self.textLabel.frame, 0.0f, 25.0f);
    detailTextLabelFrame.size.height = [[self class] heightForCellWithNotificaction:_notification] - 45.0f;
    self.detailTextLabel.frame = detailTextLabelFrame;
}

@end
