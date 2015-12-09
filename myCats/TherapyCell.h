//
//  TherapyCell.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 29/3/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TherapyCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *therapyLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *theparyTypeImageView;

@end
