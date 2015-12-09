//
//  WeightPointCell.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 30/1/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "WeightPointCell.h"

@implementation WeightPointCell

@synthesize weightLabel;
@synthesize dateLabel;
@synthesize weightSign;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
