//
//  ShowPetDetailsViewController.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 16/2/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

@class Pet;
@class ShowPetDetailsViewController;

@protocol ShowPetDetailsViewControllerDelegate <NSObject>
- (void)showPetDetailsViewController:(ShowPetDetailsViewController *)controller remove:(Pet *)pet;
@end

@interface ShowPetDetailsViewController : UIViewController

@property (nonatomic, weak) id <ShowPetDetailsViewControllerDelegate> delegate;

@property (nonatomic, strong) Pet *pet;
@property (nonatomic, assign) NSInteger weightUnit;

@end
