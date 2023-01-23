//
//  ViewController.swift
//  MultipleCoachMark
//
//  Created by Admin on 18/01/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
//    @IBOutlet weak var lbl5: UILabel!
    
    @IBOutlet weak var btn: UIButton!


    override func viewDidAppear(_ animated: Bool) {
        
        // Do any additional setup after loading the view.
        let coachMarks: [[CoachMark]] = [
            [
                CoachMark(
                    rect: lbl.extendedFrame,
                    caption: "Tap task for  task details & messages",
                    shape: .roundedRect(cornerRadius: 10)
                ),
                CoachMark(
                    rect: view.getConvertedFrame(fromSubview: lbl1),
                    caption: "Tap name for patient notes & all task details",
                    shape: .square
                ),
            ],
            [
                CoachMark(
                    rect: lbl2.extendedFrame,
                    caption: "Swipe for more options",
                    shape: .round
                ),
                CoachMark(
                    rect: lbl4.extendedFrame,
                    caption: "All your patients & task history",
                    shape: .round
                )
            ],
            [
                CoachMark(
                    rect: lbl3.extendedFrame,
                    caption: "All your patients & task history",
                    shape: .square
                )
            ]
        
        ]
        
        let coachMarksView = CoachMarksView(frame: self.view.bounds, coachMarksGroups: coachMarks)
        coachMarksView.delegate = self
        self.view.addSubview(coachMarksView)
        coachMarksView.start()
    }
}

extension ViewController: CoachMarksViewDelegate {
    func coachMarksView(_ coachMarksView: CoachMarksView, willNavigateTo index: Int) {
    }
    
    func coachMarksView(_ coachMarksView: CoachMarksView, didNavigateTo index: Int) {
    }
    
    func coachMarksViewWillCleanup(_ coachMarksView: CoachMarksView) {
    }
    
    func didTap(at index: Int) {
        print(index)
    }
    
    func coachMarksViewDidCleanup(_ coachMarksView: CoachMarksView) {
        print("coach marks completed")
    }
}
