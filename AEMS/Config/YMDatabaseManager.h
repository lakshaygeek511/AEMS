
#import <Foundation/Foundation.h>

enum errorCodes {
    kDBNotExists,
    kDBFailAtOpen,
    kDBFailAtCreate,
    kDBErrorQuery,
    kDBFailAtClose,
    kDBException
};

@interface YMDatabaseManager : NSObject

// Singleton object
+ (YMDatabaseManager *) sharedInstance;

- (NSError *)update:(NSString *)tableName : (NSDictionary *)dict : (NSString *)condition;
- (NSError *)deleteData:(NSString *)tableName : (NSString *)condition;
- (NSError *)insert:(NSString *)tableName : (NSDictionary *)dict;
- (NSArray *)getQueryResult:(NSString *)tableName : (NSString *)fields : (NSString *)condition;
- (NSError *)createTable:(NSString *)query;
- (NSError *)truncate:(NSString *)tableName;
- (NSError *)drop:(NSString *)tableName;
- (NSError *)saveApiResultsInTable:(NSString *)tableName data:(NSArray *)data;
- (NSError *)doQuery:(NSString *)sql;
- (NSArray *)getRowsForQuery:(NSString *)sql;
- (int)checkUserVersion;
@end



