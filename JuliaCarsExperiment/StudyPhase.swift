//
//  StudyPhase.swift
//  JuliaCarsExperiment
//
//  Created by Budding Minds Admin on 2019-02-03.
//  Copyright © 2019 Budding Minds Admin. All rights reserved.
//

import UIKit
import AVFoundation

class StudyPhase: UIViewController {

    var subjID = ""
    var selfPaced = true
    var parsed_data = [[String]]()
    var player = AVAudioPlayer()
    var curr = 3
    var start_time = 0.0
    var exposureLengths = [Double]()
    var group_name = ""
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let margin = UIScreen.main.bounds.width/20  // 5% of total width
    var border_img: UIImageView!
    var readyForDemo = false
    @IBOutlet weak var nextBtn: UIButton!
    var buttonDelayAfterCrown = 0.5
    
    // Fixed timing settings
    var beforeCarsCrown_afterCars = 0.5
    var beforeWhite_afterCarsCrown = 4.0
    var beforeNextTrial_afterWhite = 0.5
    var maxStimuli = 51
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
//        leftSwipe.direction = .left
//        view.addGestureRecognizer(leftSwipe)
        for v in view.subviews {
            v.removeFromSuperview()
        }
        perform(#selector(showWhite), with: nil, afterDelay: 0.5)
        perform(#selector(performStudy), with: nil, afterDelay: 0.7)
        //perform(#selector(showPair), with: nil, afterDelay: 0.7)
    }
    
    @objc func clearScreen() {
        for v in view.subviews {
            if v.accessibilityIdentifier == nil {
                v.removeFromSuperview()
            }
        }
    }
    
    @objc func performStudy() {
        if curr < maxStimuli {
            let timingType = Int(self.parsed_data[curr][0])!
            if timingType == 1 {   // Fixed timing
                exposureLengths.append(beforeWhite_afterCarsCrown)
                view.isUserInteractionEnabled = false
                clearScreen()
                perform(#selector(showCars), with: nil, afterDelay: beforeNextTrial_afterWhite)
                perform(#selector(showCrown), with: nil, afterDelay: beforeCarsCrown_afterCars + beforeNextTrial_afterWhite)
                perform(#selector(clearScreen), with: nil, afterDelay: beforeWhite_afterCarsCrown + beforeCarsCrown_afterCars + beforeNextTrial_afterWhite)
                perform(#selector(performStudy), with: nil, afterDelay: beforeWhite_afterCarsCrown + beforeCarsCrown_afterCars + beforeNextTrial_afterWhite)
            } else if timingType == 2 {    // Participant can press Next to continue
                perform(#selector(clearScreen), with: nil, afterDelay: 0)
                perform(#selector(showCars), with: nil, afterDelay: 0.5)
                perform(#selector(showCrown), with: nil, afterDelay: 1.0)
                showButton()
            }
        } else {
            curr += 1
            perform(#selector(showStop), with: nil, afterDelay: 0)
            perform(#selector(showGo), with: nil, afterDelay: 2)
            if readyForDemo == true {
                performSegue(withIdentifier: "second_demo", sender: StudyPhase.self)
            }
        }
    }
    
    @objc func showWhite() {
        let frame_path = Bundle.main.path(forResource: "border", ofType: "png")!
        let frame_img = UIImage(contentsOfFile: frame_path)
        border_img = UIImageView(image: frame_img!)
        border_img.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        border_img.accessibilityIdentifier = "frame"
        view.addSubview(border_img)
    }
    
    @objc func showPair() {
        // essentially the row numbers for <parsed_data>
        view.isUserInteractionEnabled = false
        clearScreen()
        // page flip onto a white page with race track border
        perform(#selector(flip), with: nil, afterDelay: 0)
        perform(#selector(showCars), with: nil, afterDelay: 1)
        perform(#selector(showCrown), with: nil, afterDelay: 1.5)
        
        view.isUserInteractionEnabled = true
    }
    
    @objc func showCars() {
        let left_str = self.parsed_data[curr][8]
        let right_str = self.parsed_data[curr][9]
        let left = left_str.components(separatedBy: ".")
        let right = right_str.components(separatedBy: ".")
        let left_path = Bundle.main.path(forResource: left[0], ofType: left[1])!
        let right_path = Bundle.main.path(forResource: right[0], ofType: right[1])!
        let left_img = UIImage(contentsOfFile: left_path)
        let right_img = UIImage(contentsOfFile: right_path)
        let left_car = UIImageView(image: left_img!)
        let right_car = UIImageView(image: right_img!)
        left_car.frame = CGRect(x: 0.035*screenWidth, y: 0.4*screenHeight, width: 0.47*screenWidth, height: 0.39*screenHeight)
        right_car.frame = CGRect(x: 0.501*screenWidth, y: 0.4*screenHeight, width: 0.47*screenWidth, height: 0.39*screenHeight)
        view.addSubview(left_car)
        view.addSubview(right_car)
        curr += 1
    }
    
    @objc func showButton() {
        view.isUserInteractionEnabled = true
        nextBtn.isHidden = false
    }
    
    @objc func hideButton() {
        view.isUserInteractionEnabled = false
        nextBtn.isHidden = true
    }
    
    @objc func showCrown() {
        perform(#selector(showButton), with: nil, afterDelay: buttonDelayAfterCrown)
        let winner = Int(parsed_data[curr-1][7])
        let crown_path = Bundle.main.path(forResource: "crown", ofType: "png")!
        let crown = UIImage(contentsOfFile: crown_path)
        let crown_view = UIImageView(image: crown!)
        // left car wins
        if winner == 1 {
            crown_view.frame = CGRect(x: 0.071*screenWidth, y: 0.05*screenHeight, width: 0.39*screenWidth, height: 0.39*screenHeight)
        } else {
            crown_view.frame = CGRect(x: 0.56*screenWidth, y: 0.05*screenHeight, width: 0.39*screenWidth, height: 0.39*screenHeight)
        }
        playSound()
        view.addSubview(crown_view)
        // record start time
        start_time = Double(DispatchTime.now().uptimeNanoseconds)
    }
    
    func playSound() {
        do {
            let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "ding", ofType: "mp3")!)
            player = try AVAudioPlayer(contentsOf: sound)
            player.play()
        } catch {
            print("sound not playing")
        }
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        hideButton()
        // record stop time
        let end = Double(DispatchTime.now().uptimeNanoseconds)
        exposureLengths.append((end - start_time) / 1_000_000_000)    //seconds elapsed
        performStudy()
    }
    
    @objc func handleTaps(_ sender:UITapGestureRecognizer) {
        if readyForDemo == true {
            performSegue(withIdentifier: "second_demo", sender: StudyPhase.self)
        }
    }
    
    @objc func flip() {
        UIView.animate(withDuration: 1.0, animations: {
            let animation = CATransition()
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.type = CATransitionType(rawValue: "pageUnCurl")
            animation.subtype = CATransitionSubtype(rawValue: "fromLeft")
            self.border_img.layer.add(animation, forKey: "pageFlipAnimation")
        })
    }
    
    @objc func showStop() {
        for v in view.subviews {
            v.removeFromSuperview()
        }
        view.isUserInteractionEnabled = true
        // add red light image
        let stop_path = Bundle.main.path(forResource: "stoppage", ofType: "png")!
        let stop_img = UIImage(contentsOfFile: stop_path)
        let stop_view = UIImageView(image: stop_img!)
        stop_view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        view.addSubview(stop_view)
        readyForDemo = true
    }
    
    @objc func showGo() {
        for v in view.subviews {
            v.removeFromSuperview()
        }
        view.isUserInteractionEnabled = true
        let light_path = Bundle.main.path(forResource: "readysetgo", ofType: "png")!
        let light_img = UIImage(contentsOfFile: light_path)
        let light_view = UIImageView(image: light_img!)
        light_view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        view.addSubview(light_view)
        readyForDemo = true
        performStudy()      // last call, performs segue to second demo phase
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? DemoPhaseTwo
        vc?.subjID = self.subjID
        vc?.selfPaced = self.selfPaced
        vc?.parsed_data = self.parsed_data
        vc?.studyLengths = self.exposureLengths
        vc?.group_name = self.group_name
    }
}
