
#import <Foundation/Foundation.h>
#import "Database.h"



@implementation Database


//Database path

NSString * const DB_NAME = @"AEMSDatabase.db";
NSUInteger const DATABASE_VERSION = 1;


//Table Names

NSString * const TBL_USER_MASTER = @"user_master";
NSString * const TBL_USER_ENQUIRY_MAPPING = @"user_enqiry_mapping";
NSString * const TBL_USERTYPE_MASTER = @"usertype_master";
NSString * const TBL_STATUS_MASTER = @"status_master";



// ==================================================== //

//Create table statements

///TBL_USER_MASTER

static NSString * const CREATE_TABLE_USER_MASTER = @"CREATE TABLE IF NOT EXISTS user_master(username TEXT PRIMARY KEY,fullname TEXT,phoneNo INTEGER,email TEXT,password TEXT,usercode INTEGER)";

///TBL_USER_ENQUIRY_MAPPING

static NSString * const CREATE_TABLE_USER_ENQUIRY_MAPPING = @"CREATE TABLE IF NOT EXISTS user_enqiry_mapping(enquiryno INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT,fullname TEXT,phoneNo TEXT,email TEXT,latitude INTEGER,longitude INTEGER,address TEXT,product TEXT,quantity INTEGER,statuscode INTEGER,enquirydate INTEGER)";

///TBL_USERTYPE_MASTER

static NSString * const CREATE_TABLE_USERTYPE_MASTER = @"CREATE TABLE IF NOT EXISTS usertype_master(usercode INTEGER PRIMARY KEY, userType TEXT)";

///TBL_STATUS_MASTER

static NSString * const CREATE_TABLE_STATUS_MASTER = @"CREATE TABLE IF NOT EXISTS status_master(statuscode INTEGER PRIMARY KEY, status TEXT)";


+ (NSArray *)onDBCreationQueriesArray {
    
    static NSArray *dBCreationQueriesArray;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        dBCreationQueriesArray = @[
            CREATE_TABLE_USER_MASTER,
            CREATE_TABLE_USER_ENQUIRY_MAPPING,
            CREATE_TABLE_USERTYPE_MASTER,
            CREATE_TABLE_STATUS_MASTER
            
        ];
        
    });
    
    return dBCreationQueriesArray;
    
}


+ (NSArray *)onDBUpgradationQueriesArray {
    
    static NSArray *dBUpgradationQueriesArray;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        dBUpgradationQueriesArray = @[
            CREATE_TABLE_USER_MASTER,
            CREATE_TABLE_USER_ENQUIRY_MAPPING,
            CREATE_TABLE_USERTYPE_MASTER,
            CREATE_TABLE_STATUS_MASTER
        ];
        
    });
    
    return dBUpgradationQueriesArray;
    
}



+ (NSArray *)onDBUpgradationLastSyncDMResetArray
{
    
    static NSArray *dBUpgradationLastSyncDMResetArray;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        dBUpgradationLastSyncDMResetArray = @[
                
            CREATE_TABLE_USERTYPE_MASTER,
            CREATE_TABLE_STATUS_MASTER
            
        ];
        
    });
    
    return dBUpgradationLastSyncDMResetArray;
    
}



@end
