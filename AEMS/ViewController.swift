import CoreLocation
import UIKit
import GoogleMaps

class MapController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate
{

    @IBOutlet weak var mapView: GMSMapView!
   
    @IBOutlet weak var BackView: UIView!
    
    var latitudevalue:Double = 0.0
    var longitudevalue:Double = 0.0
        
    let manager = CLLocationManager()
        
    @IBAction func BackAction(_ sender: Any)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.performSegue(withIdentifier: MAP_BACK_SEGUE, sender: nil)
        }
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        let Frame = BackView.frame
        let convertedFrame = view.convert(Frame, from: BackView.superview)
        BackView.frame = convertedFrame
               
        
        view.addSubview(BackView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        
        let camera = GMSCameraPosition.camera(withLatitude: latitudevalue, longitude: longitudevalue, zoom: 10.0)
        mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitudevalue, longitude: longitudevalue)
        marker.title = "Your Location"
        marker.icon = UIImage(named:"PIN")
        marker.map = mapView
        
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer)
    {
        let location = gesture.location(in: view)
        
        if BackView.isHidden == true {
            showView()
        } else {
            if !BackView.frame.contains(location)
            {
                    hideView()
            }
        }
    }
    
    
    func showView()
    {
        UIView.animate(withDuration: 0.8)
        {
            self.BackView.isHidden = false
        }
    }
    
    func hideView()
    {
        UIView.animate(withDuration: 0.8)
        {
            self.BackView.isHidden = false
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
}

