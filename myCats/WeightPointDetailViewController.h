//
//  WeightPointViewController.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 20/6/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

@class WeightPoint;
@class WeightPointDetailViewController;

@protocol WeightPointViewControllerDelegate <NSObject>
- (void)weightPointViewControllerDidCancel:(WeightPointDetailViewController *)controller;
- (void)weightPointViewController:(WeightPointDetailViewController *)controller didSave:(WeightPoint *)weightPoint;
- (void)weightPointViewController:(WeightPointDetailViewController *)controller didEdit:(WeightPoint *)weightPoint;
@end

@interface WeightPointDetailViewController : UITableViewController

@property (weak, nonatomic) id <WeightPointViewControllerDelegate> delegate;

@property (strong, nonatomic) WeightPoint *weightPoint;
@property (strong, nonatomic) NSDate *previousDate;
@property (strong, nonatomic) NSDate *nextDate;
@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) NSInteger weightUnit;

@property (assign, nonatomic) BOOL helpStatus;

@end
