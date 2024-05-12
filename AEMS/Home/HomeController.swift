
import Foundation

import UIKit
import CoreLocation

class HomeController:UIViewController, UITabBarDelegate, UIGestureRecognizerDelegate,CLLocationManagerDelegate, UITableViewDataSource , UITableViewDelegate ,OrderCellDelegate,UITextFieldDelegate
{
 
    // Home VC Bar & Bar Items
    
    @IBOutlet weak var Bar:UITabBar!
    
    @IBOutlet var barItem:[UITabBarItem]!
    
    // Home VC Buttons, Collections
    
    @IBOutlet var button: [UIButton]!
    
    @IBOutlet weak var backbutton: UIButton!
    
    @IBOutlet var updatebutton: [UIButton]!
    
    @IBOutlet var updateButtonLabel: UIButton!
    
    // Home VC TextFields Collection
    
    @IBOutlet var textfields: [UITextField]!
    
    @IBOutlet var updatetextfields: [UITextField]!
        
    // Home VC Labels & Labels Collection
    
    @IBOutlet var countlabels: [UILabel]!
    
    @IBOutlet var updatedLabels: [UILabel]!
    
    @IBOutlet var updatedDataLabels: [UILabel]!
    
    @IBOutlet var dashboardLabels: [UILabel]!
    
    @IBOutlet var enquiryDetails: UILabel!
    
    // Keyboard Gesture Handling
    
    @IBAction func keyboard(_ sender: Any)
    {
        view.endEditing(true)
    }
    
    // Home VC Views
    
    @IBOutlet weak var CreateEnquiryView: UIView!
    
    @IBOutlet weak var EnquiryHistoryView: UITableView!
    
    @IBOutlet weak var UpdateEnquiryView: UIView!
    
    @IBOutlet weak var CountView: UIView!
    
    @IBOutlet weak var EnquiryDataView: UIView!
    
    
    // Home VC Variables & Instances
    
    var user:Int?
    
    var countretail:Int = 0
    
    var countclosed:Int = 0
    
    var viewEnquires:[[String]] = []
    var NoEnquires: UILabel!
    var Init:[HistoryDTO] = []
    var filter:String = "None"
    
    var ID:String = ""
    var Product:String = ""
    var Status:Int = 0
    
    var lat:Double = 0.0
    var long:Double = 0.0
    
    var userLatitude: Double?
    var userLongitude: Double?
    
    let oDBHelper = DBHelper()
    
    var responseData: [String: Any] = [:]
        
    // Home VC Image Views
    
    @IBOutlet weak var home: UIImageView!
    
    @IBOutlet weak var background: UIImageView!
    
    // Home Back Button Operation
    
    @IBAction func back(_ sender: Any)
    {
        tabBar(Bar, didSelect: barItem[1])
    }
    
    // Create Enquiry Button Operation
    
    @IBAction func createEnquiry(_ sender: Any)
    {
        let oDBHelper = DBHelper()
        
        
        let strCustomerName = textfields[0].text?.trimmingCharacters(in: .whitespaces) ?? ""
        let strUserName = SharedPrefs.getPrefs(USER_USERNAME).aesDecrypt()
        let strPhoneNo = textfields[1].text?.trimmingCharacters(in: .whitespaces) ?? ""
        let strEmail = textfields[2].text?.trimmingCharacters(in: .whitespaces) ?? ""
        let strAddress = textfields[3].text?.trimmingCharacters(in: .whitespaces) ?? ""
        let strQuantity = textfields[4].text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        
        // Validate CustomerName
        if strCustomerName.isEmpty
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_CUST_NAME"))
            return
        }
        
        // Validate Phone No
        else if strPhoneNo.isEmpty
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PHONE_NO"))
            return
        }
        
        
        else if strPhoneNo.validatePhoneNumber(strPhoneNo) == false
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PHONE_NO_FORMAT"))
            return
        }
        
        // Validate Email
        else if strEmail.isEmpty {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_EMAIL"))
            return
        }
        
        else if String.validateEmail(strEmail) == false
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_EMAIL_FORMAT"))
            return
        }
        // Validate Address
        else if strAddress.isEmpty
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_ADDRESS"))
            return
        }
        
        // Validate Quantity
        else if String.validateQuantity(strQuantity) == false
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_QUANTITY"))
            return
        }
        
        // Select Location
        else if button[0].titleLabel?.text == SEL_LOC
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_LOC_SEL"))
            return
        }
        
        // Select Product
        else if button[1].titleLabel?.text == SEL_PROD
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PROD_SEL"))
            return
        }
        
        if let selectedLocation = button[0].titleLabel?.text, selectedLocation != SEL_LOC
        {
            if let selectedLocation = button[0].titleLabel?.text?.trimmingCharacters(in: .whitespaces), let coordinates = cityCoordinates[selectedLocation]
            {
                userLatitude = coordinates.0
                userLongitude = coordinates.1
            }
        }
        
        let statusdata = oDBHelper.getStatus(condition: "where status = 'New'")
        
        
        let currentDate = Date()
        let timestamp = Int(currentDate.timeIntervalSince1970)
        
        // Enquiry PACKET
        
        responseData["username"] = SharedPrefs.getPrefs(USER_USERNAME).aesDecrypt()
        responseData["fullname"] = textfields[0].text?.trimmingCharacters(in: .whitespaces) ?? ""
        responseData["phoneNo"] = textfields[1].text?.trimmingCharacters(in: .whitespaces) ?? ""
        responseData["email"] = textfields[2].text?.trimmingCharacters(in: .whitespaces) ?? ""
        responseData["latitude"] =  userLatitude
        responseData["longitude"] = userLongitude
        responseData["address"] = textfields[3].text?.trimmingCharacters(in: .whitespaces) ?? ""
        responseData["product"] = button[1].titleLabel?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        responseData["quantity"] = Int(textfields[4].text?.trimmingCharacters(in: .whitespaces) ?? "")
        responseData["statuscode"] = statusdata![0].statuscode
        responseData["enquirydate"] = timestamp
                
        let response = oDBHelper.insertEnquiryDetails(enquirydata: responseData)
        
        if response == nil
        {
            ShowAlert(value: ENQUIRY_SUCCESS_ALERT)
        }
        else
        {
            ShowWentWrongAlert()
        }
                
        tabBar(Bar, didSelect: barItem[1])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
        {
            for value in 0..<self.textfields.count
            {
                self.textfields[value].text?.removeAll()
            }
            
            self.setProductsbutton()
            self.setLocationbutton()
        }
        
    }
    
    // Update Enquiry Button Operation
    
    @IBAction func update(_ sender: Any)
    {
        
        let oDBHelper = DBHelper()
        
        let upstrphoneNo = updatetextfields[0].text?.trimmingCharacters(in: .whitespaces) ?? ""
        let upstrEmail = updatetextfields[1].text?.trimmingCharacters(in: .whitespaces) ?? ""
        let upstrAddress = updatetextfields[2].text?.trimmingCharacters(in: .whitespaces) ?? ""
        let upstrQuantity = updatetextfields[3].text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        // Validate Phone No
        if upstrphoneNo.isEmpty
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PHONE_NO"))
            return
        }
        else if upstrphoneNo.validatePhoneNumber(upstrphoneNo) == false
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_PHONE_NO_FORMAT"))
            return
        }
        
        // Validate Email
        else if upstrEmail.isEmpty {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_EMAIL"))
            return
        }
        
        else if String.validateEmail(upstrEmail) == false
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_EMAIL_FORMAT"))
            return
        }
        // Validate Address
        else if upstrAddress.isEmpty
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_ADDRESS"))
            return
        }
        
        else if updatebutton[0].titleLabel?.text == SEL_STATUS
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_STATUS"))
            return
        }
        else if String.validateQuantity(upstrQuantity) == false
        {
            ShowFieldAlert(value: Lang.getLocalizedString(fromKey: "ALERT_QUANTITY"))
            return
        }
        
        
        // Update Enquiry Packet
        
        var responseData: [String: Any] = [:]
        
        let currentDate = Date()
        let timestamp = Int(currentDate.timeIntervalSince1970)
        
        let statusdata = oDBHelper.getStatus(condition: "where status = '\(updatebutton[0].titleLabel?.text?.trimmingCharacters(in: .whitespaces) ?? "")'")
        
        responseData["phoneNo"] = updatetextfields[0].text?.trimmingCharacters(in: .whitespaces) ?? ""
        responseData["email"] = updatetextfields[1].text?.trimmingCharacters(in: .whitespaces) ?? ""
        responseData["address"] = updatetextfields[2].text?.trimmingCharacters(in: .whitespaces) ?? ""
        responseData["quantity"] = Int(updatetextfields[3].text?.trimmingCharacters(in: .whitespaces) ?? "")
        responseData["statuscode"] = statusdata![0].statuscode
        
        let response = oDBHelper.updateEnquiryDetails(enquirydata: responseData, enquiryno: Int(ID)!)
        
        
        if response == nil
        {
            ShowAlert(value: ENQUIRY_UPDATE_SUCCESS_ALERT)
        }
        else
        {
            ShowWentWrongAlert()
        }
        
        tabBar(Bar, didSelect: barItem[1])
        
    }
    
    
    // Enquiry Filters Operations
    
    @IBAction func totalEnquiryFilter(_ sender: Any)
    {
        filter = NONE_FILTER
        fetchData()
    }
    
    
    @IBAction func retailFilter(_ sender: Any)
    {
        filter = RETAIL_FILTER
        fetchData()
    }
    
    @IBAction func closedFilter(_ sender: Any)
    {
        filter = CLOSED_FILTER
        fetchData()
    }
    
    
    // Enquiry History Table Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if tableView == EnquiryHistoryView
        {
            return viewEnquires.count
        }
        
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        // CUSTOM TABLE CELL SETUP
        
        let advancecell = tableView.dequeueReusableCell(withIdentifier: "AdvCell", for: indexPath) as! OrderCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        
        let data = oDBHelper.getStatus(condition: "where statuscode = '\(viewEnquires[indexPath.row][3])'")
        
        advancecell.Product.text = viewEnquires[indexPath.row][0]
        advancecell.Name.text = viewEnquires[indexPath.row][7]
        advancecell.EnquiryNo.text = "ID : " + viewEnquires[indexPath.row][1]
        advancecell.EnquiryDate.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(viewEnquires[indexPath.row][2])!))
        advancecell.Status.text =   (data?[0].status)!
        advancecell.Quantity.text = viewEnquires[indexPath.row][4]
        advancecell.Logo.image = UIImage(named: viewEnquires[indexPath.row][0])
        
        switch advancecell.Status.text
        {
            case STATUS_PROGRESS:
                advancecell.Box.setImage(UIImage(systemName: PROGRESS_IMAGE), for: .normal)
                advancecell.Box.tintColor = .systemOrange
            case STATUS_RETAIL:
                advancecell.Box.setImage(UIImage(systemName: RETAIL_IMAGE), for: .normal)
                advancecell.Box.tintColor = .systemGreen
            case STATUS_CLOSED:
                advancecell.Box.setImage(UIImage(systemName: CLOSED_IMAGE), for: .normal)
                advancecell.Box.tintColor = .systemYellow
            default:
                advancecell.Box.setImage(UIImage(systemName: DEFAULT_IMAGE), for: .normal)
                advancecell.Box.tintColor = .systemBlue
        }

        
        if(SharedPrefs.getIntegerPrefs(USER_TYPE) == 2)
        {
            advancecell.Locate.isHidden = true
        }
        if(SharedPrefs.getIntegerPrefs(USER_TYPE) == 1)
        {
            advancecell.Name.isHidden = true
            advancecell.Locate.isHidden = true
        }
        
        advancecell.delegate = self
        return advancecell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // TABLE CELL SELECT USER RELATIVE OPERATION
        
        if tableView == EnquiryHistoryView
        {
            Product = viewEnquires[indexPath.row][0]
            ID = viewEnquires[indexPath.row][1]
            Status = Int(viewEnquires[indexPath.row][3])!
            
            updatetextfields[0].text = viewEnquires[indexPath.row][8]
            updatetextfields[1].text = viewEnquires[indexPath.row][9]
            updatetextfields[2].text = viewEnquires[indexPath.row][10]
            updatetextfields[3].text = viewEnquires[indexPath.row][4]

            
            updatedLabels[0].text = "🙍‍♂️ " + viewEnquires[indexPath.row][7]
            updatedLabels[1].text = "📦 " + viewEnquires[indexPath.row][0]
            
            
                tabBar(Bar, didSelect: barItem[2])
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        
        if tableView == EnquiryHistoryView
        {
            ID = ""
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    
    // Fetch Enquiry History Call
    
    func fetchData()
    {
        var responseData: [String: Any] = [:]
        
        responseData["username"] =  SharedPrefs.getPrefs(USER_USERNAME).aesDecrypt()
        responseData["usercode"] =  SharedPrefs.getIntegerPrefs(USER_TYPE)
        
        viewEnquires = []
        countretail = 0
        countclosed = 0
        
        // Enquiry History Filtering CALLS
       
        if(filter == NONE_FILTER)
        {
            Init = oDBHelper.getEnquiryData(enquirydata:responseData)!
        }
        else if(filter == RETAIL_FILTER)
        {
            Init = oDBHelper.doEnquiryFilter(enquirydata:responseData,statuscode: "40")!
        }
        else if(filter == CLOSED_FILTER)
        {
            Init =  oDBHelper.doEnquiryFilter(enquirydata:responseData,statuscode: "10")!
        }

        var index:Int = 0
        var push:[String] = []
        
        for value in self.Init
        {
            push.append(value.product!)
            push.append(String(value.enquiryno!))
            push.append(String(value.enquirydate!))
            push.append(String(value.statuscode!))
            push.append(String(value.quantity!))
            push.append(String(value.latitude!))
            push.append(String(value.longitude!))
            push.append(String(value.fullname!))
            push.append(String(value.phoneNo!))
            push.append(String(value.email!))
            push.append(String(value.address!))
            
            
            self.viewEnquires.append(push)
            
            if(index<self.Init.count-1)
            {
                index += 1
                push = []
            }
        }
        
        
        for count in self.viewEnquires
        {
            if count[3] == "40"
            {
                self.countretail += 1
            }
            
            if count[3] == "10"
            {
                self.countclosed += 1
            }
            
        }
        
        DispatchQueue.main.async
        {
            self.CreateEnquiryView.isHidden = true
            self.UpdateEnquiryView.isHidden = true
            self.CountView.isHidden = false
            self.dashboardLabels[0].isHidden = false
            self.dashboardLabels[1].isHidden = false
            if self.filter == NONE_FILTER
            {
                self.countlabels[0].text = "\(self.Init.count)"
                self.countlabels[1].text = "\(self.countretail)"
                self.countlabels[2].text = "\(self.countclosed)"
            }
            self.EnquiryHistoryView.isHidden = false
            self.backbutton.isHidden = true
            self.EnquiryHistoryView.tableHeaderView = nil
            if self.Init.count == 0
            {
                self.NoEnquires = UILabel(frame: CGRect(x: 0, y: 0, width: self.EnquiryHistoryView.frame.width, height: self.EnquiryHistoryView.frame.height))
                self.NoEnquires.text = NO_ENQUIRES
                self.NoEnquires.textColor = UIColor.lightGray
                self.NoEnquires.textAlignment = .center
                self.NoEnquires.font = UIFont.systemFont(ofSize: 30)
                self.EnquiryHistoryView.tableHeaderView = self.NoEnquires
            }
            self.EnquiryHistoryView.reloadData()
        }
        
    }
    
    // Home VC View Load Setup
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if SharedPrefs.getIntegerPrefs(USER_TYPE) == 1
        {
            Bar.items?.removeAll()
            Bar.items?.append(barItem[0])
            Bar.items?.append(barItem[1])
            Bar.items?.append(barItem[2])
        }
        else if SharedPrefs.getIntegerPrefs(USER_TYPE) == 2
        {
            Bar.items?.removeAll()
            Bar.items?.append(barItem[1])
        }
        
        
        
        Bar.delegate = self
        
        EnquiryHistoryView.dataSource = self
        EnquiryHistoryView.delegate = self
        
        EnquiryDataView.layer.borderWidth = 1
        EnquiryDataView.layer.borderColor = UIColor.systemGreen.cgColor
        
        button[0].layer.cornerRadius = 5
        button[0].clipsToBounds = true
        button[0].layer.borderWidth = 1
        button[0].layer.borderColor = UIColor.lightGray.cgColor
        
        button[1].layer.cornerRadius = 5
        button[1].clipsToBounds = true
        button[1].layer.borderWidth = 1
        button[1].layer.borderColor = UIColor.lightGray.cgColor
        
        button[2].layer.cornerRadius = 5
        button[2].clipsToBounds = true
        
        updatebutton[0].layer.cornerRadius = 5
        updatebutton[0].clipsToBounds = true
        updatebutton[0].layer.borderWidth = 1
        updatebutton[0].layer.borderColor = UIColor.lightGray.cgColor
                
        Utils.printLogs(String(self.viewEnquires.count))
        
        for value in 0..<textfields.count
        {
            textfields[value].attributedPlaceholder = NSAttributedString(string: " " + textfields[value].placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            textfields[value].layer.cornerRadius = 5
            textfields[value].clipsToBounds = true
            textfields[value].alpha = 1
            textfields[value].layer.borderWidth = 1
            textfields[value].layer.borderColor = UIColor.lightGray.cgColor
        }
        
        for value in 0..<updatetextfields.count
        {
            updatetextfields[value].attributedPlaceholder = NSAttributedString(string: " " + updatetextfields[value].placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            updatetextfields[value].layer.cornerRadius = 5
            updatetextfields[value].clipsToBounds = true
            updatetextfields[value].alpha = 1
            updatetextfields[value].layer.borderWidth = 1
            updatetextfields[value].layer.borderColor = UIColor.lightGray.cgColor
        }
        
        oDBHelper.schemaStatusQuery()
        oDBHelper.schemausertypeQuery()
        
        textfields[1].delegate = self
        updatetextfields[0].delegate = self
        
        fetchData()
    }
    
    // TAB BAR DELEGATE METHODS
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        if item == barItem[0]
        {
            CreateEnquiryView.isHidden = false
            EnquiryHistoryView.isHidden = true
            UpdateEnquiryView.isHidden = true
            CountView.isHidden = true
            dashboardLabels[0].isHidden = true
            dashboardLabels[1].isHidden = true
            setLocationbutton()
            setProductsbutton()
            oDBHelper.schemaStatusQuery()
            backbutton.isHidden = false
            home.alpha = 0.7
            ID = ""
            
        }
        if item == barItem[1]
        {
            filter = NONE_FILTER
            fetchData()
            home.alpha = 1
            ID = ""
        }
        
        if item == barItem[2]
        {
                    if(viewEnquires.isEmpty)
                    {
                        ShowSelectionAlert(value: Lang.getLocalizedString(fromKey: "ALERT_CREATE_UPDATE"))
                    }
                    else
                    {
                        if(CreateEnquiryView.isHidden == false)
                        {
                            fetchData()
                        }
                        
                        if ID == ""
                        {
                            ShowSelectionAlert(value: Lang.getLocalizedString(fromKey: "ALERT_SEL_UPDATE"))
                        }
                        else
                        {
                            CreateEnquiryView.isHidden = true
                            EnquiryHistoryView.isHidden = true
                            CountView.isHidden = true
                            UpdateEnquiryView.isHidden = false
                            dashboardLabels[0].isHidden = true
                            dashboardLabels[1].isHidden = true
                            setStatusbutton()
                            backbutton.isHidden = false
                            home.alpha = 0.7
                            
                            if SharedPrefs.getIntegerPrefs(USER_TYPE) == 2
                            {
                                
                                for label in updatedDataLabels
                                {
                                    if let currentText = label.text
                                    {
                                        label.text = currentText.replacingOccurrences(of: "Set", with: "").replacingOccurrences(of: "Select", with: "").replacingOccurrences(of: "New", with: "").trimmingCharacters(in: .whitespaces)
                                    }
                                }
                                
                                enquiryDetails.text = ENQUIRY_DETAILS
                                updateButtonLabel.isHidden = true
                                for textField in updatetextfields {
                                    textField.isUserInteractionEnabled = false
                                }
                                
                                for button in updatebutton {
                                    button.isUserInteractionEnabled = false
                                }
                            }
                        }
                    }
        }
        
    }
    
    // TEXT FIELD DELEGATE
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Calculate the new text length if the user enters the new string
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Set your desired maximum length here (e.g., 10 characters)
            let maxLength = 10
            
            // Return true if the new text length is within the maximum length, false otherwise
            return newText.count <= maxLength
        }
    
    
    
    // MENU BUTTON SETUPS
    
    
    // LOCATION BUTTON SETUP
    
    func setLocationbutton()
    {
        
        let optionClosure = { (action: UIAction) in
            Utils.printLogs(action.title)
        }
                
        var menuItems: [UIAction] = []
        
        let menuItem = UIAction(title: SEL_LOC,state: .on, handler: optionClosure)
        
        menuItems.append(menuItem)
        
        for city in cities {
            let menuItem = UIAction(title: "   " + city, handler: optionClosure)
            menuItems.append(menuItem)
        }
        
        button[0].menu = UIMenu(children: menuItems)
        button[0].showsMenuAsPrimaryAction = true
        button[0].changesSelectionAsPrimaryAction = true
        
    }
    
    // STATUS BUTTON SETUP
    
    func setStatusbutton()
    {
        
        let optionClosure = { (action: UIAction) in
            Utils.printLogs(action.title)
        }
                
        var menuItems: [UIAction] = []
        
        let statusdata = oDBHelper.getStatus(condition: "where statuscode = '\(Status)'")
        
        let menuItem = UIAction(title: "   "+statusdata![0].status!,state: .on, handler: optionClosure)
        
        menuItems.append(menuItem)
    
        for value in status
        {
            if(value != statusdata![0].status!)
            {
                let menuItem = UIAction(title: "   " + value, handler: optionClosure)
                menuItems.append(menuItem)
            }
        }
        
        updatebutton[0].menu = UIMenu(children: menuItems)
        updatebutton[0].showsMenuAsPrimaryAction = true
        updatebutton[0].changesSelectionAsPrimaryAction = true
        
    }
    
    
    // PRODUCTS BUTTON SETUP
    
    func setProductsbutton()
    {
        
        let optionClosure = { (action: UIAction) in
            Utils.printLogs(action.title)
        }
                
        var menuItems: [UIAction] = []
        
        let menuItem = UIAction(title: SEL_PROD,state: .on, handler: optionClosure)
        
        menuItems.append(menuItem)
                
        for product in products {
            let menuItem = UIAction(title: "   " + product, handler: optionClosure)
            menuItems.append(menuItem)
        }
        
        button[1].menu = UIMenu(children: menuItems)
        button[1].showsMenuAsPrimaryAction = true
        button[1].changesSelectionAsPrimaryAction = true
        
    }
    
    // SIGN OUT OPERATION
    
    @IBAction func signOutAction(_ sender: Any)
    {
        ShowAlert(value: Lang.getLocalizedString(fromKey: "ALERT_SIGNOUT"))
        UIView.animate(withDuration: 0.3)
        {
            self.CreateEnquiryView.isHidden = true
            self.UpdateEnquiryView.isHidden = true
        }
        
        UIView.animate(withDuration: 0.3)
        {
            self.fetchData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8)
        {
            self.performSegue(withIdentifier: SIGN_OUT_SEGUE, sender: nil)
            SharedPrefs.setBooleanType(false, key: USER_LOGGED_IN)
            SharedPrefs.setPrefs(nil,key: USER_TYPE)
        }
        
    }
    
    func locateButtonTapped(cell: OrderCell)
    {
        guard let indexPath = EnquiryHistoryView.indexPath(for: cell) else {
            return
        }
        
        let lat = Double(viewEnquires[indexPath.row][5])!
        let long = Double(viewEnquires[indexPath.row][6])!
        
        performSegue(withIdentifier: MAP_SEGUE, sender: (lat, long))
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MAP_SEGUE,
           let (lat, long) = sender as? (Double, Double),
           let destinationVC = segue.destination as? MapController {
            destinationVC.latitudevalue = lat
            destinationVC.longitudevalue = long
        }
    }
    
    
}

class OrderCell: UITableViewCell
{
    
    // CUSTOM TABLE CELL VARIABLES
    
    @IBOutlet weak var Name:UILabel!
    
    @IBOutlet weak var Product:UILabel!
    
    @IBOutlet weak var Status:UILabel!
    
    @IBOutlet weak var EnquiryNo:UILabel!
    
    @IBOutlet weak var EnquiryDate:UILabel!
    
    @IBOutlet weak var Quantity: UILabel!
    
    @IBOutlet weak var Locate: UIButton!
    
    @IBOutlet weak var Logo: UIImageView!
    
    @IBOutlet weak var Box:UIButton!
    
    
    weak var delegate: OrderCellDelegate?
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        delegate?.locateButtonTapped(cell: self)
    }
}

protocol OrderCellDelegate: AnyObject
{
    func locateButtonTapped(cell: OrderCell)
}

