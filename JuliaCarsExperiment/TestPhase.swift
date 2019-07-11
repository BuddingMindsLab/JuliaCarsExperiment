//
//  TestPhase.swift
//  JuliaCarsExperiment
//
//  Created by Budding Minds Admin on 2019-02-03.
//  Copyright © 2019 Budding Minds Admin. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI

class TestPhase: UIViewController, MFMailComposeViewControllerDelegate {

    var subjID = ""
    var selfPaced = true
    var parsed_data = [[String]]()
    var player = AVAudioPlayer()
    var test_start = 53
    var curr = 0
    var start_time = 0.0
    var studyLengths = [Double]()
    var testLengths = [Double]()
    var testTaps = [String]()
    var timeLimit = 0.0
    var timer = Timer()
    var group_name = ""
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let margin = UIScreen.main.bounds.width/20  // 5% of total width
    var arrow_view: UIImageView!
    var border_img: UIImageView!
    var final_data = ""
    @IBOutlet weak var okBtn: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        curr = test_start
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        setupArrow()
        perform(#selector(showWhite), with: nil, afterDelay: 0.5)
        perform(#selector(showPair), with: nil, afterDelay: 0.7)
    }
    
    @objc func showWhite() {
        let frame_path = Bundle.main.path(forResource: "border", ofType: "png")!
        let frame_img = UIImage(contentsOfFile: frame_path)
        border_img = UIImageView(image: frame_img!)
        border_img.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        border_img.accessibilityIdentifier = "frame"
        view.addSubview(border_img)
    }
    
    func setupArrow() {
        let arrow_path = Bundle.main.path(forResource: "arrow", ofType: "png")!
        let arrow_img = UIImage(contentsOfFile: arrow_path)
        arrow_view = UIImageView(image: arrow_img!)
    }
    
    @objc func showPair() {
        // essentially the row numbers for <parsed_data>
        view.isUserInteractionEnabled = false
        for v in view.subviews {
            if v.accessibilityIdentifier == nil {
                v.removeFromSuperview()
            }
        }
        perform(#selector(showCars), with: nil, afterDelay: 0.5)
        view.isUserInteractionEnabled = true
        perform(#selector(showButton), with: nil, afterDelay: 0.6)
        // no crowns will show for testing phase
        
//        if selfPaced == false && curr <= 42 {
//            startTimer()
//        }
        
        //playClickSound()
        
    }
    
    @objc func showButton() {
        okBtn.isUserInteractionEnabled = true
        okBtn.isHidden = false
    }
    
    @objc func showCars() {
        let left_str = parsed_data[curr][8]
        let right_str = parsed_data[curr][9]
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
        // wait 500 ms before car appears
        //usleep(500000)
        view.addSubview(left_car)
        view.addSubview(right_car)
        // record start time
        start_time = Double(DispatchTime.now().uptimeNanoseconds)
        curr += 1
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
    
    func playClickSound() {
        do {
            let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "click", ofType: "mp3")!)
            player = try AVAudioPlayer(contentsOf: sound)
            player.play()
        } catch {
            print("sound not playing")
        }
    }
    
    // a new Timer object is created for every pair
//    func startTimer() {
//        timer = Timer.scheduledTimer(timeInterval: timeLimit, target: self, selector: (#selector(TestPhase.showPair)), userInfo: nil, repeats: false)
//    }
    
    @objc func handleTap(_ sender:UITapGestureRecognizer) {
        playClickSound()
        let tap_loc = sender.location(in: view)
        if tap_loc.x < UIScreen.main.bounds.width/2 {
            arrow_view.frame = CGRect(x: 0.108*screenWidth, y: 0.05*screenHeight, width: 0.39*screenWidth, height: 0.39*screenHeight)
            view.addSubview(arrow_view)
            testTaps.append("1")
        } else {
            arrow_view.frame = CGRect(x: 0.57*screenWidth, y: 0.05*screenHeight, width: 0.39*screenWidth, height: 0.39*screenHeight)
            view.addSubview(arrow_view)
            testTaps.append("2")
        }
    }
    
    @IBAction func okBtnPressed(_ sender: Any) {
        okBtn.isUserInteractionEnabled = false
        okBtn.isHidden = true
        let num_tests : Int = 89
        if self.curr <= num_tests  {
            timer.invalidate()
            let end = Double(DispatchTime.now().uptimeNanoseconds)
            let diff = (end - start_time) / 1_000_000_000    //seconds elapsed
            testLengths.append(diff)
            
            if self.curr <= num_tests - 1 {
                perform(#selector(showPair), with: nil, afterDelay: 1.5)
            }
        }
        if self.curr == num_tests {
            final_data = format_final_data()
            saveData(data: final_data, fileName: subjID)
            showStop()
            // email results
            perform(#selector(sendEmail), with: nil, afterDelay: 3)
        }
    }
    
    @objc func showStop() {
        for v in view.subviews {
            v.removeFromSuperview()
        }
        view.isUserInteractionEnabled = false
        // add red light image
        let stop_path = Bundle.main.path(forResource: "stoppage", ofType: "png")!
        let stop_img = UIImage(contentsOfFile: stop_path)
        let stop_view = UIImageView(image: stop_img!)
        stop_view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        view.addSubview(stop_view)
    }
    
    func format_final_data() -> String {
        var data =  "phase,videoorimage,repnr,pairtype,distance,leftcolour,rightcolour,winnerlr,leftim,rightim,response,Reaction Time (ms)\n"

        // practice phase 1
        for row in 1...2 {
//            data += subjID + ","
            let row_length = parsed_data[row].count
            for i in 0..<row_length {
                data += parsed_data[row][i] + ","
            }
            
            // Need to add nan as first row is a video file, so rightim is nan
            if row == 1 {
                data += "nan,"
            }
            data += "nan,nan\n"
        }
        
        // study phase
        for study in 0..<studyLengths.count {
//            data += subjID + ","
            let row_length = parsed_data[study+3].count
            for col in 0..<row_length {
                data += parsed_data[study+3][col] + ","
            }
            data += "nan,"
            data += String(studyLengths[study]) + "\n"
        }
        
        // practice phase 2
        for row in 51...52 {
//            data += subjID + ","
            let row_length = parsed_data[row].count
            for i in 0..<row_length {
                data += parsed_data[row][i] + ","
            }
            // Need to add nan as first row is a video file, so rightim is nan
            if row == 51 {
                data += "nan,"
            }
            data += "nan,nan\n"
        }

        // test phase
        let upperbound = min(testTaps.count, testLengths.count)
        for test in 0..<upperbound {
//            data += subjID + ","
            let row_length = parsed_data[test+test_start].count
            for col in 0..<row_length {
                data += parsed_data[test+test_start][col] + ","
            }
            data += testTaps[test] + ","
            data += String(testLengths[test]) + "\n"
        }
        return data
    }
    
    func saveData(data: String, fileName: String) {
        let this_file = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do{
            try data.write(to: this_file, atomically: true, encoding: String.Encoding.utf8)
            print("file written")
        } catch {
            print("Failed to write")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc func sendEmail() {
//        var studylens = ""
//        var testlens = ""
//        for sl in studyLengths {
//            studylens += String(sl) + ","
//        }
//        let upperbound = min(testTaps.count, testLengths.count)
//        for i in 0..<upperbound {
//            testlens += testTaps[i] + "," + String(testLengths[i]) + ","
//        }
            
        // create excel file
        let fileName = subjID + ".csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        do {
            try final_data.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
                mail.setToRecipients([""])
                mail.setSubject("Data for subject " + subjID)
                mail.setMessageBody("Hi,\n\nPlease find attached the .csv file\n\nBudding Minds Lab", isHTML: false)
                try mail.addAttachmentData(NSData(contentsOf: path!) as Data, mimeType: "text/csv", fileName: subjID + ".csv")
                present(mail, animated: true)
            } else {
                print("Email failed")
            }
        } catch {
            print("Attachment failed")
        }
        
        
        
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}
