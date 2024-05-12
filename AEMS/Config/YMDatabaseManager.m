
#import "YMDatabaseManager.h"
#import "sqlite3.h"
#import "Database.h"
#import "Constants.h"
#import "SharedPrefs.h"

@implementation YMDatabaseManager {
    //The SQLite db reference. Created by sqlite3_open() and destroyed by sqlite3_close().
    sqlite3 *db;
    NSString *databasePath;
}

#pragma mark Init & Dealloc

// Singleton object
+ (YMDatabaseManager *) sharedInstance {
    static YMDatabaseManager *_sharedInstance = nil;
    
    // A predicate for use with the dispatch_once function.
    static dispatch_once_t onceToken;
    
    // Executes a block object once and only once for the lifetime of an application.
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[YMDatabaseManager alloc] init];
    });
    
    return _sharedInstance;
}

/**
 * Init method.
 * Use this method to initialise the object, instead of just "init".
 *
 * @return the SQLiteManager object initialised.
 */
- (id)init {
    // Invoking an initializer of its superclass
    self = [super init];
    
    // If the value is not nil, the superclass initializer has returned a valid object, so you may proceed with initialization.
    if (self) {
        /** The sqlite3_config() interface is used to make global configuration changes to SQLite in order to tune SQLite to the specific needs of the application. The
         * default configuration is recommended for most applications and so this routine is usually not necessary. It is provided to support rare applications with unusual
         * needs.
         */
        sqlite3_config(SQLITE_CONFIG_SERIALIZED,SQLITE_CONFIG_MULTITHREAD);
        
        db = nil;
        
        // Get the database version from NSUserDefaults
        NSInteger databaseVersion = [SharedPrefs getIntegerPrefs:@"DATABASE_VERSION"];
        
        if(databaseVersion == 0) {
            // DB does not exist
            
            // Create the database
            [self onDBCreate];
            
            //Save DATABASE_VERSION in NSUserDefaults
            [SharedPrefs setIntegerPrefs:DATABASE_VERSION key:@"DATABASE_VERSION"];
            
        } else if(databaseVersion != DATABASE_VERSION) {
            // DB Upgradation required
            
            // Upgrade the database
            [self onDBUpgrade];
            
            //Save DATABASE_VERSION in NSUserDefaults
            [SharedPrefs setIntegerPrefs:DATABASE_VERSION key:@"DATABASE_VERSION"];
        }
    }
    return self;
}

/**
 * Creates the tables in database if not exists
 */
- (void)onDBCreate {
    @try {
        NSArray *array = [Database onDBCreationQueriesArray];
        for(NSString *query in array) {
            [self doQuery:query];
        }
    }
    @catch (NSException *exception) {
        //Exception
        if(DATABASE_DEBUG_MODE_FLAG){
            NSLog(@"NSException : %@",exception.description);
        }
    }
}


/**
 * Upgrades the database
 */
- (void)onDBUpgrade {
    @try {
        NSArray *array = [Database onDBUpgradationQueriesArray];
        for(NSString *query in array) {
            [self doQuery:query];
        }
        
        // Reset tables last sync timestamp
        [self resetTablesLastSyncedOn];
        
        // Set the Sync data flag value to false in prefrences
        [SharedPrefs setBooleanTypePrefs:NO key:PREFS_IS_DATA_SYNC];
        
        //[SharedPrefs setBooleanTypePrefs:NO key:PREFS_IS_LOGGED_IN];
    }
    @catch (NSException *exception) {
        //Exception
        if(DATABASE_DEBUG_MODE_FLAG){
            NSLog(@"NSException : %@",exception.description);
        }
    }
}


/**
 * Resets the tables last sync timestamp value
 */
- (void)resetTablesLastSyncedOn {
    @try {
        NSArray *array = [Database onDBUpgradationLastSyncDMResetArray];
        for(NSString *updatedOnKey in array) {
            [SharedPrefs setPrefs:@"0" key:updatedOnKey];
        }
    }
    @catch (NSException *exception) {
        //Exception
        if(DATABASE_DEBUG_MODE_FLAG){
            NSLog(@"NSException : %@",exception.description);
        }
    }
}

/**
 * Gets the database file path (in NSDocumentDirectory).
 *
 * @return the path to the db file.
 */
- (NSString *)getDatabasePath {
    @try {
        if(databasePath != nil){
            return databasePath;
        } else {
            // Get the documents directory
            NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docsDir = [dirPaths objectAtIndex:0];
            databasePath = [docsDir stringByAppendingPathComponent:DB_NAME];
            return databasePath;
        }
    }
    @catch (NSException *exception) {
        if(DATABASE_DEBUG_MODE_FLAG){
            NSLog(@"NSException : %@",exception.description);
        }
    }
    
    return @"";
}

#pragma mark SQLite Operations

/**
 * Open or create a SQLite3 database.
 *
 * If the db exists, then is opened and ready to use. If not exists then is created and opened.
 *
 * @return nil if everything was ok, an NSError in other case.
 *
 */



- (NSError *)openDatabase {
    NSError *error = nil;
    
    NSString *databasePath = [self getDatabasePath];
    
    const char *dbpath = [databasePath UTF8String];
    /*
     * Open a connection to a new or existing SQLite database. The constructor for sqlite3.
     *
     * sqlite3_open() : opens a connection to an SQLite database file and returns a database connection object.
     * This is often the first SQLite API call that an application makes and is a prerequisite for most other SQLite APIs.
     * Many SQLite interfaces require a pointer to the database connection object as their first parameter and can be thought of as methods on the database connection object.
     * This routine is the constructor for the database connection object.
     *
     * The SQLITE_OK result code means that the operation was successful and that there were no errors.
     */
    int result = sqlite3_open(dbpath, &db);
    if (result != SQLITE_OK) {
        const char *errorMsg = sqlite3_errmsg(db);
        NSString *errorStr = [NSString stringWithFormat:@"The database could not be opened: %@",[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]];
        error = [self createDBErrorWithDescription:errorStr    andCode:kDBFailAtOpen];
    }
    
    return error;
}

/**
 * Closes the database.
 *
 * @return nil if everything was ok, NSError in other case.
 */
- (NSError *)closeDatabase {
    NSError *error = nil;
    
    if (db != nil) {
        /*
         * Destructor for sqlite3.
         *
         * sqlite3_close() : This routine closes a database connection previously opened by a call to sqlite3_open().
         * All prepared statements associated with the connection should be finalized prior to closing the connection.
         */
        if (sqlite3_close(db) != SQLITE_OK){
            const char *errorMsg = sqlite3_errmsg(db);
            NSString *errorStr = [NSString stringWithFormat:@"The database could not be closed: %@",[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]];
            error = [self createDBErrorWithDescription:errorStr andCode:kDBFailAtClose];
        }
        
        db = nil;
    }
    
    return error;
}

/**
 * Checks the user version
 *
 * @return the user version
 */
- (int)checkUserVersion {
    int databaseVersion = -1;
    
    static sqlite3_stmt *stmt_version;
   
    
    
    @try {
        NSError *openError = nil;
        
        //Check if database is open and ready.
        if (db == nil) {
            openError = [self openDatabase];
        }
        
        int databaseVersion;
        
        if(sqlite3_prepare_v2(db, "PRAGMA user_version;", -1, &stmt_version, NULL) == SQLITE_OK) {
            while(sqlite3_step(stmt_version) == SQLITE_ROW) {
                databaseVersion = sqlite3_column_int(stmt_version, 0);
                NSLog(@"%s: version %d", __FUNCTION__, databaseVersion);
            }
            NSLog(@"%s: the databaseVersion is: %d", __FUNCTION__, databaseVersion);
        } else {
            NSLog(@"%s: ERROR Preparing: , %s", __FUNCTION__, sqlite3_errmsg(db) );
        }
        sqlite3_finalize(stmt_version);
        
        return databaseVersion;
        
        if (openError == nil) {
            sqlite3_busy_timeout(db, 1000);
            sqlite3_stmt *statement;
            if(sqlite3_prepare_v2(db, "PRAGMA user_version;", -1, &statement, NULL) == SQLITE_OK) {
                while(sqlite3_step(statement) == SQLITE_ROW) {
                    databaseVersion = sqlite3_column_int(statement, 0);
                    if(DATABASE_DEBUG_MODE_FLAG) {NSLog(@"Version: %d", databaseVersion);}
                }
            }
            
            sqlite3_finalize(statement);
        }
        
    } @catch (NSException *exception) {
        if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"NSException : %@",exception.description); }
    } @finally {
        [self closeDatabase];
    }
    
    return databaseVersion;
    
    //NSLog(@"Tables: %@",[[YMDatabaseManager sharedInstance] getRowsForQuery:@"SELECT Count(*) FROM sqlite_master WHERE type = 'table' AND (NOT Name LIKE 'sqlite_%');"]);
}

/**
 * Does an SQL query.
 *
 * You should use this method for everything but SELECT statements.
 *
 * @param sql the sql statement.
 *
 * @return nil if everything was ok, NSError in other case.
 */
- (NSError *)doQuery:(NSString *)sql {
    //Query
    if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Query: %@",sql); }
    
    NSError *openError = nil;
    NSError *errorQuery = nil;
    
    @try {
        //Check if database is open and ready.
        if (db == nil) {
            openError = [self openDatabase];
        }
        
        if (openError == nil) {
            sqlite3_stmt *statement;
            const char *query = [sql UTF8String];
            
            sqlite3_busy_timeout(db, 1000);
            
            /*
             * Compile SQL text into byte-code that will do the work of querying or updating the database. The constructor for sqlite3_stmt.
             *
             * sqlite3_prepare_v2() : This routine converts SQL text into a prepared statement object and returns a pointer to that object.
             * This interface requires a database connection pointer created by a prior call to sqlite3_open() and a text string containing the SQL statement to be prepared.
             * This API does not actually evaluate the SQL statement. It merely prepares the SQL statement for evaluation.
             *
             * Think of each SQL statement as a small computer program. The purpose of sqlite3_prepare_v2() is to compile that program into object code.
             * The prepared statement is the object code. The sqlite3_step() interface then runs the object code to get a result.
             *
             * The SQLITE_OK result code means that the operation was successful and that there were no errors.
             */
            if(sqlite3_prepare_v2(db, query, -1, &statement, NULL)==SQLITE_OK) {
                if (sqlite3_step(statement) == SQLITE_ERROR) {
                    const char *errorMsg = sqlite3_errmsg(db);
                    errorQuery = [self createDBErrorWithDescription:[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]
                                                            andCode:kDBErrorQuery];
                }
            } else {
                const char *errorMsg = sqlite3_errmsg(db);
                errorQuery = [self createDBErrorWithDescription:[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]
                                                        andCode:kDBErrorQuery];
            }
            
            sqlite3_finalize(statement);
            //errorQuery = [self closeDatabase];
        }
        else {
            errorQuery = openError;
        }
        
    } @catch (NSException *exception) {
        if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"NSException : %@",exception.description); }
        
        errorQuery = [self createDBErrorWithDescription:exception.description
                                                andCode:kDBException];
    } @finally {
        if(errorQuery == nil) {
            errorQuery = [self closeDatabase];
        } else {
            // Close the DB connection
            [self closeDatabase];
        }
    }
    
    return errorQuery;
}


// create the table
-(NSError *)createTable : (NSString *)query {
    return [self doQuery:query];
}

//insert data in the table
-(NSError *)insert : (NSString *)tableName : (NSDictionary *)dict {
    NSError *dbError = nil;

    @try {
        NSArray *columns = [dict allKeys];
        //Create a prepared statement for insert query
        NSString *insertSQL = @"INSERT OR REPLACE INTO ";
        insertSQL=[insertSQL stringByAppendingString:tableName];
        insertSQL=[insertSQL stringByAppendingString:@" ("];
        
        for(int j=0; j<(int)[columns count]; j++) {
            //append column names
            insertSQL = [insertSQL stringByAppendingString:[columns objectAtIndex:j]];
            
            //seperate column names by comma
            if(j<(int)[columns count]-1)
                insertSQL=[insertSQL stringByAppendingString:@","];
        }
        
        insertSQL=[insertSQL stringByAppendingString:@") VALUES("];
        
        for(int j=0; j<(int)[columns count]; j++) {
            //append "value" for each column
            insertSQL=[insertSQL stringByAppendingString:@"\""];
            NSString *val= [NSString stringWithFormat:@"%@",[dict objectForKey:[columns objectAtIndex:j]]];
            if(!([val isEqual:[NSNull null]])){
                val  = [val stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                insertSQL=[insertSQL stringByAppendingString:[NSString stringWithFormat:@"%@",val]];
            }
            else {
                insertSQL=[insertSQL stringByAppendingString:@""];
            }
            insertSQL=[insertSQL stringByAppendingString:@"\""];
            
            //seperate '?' by comma
            if(j<(int)[columns count]-1)
                insertSQL=[insertSQL stringByAppendingString:@","];
        }
        
        insertSQL=[insertSQL stringByAppendingString:@");"];
        
        int count=0;
        while(1) {
            dbError = [self doQuery:insertSQL];
            
            if (dbError == nil){
                if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"DB Suceess %@: %@",tableName, insertSQL); }
                break;
                return nil;
            }
            else {
                if(count < 10) {
                    sqlite3_sleep(500);
                    count++;
                    continue;
                } else
                    break;
                
                return dbError;
            }
        }
    }
    @catch (NSException *exception) {
        //Exception
        if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Exception : %@",exception.description); }
    }
    
    return dbError;
}

//upadte the table
-(NSError *)update : (NSString *)tableName : (NSDictionary *)dict : (NSString *)condition {
    NSError *dbError = nil;
    
    @try {
        NSArray *columns = [dict allKeys];
        
        // Create an update query
        NSString *updateValues=@"";
        for (int i=0; i<(int)[[dict allKeys] count]; i++) {
            
            updateValues=[updateValues stringByAppendingString:[columns objectAtIndex:i]];
            updateValues=[updateValues stringByAppendingString:@"="];
            updateValues=[updateValues stringByAppendingString:@"\""];
            
            NSString *val= [NSString stringWithFormat:@"%@",[dict objectForKey:[columns objectAtIndex:i]]];
            if(!([val isEqual:[NSNull null]])){
                val  = [val stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                updateValues=[updateValues stringByAppendingString:[NSString stringWithFormat:@"%@",val]];
            }
            else {
                updateValues=[updateValues stringByAppendingString:@" "];
            }
            
            updateValues=[updateValues stringByAppendingString:@"\""];
            if (i<(int)[[dict allKeys] count]-1)
                updateValues=[updateValues stringByAppendingString:@" , "];
        }
        
        // The update query
        NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET %@ %@",tableName,updateValues,condition];
        
        int count=0;
        while(1) {
            dbError = [self doQuery:query];
            
            if (dbError == nil){
                if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"DB Update Suceess %@: %@",tableName, query); }
                break;
                return nil;
            }
            else {
                if(count < 10) {
                    sqlite3_sleep(500);
                    count++;
                    continue;
                } else
                    break;
                
                return dbError;
            }
        }
        
    } @catch (NSException *exception) {
        //Exception
        if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Exception : %@",exception.description); }
    }
    
    return dbError;
}






/**
 * Does a SELECT query and gets the info from the db.
 *
 * The return array contains an NSDictionary for row, made as: key=columName value= columnValue.
 *
 * For example, if we have a table named "users" containing:
 * name | pass
 * -------------
 * admin| 1234
 * dinesh | 5678
 *
 * it will return an array with 2 objects:
 * resultingArray[0] = name=admin, pass=1234;
 * resultingArray[1] = name=dinesh, pass=5678;
 *
 * So to get the admin password:
 * [[resultingArray objectAtIndex:0] objectForKey:@"pass"];
 *
 * @param sql the sql query (remember to use only a SELECT statement!).
 *
 * @return an array containing the rows fetched.
 */
- (NSArray *)getRowsForQuery:(NSString *)sql {
    //Query
    if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Query: %@",sql); }
    
    NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    
    @try {
        if (db == nil) {
            // Open the DB connection
            [self openDatabase];
        }
        
        sqlite3_busy_timeout(db, 1000);
        
        sqlite3_stmt *statement;
        const char *query = [sql UTF8String];
        int returnCode = sqlite3_prepare_v2(db, query, -1, &statement, NULL);
        
        if (returnCode == SQLITE_ERROR) {
            const char *errorMsg = sqlite3_errmsg(db);
            [self createDBErrorWithDescription:[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]
                                       andCode:kDBErrorQuery];
        }
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            // Return the number of columns in the result set returned by the statement.
            int columns = sqlite3_column_count(statement);
            
            NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:columns];
            
            for (int i = 0; i<columns; i++) {
                // Return the name assigned to a particular column in the result set of a SELECT statement.
                const char *name = sqlite3_column_name(statement, i);
                
                NSString *columnName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                
                // Returns the datatype code for the initial data type of the result column.
                int type = sqlite3_column_type(statement, i);
                
                switch (type) {
                    case SQLITE_INTEGER:
                    {
                        int value = sqlite3_column_int(statement, i);
                        [result setObject:[NSNumber numberWithInt:value] forKey:columnName];
                        break;
                    }
                    case SQLITE_FLOAT:
                    {
                        float value = sqlite3_column_double(statement, i);
                        [result setObject:[NSNumber numberWithFloat:value] forKey:columnName];
                        break;
                    }
                    case SQLITE_TEXT:
                    {
                        const char *value = (const char*)sqlite3_column_text(statement, i);
                        if(value == NULL) value = "";
                        [result setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnName];
                        break;
                    }
                        
                    case SQLITE_BLOB:
                    {
                        int bytes = sqlite3_column_bytes(statement, i);
                        if (bytes > 0) {
                            const void *blob = sqlite3_column_blob(statement, i);
                            if (blob != NULL) {
                                [result setObject:[NSData dataWithBytes:blob length:bytes] forKey:columnName];
                            }
                        }
                        break;
                    }
                        
                    case SQLITE_NULL:
                        [result setObject:[NSNull null] forKey:columnName];
                        break;
                        
                    default:
                    {
                        const char *value = (const char *)sqlite3_column_text(statement, i);
                        if(value == NULL) value = "";
                        [result setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnName];
                        break;
                    }
                        
                } //end switch
                
                
            } //end for
            
            [resultsArray addObject:result];
            
        } //end while
        
        sqlite3_finalize(statement);
        
    } @catch (NSException *exception) {
        if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"NSException : %@",exception.description); }
    } @finally {
        // Closes the DB connection
        [self closeDatabase];
    }
    
    return resultsArray;
}

//getQueryResults from table
-(NSArray *)getQueryResult : (NSString *)tableName : (NSString *)fields : (NSString *)condition {
    //sql select query
    
    NSString *querySQL = [NSString stringWithFormat: @"SELECT %@ from %@ %@",fields,tableName,condition];
    return [self getRowsForQuery:querySQL];
}

/**
 * Does an SQL parameterized query.
 *
 * You should use this method for parameterized INSERT or UPDATE statements.
 *
 * @param sql the sql statement using ? for params.
 *
 * @param params NSArray of params type (id), in CORRECT order please.
 *
 * @return nil if everything was ok, NSError in other case.
 */
- (NSError *)doUpdateQuery:(NSString *)sql withParams:(NSArray *)params {
    //Query
    if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Query: %@",sql); }
    
    NSError *openError = nil;
    NSError *errorQuery = nil;

    @try {
        //Check if database is open and ready.
        if (db == nil) {
            // Open the DB connection
            openError = [self openDatabase];
        }
        
        if (openError == nil) {
            sqlite3_busy_timeout(db, 1000);
            sqlite3_stmt *statement;
            const char *query = [sql UTF8String];
            
            /*
             * Compile SQL text into byte-code that will do the work of querying or updating the database. The constructor for sqlite3_stmt.
             *
             * sqlite3_prepare_v2() : This routine converts SQL text into a prepared statement object and returns a pointer to that object.
             * This interface requires a database connection pointer created by a prior call to sqlite3_open() and a text string containing the SQL statement to be prepared.
             * This API does not actually evaluate the SQL statement. It merely prepares the SQL statement for evaluation.
             *
             * Think of each SQL statement as a small computer program. The purpose of sqlite3_prepare_v2() is to compile that program into object code.
             * The prepared statement is the object code. The sqlite3_step() interface then runs the object code to get a result.
             *
             * The SQLITE_OK result code means that the operation was successful and that there were no errors.
             */
            if(sqlite3_prepare_v2(db,query , -1, &statement, NULL)==SQLITE_OK) {
                //BIND the params!
                int count =0;
                for (id param in params ) {
                    count++;
                    if ([param isKindOfClass:[NSString class]] )
                        sqlite3_bind_text(statement, count, [param UTF8String], -1, SQLITE_TRANSIENT);
                    if ([param isKindOfClass:[NSNumber class]] ) {
                        if (!strcmp([param objCType], @encode(float)))
                            sqlite3_bind_double(statement, count, [param doubleValue]);
                        else if (!strcmp([param objCType], @encode(int)))
                            sqlite3_bind_int(statement, count, [param intValue]);
                        else if (!strcmp([param objCType], @encode(BOOL)))
                            sqlite3_bind_int(statement, count, [param intValue]);
                        else
                            NSLog(@"unknown NSNumber");
                    }
                    if ([param isKindOfClass:[NSDate class]]) {
                        sqlite3_bind_double(statement, count, [param timeIntervalSince1970]);
                    }
                    if ([param isKindOfClass:[NSData class]] ) {
                        sqlite3_bind_blob(statement, count, [param bytes], (int)[param length], SQLITE_STATIC);
                    }
                }
                
                /*
                 * Advance an sqlite3_stmt to the next result row or to completion.
                 *
                 * sqlite3_step() : This routine is used to evaluate a prepared statement that has been previously created by the sqlite3_prepare() interface.
                 * The statement is evaluated up to the point where the first row of results are available.
                 * To advance to the second row of results, invoke sqlite3_step() again. Continue invoking sqlite3_step() until the statement is complete.
                 * Statements that do not return results (ex: INSERT, UPDATE, or DELETE statements) run to completion on a single call to sqlite3_step().
                 *
                 * The SQLITE_ROW result code returned by sqlite3_step() indicates that another row of output is available.
                 */
                if (sqlite3_step(statement) == SQLITE_ERROR) {
                    const char *errorMsg = sqlite3_errmsg(db);
                    errorQuery = [self createDBErrorWithDescription:[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]
                                                            andCode:kDBErrorQuery];
                }
                
                //clear the binding and reset the statement
                sqlite3_clear_bindings(statement);
                
                /*
                 * SQLite allows the same prepared statement to be evaluated multiple times. This is accomplished using the following routines:
                 
                 * sqlite3_reset()
                 * sqlite3_bind()
                 *
                 * After a prepared statement has been evaluated by one or more calls to sqlite3_step(), it can be reset in order to be evaluated again by a call to sqlite3_reset().
                 * Think of sqlite3_reset() as rewinding the prepared statement program back to the beginning. Using sqlite3_reset() on an existing prepared statement rather than creating a new prepared statement avoids unnecessary calls to sqlite3_prepare().
                 * For many SQL statements, the time needed to run sqlite3_prepare() equals or exceeds the time needed by sqlite3_step().
                 * So avoiding calls to sqlite3_prepare() can give a significant performance improvement.
                 *
                 */
                sqlite3_reset(statement);
                
            } else {
                const char *errorMsg = sqlite3_errmsg(db);
                errorQuery = [self createDBErrorWithDescription:[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]
                                                        andCode:kDBErrorQuery];
            }
            
            sqlite3_finalize(statement);
            //errorQuery = [self closeDatabase];
        }
        else {
            errorQuery = openError;
        }
        
    } @catch (NSException *exception) {
        if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"NSException : %@",exception.description); }
        
        errorQuery = [self createDBErrorWithDescription:exception.description
                                                andCode:kDBException];
    } @finally {
        if(errorQuery == nil) {
            // Closes the DB connection
            errorQuery = [self closeDatabase];
        } else {
            // Closes the DB connection
            [self closeDatabase];
        }
    }
    
    return errorQuery;
}

- (NSError *)saveApiResultsInTable:(NSString *)tableName data:(NSArray *)data {
    NSError *openError = nil;
    NSError *errorQuery = nil;
    
    //The prepared statement object. Created by sqlite3_prepare() and destroyed by sqlite3_finalize().
    sqlite3_stmt *compiledstatement;
    
    @try {
        NSString *primaryKey;
        NSArray *keyArray;
        
        //get the insert prepared statement
        NSString *insertSQL = [self prepareStmtForTable:tableName pk:&primaryKey keyArray:&keyArray];
        
        //Check if database is open and ready.
        if (db == nil) {
            // Open the DB connection
            openError = [self openDatabase];
        }
        
        if (openError == nil) {
            sqlite3_busy_timeout(db, 1000);
            
            //sqlite3_exec() : A wrapper function that does sqlite3_prepare(), sqlite3_step(), sqlite3_column(), and sqlite3_finalize() for a string of one or more SQL statements.
            sqlite3_exec(db, "BEGIN", 0, 0, 0);
            
            const char *sqlstatement = [insertSQL UTF8String];

            /*
             * Compile SQL text into byte-code that will do the work of querying or updating the database. The constructor for sqlite3_stmt.
             *
             * sqlite3_prepare_v2() : This routine converts SQL text into a prepared statement object and returns a pointer to that object.
             * This interface requires a database connection pointer created by a prior call to sqlite3_open() and a text string containing the SQL statement to be prepared.
             * This API does not actually evaluate the SQL statement. It merely prepares the SQL statement for evaluation.
             *
             * Think of each SQL statement as a small computer program. The purpose of sqlite3_prepare_v2() is to compile that program into object code.
             * The prepared statement is the object code. The sqlite3_step() interface then runs the object code to get a result.
             *
             * The SQLITE_OK result code means that the operation was successful and that there were no errors.
             */
            if(sqlite3_prepare_v2(db,sqlstatement , -1, &compiledstatement, NULL)==SQLITE_OK) {
                
                //fetch the dictionary(key,value) from the array of api result
                for (NSDictionary *rowData in data) {
                    if(([[rowData objectForKey:RESPONSE_IS_DELETED_KEY] boolValue] && (primaryKey != nil))) {
                        //if delete condition in api result is true
                        
                        errorQuery = [self deleteRecordInTable:tableName record:rowData primaryKey:primaryKey];
                    }
                     else {
                        NSString *preparedQueryValues = @"";
                        //get the value for ech key from api response and execute the insert statement
                        for(int j=0;j<(int)[keyArray count];j++) {
                            NSString *val = @"";
                            NSString *jsonKey = [keyArray objectAtIndex:j];
                            NSString *value=(NSString *)[rowData objectForKey:jsonKey];
                            if((value != nil) && (![value isEqual:[NSNull null]])){
                                val=[NSString stringWithFormat:@"%@",value];
                            
                                sqlite3_bind_text(compiledstatement,j+1,[val UTF8String], -1, SQLITE_TRANSIENT);
                            }
                            
                            preparedQueryValues=[preparedQueryValues stringByAppendingString:val];
                            
                            //seperate column names by comma
                            if(j<(int)[keyArray count]-1)
                                preparedQueryValues=[preparedQueryValues stringByAppendingString:@","];
                        }
                        
                        if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Prepared Query Values : %@",preparedQueryValues); }
                        
                        /*
                         * Advance an sqlite3_stmt to the next result row or to completion.
                         *
                         * sqlite3_step() : This routine is used to evaluate a prepared statement that has been previously created by the sqlite3_prepare() interface.
                         * The statement is evaluated up to the point where the first row of results are available.
                         * To advance to the second row of results, invoke sqlite3_step() again. Continue invoking sqlite3_step() until the statement is complete.
                         * Statements that do not return results (ex: INSERT, UPDATE, or DELETE statements) run to completion on a single call to sqlite3_step().
                         *
                         * The SQLITE_ROW result code returned by sqlite3_step() indicates that another row of output is available.
                         */
                        if(sqlite3_step(compiledstatement) != SQLITE_DONE) {
                            const char *errorMsg = sqlite3_errmsg(db);
                            errorQuery = [self createDBErrorWithDescription:[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]
                                                                    andCode:kDBErrorQuery];
                        }
                        
                        //clear the binding and reset the statement
                        sqlite3_clear_bindings(compiledstatement);
                        
                        /*
                         * SQLite allows the same prepared statement to be evaluated multiple times. This is accomplished using the following routines:
                         
                         * sqlite3_reset()
                         * sqlite3_bind()
                         *
                         * After a prepared statement has been evaluated by one or more calls to sqlite3_step(), it can be reset in order to be evaluated again by a call to sqlite3_reset().
                         * Think of sqlite3_reset() as rewinding the prepared statement program back to the beginning. Using sqlite3_reset() on an existing prepared statement rather than creating a new prepared statement avoids unnecessary calls to sqlite3_prepare().
                         * For many SQL statements, the time needed to run sqlite3_prepare() equals or exceeds the time needed by sqlite3_step().
                         * So avoiding calls to sqlite3_prepare() can give a significant performance improvement.
                         *
                         */
                        sqlite3_reset(compiledstatement);
                    }
                    
                }
                
                //sqlite3_exec() : A wrapper function that does sqlite3_prepare(), sqlite3_step(), sqlite3_column(), and sqlite3_finalize() for a string of one or more SQL statements.
                sqlite3_exec(db, "COMMIT", 0, 0, 0);
            } else {
                const char *errorMsg = sqlite3_errmsg(db);
                errorQuery = [self createDBErrorWithDescription:[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]
                                                        andCode:kDBErrorQuery];
            }
            
            
        } else {
            errorQuery = openError;
        }
    } @catch (NSException *exception) {
        if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"NSException : %@",exception.description); }
        
        errorQuery = [self createDBErrorWithDescription:exception.description
                                                andCode:kDBException];
    } @finally {
        /*
         * Destructor for sqlite3_stmt.
         * sqlite3_finalize() : This routine destroys a prepared statement created by a prior call to sqlite3_prepare().
         * Every prepared statement must be destroyed using a call to this routine in order to avoid memory leaks.
         */
        sqlite3_finalize(compiledstatement);
        
        if(errorQuery == nil) {
            // Closes the DB connection
            errorQuery = [self closeDatabase];
        } else {
            // Closes the DB connection
            [self closeDatabase];
        }
    }
    
    //return data save status
    return errorQuery;
}

- (NSError *)deleteRecordInTable:(NSString *)tableName record:(NSDictionary *)record primaryKey:(NSString *)primaryKey {
    NSError *error;
    @try {

        // create delete condition
        NSString *condn = [NSString stringWithFormat:@"%@=%@",primaryKey,[record objectForKey:primaryKey]];
        
        char *errMsg;
        
        //prepare sql delete statement
        const char *sql_stmt= [[NSString stringWithFormat:@"DELETE from %@ where %@",tableName,condn] UTF8String];
        
        if(DATABASE_DEBUG_MODE_FLAG) NSLog(@"Delete Query : %s",sql_stmt);
        
        /*
         * sqlite3_exec() : A wrapper function that does sqlite3_prepare(), sqlite3_step(), sqlite3_column(), and sqlite3_finalize() for a string of one or more SQL statements.
         *
         * The SQLITE_OK result code means that the operation was successful and that there were no errors.
         */
        if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
            if(DATABASE_DEBUG_MODE_FLAG) NSLog(@"DB Error Messgae : %s",errMsg);
            
            error = [self createDBErrorWithDescription:[NSString stringWithCString:errMsg encoding:NSUTF8StringEncoding]
                                                    andCode:kDBErrorQuery];
        }
    } @catch (NSException *exception) {
        //Exception
        if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"NSException : %@",exception.description); }
        
        error = [self createDBErrorWithDescription:exception.description
                                                andCode:kDBException];
    }
    
    return error;
}


//delete data from table
-(NSError *)deleteData : (NSString *)tableName : (NSString *)condition {
    NSString *query = @"";
    if(![condition isEqualToString:@""])
        query= [NSString stringWithFormat:@"DELETE from %@ where %@",tableName,condition];
    else
        query= [NSString stringWithFormat:@"DELETE from %@%@",tableName,condition];
    
    if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Query : %@",query); }
    return [self doQuery:query];
}

//delete data from table
-(NSError *)truncate:(NSString *)tableName {
    NSString *query = [NSString stringWithFormat:@"DELETE FROM %@; VACUUM;",tableName];
    if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Query : %@",query); }
    return [self doQuery:query];
}

//Delete records for a table

-(NSError *)truncate:(NSString *)tableName condition:(NSString *)condition {
    NSString *query = [NSString stringWithFormat:@"DELETE FROM %@; VACUUM;",tableName];
    if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Query : %@",query); }
    return [self doQuery:query];
}

//drop table
-(NSError *)drop : (NSString *)tableName {
    NSString *query = [NSString stringWithFormat:@"DROP TABLE %@",tableName];
    if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Query : %@",query); }
    return [self doQuery:query];
}

- (NSArray *)getTableInfo:(NSString *)tableName {
    NSString *query = [NSString stringWithFormat:@"PRAGMA table_info(%@);",tableName];
    return [self getRowsForQuery:query];
}

- (BOOL)didTableHaveAutoincrementPK:(NSString *)tableName {
    NSString *query = [NSString stringWithFormat:@"SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = '%@' AND sql LIKE '%%AUTOINCREMENT%%'",tableName];
    NSArray *resultsToCheckAutoIncrementPK = [self getRowsForQuery:query];
    BOOL isPKAutoincrement = NO;
    if(resultsToCheckAutoIncrementPK.count > 0) {
        isPKAutoincrement = YES;
    }
    
    return isPKAutoincrement;
}


-(NSString *)prepareStmtForTable:(NSString *)tableName pk:(NSString **)pk keyArray:(NSArray **)keyArray {
    @try {
        NSArray *results = [self getTableInfo:tableName];
        BOOL isPKAutoincrement = [self didTableHaveAutoincrementPK:tableName];

        NSMutableArray *columns = [[NSMutableArray alloc] init];
        if(results.count > 0) {
            for (NSDictionary *tableInfo in results) {
                NSString *columnName = tableInfo[@"name"];
                
                if([tableInfo[@"pk"] boolValue]) {
                    *pk = columnName;
                }
                
                if(([tableInfo[@"pk"] boolValue]) && (isPKAutoincrement)) {
                    continue;
                }

                if([@"isSent" isEqualToString:columnName]) {
                    continue;
                }

                [columns addObject:columnName];
            }
            
            *keyArray = columns;
        } else {
            return nil;
        }

        //Create a prepared statement for insert query
        NSString *insertSQL = @"INSERT OR REPLACE INTO ";
        insertSQL=[insertSQL stringByAppendingString:tableName];
        insertSQL=[insertSQL stringByAppendingString:@" ("];
        
        
        for(int j=0; j<(int)[columns count]; j++) {
            //append column names
            insertSQL = [insertSQL stringByAppendingString:[columns objectAtIndex:j]];
            
            //seperate column names by comma
            if(j<(int)[columns count]-1)
                insertSQL=[insertSQL stringByAppendingString:@","];
        }
        
        insertSQL=[insertSQL stringByAppendingString:@") VALUES("];
        
        for(int j=0; j<(int)[columns count]; j++) {
            //append '?' for each column
            insertSQL = [insertSQL stringByAppendingString:@"?"];
            
            //seperate '?' by comma
            if(j<(int)[columns count]-1)
                insertSQL=[insertSQL stringByAppendingString:@","];
        }
        
        insertSQL=[insertSQL stringByAppendingString:@");"];
        
        
        if(DATABASE_DEBUG_MODE_FLAG) {
            NSLog(@"Prepared Query : %@",insertSQL);
        }
        
        return insertSQL;
    } @catch (NSException *exception) {
        //Exception
        if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Exception : %@",exception.description); }
    }
    
    //return the insert prepared statement
    return nil;
}

/**
 * Creates an NSError.
 *
 * @param description the description wich can be queried with [error localizedDescription];
 * @param code the error code (code erors are defined as enum in the header file).
 *
 * @return the NSError just created.
 *
 */
- (NSError *)createDBErrorWithDescription:(NSString*)description andCode:(int)code {
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"SQLite Error" code:code userInfo:userInfo];
    
    if(DATABASE_DEBUG_MODE_FLAG){ NSLog(@"Error : %@",error); }
    
    return error;
}


/*
 To run an SQL statement, the application follows these steps:
 
 1. Create a prepared statement using sqlite3_prepare().
 2. Evaluate the prepared statement by calling sqlite3_step() one or more times.
 3. For queries, extract results by calling sqlite3_column() in between two calls to sqlite3_step().
 4. Destroy the prepared statement using sqlite3_finalize().
 
 * The sqlite3_exec() interface is a convenience wrapper that carries out all four of the above steps with a single function call. A callback function passed into sqlite3_exec() is used to process each row of the result set. The sqlite3_get_table() is another convenience wrapper that does all four of the above steps. The sqlite3_get_table() interface differs from sqlite3_exec() in that it stores the results of queries in heap memory rather than invoking a callback.
 
 */

@end



