//
//  CalendarCell.h
//  myPets
//
//  Created by Angelos Plastropoulos on 7/27/14.
//  Copyright (c) 2014 plusangel@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *calendarIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *appointmentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *appointmentDate;

@end
