//
//  ViewController.swift
//  JuliaCarsExperiment
//
//  Created by Budding Minds Admin on 2018-12-07.
//  Copyright © 2018 Budding Minds Admin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    

    @IBOutlet weak var mLabel: UILabel!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var btnDelayField: UITextField!
    @IBOutlet weak var carsField: UITextField!
    @IBOutlet weak var carsCrownField: UITextField!
    @IBOutlet weak var trialGapField: UITextField!
    @IBOutlet weak var maxStimuli: UITextField!
    
    // @IBOutlet weak var picker: UIPickerView!
    let groups = ["group10", "group1", "group2", "group3", "group4", "group5", "group6", "group7", "group8", "group9"]
    
    @IBAction func startButton(_ sender: Any) {
        if idField.text == nil || idField.text == "" {
            let alert = UIAlertController(title: "Attention", message: "Subject id cannot be empty", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            group_name = groups[Int(idField.text!)! % 10]
            let data = load_data(fileName: group_name, fileType: "csv")
            group_data = data!
            do {
                player = try AVAudioPlayer(contentsOf: sound)
                player.play()
                sleep(3)
            } catch {
                print("sound not playing")
            }
            performSegue(withIdentifier: "start_experiment", sender: ViewController.self)
        }
    }
    
    // called when toggle's value changes, default is <on>
    @IBAction func selfPaceToggle(_ sender: Any) {
        
        if self.toggle == true {
            self.toggle = false
            timeField.isEnabled = true
        } else {
            self.toggle = true
            timeField.isEnabled = false
        }
    }
    var seq = ""
    var toggle = true
    var group_data = ""
    var group_name = ""
    let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "start", ofType: "wav")!)
    var player = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        picker.dataSource = self as UIPickerViewDataSource
//        picker.delegate = self as UIPickerViewDelegate
        
//        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
//
//        leftSwipe.direction = .left
//        rightSwipe.direction = .right
//
//        view.addGestureRecognizer(leftSwipe)
//        view.addGestureRecognizer(rightSwipe)
    }

    func load_data(fileName: String, fileType: String) -> String! {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                
                return nil
        }
        do {
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)
            // contents = cleanRows(file: contents)
            return contents
        } catch {
            return nil
        }
    }
    
//    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
//        if (sender.direction == .left) {
//            let labelPosition = CGPoint(x: self.mLabel.frame.origin.x - 50.0, y: self.mLabel.frame.origin.y)
//            mLabel.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.mLabel.frame.size.width, height: self.mLabel.frame.size.height)
//        } else if (sender.direction == .right) {
//            print("Swipe Right")
//            let labelPosition = CGPoint(x: self.mLabel.frame.origin.x + 50.0, y: self.mLabel.frame.origin.y)
//            mLabel.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.mLabel.frame.size.width, height: self.mLabel.frame.size.height)
//        }
//    }
//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? DemoPhase
        vc?.subjID = idField.text!
        vc?.selfPaced = self.toggle
        vc?.data = self.group_data
        vc?.group_name = group_name
        if toggle == false {
            vc?.timeLimit = Double(timeField.text!)!
        }
        if self.btnDelayField.text != nil && self.btnDelayField.text != ""{
            vc?.buttonDelayAfterCrown = Double(self.btnDelayField.text!)!
        }
        if self.maxStimuli.text != nil && self.maxStimuli.text != "" {
            vc?.maxStimuli = Int(self.maxStimuli.text!)!
        }
    }
    
//    // picker methods
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return pickerData.count
//    }
//
//    // Delegates
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return pickerData[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        group_name = pickerData[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        let titleData = pickerData[row]
//        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
//
//        return myTitle
//    }

}

