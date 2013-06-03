//
//  SSNotificationCell.m
//  salesucre
//
//  Created by Haitham Reda on 5/22/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSNotificationCell.h"
#import "UIColor+Helpers.h"

#import <QuartzCore/QuartzCore.h>

@implementation SSNotificationCell

@synthesize notification = _notification;
@synthesize defaultFont;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.defaultFont = [UIFont fontWithName:THEME_FONT_GESTA size:16.0];
        [self.textLabel setNumberOfLines:0];
        [self.detailTextLabel setNumberOfLines:0];
        
//        CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
//		gradientLayer.colors =
//        [NSArray arrayWithObjects:
//         (id)[UIColor UIColorFromHex:0xf8f4ed].CGColor,
//         (id)[UIColor UIColorFromHex:0xF1E8DA].CGColor,
//         nil];
//		self.backgroundColor = [UIColor clearColor];
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
//    self.textLabel.font = self.defaultFont;
//    self.textLabel.textColor = [UIColor UIColorFromHex:0x673F32];
//    self.textLabel.text = @"blabla";
    
    self.detailTextLabel.font = self.defaultFont;
    self.detailTextLabel.textColor = [UIColor UIColorFromHex:0x673F32];
    self.detailTextLabel.text = _notification.dataAlertExtend;
//    [self.imageView setImageWithURL:[NSURL URLWithString:_post.user.avatarImageURLString] placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
    
    [self setNeedsLayout];
}

+ (CGFloat)heightForCellWithNotificaction:(SSNotification *)notification
{
    CGSize sizeToFit = [notification.dataAlertExtend sizeWithFont:[UIFont fontWithName:THEME_FONT_GESTA size:16.0]
                                                constrainedToSize:CGSizeMake(280.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    return fmaxf(70.0f, sizeToFit.height + 25.0);
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(20.0f, 5.0f, 280.0f, 20.0f);
    
    CGRect detailTextLabelFrame = CGRectOffset(self.textLabel.frame, 0.0f, 0.0f);
    detailTextLabelFrame.size.height = [[self class] heightForCellWithNotificaction:_notification ] ;
    self.detailTextLabel.frame = detailTextLabelFrame;
    
    DDLogWarn(@"frame: %@", NSStringFromCGRect(detailTextLabelFrame));
    
    // ---- gradiant ---- //
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    gradientLayer.frame = self.bounds;
    //DDLogWarn(@"bounds: %@", NSStringFromCGRect(self.bounds));
    
    [gradientLayer setLocations:[NSArray arrayWithObjects:
                                 [NSNumber numberWithFloat:0.0f],
                                 [NSNumber numberWithFloat:0.5f],
                                 [NSNumber numberWithFloat:0.95f],
                                 nil]];
    
    [gradientLayer setColors:[NSArray arrayWithObjects:
                             (id)[UIColor UIColorFromHex:0xf8f4ed].CGColor,
                              (id)[UIColor UIColorFromHex:0xF8F4ED].CGColor,
                             (id)[UIColor UIColorFromHex:0xF1E8DA].CGColor,
                              nil] ];
    
    //[self.layer setOpacity:0.1];
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

@end
