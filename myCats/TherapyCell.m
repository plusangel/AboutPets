//
//  TherapyCell.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 29/3/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "TherapyCell.h"

@implementation TherapyCell
@synthesize therapyLabel;
@synthesize dateLabel;
@synthesize priceLabel;

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
