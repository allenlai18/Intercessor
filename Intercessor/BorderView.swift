import UIKit

class BorderView: UIView {
    struct BorderAttributes {
        var draw = false
        var width: CGFloat = 0.0
        var color = UIColor.clear
    }
    
    var topBorderAttributes = BorderAttributes()
    var rightBorderAttributes = BorderAttributes()
    var bottomBorderAttributes = BorderAttributes()
    var leftBorderAttributes = BorderAttributes()
    
    override func draw(_ rect: CGRect) {
        if topBorderAttributes.draw {
            setBorderTop(topBorderAttributes.width, borderColor: topBorderAttributes.color)
        }
        if rightBorderAttributes.draw {
            setBorderRight(rightBorderAttributes.width, borderColor: rightBorderAttributes.color)
        }
        if bottomBorderAttributes.draw {
            setBorderBottom(bottomBorderAttributes.width, borderColor: bottomBorderAttributes.color)
        }
        if leftBorderAttributes.draw {
            setBorderLeft(leftBorderAttributes.width, borderColor: leftBorderAttributes.color)
        }
        
        super.draw(rect)
    }
    
    func setBorder(_ borderWidth: CGFloat, borderColor: UIColor?, borderRadius: CGFloat?) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
        if let _ = borderRadius {
            self.layer.cornerRadius = borderRadius!
        }
        self.layer.masksToBounds = true
    }
    
    func setBorderTop(_ borderWidth: CGFloat, borderColor: UIColor?) {
        let line = setLine(borderColor)
        line.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: borderWidth)
        self.layer.addSublayer(line)
    }
    
    func setBorderRight(_ borderWidth: CGFloat, borderColor: UIColor?) {
        let line = setLine(borderColor)
        line.frame = CGRect(x: 0.0, y: 0.0, width: borderWidth, height: self.frame.height)
        self.layer.addSublayer(line)
    }
    
    func setBorderBottom(_ borderWidth: CGFloat, borderColor: UIColor?) {
        let line = setLine(borderColor)
        line.frame = CGRect(x: 0.0, y: self.frame.height - borderWidth, width: self.frame.width, height: borderWidth)
        self.layer.addSublayer(line)
    }
    
    func setBorderLeft(_ borderWidth: CGFloat, borderColor: UIColor?) {
        let line = setLine(borderColor)
        line.frame = CGRect(x: 0.0, y: 0.0, width: borderWidth, height: self.frame.height)
        self.layer.addSublayer(line)
    }
    
    // MARK : private func
    
    fileprivate func setLine(_ borderColor: UIColor?) -> CALayer {
        let line = CALayer()
        self.layer.masksToBounds = true
        if let _ = borderColor {
            line.backgroundColor = borderColor!.cgColor
        } else {
            line.backgroundColor = UIColor.white.cgColor
        }
        return line
    }
    
    // MARK : @IBInspectable
    @IBInspectable
    var topBorderDraw: Bool {
        get {
            return topBorderAttributes.draw
        }
        set {
            topBorderAttributes.draw = newValue
        }
    }
    
    @IBInspectable
    var topBorderWidth: CGFloat {
        get {
            return topBorderAttributes.width
        }
        set {
            topBorderAttributes.width = newValue
        }
    }
    
    @IBInspectable
    var topBorderColor: UIColor {
        get {
            return topBorderAttributes.color
        }
        set {
            topBorderAttributes.color = newValue
        }
    }
    
    @IBInspectable
    var rightBorderDraw: Bool {
        get {
            return rightBorderAttributes.draw
        }
        set {
            rightBorderAttributes.draw = newValue
        }
    }
    
    @IBInspectable
    var rightBorderWidth: CGFloat {
        get {
            return rightBorderAttributes.width
        }
        set {
            rightBorderAttributes.width = newValue
        }
    }
    
    @IBInspectable
    var rightBorderColor: UIColor {
        get {
            return rightBorderAttributes.color
        }
        set {
            rightBorderAttributes.color = newValue
        }
    }
    
    @IBInspectable
    var bottomBorderDraw: Bool {
        get {
            return bottomBorderAttributes.draw
        }
        set {
            bottomBorderAttributes.draw = newValue
        }
    }
    
    @IBInspectable
    var bottomBorderWidth: CGFloat {
        get {
            return bottomBorderAttributes.width
        }
        set {
            bottomBorderAttributes.width = newValue
        }
    }
    
    @IBInspectable
    var bottomBorderColor: UIColor {
        get {
            return bottomBorderAttributes.color
        }
        set {
            bottomBorderAttributes.color = newValue
        }
    }
    
    @IBInspectable
    var leftBorderDraw: Bool {
        get {
            return leftBorderAttributes.draw
        }
        set {
            leftBorderAttributes.draw = newValue
        }
    }
    
    @IBInspectable
    var leftBorderWidth: CGFloat {
        get {
            return leftBorderAttributes.width
        }
        set {
            leftBorderAttributes.width = newValue
        }
    }
    
    @IBInspectable
    var leftBorderColor: UIColor {
        get {
            return leftBorderAttributes.color
        }
        set {
            leftBorderAttributes.color = newValue
        }
    }
    
    // MARK : @IBInspectable
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let _ = self.layer.borderColor {
                return UIColor(cgColor: self.layer.borderColor!)
            }
            return nil
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
//    @IBInspectable
//    var cornerRadius: CGFloat {
//        get {
//            return self.layer.cornerRadius
//        }
//        set {
//            self.layer.cornerRadius = newValue
//        }
//    }
    
}
