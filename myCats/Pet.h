//
//  Pet.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 6/1/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;
@class Therapy;

@interface Pet : NSManagedObject

@property (nonatomic, retain) NSString *breed;
@property (nonatomic, retain) NSDate *dob;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *registration;
@property (nonatomic, retain) NSString *microchip;
@property (nonatomic, retain) NSData *weight;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, assign) BOOL sex;
@property (nonatomic, assign) BOOL kind;
@property (nonatomic, retain) NSDate *lastAppointment;
@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) NSSet *therapy;
@property (nonatomic, retain) NSSet *appointment;
@end
