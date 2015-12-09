//
//  PetPictureDetailViewController.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 6/1/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "PetPictureDetailViewController.h"
#import "Pet.h"
#import "Photo.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface PetPictureDetailViewController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
    
@end

@implementation PetPictureDetailViewController
{
    UIButton *addButton;
    UIButton *deleteButton;
    UIImageView *photoView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.pet.name;
    
    //self.view.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:250.0f/255.0f blue:234.0f/255.0f alpha:1.0f];

    // photo ImageView
    photoView = [[UIImageView alloc] init];
    photoView.translatesAutoresizingMaskIntoConstraints = NO;
    photoView.clipsToBounds = YES;
    photoView.layer.cornerRadius = 10.0f;
    //photoView.contentMode = UIViewContentModeScaleAspectFill;
    
    // add Button
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    addButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    [addButton setBackgroundColor:[UIColor colorWithRed:0.0f green:99.0f/255.0f blue:0.0f alpha:1.0f]];
    addButton.clipsToBounds = YES;
    addButton.layer.cornerRadius = 5.0f;
    
    [addButton addTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    // delete Button
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    deleteButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    [deleteButton setBackgroundColor:[UIColor redColor]];
    deleteButton.clipsToBounds = YES;
    deleteButton.layer.cornerRadius = 5.0f;

    [deleteButton addTarget:self action:@selector(deletePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [self updatePhotoInfo];

}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.view removeConstraints:self.view.constraints];
    
    if (!self.pet.photo.image) {
        
        [self.view addSubview:addButton];
        
        if (deleteButton.superview != nil) {
            [deleteButton removeFromSuperview];
        }
        
        if (photoView.superview != nil) {
            [photoView removeFromSuperview];
        }
        
        // modify addButton's title
        [addButton setTitle:NSLocalizedString(@"select photo", @"select photo string") forState:UIControlStateNormal];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:addButton
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0f
                                                                       constant:0.0f];
        
        [self.view addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:addButton
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0f
                                                   constant:-20.0f];
        
        [self.view addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:addButton
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:1.0f
                                                   constant:37.0f];
        
        [addButton addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:addButton
                                                  attribute:NSLayoutAttributeWidth
                                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                     toItem:nil
                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:1.0f
                                                   constant:140.0f];
        
        [addButton addConstraint:constraint];
        
    } else {
        
        if (addButton.superview != nil) {
            [addButton removeFromSuperview];
        }
        [self.view addSubview:addButton];
        [self.view addSubview:deleteButton];
        [self.view addSubview:photoView];
        
        // modify button's title
        [addButton setTitle:NSLocalizedString(@"select new photo", @"select new photo string") forState:UIControlStateNormal];
        [deleteButton setTitle:NSLocalizedString(@"delete photo", @"delete photo string") forState:UIControlStateNormal];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:deleteButton
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0f
                                                                       constant:37.0f];
        
        [deleteButton addConstraint:constraint];
        
        NSDictionary *photoImageViewDictionary = NSDictionaryOfVariableBindings(photoView);
        
        NSArray *constraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[photoView]-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:photoImageViewDictionary];
        [self.view addConstraints:constraints2];
        
        constraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[photoView(==280)]"
                                                               options:0
                                                               metrics:nil
                                                                 views:photoImageViewDictionary];
        [self.view addConstraints:constraints2];

        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(deleteButton, addButton);
        
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[deleteButton(>=120)]-[addButton(>=140)]-|"
                                                              options:NSLayoutFormatAlignAllTop
                                                              metrics:nil
                                                                views:viewsDictionary];
        [self.view addConstraints:constraints];
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[addButton(==37)]-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary];
        
        [self.view addConstraints:constraints];
        }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Methods

- (void)updatePhotoInfo
{
    photoView.image = self.pet.photo.image;
    
    [self.view setNeedsUpdateConstraints];
}


#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:NSLocalizedString(@"Continue", @"Continue String")])
    {
        NSManagedObjectContext *context = self.pet.managedObjectContext;
        [context deleteObject:self.pet.photo];
        self.pet.thumbnail = nil;
        
        NSError *error = nil;
        if (![context save:&error]) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText:NSLocalizedString(@"delete the photo", @"Error description in deleting the photo")];
        }
        
        [self updatePhotoInfo];
    }
    
}
#

#pragma mark - Actions

- (IBAction)deletePhoto
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove photo", @"Remove Pets Photo")
                                message:NSLocalizedString(@"Are you sure that you want to remove the selected photo?", @"Removing photo confirmation message")
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel String")
                      otherButtonTitles:NSLocalizedString(@"Continue", @"Continue String"), nil] show];

}

- (IBAction)choosePhoto
{
    // Show an image picker to allow the user to choose a new photo
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    //[imagePicker.navigationBar setBackgroundImage:[UIImage imageNamed:@"toolBar_44.png"] forBarMetrics:UIBarMetricsDefault];
    [self presentViewController:imagePicker animated:YES completion:nil];
}
     

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    NSManagedObjectContext *context = self.pet.managedObjectContext;
    
    // If the pet already has a photo delete it
    if (self.pet.photo) {
        [context deleteObject:self.pet.photo];
    }
    
    // Create a new photo object and set the image
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
    UIImage *imageToDislpay = [self image:image byScalingToSize:CGSizeMake(560.0, 560.0)];
    photo.image = imageToDislpay;
    
    // Associate the photo with the pet
    self.pet.photo = photo;
    
    // Create a thumbnail version of the image for the pet
    CGSize size = image.size;
    CGFloat ratio = 0;
    if (size.width > size.height) {
        //ratio = 44.0 / size.width;
        ratio = 92.0 / size.width;
    } else {
        //ratio = 44.0 /size.height;
        ratio = 92.0 / size.width;
    }
    CGRect rect = CGRectMake(0.0, 0.0, ratio*size.width, ratio*size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    self.pet.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Commit the change
    NSError *error = nil;
    if (![context save:&error]) {
        [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText:NSLocalizedString(@"add the photo", @"Error description in adding a photo")]; 
    }
    
    [self updatePhotoInfo];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods

static inline double radians (double degrees) 
{
    return degrees * M_PI/180;
}

- (UIImage*)image:(UIImage *)sourceImage byScalingToSize:(CGSize)targetSize
{
    //UIImage *sourceImage = self; 
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo =  (CGBitmapInfo)kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }       
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage; 
}

@end
