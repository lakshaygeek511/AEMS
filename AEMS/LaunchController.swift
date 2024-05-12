
import UIKit


class LaunchController: UIViewController
{
    
    // Launch VC Labels
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    
    // Launch VC Buttons
    
    @IBOutlet weak var startButton: UIButton!
    
    // Start Button Operation
    @IBAction func startAction(_ sender: UIButton)
    {
        if SharedPrefs.getBooleanTypePrefs(USER_LOGGED_IN) == true
        {
            performSegue(withIdentifier: "homesegue", sender: nil)
        }
        else
        {
            
            if SharedPrefs.getBooleanTypePrefs(IS_NOT_FIRST_LAUNCH) == false
            {
                
                SharedPrefs.setBooleanType(true, key: IS_NOT_FIRST_LAUNCH)
                performSegue(withIdentifier: "signupsegue", sender: nil)
            }
            else
            {
                performSegue(withIdentifier: "signinsegue", sender: nil)
            }
        }
    }
    
    // Initial Layout Setup
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupInitialUI()
        introLabel.text = Lang.getLocalizedString(fromKey: "INTRO_LABELS")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showLabelsAndButton()
        }
    }
    
        
        private func setupInitialUI() {
            welcomeLabel.alpha = 0.0
            introLabel.alpha = 0.0
            startButton.alpha = 0.0
            startButton.layer.cornerRadius = 10
            startButton.clipsToBounds = true
            startButton.layer.borderColor = UIColor.green.cgColor
            startButton.layer.borderWidth = 1.0
            startButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            welcomeLabel.isHidden = true
            introLabel.isHidden = true
            startButton.isHidden = true
        }
        
        private func showLabelsAndButton() {
            welcomeLabel.isHidden = false
            
            UIView.animate(withDuration: 0.5, animations: {
                self.welcomeLabel.alpha = 1.0
            }) { (_) in
                self.introLabel.isHidden = false
                UIView.animate(withDuration: 0.5, animations: {
                    self.introLabel.alpha = 1.0
                    self.introLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }) { (_) in
                    self.startButton.isHidden = false
                    UIView.animate(withDuration: 0.3, animations: {
                        self.introLabel.transform = CGAffineTransform.identity
                        self.startButton.alpha = 1.0
                        self.startButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    }) { (_) in
                        UIView.animate(withDuration: 0.2, animations: {
                            self.startButton.transform = CGAffineTransform.identity
                        })
                    }
                }
            }
        }
}
    

    
    

