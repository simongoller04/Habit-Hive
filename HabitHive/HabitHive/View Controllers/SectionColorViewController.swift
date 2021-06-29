//
//  SectionColorViewController.swift
//  ProjectWeidlinger
//
//  Created by Sebastian Weidlinger on 26.06.21.
//

import UIKit

protocol GetColorDelegate {
    func didTapColorPickerButton (color: UIColor)
}

class SectionColorViewController: UIViewController {
    
    var colorDelegate: GetColorDelegate?
    
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var grayButton: UIButton!
    var update: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCornerBorder()
        rotateHexagon()
        
        let current = UserDefaults().integer(forKey: "sectionColor")
        
        switch current{
        case 1:
            selectButton(button: blueButton)
        case 2:
            selectButton(button: greenButton)
        case 3:
            selectButton(button: yellowButton)
        case 4:
            selectButton(button: orangeButton)
        case 5:
            selectButton(button: purpleButton)
        default:
            selectButton(button: grayButton)
        }
        
    }
    
    @IBAction func blueButtonPressed(_ sender: Any) {
        selectButton(button: blueButton)
        UserDefaults.standard.setValue(1, forKey: "sectionColor")
    }
    
    @IBAction func greenButtonPressed(_ sender: Any) {
        selectButton(button: greenButton)
        UserDefaults.standard.setValue(2, forKey: "sectionColor")
    }
    
    @IBAction func yellowButtonPressed(_ sender: Any) {
        selectButton(button: yellowButton)
        UserDefaults.standard.setValue(3, forKey: "sectionColor")
    }
    
    @IBAction func orangeButtonPressed(_ sender: Any) {
        selectButton(button: orangeButton)
        UserDefaults.standard.setValue(4, forKey: "sectionColor")
    }
    
    @IBAction func purpleButtonPressed(_ sender: Any) {
        selectButton(button: purpleButton)
        UserDefaults.standard.setValue(5, forKey: "sectionColor")
    }
    
    @IBAction func grayButtonPressed(_ sender: Any) {
        selectButton(button: grayButton)
        UserDefaults.standard.setValue(6, forKey: "sectionColor")
    }
    
    func selectButton(button: UIButton) {
        deselectButton(button: blueButton)
        deselectButton(button: greenButton)
        deselectButton(button: yellowButton)
        deselectButton(button: orangeButton)
        deselectButton(button: purpleButton)
        deselectButton(button: grayButton)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 3
    }
    
    func deselectButton(button: UIButton) {
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0
    }
    
    func rotateHexagon() {
        blueButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        yellowButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        greenButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        orangeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        purpleButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        grayButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
    }
    
    func addCornerBorder() {
        blueButton.layer.cornerRadius = 10
        yellowButton.layer.cornerRadius = 10
        greenButton.layer.cornerRadius = 10
        orangeButton.layer.cornerRadius = 10
        purpleButton.layer.cornerRadius = 10
        grayButton.layer.cornerRadius = 10
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var color = UIColor()
        let current = UserDefaults().integer(forKey: "sectionColor")
        switch current{
        case 1:
            color = UIColor.systemBlue
        case 2:
            color = UIColor.systemGreen
        case 3:
            color = UIColor.systemYellow
        case 4:
            color = UIColor.systemOrange
        case 5:
            color = UIColor.systemPurple
        default:
            color = UIColor.systemGray
        }
        colorDelegate?.didTapColorPickerButton(color: color)
    }

}
