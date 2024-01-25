//
//  CalculationsListViewController.swift
//  TinkoffCalculator
//
//  Created by Yoji on 25.01.2024.
//

import UIKit

final class CalculationsListViewController: UIViewController {
    @IBOutlet weak var calculationLabel: UILabel!
    var result: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calculationLabel.text = self.result
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
