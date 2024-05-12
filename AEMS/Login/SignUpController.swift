import UIKit

class SignUpController: UIViewController, UITextFieldDelegate
{
    // Sign UP VC Labels
    
    @IBOutlet weak var accountLabel: UILabel!
    
    // Sign UP VC TextFields
    
    @IBOutlet weak var fullNameText: UITextField!
    @IBOutlet weak var phoneNoText: UITextField!
    @IBOutlet weak var EmailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var username: UITextField!
    
    // Sign UP VC Buttons
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var usertypeButton: UIButton!
    @IBOutlet weak var policyButton: UIButton!
   
    // Sign UP VC Variables
    
    let oDBHelper = DBHelper()
    var responseData: [String: Any] = [:]

    // Sign Up VC Gesture Responsing
    
    @IBAction func keyboard(_ sender: Any)
    {
            view.endEditing(true)
    }
    
    // Sign Up VC Password Policy Operation
    
    @IBAction func passwordpolicy(_ sender: Any)
    {
        ShowImageAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PASSWORD_POLICY"))
        
    }
    
    // Sign Up VC User Menu Setup
    
    func setusertypeButton()
    {
        let optionClosure = {(action:UIAction) in Utils.printLogs(action.title)}
        
        let oDBHelper = DBHelper()
        
        oDBHelper.schemausertypeQuery()
        
        var menuItems: [UIAction] = []
        
        let menuItem = UIAction(title: SEL_USER,state: .on, handler: optionClosure)
        
        menuItems.append(menuItem)
        
        let result = oDBHelper.getUserType(condition: "")
        
        for val in 0..<result!.count {
            let menuItem = UIAction(title: "   " + String((result?[val].userType)!), handler: optionClosure)
            menuItems.append(menuItem)
        }
        
        usertypeButton.menu = UIMenu(children: menuItems)
        usertypeButton.showsMenuAsPrimaryAction = true
        usertypeButton.changesSelectionAsPrimaryAction = true
        
    }
    
    // Initial Layout Setup
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        username.attributedPlaceholder = NSAttributedString(string: " User Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        fullNameText.attributedPlaceholder = NSAttributedString(string: " Full Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        phoneNoText.attributedPlaceholder = NSAttributedString(string: " Phone Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        EmailText.attributedPlaceholder = NSAttributedString(string: " Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        passwordText.attributedPlaceholder = NSAttributedString(string: " Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        signUpButton.layer.cornerRadius = 10
        signUpButton.clipsToBounds = true
        signUpButton.layer.borderColor = UIColor.green.cgColor
        signUpButton.layer.borderWidth = 1.0
        
        usertypeButton.layer.cornerRadius = 5
        usertypeButton.clipsToBounds = true
        
        setusertypeButton()
        
        let oDBHelper = DBHelper()
        
        oDBHelper.schemausertypeQuery()
        
        phoneNoText.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
            // Calculate the new text length if the user enters the new string
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Set your desired maximum length here (e.g., 10 characters)
            let maxLength = 10
            
            // Return true if the new text length is within the maximum length, false otherwise
            return newText.count <= maxLength
    }
    
    // Sign In Screen Initializer
    
    @IBAction func signInAction(_ sender: Any) {
        performSegue(withIdentifier: SIGN_UP_IN_SEGUE, sender: nil)
    }
    
    // Sign Up Operation
    
    @IBAction func signUpAction(_ sender: Any)
    {
        let strUserName = username.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let strFullName = fullNameText.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let strEmail = EmailText.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let strPhoneNo = phoneNoText.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let strPassword = passwordText.text ?? ""
        
        // Validate Empty Fields
        
        if strUserName.isEmpty && strFullName.isEmpty && strEmail.isEmpty && strPhoneNo.isEmpty && strPassword.isEmpty
        {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_EMPTY_FIELDS"))
            return
        }
        
        
        // Validate UserName
        if strUserName.isEmpty {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_USERNAME"))
            return
        }
        
        // Validate FullName
        if strFullName.isEmpty {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_FULL_NAME"))
            return
        }
        
        // Validate Phone No
        if strPhoneNo.isEmpty {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PHONE_NO"))
            return
        }
        if strPhoneNo.validatePhoneNumber(strPhoneNo) == false
        {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PHONE_NO_FORMAT"))
            return
        }
        
        // Validate Email
        if strEmail.isEmpty
        {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_EMAIL"))
            return
        }
        
        if String.validateEmail(strEmail) == false
        {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_EMAIL_FORMAT"))
            return
        }
        
        // Validate Password
        if strPassword.isEmpty
        {
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
        
        if usertypeButton.titleLabel?.text == SEL_USER
        {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_SEL_USER"))
            return
        }
                        
        let usertypedata = oDBHelper.getUserType(condition: "where usertype = '\(usertypeButton.titleLabel?.text?.trimmingCharacters(in: .whitespaces) ?? "")'")
        
        responseData["username"] = username.text ?? ""
        responseData["fullname"] = fullNameText.text ?? ""
        responseData["phoneNo"] = Int(phoneNoText.text ?? "")
        responseData["email"] = EmailText.text ?? ""
        responseData["password"] = passwordText.text ?? ""
        responseData["usercode"] = (usertypedata?[0].usercode)!

        let result = oDBHelper.getUserAuthenticated(userdata: responseData["username"] as! String)
        
        if(result!.isEmpty)
        {
            
            oDBHelper.insertUserSignUpDetails(userData: responseData)
            
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_SIGNUP"))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8)
            {
                self.performSegue(withIdentifier: SIGN_UP_IN_SEGUE, sender: nil)
            }
        }
        else
        {
            ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_USERNAME_EXIST"))
        }
        
    }
    
    // Sign Up VC Alerts
    
    func ShowAlert(value:String)
    {
        let alert = UIAlertController(title: "", message: value, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
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



