//
//  AddTherapyViewController.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 28/3/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

@class Therapy;
@class TherapyDetailsViewController;

@protocol DetailsTherapyViewControllerDelegate <NSObject>
- (void)detailsTherapyViewControllerDidCancel:(TherapyDetailsViewController *)controller;
- (void)detailsTherapyViewController:(TherapyDetailsViewController *)controller didSave:(Therapy *)therapy;
- (void)detailsTherapyViewController:(TherapyDetailsViewController *)controller didEdit:(Therapy *)therapy;
- (void)detailsTherapyViewController:(TherapyDetailsViewController *)controller didDelete:(Therapy *)therapy;
@end

@interface TherapyDetailsViewController : UITableViewController

@property (nonatomic, weak) id <DetailsTherapyViewControllerDelegate> delegate;
@property (nonatomic, strong) Therapy *therapy;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) NSInteger currencyUnit;

@property (nonatomic, assign) BOOL helpStatus;

@end
