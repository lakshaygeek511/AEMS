
import Foundation


class APIHelper
{
        
    func postSignUpData(user: [String: Any] , completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: HOST_IP + "/signup") else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: user, options: [])
        } catch {
            Utils.printLogs("Error: Failed to serialize request data")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                Utils.printLogs("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                Utils.printLogs("API response: \(responseString)")
                
                // Handle the response as needed
            } else {
                Utils.printLogs("Error: Invalid response data")
            }
        }

        task.resume()
        
    }
    

    func getOrderData(user: [String: Any], completion: @escaping (Result<[HistoryDTO], Error>) -> Void) {
        guard let url = URL(string: HOST_IP + "/orderhistory") else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        do {
            // Serialize the dictionary to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: user, options: [])
            request.httpBody = jsonData
        } catch {
            Utils.printLogs("Error: Failed to serialize request data")
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                Utils.printLogs("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    Utils.printLogs("Data: \(data)")
                    // Deserialize the response data to a HistoryDTO object
                    let userDTO = try JSONDecoder().decode([HistoryDTO].self, from: data)
                    completion(.success(userDTO))
                } catch {
                    Utils.printLogs("Error: Failed to decode response data")
                    completion(.failure(error))
                }
            } else {
                Utils.printLogs("Error: Invalid response data")
                let error = NSError(domain: "Invalid response data", code: 0, userInfo: nil)
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

}
