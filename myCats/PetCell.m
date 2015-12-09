//
//  CatCell.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 17/12/11.
//  Copyright (c) 2011 plusangel@gmail.com. All rights reserved.
//

#import "PetCell.h"

@implementation PetCell

@synthesize nameLabel;
@synthesize breedLabel;
@synthesize petImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    self.accessoryView = [[ UIImageView alloc ]
                          initWithImage:[UIImage imageNamed:@"pawButton" ]];
    return self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
