//
//  RAMContactsManager.h
//  RAMContacts
//
//  Created by Rodrigo A. Morbach on 17/03/16.
//  Copyright © 2016 Morbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <UIKit/UIKit.h>

@interface RAMContactsManager : NSObject

//The singleton instance
+ (instancetype)sharedContactsManager;

//Return if the user has granted permission to access his address book
- (BOOL)hasPermissionGranted;

//Return all contacts from the address book
- (NSArray *)allContacts;

//Return the name of the contact based on the given phone number
- (NSString *)contactNameWithPhoneNumber:(NSString *)phoneNumber;

//Return the contact image based on the given phone number
- (UIImage *)contactImageWithPhoneNumber:(NSString *)phoneNumber;

//Return the group of the user based on the given phone number
- (NSString *)contactGroupWithPhoneNumber:(NSString *)phoneNumber;

@end

