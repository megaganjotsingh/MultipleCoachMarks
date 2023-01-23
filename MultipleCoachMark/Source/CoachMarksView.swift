
import Foundation
import UIKit

// MARK: - CoachMarksView Delegate
protocol CoachMarksViewDelegate: AnyObject {
    func coachMarksView(_ coachMarksView: CoachMarksView, willNavigateTo index: Int)
    func coachMarksView(_ coachMarksView: CoachMarksView, didNavigateTo index: Int)
    func coachMarksViewWillCleanup(_ coachMarksView: CoachMarksView)
    func coachMarksViewDidCleanup(_ coachMarksView: CoachMarksView)
    func didTap(at index: Int)
}

/// Handles cycling through and displaying CoachMarks
public class CoachMarksView: UIView {
    
//    public typealias CoachMark = [CoachMark]
    
    // MARK:- Properties
    
    var focusView: FocusView?
    var bubbles: [[BubbleView]]?
    var activeBubbles: [BubbleView]? = []
//    var activeBlurrLayers: [CAShapeLayer] = []
    
    /// A layer that overlays the entire app screen to allow for accenting the focusView
    var overlay: CAShapeLayer
    var overlayColor: UIColor = UIColor.white
    
    weak var delegate: CoachMarksViewDelegate?
    
    var coachMarksGroups: [[CoachMark]]
    var markIndex: Int = 0
    
    var animationDuration: CGFloat = 0.3
//    var cutoutRadius: CGFloat = 8.0
    var maxLblWidth: CGFloat = 230
    var lblSpacing: CGFloat = 35
    var useBubbles: Bool = true
    
    // MARK:- Init
    
    public init(frame: CGRect, coachMarksGroups: [[CoachMark]]) {
        
        self.coachMarksGroups = coachMarksGroups
        self.overlay = CAShapeLayer()
        
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configures overlay and touch gesture recognizers
    func setup() {
        // Overlay config
        overlay.fillRule = CAShapeLayerFillRule.evenOdd
        overlay.fillColor = UIColor(white: 0.0, alpha: 0.8).cgColor
        layer.addSublayer(overlay)
        
        // Gesture recognizer config
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userDidTap(_:)))
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(userDidTap(_:)))
        swipeGestureRecognizer.direction = [.left, .right]
        addGestureRecognizer(swipeGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)

        // Hide until invoked
        isHidden = true
    }
    
    /// Starts CoachMark process with first CoachMark
    public func start() {
        
        guard coachMarksGroups.count > 0 else {
            return
        }
        
        // Fade in self
        alpha = 0.0
        isHidden = false
        UIView.animate(withDuration: Double(self.animationDuration), animations: {
            self.alpha = 1.0
        }, completion: { finished in
            self.goToCoachmarkGroup(index: 0)
        })
    }
    
    // MARK:- Cutout Modification
    func getCutout(to rect: CGRect, with shape: CoachMark.Shape) -> UIBezierPath {
        // Define shape
        let cutoutPath: UIBezierPath
        
        switch shape {
        case .round:
            cutoutPath = UIBezierPath(ovalIn: rect)
        case .square:
            cutoutPath = UIBezierPath(rect: rect)
        case let .roundedRect(cornerRadius):
            cutoutPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        }
        cutoutPath.usesEvenOddFillRule = true
//        let blurrLayer = CAShapeLayer()
//        blurrLayer.path = cutoutPath.cgPath
//        blurrLayer.fillColor = UIColor.clear.cgColor
//        blurrLayer.fillRule = .evenOdd
//
//        blurrLayer.masksToBounds = false
//        blurrLayer.shadowColor = UIColor.white.cgColor
//        blurrLayer.shadowOpacity = 0.5
//        blurrLayer.shadowOffset = CGSize(width: 1, height: 1)
//        blurrLayer.shadowRadius = 4
//
//        blurrLayer.shadowPath = cutoutPath.cgPath
//        blurrLayer.shouldRasterize = true
//        blurrLayer.rasterizationScale =  1
//
//        layer.insertSublayer(blurrLayer, at: 0)
//        activeBlurrLayers.append(blurrLayer)
        return cutoutPath
    }
 
    
    
    // MARK:- Animation
    
//    func animateCutout(to rect: CGRect, with shape: CoachMark.Shape) {
//        // Define shape
//        let maskPath = UIBezierPath(rect: bounds)
//        let cutoutPath: UIBezierPath
//
//        switch shape {
//        case .round:
//            cutoutPath = UIBezierPath(ovalIn: rect)
//        case .square:
//            cutoutPath = UIBezierPath(rect: rect)
//        case let .roundedRect(cornerRadius):
//            cutoutPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
//        }
//
//        maskPath.append(cutoutPath)
//
//        // Animate it
//        let anim = CABasicAnimation(keyPath: "path")
//        anim.delegate = self
//        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        anim.duration = CFTimeInterval(animationDuration)
//        anim.isRemovedOnCompletion = false
//        anim.fillMode = CAMediaTimingFillMode.both
//        anim.fromValue = overlay.path
//        anim.toValue = maskPath.cgPath
//        overlay.add(anim, forKey: "path")
//        overlay.path = maskPath.cgPath
//    }
    
    func goToCoachmarkGroup(index: Int) {
        // Out of bounds
        guard index < coachMarksGroups.count else {
            cleanup()
            return
        }
        
        // Current index
        markIndex = index
        
        // Delegate
        delegate?.coachMarksView(self, willNavigateTo: markIndex)
        
        // Coach mark definition
        let coachMarkGroup = coachMarksGroups[index]
        setCutoutsForGroup(coachMarkGroup)
    }
    
    func setCutoutsForGroup(_ group: [CoachMark]) {
        if useBubbles {
            animateNextBubbles(with: group)
        }
        let maskPath = UIBezierPath(rect: bounds)

        group.forEach { coachMark in
            let markRect = coachMark.rect
            let shape = coachMark.shape
            let cutout = getCutout(to: markRect, with: shape)
            maskPath.append(cutout)
        }
        
        // Set the new path
        overlay.path = maskPath.cgPath
    }
        
    func animateNextBubbles(with coachMarkGroup: [CoachMark]) {
        // Remove previous bubble
        if !(activeBubbles?.isEmpty ?? false) {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
                self.activeBubbles?.forEach({ $0.alpha = 0 })
            }, completion: nil)
        }
//        if !(activeBlurrLayers.isEmpty) {
//            UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
//                self.activeBlurrLayers.forEach({ $0.removeFromSuperlayer() })
//            }, completion: nil)
//        }
        activeBubbles = []
//        activeBlurrLayers = []

        coachMarkGroup.forEach { coachMark in
            let bubble = setBubbles(for: coachMark)
            guard let bubble = bubble else {
                return
            }
            activeBubbles?.append(bubble)
        }
    }
    
    func setBubbles(for coachMark: CoachMark) -> BubbleView? {
        var bubble: BubbleView?
        // Get current coach mark info
        let markCaption = coachMark.caption
        let frame = coachMark.rect
        let poi = coachMark.poi
        let font = coachMark.font
        
        // Return if no text for bubble
        if (markCaption.isEmpty) {
            return nil
        }
        
        // Create Bubble
        // Use POI if available, else use the cutout frame
        bubble = BubbleView(frame: poi ?? frame, text: markCaption, color: nil,font: font)
        bubble!.font = font
        bubble!.alpha = 0.0
        addSubview(bubble!)
        
        // Fade in & bounce animation
        UIView.animate(withDuration: 0.8, delay: 0.3, options: [], animations: {
            bubble!.alpha = 1.0
            bubble!.animate()
        }, completion: nil)
        return bubble
    }
    
    // MARK:- Gestures
    
    @objc  func userDidTap(_ recognizer: UIGestureRecognizer) {
        delegate?.didTap(at: markIndex)
        
        // Go to the next coach mark
        goToCoachmarkGroup(index: markIndex+1)
    }
    
    func cleanup() {
        delegate?.coachMarksViewWillCleanup(self)
        
        weak var weakSelf = self
        
        // Animate & remove from super
        UIView.animate(withDuration: 0.6, delay: 0.3, options: [], animations: {
            self.alpha = 0.0
            self.focusView?.alpha = 0.0
            self.activeBubbles?.forEach({ $0.alpha = 0 })
        }, completion: { (finished) in
            weakSelf?.focusView?.animationShouldStop = true
            self.activeBubbles?.forEach({ $0.animationShouldStop = true })
            weakSelf?.focusView?.removeFromSuperview()
            weakSelf?.activeBubbles?.forEach({ $0.removeFromSuperview() })
//            weakSelf?.activeBlurrLayers.forEach({ $0.removeFromSuperlayer() })
            weakSelf?.removeFromSuperview()
            weakSelf?.delegate?.coachMarksViewDidCleanup(weakSelf!)
        })
        
    }

}

// MARK:- CAAnimation Delegate

extension CoachMarksView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        delegate?.coachMarksView(self, didNavigateTo: markIndex)
    }
}

extension UIView {
    var extendedFrame: CGRect {
        var exFrame = frame
        exFrame.origin.x -= 8
        exFrame.origin.y -= 8
        exFrame.size.width += 16
        exFrame.size.height += 16
        return exFrame
    }
    
    // there can be other views between `subview` and `self`
    func getConvertedFrame(fromSubview subview: UIView) -> CGRect {
        // check if `subview` is a subview of self
        guard subview.isDescendant(of: self) else {
            return .zero
        }
        
        var frame = subview.extendedFrame
        if subview.superview == nil {
            return frame
        }
        
        var superview = subview.superview
        while superview != self {
            frame = superview!.convert(frame, to: superview!.superview)
            if superview!.superview == nil {
                break
            } else {
                superview = superview!.superview
            }
        }
        
        return superview!.convert(frame, to: self)
    }
}
