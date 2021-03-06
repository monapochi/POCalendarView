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
    
    
    var duration = 120
    var year = 0
    var month = 0
    var day = 0
    var text: String {
        get{
            return "\(year)/\(String(format: "%02d", month))/\(String(format: "%02d", day))"
        }
        
        set {
            let date = newValue.components(separatedBy: "/")
            if(date.count != 3) { return }
            
            year = Int(date[0])!
            month = Int(date[1])!
            day = Int(date[2])!
            
            initYears()
            
        }
    }
    var stringValue: String {
        get{
            return text
        }
        set {
            text = newValue
        }
    }
    
    @IBOutlet var _calendarView: NSView!
    @IBOutlet weak var _year: NSPopUpButton!
    @IBOutlet weak var _month: NSPopUpButton!
    @IBOutlet weak var _day: NSPopUpButton!

    private let _dateformatter = DateFormatter()
    private let _dateformatterja = DateFormatter()

    private static var _warekiDictionary: [String:String]!
    private static let _group = DispatchGroup() // 辞書作成が重いため


    @IBAction func onSelected(_ sender: NSPopUpButton) {
        
        let num = sender.selectedItem?.representedObject! as! Int
        
        switch sender.tag {
        case 0:
            year = num
            initMonth()
            break
        case 1:
            month = num
            initDay()
            break
        case 2:
            day = num
            break
        default:
            break
        }
    }

    private func initDay() {
        
        _day.removeAllItems()
        let today = Date()
        let now =  _dateformatter.calendar.dateComponents([.year, .month, .day], from: today)
        let range  = _dateformatter.calendar.range(of: .day, in: .month, for: today)
        var d = (range?.count)! // the lastday of this month
        if(now.year == self.year && now.month == self.month) {
            d = now.day!
        }
        while(d > 0) {
            let item = NSMenuItem()
            item.title = " \(d) 日"
            item.representedObject = d
            _day.menu?.addItem(item)
            if( day == d) {
                _day.select(item)
            }
            
            d -= 1
        }
    }
    
    private func initMonth() {
        
        _month.removeAllItems()
        let now =  _dateformatter.calendar.dateComponents([.year, .month], from: Date())
        var m = 12
        if(now.year == year) {
            m = now.month!
        }
        while(m > 0) {
            let item = NSMenuItem()
            item.title = " \(m) 月"
            item.representedObject = m
            _month.menu?.addItem(item)
            if( month == m) {
                _month.select(item)
            }
            
            m -= 1
        }
        
        initDay()
    }
    
    private func initYears() {
        
        _year.removeAllItems()

        DispatchQueue.global(qos: .default).async {
            // soted keys
            let keys = POCalendarView._warekiDictionary.keys.sorted { (a, b) -> Bool in
                a > b
            }
            
            for k in keys {
                let str = " \(k) 年（\(POCalendarView._warekiDictionary["\(k)"]!)）"
                let item = NSMenuItem()
                item.title = str
                item.representedObject = Int(k)
                self._year.menu?.addItem(item)
                if(String(self.year) == k) {
                    self._year.select(item)
                }
            }
            
            self.initMonth()
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
        
        if(POCalendarView._warekiDictionary != nil) { return }

        DispatchQueue.global(qos: .default).async(group: POCalendarView._group) {

            POCalendarView._warekiDictionary = [String:String]()
            
            let now = Date()
            let componentsNow = self._dateformatter.calendar.dateComponents([.year, .month], from: now)
            self._dateformatterja.dateFormat = "Gy年"
            
            let currentYear = componentsNow.year!
            var arr = [[String]]()
            
            for i in 0..<self.duration {
                let y = currentYear - i
                
                var prevWareki = ""
                var tempArr = [String]()
                for m in 1...12 {
                    for d in 1...31 {
                        if let date = self._dateformatter.date(from: "\(y)/\(m)/\(d)") {
                            let wareki = self._dateformatterja.string(from:date)
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
                POCalendarView._warekiDictionary["\(y)"] = yearStr
                y -= 1
            }
        }
    }
    
    private func initDatePickers() {
        
        // init dateformatters
        _dateformatter.dateFormat = "YYYY/MM/dd"
        _dateformatterja.dateStyle = .long
        _dateformatterja.calendar = Calendar(identifier: Calendar.Identifier.japanese)
        
        // 年号辞書作成
        self.initWarekiDictionary()
        
        // 今日が初期値
        let now = _dateformatter.calendar.dateComponents([.year, .month, .day], from: Date())
        year = now.year!
        month = now.month!
        day = now.day!
        
        // 年月一覧更新
        
        POCalendarView._group.notify(queue: DispatchQueue.global(qos: .default)) {
            self.initYears() //　すべて連続で初期化される
            
            // 初期時にだけ、現在の日付を適用
            self._year.selectItem(at: 0)
            self._month.selectItem(at: 0)
            self._day.selectItem(at: 0)
        }
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
