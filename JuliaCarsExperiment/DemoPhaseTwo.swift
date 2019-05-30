//
//  DemoPhaseTwo.swift
//  JuliaCarsExperiment
//
//  Created by Budding Minds Admin on 2019-02-17.
//  Copyright © 2019 Budding Minds Admin. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class DemoPhaseTwo: UIViewController {
    
    var subjID = ""
    var selfPaced = true
    var parsed_data = [[String]]()
    var studyLengths = [Double]()
    var timeLimit = 0.0
    var group_name = ""
    var arrow_view = UIImageView()
    
    // what demo step it is: 0 for tapping the winning car, 1 for moving on to TestPhase
    var step = 0
    var readyForTesting = false
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let margin = UIScreen.main.bounds.width/20  // 5% of total width
    
    var player = AVAudioPlayer()
    var moviePlayer:AVPlayer?
    var moviePlayerVC:AVPlayerViewController = AVPlayerViewController()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTaps(_:)))
        view.addGestureRecognizer(tap)
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        view.isUserInteractionEnabled = false
        let video = parsed_data[51][8]
        let video_file = video.components(separatedBy: ".")
        let video_url = URL(fileURLWithPath: Bundle.main.path(forResource: video_file[0], ofType: video_file[1])!)
        moviePlayer = AVPlayer(url: video_url)
        self.moviePlayerVC.player = moviePlayer
        
        setupArrow()
        showResults()
        view.isUserInteractionEnabled = true
    }
    
    @objc func showVideo() {
        present(self.moviePlayerVC, animated: true) {
            self.moviePlayerVC.showsPlaybackControls = false
            self.moviePlayerVC.player?.play()
        }
    }
    
    @objc func dismissVideo() {
        dismiss(animated: true) {
            self.perform(#selector(self.showCars), with: nil, afterDelay: 0.5)
            self.perform(#selector(self.showCrown), with: nil, afterDelay: 1)
        }
    }
    
    func showResults() {
        perform(#selector(showVideo), with: nil, afterDelay: 1)
        perform(#selector(dismissVideo), with: nil, afterDelay: 18)
    }
    
    @objc func showGo() {
        for v in view.subviews {
            v.removeFromSuperview()
        }
        let light_path = Bundle.main.path(forResource: "readysetgo", ofType: "png")!
        let light_img = UIImage(contentsOfFile: light_path)
        let light_view = UIImageView(image: light_img!)
        light_view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        view.addSubview(light_view)
    }
    
    @objc func showCars() {
        let left_str = self.parsed_data[52][8]
        let right_str = self.parsed_data[52][9]
        let left = left_str.components(separatedBy: ".")
        let right = right_str.components(separatedBy: ".")
        let left_path = Bundle.main.path(forResource: left[0], ofType: left[1])!
        let right_path = Bundle.main.path(forResource: right[0], ofType: right[1])!
        let left_img = UIImage(contentsOfFile: left_path)
        let right_img = UIImage(contentsOfFile: right_path)
        let left_car = UIImageView(image: left_img!)
        let right_car = UIImageView(image: right_img!)
        left_car.frame = CGRect(x: 0.032*screenWidth, y: 0.4*screenHeight, width: 0.47*screenWidth, height: 0.39*screenHeight)
        right_car.frame = CGRect(x: 0.482*screenWidth, y: 0.4*screenHeight, width: 0.47*screenWidth, height: 0.39*screenHeight)
        view.addSubview(left_car)
        view.addSubview(right_car)
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
    
    @objc func showCrown() {
        let winner = Int(parsed_data[52][7])
        print("demo2, winner line ")
        print(parsed_data[52])
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
    }
    
    func showWhite() {
        let white_path = Bundle.main.path(forResource: "white", ofType: "jpg")!
        let white_img = UIImage(contentsOfFile: white_path)
        let white_img_view = UIImageView(image: white_img!)
        white_img_view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        white_img_view.accessibilityIdentifier = "white"
        view.addSubview(white_img_view)
        
        let frame_path = Bundle.main.path(forResource: "border", ofType: "png")!
        let frame_img = UIImage(contentsOfFile: frame_path)
        let border_img = UIImageView(image: frame_img!)
        border_img.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        border_img.accessibilityIdentifier = "frame"
        view.addSubview(border_img)
    }
    
    @objc func showSelect() {
        showWhite()
        showCars()
    }
    
    func setupArrow() {
        let arrow_path = Bundle.main.path(forResource: "arrow", ofType: "png")!
        let arrow_img = UIImage(contentsOfFile: arrow_path)
        arrow_view = UIImageView(image: arrow_img!)
    }
    
    @objc func handleTaps(_ sender:UITapGestureRecognizer) {
        if readyForTesting == false {
            let tap_loc = sender.location(in: view)
            if tap_loc.x < UIScreen.main.bounds.width/2 {
                arrow_view.frame = CGRect(x: 0.108*screenWidth, y: 0.05*screenHeight, width: 0.39*screenWidth, height: 0.39*screenHeight)
                view.addSubview(arrow_view)
            } else {
                arrow_view.frame = CGRect(x: 0.57*screenWidth, y: 0.05*screenHeight, width: 0.39*screenWidth, height: 0.39*screenHeight)
                view.addSubview(arrow_view)
            }
            //step += 1
            readyForTesting = true
            self.perform(#selector(self.showGo), with: nil, afterDelay: 1)
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            self.perform(#selector(self.showSelect), with: nil, afterDelay: 0)
        }
        if readyForTesting == true {
            performSegue(withIdentifier: "test_segue", sender: DemoPhaseTwo.self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? TestPhase
        vc?.subjID = self.subjID
        vc?.selfPaced = self.selfPaced
        vc?.parsed_data = self.parsed_data
        vc?.studyLengths = self.studyLengths
        vc?.timeLimit = self.timeLimit
        vc?.group_name = self.group_name
    }

}
