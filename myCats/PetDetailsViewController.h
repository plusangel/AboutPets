//
//  PetDetailsViewController.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 21/12/11.
//  Copyright (c) 2011 plusangel@gmail.com. All rights reserved.
//

@class PetDetailsViewController;
@class Pet;

@protocol PetDetailsViewControllerDelegate <NSObject>
- (void)petDetailsViewControllerDidCancel:(PetDetailsViewController *)controller withRemovingDummyPet:(Pet *)pet;
- (void)petDetailsViewController:(PetDetailsViewController *)controller didAddPet:(Pet *)pet;
- (void)petDetailsViewController:(PetDetailsViewController *)controller didEditPet:(Pet *)pet;
@end

@interface PetDetailsViewController : UIViewController

@property (nonatomic, weak) id <PetDetailsViewControllerDelegate> delegate;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) Pet *pet;
@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) NSInteger weightUnit;

@end
