//
//  ResultViewController.swift
//  speechAssistant_Example
//
//  Created by Vishal on 01/08/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
	
	var resultString = ""
	
	@IBOutlet weak var textLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
			textLabel.text = resultString
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
