//
//  RAMContactsManager.m
//  RAMContacts
//
//  Created by Rodrigo A. Morbach on 17/03/16.
//  Copyright © 2016 Morbach. All rights reserved.
//

#import "RAMContactsManager.h"
#import "RAMContact.h"

@interface RAMContactsManager()

@property (nonatomic, strong) NSArray * contacts;
@property (nonatomic, assign) BOOL permissionGranted;
@end

static RAMContactsManager * sharedManager;

@implementation RAMContactsManager

+ (instancetype)sharedContactsManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[RAMContactsManager alloc]init];
    });
    [sharedManager askPermission];
    return sharedManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (NSArray *)allContacts
{
    return self.contacts;
}

- (NSString *)contactNameWithPhoneNumber:(NSString *)phoneNumber
{
    NSString * contactName = nil;
    RAMContact * foundCountact = [self contactFromPhoneNumber:phoneNumber];
    if (foundCountact) {
        contactName = foundCountact.firstName;
    }
    return contactName;
}

- (NSString *)contactGroupWithPhoneNumber:(NSString *)phoneNumber
{
    NSString * contactGroup = nil;
    RAMContact * foundCountact = [self contactFromPhoneNumber:phoneNumber];
    if (foundCountact) {
        contactGroup = [foundCountact.numbersAndGroups valueForKey:phoneNumber];
    }
    return contactGroup;
}

- (RAMContact *)contactFromPhoneNumber:(NSString *)phoneNumber
{
    RAMContact * foundContact = nil;
    for (RAMContact * contact in self.contacts) {
        for (NSString * phNumber in contact.phoneNumbers) {
            if ([phoneNumber isEqualToString:[self sanitizePhoneNumberForSearch:phNumber]]) {
                foundContact = contact;
                break;
            }
        }
    }
    return foundContact;
}

- (UIImage *)contactImageWithPhoneNumber:(NSString *)phoneNumber
{
    UIImage * contactImage = nil;
    RAMContact * foundCountact = [self contactFromPhoneNumber:phoneNumber];
    if (foundCountact) {
        contactImage = foundCountact.picture;
    }
    return contactImage;
}

- (BOOL)hasPermissionGranted
{
    return self.permissionGranted;
}

- (void)askPermission
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    self.permissionGranted = accessGranted;
    if (accessGranted) {
        [self loadContactsFromAddressBook:addressBook];
    }
    
}

- (void)loadContactsFromAddressBook:(ABAddressBookRef )addressBook
{
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NSMutableArray * contactsList = [[NSMutableArray alloc]init];
    for (int i=0;i < nPeople;i++) {
        RAMContact * person = [[RAMContact alloc]init];
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //The firstName and the surName
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        NSString * firstName = (__bridge_transfer NSString*)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        NSString * lastName  = (__bridge_transfer NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        //  NSString * group = (__bridge_transfer NSString *)ABRecordCopyValue(ref, kABPersonPhoneMainLabel);
        person.firstName = firstName;
        person.lastName = lastName;
        //For Phone number
        NSMutableArray * phoneNumbers = [NSMutableArray array];
        //For add all phoneNumbers
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++) {
            NSString * phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j);
            [phoneNumbers addObject:[self sanitizePhoneNumber:phoneNumber]];
            
            //Group
            ABMultiValueRef phoneNumberMultiValue = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            CFStringRef labelStringRef = ABMultiValueCopyLabelAtIndex (phoneNumberMultiValue, j);
            
            NSString *phoneLabelLocalized = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(labelStringRef);
            
            [person addPhoneNumber:[self sanitizePhoneNumberForSearch:phoneNumber] andGroup:phoneLabelLocalized];
            CFRelease((__bridge CFTypeRef)(phoneLabelLocalized));
            CFRelease(labelStringRef);
            CFRelease(phoneNumberMultiValue);
        }
        CFRelease(phones);
        person.phoneNumbers = [NSArray arrayWithArray:phoneNumbers];
        
        //Try to load the image
        NSData * pictureData = (__bridge NSData *)ABPersonCopyImageData(ref);
        if (pictureData) {
            person.picture = [UIImage imageWithData:pictureData];
        }
        //Only add the person to the list if there is a number
        if (person.phoneNumbers.count > 0) {
            [contactsList addObject:person];
        }
    }
    CFRelease(allPeople);
    self.contacts = [NSArray arrayWithArray:contactsList];
}

- (NSString *)sanitizePhoneNumberForSearch:(NSString *)phoneNumber
{
    NSString * sanitizedPhoneNumber = [self removeSpecialCharacteresFromPhoneNumber:phoneNumber];
    return sanitizedPhoneNumber;
}

- (NSString *)sanitizePhoneNumber:(NSString *)phoneNumber
{
    NSString * sanitizedPhoneNumber = [self removeSpecialCharacteresFromPhoneNumber:phoneNumber];
    return sanitizedPhoneNumber;
}

- (NSString *)removeSpecialCharacteresFromPhoneNumber:(NSString *)phoneNumber
{
    NSString * sanitizedPhoneNumber = nil;
    NSArray* words = [phoneNumber componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    sanitizedPhoneNumber = [words componentsJoinedByString:@""];
    sanitizedPhoneNumber = [sanitizedPhoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    sanitizedPhoneNumber = [sanitizedPhoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    sanitizedPhoneNumber = [sanitizedPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    sanitizedPhoneNumber = [sanitizedPhoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    return sanitizedPhoneNumber;
}


@end