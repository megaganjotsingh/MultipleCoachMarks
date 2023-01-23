# MultipleCoachMarks

Easy to Use
  ---
  
  ### Define all coach marks 

  ```swift
         let coachMarks: [[CoachMark]] = [
            [
                CoachMark(
                    rect: Your view's frame,
                    caption: "Tap task for  task details & messages",
                    shape: .roundedRect(cornerRadius: 10)
                ),
                CoachMark(
                    rect: Your view's frame,
                    caption: "Tap name for patient notes & all task details",
                    shape: .square
                ),
            ],
            [
                CoachMark(
                    rect: Your view's frame,
                    caption: "Swipe for more options",
                    shape: .round
                ),
                CoachMark(
                    rect: Your view's frame,
                    caption: "All your patients & task history",
                    shape: .round
                )
            ],
            [
                CoachMark(
                    rect: Your view's frame,
                    caption: "All your patients & task history",
                    shape: .square
                )
            ]
        
        ]
  ```

### You can simply add above coach marks to view
  
  ```swift
        let coachMarksView = CoachMarksView(frame: view.bounds, coachMarks: coachMarks)
        view.addSubview(coachMarksView)
  ```
  
### Now run the coach marks by calling start() function
  
  ```swift
        coachMarksView.start()
  ```
  
  Collaboration
---

I tried to build an easy to use API, but I'm sure there are ways of improving and adding more features, If you think that we can do the MultipleCoachMarks more powerful please contribute with this project.
