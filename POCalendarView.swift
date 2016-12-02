//
//  POCalendarView.swift
//  CalendarDev
//
//  Created by 直井　真一郎 on 2016/12/02.
//  Copyright © 2016年 Shinichiro Naoi. All rights reserved.
//

import Cocoa

@IBDesignable
class POCalendarView : NSView {
    
    
    var duration = 120;
    
    
    @IBOutlet var _calendarView: NSView!
    @IBOutlet weak var _year: NSPopUpButton!
    @IBOutlet weak var _month: NSPopUpButton!
    @IBOutlet weak var _day: NSPopUpButton!

    private let _dateformatter = DateFormatter()
    private let _dateformatterja = DateFormatter()

    private var _warekiDictionary = [String:String]()
    
    
    private func initYears() {
        
        _year.removeAllItems()
        // soted keys
        let keys = _warekiDictionary.keys.sorted { (a, b) -> Bool in
            a > b
        }
        
        for k in keys {
            let str = " \(k) 年（\(_warekiDictionary["\(k)"]!)）"
            _year.addItem(withTitle: str)
        }
        
        
//        for c in _warekiDictionary {
//            let str = "\(c.key)年 （\(c.value)）"
//            _year.addItem(withTitle: str)
//        }
        
//        let now = Date()
//        let componentsNow = _dateformatter.calendar.dateComponents([.year, .month], from: now)
//        let currentYear = componentsNow.year!
//        
//        for i in 0..<_warekiDictionary.count {
//            let y = currentYear - i
//            let str = "\(y)年 （\(_warekiDictionary["\(y)"]!)）"
//            _year.addItem(withTitle: str)
//        }
        
    }
    
    private func initWarekiDictionary() {
        
        let now = Date()
        let componentsNow = _dateformatter.calendar.dateComponents([.year, .month], from: now)
        _dateformatterja.dateFormat = "Gy年"
        
        let currentYear = componentsNow.year!
        var arr = [[String]]()
        
        for i in 0..<duration {
            let y = currentYear - i
            
            var prevWareki = ""
            var tempArr = [String]()
            for m in 1...12 {
                for d in 1...31 {
                    if let date = _dateformatter.date(from: "\(y)/\(m)/\(d)") {
                        let wareki = _dateformatterja.string(from:date)
                        if( prevWareki != wareki) {
                            tempArr.append(wareki)
                        }
                        prevWareki = wareki
                    }
                }
            }
            
            arr.append(tempArr)
        }
        
        // Creare Wareki dictionary
        var y = currentYear
        for a in arr {
            var i = a.count - 1
            var yearStr = a[i]
            i -= 1
            while(i > -1) {
                yearStr += "、" + a[i]
                i -= 1
            }
            _warekiDictionary["\(y)"] = yearStr
            y -= 1
        }
    }
    
    private func initDatePickers() {
        
        // init dateformatters
        _dateformatter.dateFormat = "YYYY/MM/dd"
        _dateformatterja.dateStyle = .long
        _dateformatterja.calendar = Calendar(identifier: Calendar.Identifier.japanese)
        
        // 年号辞書作成
        initWarekiDictionary()
        
        // 年一覧更新
        initYears()
    }
    
    // shared init
    private func sharedInit() {
        
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed("POCalendarView", owner: self, topLevelObjects: nil)
        
        _calendarView.frame = self.bounds
        addSubview(_calendarView)
        
        initDatePickers()
    }
    
    // init for code
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    // init for storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
}
