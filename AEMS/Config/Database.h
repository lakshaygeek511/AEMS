#import <Foundation/Foundation.h>


@interface Database : NSObject


//Database path

extern NSString * const DB_NAME;

extern NSUInteger const DATABASE_VERSION;


//Table Names

extern NSString * const TBL_USER_MASTER;

extern NSString * const TBL_USER_ENQUIRY_MAPPING;

extern NSString * const TBL_USERTYPE_MASTER;

extern NSString * const TBL_STATUS_MASTER;


+ (NSArray *)onDBCreationQueriesArray;

+ (NSArray *)onDBUpgradationQueriesArray;

+ (NSArray *)onDBUpgradationLastSyncDMResetArray;



@end

