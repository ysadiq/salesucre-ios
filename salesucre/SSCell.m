//
//  SSCell.m
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSCell.h"
#import "UIColor+Helpers.h"
#import "Images.h"

#import <QuartzCore/QuartzCore.h>


@interface SSCell ()
@property UIFont *subtitleFont;

@end

@implementation SSCell
@synthesize defaultFont;
@synthesize subtitleFont;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self addBackground];
        // Rounded corners
        self.imageView.frame = CGRectMake(6.5f, 6.5f, 50.0f, 50.0f);
        
        
        CALayer *layer = self.imageView.layer;
        layer.cornerRadius = self.imageView.frame.size.width / 2;
        
        [layer setMasksToBounds:YES];
        [layer setBorderWidth:1.0];
        [layer setBorderColor:[UIColor whiteColor].CGColor];
        
        
        self.defaultFont = [UIFont fontWithName:THEME_FONT_GESTA size:18.0];
        self.subtitleFont = [UIFont fontWithName:THEME_FONT_GESTA size:14];
        
        [self.detailTextLabel setAdjustsFontSizeToFitWidth:YES];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)prepareForReuse
{
    self.imageView.image = nil;
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
}

#pragma mark - UIView
- (void)addBackground
{
    UIImage *bg = [UIImage imageNamed:THEME_CELL_BACKGROUND];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:bg];
    self.backgroundView = imgView;
//    self.backgroundColor = [UIColor UIColorFromHex:0xF8F4ED];
    
    UIImageView *arrow = [[UIImageView alloc] init];
    arrow.frame = CGRectMake(292.0f, 26.0f, 9.0f, 15.0f);
    [arrow setImage:[UIImage imageNamed:THEME_CELL_ARROW]];
    [self addSubview:arrow];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(6.5f, 6.5f, 50.0f, 50.0f);
    
    if ( [self.detailTextLabel.text length] > 0 )
    {
        self.textLabel.frame = CGRectMake(70.0f, 10.0f, 240.0f, 20.0f);
        self.detailTextLabel.frame = CGRectMake(70.0f, 30.0f, 230.0f, 20.0f);
    }
    else
    {
        self.textLabel.frame = CGRectMake(70.0f, 23.0f, 240.0f, 20.0f);
    }
    
//    CGRect detailTextLabelFrame = CGRectOffset(self.textLabel.frame, 0.0f, 25.0f);
//    detailTextLabelFrame.size.height = [[self class] heightForCellWithPost:_post] - 45.0f;
//    self.detailTextLabel.frame = detailTextLabelFrame;
}

#pragma mark Data Methods
- (void)setCateforiesData:(SSCategory *)currentCategory withLanguage:(NSString *)language
{
    [self.textLabel setFont:self.defaultFont];
    [self.textLabel setTextColor:[UIColor UIColorFromHex:0x673F32]];
    [[self textLabel] setText:[currentCategory name]];
    
    if ( [[[currentCategory images] allObjects] count] >= 1)
    {
        [self.imageView setImageWithURL:[[SSAPIClient sharedInstance] imageFullURLFromString:[[[[currentCategory images] allObjects] objectAtIndex:0] path]
                                                                                  withWidth:50 andHeight:50]
                                                                           placeholderImage:[UIImage imageNamed:THEME_CELL_IMAGE_PLACEHOLDER] ];
    }
    else
    {
        DDLogWarn(@"no image found for category: %@, setting placeholder",currentCategory.name);
        [self.imageView setImage:[UIImage imageNamed:THEME_CELL_IMAGE_PLACEHOLDER]];
    }
}

- (void)setMenuItem:(SSMenuItem *)currentItem
{
    
    [self.textLabel setFont:self.defaultFont];
    [self.textLabel setBackgroundColor:[UIColor clearColor]];
    [self.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    [self.textLabel setTextColor:[UIColor UIColorFromHex:0x673F32]];
    [self.textLabel setText:[currentItem name]];
    
    if ( [[[currentItem images] allObjects] count] >= 1)
    {
        [self.imageView setImageWithURL:[[SSAPIClient sharedInstance] imageFullURLFromString:[[[[currentItem images] allObjects] objectAtIndex:0] path]
                                                                                   withWidth:50 andHeight:50]
                       placeholderImage:[UIImage imageNamed:THEME_CELL_IMAGE_PLACEHOLDER] ];
    }
    else
    {
        DDLogWarn(@"no image found for category: %@, setting placeholder",currentItem.name);
        [self.imageView setImage:[UIImage imageNamed:THEME_CELL_IMAGE_PLACEHOLDER]];
    }
}

- (void)setBranchDetails:(Branch *)branch
{
    [self.textLabel setFont:self.defaultFont];
    [self.textLabel setTextColor:[UIColor UIColorFromHex:0x673F32]];
    [self.textLabel setText:branch.distirctName ];
    
    [self.detailTextLabel setFont:self.subtitleFont];
    [self.detailTextLabel setTextColor:[UIColor UIColorFromHex:0xE65C00]];
    self.detailTextLabel.text = branch.street;
    
    [self.imageView setImage:[UIImage imageNamed:THEME_SALESUCRE_LOGO]];

}

@end
