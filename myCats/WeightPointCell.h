//
//  WeightPointCell.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 30/1/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeightPointCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *weightLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *weightSign;

@end
