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

@implementation SSCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self addBackground];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UIView
- (void)addBackground
{
    UIImage *bg = [UIImage imageNamed:THEME_CELL_BACKGROUND];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:bg];
    self.backgroundView = imgView;
//    self.backgroundColor = [UIColor UIColorFromHex:0xF8F4ED];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10.0f, 10.0f, 50.0f, 50.0f);
    self.textLabel.frame = CGRectMake(70.0f, 10.0f, 240.0f, 20.0f);
   
//    CGRect detailTextLabelFrame = CGRectOffset(self.textLabel.frame, 0.0f, 25.0f);
//    detailTextLabelFrame.size.height = [[self class] heightForCellWithPost:_post] - 45.0f;
//    self.detailTextLabel.frame = detailTextLabelFrame;
}

#pragma mark Data Methods
- (void)setCateforiesData:(SSCategory *)currentCategory withLanguage:(NSString *)language
{
    [self.textLabel setTextColor:[UIColor UIColorFromHex:0x673F32]];
    [[self textLabel] setText:[currentCategory name]];
    
    NSArray *imgs = [[currentCategory images] allObjects];
    
    [imgs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DDLogInfo(@"current image: %@", [(Images *)[imgs objectAtIndex:idx] path]);
    }];
    

}

- (void)setMenuItem:(SSMenuItem *)currentItem
{
    [self.textLabel setTextColor:[UIColor UIColorFromHex:0x673F32]];
    [self.textLabel setText:[currentItem name]];
}

- (void)setBranchDetails:(Branch *)branch
{
    [self.textLabel setTextColor:[UIColor UIColorFromHex:0x673F32]];
    [self.textLabel setText:branch.distirctName ];

}

@end
