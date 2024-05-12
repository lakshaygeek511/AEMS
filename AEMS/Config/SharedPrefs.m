//
//  SharedPrefs.m
//  Yamaha Maps
//
//  Created by VE00YM572 on 30/06/23.
//

#import <Foundation/Foundation.h>
#import "SharedPrefs.h"

@implementation SharedPrefs


/**
 Method to save the NSString type value in NSUserDefaults
 
 @param value The value to be saved
 @param key The key for the value to be saved
 */
+ (void)setPrefs : (NSString *)value key: (NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

/**
 Method to fetch the NSString type value from NSUserDefaults
 
 @param key The key by which the value to be fetched
 @return The value of the key from NSUserDefaults
 */
+ (NSString *)getPrefs : (NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:key];
}


/**
 Method to save the BOOL type value in NSUserDefaults
 
 @param value The value to be saved
 @param key The key for the value to be saved
 */
+ (void)setBooleanTypePrefs :(BOOL)value key:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:key];
    [userDefaults synchronize];
}


/**
 Method to fetch the BOOL type value from NSUserDefaults
 
 @param key The key by which the value to be fetched
 @return The value of the key from NSUserDefaults
 */
+ (BOOL)getBooleanTypePrefs : (NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:key];
}


/**
 Method to save the NSInteger type value in NSUserDefaults
 
 @param value The value to be saved
 @param key The key for the value to be saved
 */
+ (void)setIntegerPrefs :(NSInteger)value key:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:key];
    [userDefaults synchronize];
}


/**
 Method to fetch the NSInteger type value from NSUserDefaults
 
 @param key The key by which the value to be fetched
 @return The value of the key from NSUserDefaults
 */
+ (NSInteger)getIntegerPrefs : (NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:key];
}

/**
Method to remove value from NSUserDefaults corresponding to given key

@param key The key by which the value to be fetched
*/
+ (void)removePrefsForKey :(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}

@end
