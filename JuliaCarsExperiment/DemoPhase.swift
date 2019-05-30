//
//  DemoPhase.swift
//  JuliaCarsExperiment
//
//  Created by Budding Minds Admin on 2019-02-03.
//  Copyright © 2019 Budding Minds Admin. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class DemoPhase: UIViewController {

    var subjID = ""
    var selfPaced = true
    var data = ""
    var parsed_data = [[String]]()
    var player = AVAudioPlayer()
    var timeLimit = 0.0
    var group_name = ""
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let margin = UIScreen.main.bounds.width/20  // 5% of total width
    
    var moviePlayer:AVPlayer?
    var moviePlayerVC:AVPlayerViewController = AVPlayerViewController()
    
    var count = 0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTaps(_:)))
//        view.addGestureRecognizer(tap)
        
        view.isUserInteractionEnabled = false
        parse_data()
        let video = parsed_data[1][8]
        let video_file = video.components(separatedBy: ".")
        let video_url = URL(fileURLWithPath: Bundle.main.path(forResource: video_file[0], ofType: video_file[1])!)
        moviePlayer = AVPlayer(url: video_url)
        self.moviePlayerVC.player = moviePlayer
        //showVideo()
        //sleep(60)
        showResults()
    }
    
    // turns the csv file into a [[String]] object
    func parse_data() {
        let lines = data.components(separatedBy: "\r")
        for line in lines {
            parsed_data.append(line.components(separatedBy: ","))
        }
    }
    
    @objc func showVideo() {
        present(self.moviePlayerVC, animated: true) {
            self.moviePlayerVC.showsPlaybackControls = false
            self.moviePlayerVC.player?.play()
        }
    }
    
    @objc func dismissVideo() {
        dismiss(animated: true) {
            self.perform(#selector(self.showCars), with: nil, afterDelay: 1)
            self.view.isUserInteractionEnabled = true
            self.perform(#selector(self.showCrown), with: nil, afterDelay: 2)
            
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
        view.isUserInteractionEnabled = true
        // add ready set go image
        let light_path = Bundle.main.path(forResource: "readysetgo", ofType: "png")!
        let light_img = UIImage(contentsOfFile: light_path)
        let light_view = UIImageView(image: light_img!)
        light_view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        view.addSubview(light_view)
    }
    
    @objc func showCars() {
        let left_str = self.parsed_data[2][8]
        let right_str = self.parsed_data[2][9]
        let left = left_str.components(separatedBy: ".")
        let right = right_str.components(separatedBy: ".")
        let left_path = Bundle.main.path(forResource: left[0], ofType: left[1])!
        let right_path = Bundle.main.path(forResource: right[0], ofType: right[1])!
        let left_img = UIImage(contentsOfFile: left_path)
        let right_img = UIImage(contentsOfFile: right_path)
        let left_car = UIImageView(image: left_img!)
        let right_car = UIImageView(image: right_img!)
        left_car.frame = CGRect(x: 0.032*screenWidth, y: 0.4*screenHeight, width: 0.47*screenWidth, height: 0.39*screenHeight)
        right_car.frame = CGRect(x: 0.485*screenWidth, y: 0.4*screenHeight, width: 0.47*screenWidth, height: 0.39*screenHeight)
        view.addSubview(left_car)
        view.addSubview(right_car)
    }
    
    @objc func showCrown() {
        let winner = Int(parsed_data[2][7])
        print("demo1, winner line ")
        print(parsed_data[2])
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
    
    func playSound() {
        do {
            let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "ding", ofType: "mp3")!)
            player = try AVAudioPlayer(contentsOf: sound)
            player.play()
        } catch {
            print("sound not playing")
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            if count == 0 {
                count += 1
                self.perform(#selector(self.showGo), with: nil, afterDelay: 0)
            }
            else {
                performSegue(withIdentifier: "study_segue", sender: DemoPhase.self)
            }
        }
    }
    
//    @objc func handleTaps(_ sender:UITapGestureRecognizer) {
//        performSegue(withIdentifier: "study_segue", sender: DemoPhase.self)
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? StudyPhase
        vc?.selfPaced = self.selfPaced
        vc?.subjID = self.subjID
        vc?.parsed_data = self.parsed_data
        vc?.timeLimit = self.timeLimit
        vc?.group_name = self.group_name
    }
}
