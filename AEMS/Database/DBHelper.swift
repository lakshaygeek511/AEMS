import Foundation
import os

class DBHelper
{
    let oYMDatabaseMgr = YMDatabaseManager()
    
    
    // INSERT SIGN UP CALL
    
    func insertUserSignUpDetails(userData: [String: Any]) -> Error?
    {
        return oYMDatabaseMgr.insert(TBL_USER_MASTER, userData)
        
    }
    
    // INSERT ENQUIRY DETAILS CALL
    
    func insertEnquiryDetails(enquirydata: [String: Any]) -> Error?
    {
        return oYMDatabaseMgr.insert(TBL_USER_ENQUIRY_MAPPING, enquirydata)
    }
    
    // UPDATE ENQUIRY DETAILS CALL

    func updateEnquiryDetails(enquirydata: [String: Any],enquiryno:Int) -> Error?
    {
        return oYMDatabaseMgr.update(TBL_USER_ENQUIRY_MAPPING, enquirydata, "where enquiryno='\(enquiryno)'")
    }
    
    // USER AUTH & VALIDATE CALL
    
    func getUserAuthenticated(userdata:String) ->  [UserDTO]?
    {
        do
        {
            let response = oYMDatabaseMgr.getQueryResult(TBL_USER_MASTER, "username, password, fullname, usercode", "where username='\(userdata)'")
            let jsonData = try? JSONSerialization.data(withJSONObject:response as Any)
            
            let f = try JSONDecoder().decode([UserDTO].self, from: jsonData!)
            return f
        }
        
        catch
        {
            Utils.printLogs("error : %@", "\(error)")
        }
        
        return nil
    }
    
    // ENQUIRY DETAILS CALL
    
    func getEnquiryData(enquirydata:[String: Any]) ->  [HistoryDTO]?
    {
        do
        {
            
            var response:[Any]? = []
            
            if(enquirydata["usercode"] as! Int == 1)
            {
                let name = enquirydata["username"] as! String
                response = oYMDatabaseMgr.getQueryResult(TBL_USER_ENQUIRY_MAPPING, "*", "where username ='\(name)'")
            }
            else
            {
                response = oYMDatabaseMgr.getQueryResult(TBL_USER_ENQUIRY_MAPPING, "*", "")
            }
            
            let jsonData = try? JSONSerialization.data(withJSONObject:response as Any)
            
            let f = try JSONDecoder().decode([HistoryDTO].self, from: jsonData!)
            return f
        }
        
        catch
        {
            Utils.printLogs("error : %@", "\(error)")
        }
        
        return nil
    }
    
    // FILTER ENQUIRY DETAILS CALL
    
    func doEnquiryFilter(enquirydata:[String: Any],statuscode:String) ->  [HistoryDTO]?
    {
        do
        {
            var response:[Any]? = []
            
            if(enquirydata["usercode"] as! Int == 1)
            {
                let name = enquirydata["username"] as! String
                response = oYMDatabaseMgr.getQueryResult(TBL_USER_ENQUIRY_MAPPING, "*", "where username ='\(name)' AND statuscode ='\(statuscode)'")
            }
            else
            {
                response = oYMDatabaseMgr.getQueryResult(TBL_USER_ENQUIRY_MAPPING, "*", "where statuscode ='\(statuscode)'")
            }
            
            let jsonData = try? JSONSerialization.data(withJSONObject:response as Any)
            
            let f = try JSONDecoder().decode([HistoryDTO].self, from: jsonData!)
            return f
        }
        
        catch
        {
            Utils.printLogs("error : %@", "\(error)")
        }
        
        return nil
    }
    
    // USER TYPE CALL
    
    func getUserType(condition: String?) -> [UserTypeDTO]?
    {
        do
        {
            let response = oYMDatabaseMgr.getQueryResult(TBL_USERTYPE_MASTER, "*", condition)
            let jsonData = try? JSONSerialization.data(withJSONObject:response as Any)
            
            let f = try JSONDecoder().decode([UserTypeDTO].self, from: jsonData!)
            return f
        }
        
        catch
        {
            Utils.printLogs("error : %@", "\(error)")
        }
        
        return []
    }
    
    // STATUS CALL
    
    func getStatus(condition: String?) -> [StatusDTO]?
    {
        do
        {
            let response = oYMDatabaseMgr.getQueryResult(TBL_STATUS_MASTER, "*", condition)
            let jsonData = try? JSONSerialization.data(withJSONObject:response as Any)
            
            let f = try JSONDecoder().decode([StatusDTO].self, from: jsonData!)
            return f
        }
        
        catch
        {
            Utils.printLogs("error : %@", "\(error)")
        }
        
        return []
    }
    
    // MASTER QUERIES
    
    func schemausertypeQuery()
    {
        oYMDatabaseMgr.doQuery("INSERT INTO usertype_master (usercode, usertype) VALUES (1, 'SalesPerson'), (2, 'Dealer');")
    }
    
    
    func schemaStatusQuery()
    {
        oYMDatabaseMgr.doQuery("INSERT INTO status_master (statuscode, status) VALUES (10, 'Closed'), (20, 'In Progress'), (30,'New'), (40,'Retailed')")
                               
    }
}
