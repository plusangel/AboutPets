//
//  CatCell.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 17/12/11.
//  Copyright (c) 2011 plusangel@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PetCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *breedLabel;
@property (nonatomic, weak) IBOutlet UIImageView *petImageView;

@end
