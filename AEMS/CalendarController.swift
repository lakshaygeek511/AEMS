//
//  CalendarController.swift
//  Yamaha Maps
//
//  Created by VE00YM572 on 04/07/23.
//

import UIKit
import FSCalendar
import Lottie


class CalendarController: UIViewController , FSCalendarDataSource, FSCalendarDelegate
{
    
    override func viewDidLoad()
    {
        let calendar = FSCalendar(frame: CGRect(x: 35, y: 120, width: 350, height: 700))
        
        calendar.dataSource = self
        calendar.delegate = self
        
        view.addSubview(calendar)
        
    }
    
    
}
