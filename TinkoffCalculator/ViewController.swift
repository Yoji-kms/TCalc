//
//  ViewController.swift
//  TCalc
//
//  Created by Yoji on 23.01.2024.
//

import UIKit

enum CalculationError: Error {
    case divideByZero
    case outOfRange
}

class ViewController: UIViewController {
    
    private let comma = ","
    private var isCalculationEnded = false
    private var calculationHistory: [CalculationHistoreItem] = []
    
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

    @IBOutlet private weak var label: UILabel!
    
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
            let result = try calculate()
            
            self.label.text = numberFormatter.string(from: NSNumber(value: result))
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
            let labelText = label.text,
            let labelNum = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        self.calculationHistory.append(.number(labelNum))
    }
    
    private func resetLabelText() {
        label.text = "0"
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
