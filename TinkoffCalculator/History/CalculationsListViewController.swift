//
//  CalculationsListViewController.swift
//  TinkoffCalculator
//
//  Created by Yoji on 25.01.2024.
//

import UIKit

final class CalculationsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var calculations: [(expression: [CalculationHistoryItem], result: Double)] = []
    private lazy var headerLabel: UILabel = {
        let lbl = UILabel()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let date = formatter.string(from: Date())
        lbl.text = date
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private lazy var tableHeaderView: UIView = {
        let headertView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        headertView.addSubview(self.headerLabel)
        
        NSLayoutConstraint.activate([
            self.headerLabel.topAnchor.constraint(equalTo: headertView.topAnchor),
            self.headerLabel.bottomAnchor.constraint(equalTo: headertView.bottomAnchor),
            self.headerLabel.leadingAnchor.constraint(equalTo: headertView.leadingAnchor, constant: 16),
            self.headerLabel.trailingAnchor.constraint(equalTo: headertView.trailingAnchor)
        ])
                
        return headertView
    }()
    private lazy var tableFooterView: UIView = {
        let headertView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
        return headertView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.backgroundColor = .systemGray5
        self.tableView.tableFooterView = self.tableFooterView
        
        let nib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HistoryTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension CalculationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.tableHeaderView
    }
}

extension CalculationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.calculations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else {
            let cell = UITableViewCell()
            return cell
        }
        let historyItem = calculations[indexPath.row]
        cell.configure(with: historyItem.expression.toString(), result: String(historyItem.result))
        
        return cell
    }
}

extension Array<CalculationHistoryItem> {
    func toString() -> String {
        var result = ""
        
        self.forEach { operand in
            switch operand {
            case let .number(value):
                result += String(value) + " "
            case let .operation(value):
                result += value.rawValue + " "
            }
        }
        
        return result
    }
}
