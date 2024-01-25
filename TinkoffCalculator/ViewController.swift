//
//  ViewController.swift
//  TCalc
//
//  Created by Yoji on 23.01.2024.
//

import UIKit

fileprivate enum CalculationError: Error {
    case divideByZero
    case outOfRange
}

final class ViewController: UIViewController {
    
    private let comma = ","
    private var isCalculationEnded = false
    private var calculationHistory: [CalculationHistoreItem] = []
    private var lastCalculation: String = "NoData"
    
    @IBOutlet private weak var label: UILabel!
    
    private lazy var numberFormatter: NumberFormatter = {
        let numFormatter = NumberFormatter()
        
        numFormatter.usesGroupingSeparator = false
        numFormatter.locale = Locale(identifier: "ru_RU")
        numFormatter.numberStyle = .decimal
        
        return numFormatter
    }()
    
    enum Operation: String {
        case add = "+"
        case subtract = "-"
        case multiply = "x"
        case divide = "/"
        
        func calculate(_ number1: Double, _ number2: Double) throws -> Double {
            try number1.checkRange()
            try number2.checkRange()
            
            switch self {
            case .add:
                return number1 + number2
            case .subtract:
                return number1 - number2
            case .multiply:
                return number1 * number2
            case .divide:
                if number2 == 0 {
                    throw CalculationError.divideByZero
                }
                return number1 / number2
            }
        }
    }
    
    enum CalculationHistoreItem {
        case number(Double)
        case operation(Operation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction private func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        
        if buttonText == self.comma && self.label.text?.contains(self.comma) == true {
            return
        }
        
        if self.label.text == "0" || self.isCalculationEnded {
            self.label.text = buttonText
            self.isCalculationEnded = false
        } else {
            self.label.text?.append(buttonText)
        }
    }
    
    @IBAction private func operationButtonPressed(_ sender: UIButton) {
        self.appendNumberFromLabelToHistory()
        self.appendOperationFromBtnToHistory(button: sender)
        
        self.resetLabelText()
    }
    
    @IBAction private func calculateButtonPressed(_ sender: UIButton) {
        self.appendNumberFromLabelToHistory()
        do {
            let result = try self.calculate()
            let resultString = self.numberFormatter.string(from: NSNumber(value: result))
            
            self.label.text = resultString
            self.lastCalculation = resultString ?? "NoData"
        } catch {
            switch error.self {
            case CalculationError.outOfRange:
                label.text = "Число за пределами вычислений"
            default:
                label.text = "Ошибка"
            }
        }
        
        self.calculationHistory.removeAll()
        self.isCalculationEnded = true
    }
    
    @IBAction private func clearButtonPressed(_ sender: UIButton) {
        calculationHistory.removeAll()
        
        self.resetLabelText()
    }
    
    @IBAction func showCalculationsList(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        if let vc = calculationsListVC as? CalculationsListViewController {
            vc.result = self.lastCalculation
        }
        
        self.navigationController?.pushViewController(calculationsListVC, animated: true)
    }
    
    private func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
            else { break }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        
        try currentResult.checkRange()
        
        return currentResult
    }
    
    private func appendOperationFromBtnToHistory(button: UIButton) {
        guard
            let buttonText = button.currentTitle,
            let buttonOperation = Operation(rawValue: buttonText)
        else { return }
        
        self.calculationHistory.append(.operation(buttonOperation))
    }
    
    private func appendNumberFromLabelToHistory() {
        guard
            let labelText = self.label.text,
            let labelNum = self.numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        self.calculationHistory.append(.number(labelNum))
    }
    
    private func resetLabelText() {
        self.label.text = "0"
    }
}

extension Double {
    func checkRange() throws {
        if self >= Double.greatestFiniteMagnitude 
            || self <= -Double.greatestFiniteMagnitude
            || (self <= Double.leastNonzeroMagnitude && self > 0)
            || (self >= -Double.leastNonzeroMagnitude && self < 0)
        {
            throw CalculationError.outOfRange
        }
    }
}
