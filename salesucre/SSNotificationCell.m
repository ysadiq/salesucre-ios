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
#import <TTTDateTransformers.h>

@interface SSNotificationCell ()

@property (nonatomic, strong) NSDateFormatter * dateFormatter;
@property UIFont * dateFont;

@end

@implementation SSNotificationCell

@synthesize content;
@synthesize date;
@synthesize notification = _notification;
@synthesize defaultFont;
@synthesize dateFont;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        DDLogInfo(@"inside #init");
        //self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.defaultFont = [UIFont fontWithName:THEME_FONT_GESTA size:16.0];
        self.dateFormatter = [[NSDateFormatter alloc] init];
        
        self.dateFont = [UIFont fontWithName:THEME_FONT_GESTA size:13.0];
        
        [self addContentLabel];
        [self addDateLabel];
    }
    return self;
}

- (void)addContentLabel
{
    self.content = [[UILabel alloc] init];
    [self.content setNumberOfLines:0];
    self.content.font = self.defaultFont;
    self.content.textColor = [UIColor UIColorFromHex:0x673F32];
    [self.content setBackgroundColor:[UIColor clearColor]];
    
    [self.contentView addSubview:self.content];
}

- (void)addDateLabel
{
    self.date = [[UILabel alloc] init];
    [self.date setNumberOfLines:0];
    self.date.font = self.dateFont;
    self.date.textColor = [UIColor UIColorFromHex:0x867F27];
    [self.date setBackgroundColor:[UIColor clearColor]];
    
    [self.contentView addSubview:self.date];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNotification:(SSNotification *)notification
{
    _notification = notification;
    
    self.content.text = _notification.dataAlertExtend;
    
    // ---- date ---- //
    [self.dateFormatter setDateFormat:@"dd MMM YYYY"];
    [self.dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [self.date setText: [self.dateFormatter stringFromDate:notification.lastModified] ];
    
    [self setNeedsLayout];
}

+ (CGFloat)heightForCellWithNotificaction:(SSNotification *)notification
{
    CGSize sizeToFit = [notification.dataAlertExtend sizeWithFont:[UIFont fontWithName:THEME_FONT_GESTA size:16.0]
                                                constrainedToSize:CGSizeMake(280.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    return fmaxf(70.0f, sizeToFit.height + 20.0);
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.content.frame = CGRectMake(20.0f, 0.0f, 280.0f, 5.0f);
    
    CGRect contentLabelFrame = CGRectOffset(self.content.frame, 0.0f, 0.0f);
    contentLabelFrame.size.height = [[self class] heightForCellWithNotificaction:_notification ] ;
    self.content.frame = contentLabelFrame;
    
    self.date.frame = CGRectMake( 230.0f, self.content.frame.size.height- 15.0 , 70.0f, 15.0f);
    
//    DDLogWarn(@"content frame: %@", NSStringFromCGRect(contentLabelFrame));
//    DDLogWarn(@"date frame: %@", NSStringFromCGRect(self.date.frame));
    
    // ---- gradiant ---- //
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    [gradientLayer setLocations:[NSArray arrayWithObjects:
                                 [NSNumber numberWithFloat:0.4f],
                                 [NSNumber numberWithFloat:0.8f],
                                 nil]];
    
    [gradientLayer setColors:[NSArray arrayWithObjects:
                             (id)[UIColor UIColorFromHex:0xf8f4ed].CGColor,
                             (id)[UIColor UIColorFromHex:0xF1E8DA].CGColor,
                              nil] ];
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

@end
