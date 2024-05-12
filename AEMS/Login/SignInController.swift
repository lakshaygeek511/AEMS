import UIKit

class SignInController:UIViewController
{
    
    // BACK OPERATION
    
    @IBAction func backAction(_ sender: Any) {
        performSegue(withIdentifier: SIGN_IN_UP_SEGUE, sender: nil)
    }
    
    // SIGN IN VC FIELDS & BUTTONS
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var policyButton: UIButton!
    
    // SIGN IN VC Variables
    
    var value:Int?
    
    var Check:[UserDTO]?
        
    let oDBHelper = DBHelper()

    var responseData: [String: Any] = [:]

    // Sign In VC Gesture Responsing

    @IBAction func keyboard(_ sender: Any)
    {
        view.endEditing(true)
    }
    
    // Sign In VC Password Policy Operation

    @IBAction func passwordpolicy(_ sender: Any)
    {
        ShowImageAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PASSWORD_POLICY"))
        
    }
    
    // SIGN IN OPERATION
    
    @IBAction func signInAction(_ sender: Any)
    {
        let strUserName = username.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let strPassword = passwordText.text ?? ""
        
        // Validate Empty Fields
        
        if strUserName.isEmpty && strPassword.isEmpty
        {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_EMPTY_FIELDS"))
            return
        }
        
        // Validate UserName

        if strUserName.isEmpty {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_USERNAME"))
            return
        }
        
        // Validate Password

        if strPassword.isEmpty {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PASSWORD"))
            return
        }
        
        if strPassword.validatePassword(strPassword) == false
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
            {
                    self.ShowImageAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PASSWORD_FORMAT"))
            }
            
            return
        }
                
        responseData["username"] = username.text ?? ""
        responseData["password"] = passwordText.text ?? ""
        
        Check = oDBHelper.getUserAuthenticated(userdata: responseData["username"] as! String)
        
        if !Check!.isEmpty
        {
            
            if(self.Check![0].password != responseData["password"] as? String)
            {
                DispatchQueue.main.async
                {
                    self.ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_AUTH_FAILURE"))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5)
                    {
                        self.ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PASSWORD_MATCH"))
                    }
                }
                
            }
            else if(self.Check![0].password == responseData["password"] as? String)
            {
                DispatchQueue.main.async
                {
                    self.ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_AUTH_SUCCESS"))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                    {
                        self.value = self.Check![0].usercode
                        SharedPrefs.setInteger((self.Check![0].usercode)!, key: USER_TYPE)
                        SharedPrefs.setPrefs(self.username.text!.lowercased().aesEncrypt(), key: USER_USERNAME)
                        SharedPrefs.setPrefs(self.passwordText.text!.aesEncrypt(), key: USER_PASSWORD)
                        SharedPrefs.setBooleanType(true, key: USER_LOGGED_IN)
                        
                        
                        self.performSegue(withIdentifier: SIGN_IN_HOME_SEGUE, sender: nil)
                    }
                }
            }
            
        }
        else
        {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_USERNAME_FAILURE"))
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        username.attributedPlaceholder = NSAttributedString(string: " 🙍‍♂️ User Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        passwordText.attributedPlaceholder = NSAttributedString(string: " 🔒 Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        signInButton.layer.cornerRadius = 10
        signInButton.clipsToBounds = true
        signInButton.layer.borderColor = UIColor.green.cgColor
        signInButton.layer.borderWidth = 1.0
        
    }
    
    // Sign In VC Alerts & Toasts
    
    func ShowAlert(value:String)
    {
        let alert = UIAlertController(title: "", message: value, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showToast(message: String)
    {
        let toastView = ToastView(message: message)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toastView)
        
        
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            toastView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            toastView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
        
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            toastView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                toastView.alpha = 0.0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
    
    func ShowImageAlert(value:String)
    {
        let alert = UIAlertController(title: "", message: value, preferredStyle: .alert)
        let imageView = UIImageView(image: policyButton.image(for: .normal))
        let imageSize = imageView.image?.size ?? CGSize.zero
            let newWidth: CGFloat = 30
            let newHeight = (newWidth / imageSize.width) * imageSize.height
            imageView.frame = CGRect(x: 1, y: 1, width: newWidth, height: newHeight)
        alert.view.addSubview(imageView)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}



