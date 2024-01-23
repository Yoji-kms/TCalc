//
//  ViewController.swift
//  TCalc
//
//  Created by Yoji on 23.01.2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func btnDidTap(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        print(title)
    }
}

