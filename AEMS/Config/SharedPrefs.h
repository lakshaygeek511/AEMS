#import <Foundation/Foundation.h>

@interface SharedPrefs : NSObject

/**
 Method to save the NSString type value in NSUserDefaults
 
 @param value The value to be saved
 @param key The key for the value to be saved
 */
+ (void)setPrefs : (NSString *)value key: (NSString *)key;

/**
 Method to fetch the NSString type value from NSUserDefaults
 
 @param key The key by which the value to be fetched
 @return The value of the key from NSUserDefaults
 */
+ (NSString *)getPrefs : (NSString *)key;


/**
 Method to save the BOOL type value in NSUserDefaults
 
 @param value The value to be saved
 @param key The key for the value to be saved
 */
+ (void)setBooleanTypePrefs :(BOOL)value key:(NSString *)key;


/**
 Method to fetch the BOOL type value from NSUserDefaults
 
 @param key The key by which the value to be fetched
 @return The value of the key from NSUserDefaults
 */
+ (BOOL)getBooleanTypePrefs : (NSString *)key;

/**
 Method to save the NSInteger type value in NSUserDefaults
 
 @param value The value to be saved
 @param key The key for the value to be saved
 */
+ (void)setIntegerPrefs :(NSInteger)value key:(NSString *)key;


/**
 Method to fetch the NSInteger type value from NSUserDefaults
 
 @param key The key by which the value to be fetched
 @return The value of the key from NSUserDefaults
 */
+ (NSInteger)getIntegerPrefs : (NSString *)key;


/**
Method to remove value from NSUserDefaults corresponding to given key

@param key The key by which the value to be fetched
*/
+ (void)removePrefsForKey :(NSString *)key;

@end

