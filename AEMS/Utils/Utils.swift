import UIKit
import os
class Utils
{
    static func printLogs(_ message: String, _ args: CVarArg...){
        #if DEBUG
        os_log("%@",withVaList(args, { (cVaListPointer) -> NSString in
            return NSString(format: message, arguments: cVaListPointer)
        }) as String)
        #endif
    }
}

extension String
{
    
    static func validateEmail(_ email: String) -> Bool
    {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    func validatePhoneNumber(_ phoneNumber: String) -> Bool
    {
        let phoneRegex = "^\\d{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phoneNumber)
    }
    
    func validatePassword(_ password: String) -> Bool
    {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    static func validateQuantity(_ quantity: String) -> Bool
    {
        let quantityRegex = "^(?:[1-9]|1[0-9]|2[0-5])$"
        let quantityTest = NSPredicate(format: "SELF MATCHES %@", quantityRegex)
        return quantityTest.evaluate(with: quantity)
    }
    
}


extension HomeController
{
    func showToast(message: String)
    {
        let toastView = ToastView(message: message)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toastView)
        
        
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -725),
            toastView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            toastView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
        
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations:
                        {
            toastView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                toastView.alpha = 0.0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
    
    func ShowSelectionAlert(value:String)
    {
        let alert = UIAlertController(title: "Forbidden Operation", message: value, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func ShowFieldAlert(value:String)
    {
        let alert = UIAlertController(title: "Error", message: value, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func ShowAlert(value:String)
    {
        let alert = UIAlertController(title: "Operation Successful", message: value, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func ShowWentWrongAlert()
    {
        let alert = UIAlertController(title: "Something Went Wrong", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func ShowServerAlert()
    {
        let alert = UIAlertController(title: "Server Connection Error", message: "Check Internet", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func ShowLocationAlert(value:String)
    {
        let alert = UIAlertController(title: "Location Unauthorized", message: value, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func updateOrderData(user: [String: Any] , completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: HOST_IP + "/updateorder") else {
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
                DispatchQueue.main.async
                {
                    self.ShowAlert(value: responseString)
                }
                // Handle the response as needed
            } else {
                DispatchQueue.main.async
                {
                    self.showToast(message: "Invalid Response Data")
                }
            }
        }
        
        task.resume()
    }
    
    func postOrderData(user: [String: Any] , completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: HOST_IP + "/createorder") else {
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
                DispatchQueue.main.async
                {
                    self.ShowAlert(value: responseString)
                }
            } else {
                DispatchQueue.main.async
                {
                    self.showToast(message: "Invalid Response Data")
                }
            }
        }
        
        task.resume()
        
    }
    
}


