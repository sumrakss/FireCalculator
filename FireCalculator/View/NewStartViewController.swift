//
//  NewStartViewController.swift
//  FireCalculator
//
//  Created by Алексей on 18.02.2020.
//  Copyright © 2020 Alexey Orekhov. All rights reserved.
//

import UIKit

class NewStartViewController: UITableViewController {

    @IBOutlet weak var firePlaceLabel: UILabel!
    @IBOutlet weak var hardWorkLabel: UILabel!
    @IBOutlet weak var enterTimePicker: UIDatePicker!
    @IBOutlet weak var fireTimePicker: UIDatePicker!
    @IBOutlet weak var fireTimeLabel: UILabel!
    @IBOutlet weak var enterTimeDetail: UILabel!
    @IBOutlet weak var fireTimeDetail: UILabel!
    @IBOutlet weak var fireTimeCell: UITableViewCell!
    @IBOutlet weak var firePlaceSwitch: UISwitch!
    @IBOutlet weak var hardWorkSwitch: UISwitch!
    @IBOutlet weak var fireStackLabel: UILabel!
    @IBOutlet var teamCountStack: [UIStackView]!
    @IBOutlet var enterValueFields: [UITextField]!
    @IBOutlet var firePlaceFields: [UITextField]!
    @IBOutlet weak var vSlider: UISlider! {
        didSet {
            vSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
            vSlider.minimumValue = 2
            vSlider.maximumValue = 5
            vSlider.value = 3
        }
    }
    
    let time = DateFormatter()
    var tappedCell1: Bool = false
    var tappedCell2: Bool = false
    var data = AppData()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(SettingsData.airFlow)
        tableView.keyboardDismissMode = .onDrag // Скрываем клавиатуру при прокрутке
        fireStackLabel.isHidden = true
        fireTimeCell.selectionStyle = .none
        fireTimeLabel.isEnabled = false
        fireTimeDetail.isEnabled = false
        
        time.dateFormat = "HH:mm"
        enterTimeDetail.text = time.string(from: data.enterTime)
        fireTimeDetail.text = time.string(from: data.fireTime)
        
        for item in firePlaceFields {
            item.isHidden = true
            item.borderStyle = .line
        }
        
        let count = Int(vSlider.value)
        inputFieldsView(fieldCount: count)
    }
    
  
    // Отрисовываем поля ввода в зависимости от состава звена
    func inputFieldsView(fieldCount: Int) {
            data.enterData.removeAll()
            data.hearthData.removeAll()
            data.fallPressure.removeAll()
            
            for item in teamCountStack {
                item.isHidden  = true
            }
            
            for i in 0..<fieldCount {
                if let enterValue = enterValueFields[i].text?.dotGuard() {
                    data.enterData.append(enterValue)
                }
                
                if let hearthValue = firePlaceFields[i].text?.dotGuard() {
                    data.hearthData.append(hearthValue)
                }
            
                data.fallPressure.append(data.enterData[i] - data.hearthData[i])
                teamCountStack[i].isHidden = false
                enterValueFields[i].isHidden = false
                enterValueFields[i].borderStyle = .line
            }
        }
    
    
    // Очаг
    @IBAction func firePlaceChange(_ sender: Any) {
		
        data.firePlace = !data.firePlace
        fireStackLabel.isHidden = !fireStackLabel.isHidden
        fireTimeLabel.isEnabled = !fireTimeLabel.isEnabled
        // Делаем ячейку неактивной в случае если очаг не найден
        fireTimeDetail.isEnabled = !fireTimeDetail.isEnabled
        data.firePlace ? (fireTimeCell.selectionStyle = .default) : (fireTimeCell.selectionStyle = .none)
        // Скрываем TimePicker если очаг не найден
        if tappedCell2 {  tappedCell2 = false }
        
        for item in firePlaceFields {
            item.isHidden = !item.isHidden
        }
        tableView.reloadData()
    }
    
    
    // Сложные условия
    @IBAction func hardWorkChange(_ sender: UISwitch) {
        data.hardWork = !data.hardWork
    }
    
    
    // Устанавливаем время включения
    @IBAction func enterTimeChange(_ sender: UIDatePicker) {
        data.enterTime = enterTimePicker!.date
        time.dateFormat = "HH:mm"
        enterTimeDetail.text = time.string(from: data.enterTime)
    }
    
	
    // Устанавливаем время у очага
    @IBAction func fireTimeChange(_ sender: UIDatePicker) {
        data.fireTime = fireTimePicker!.date
        time.dateFormat = "HH:mm"
        fireTimeDetail.text = time.string(from: data.fireTime)
    }
    

    // Меняем численность состава звена ГДЗС
    @IBAction func teamChange(_ sender: UISlider) {
        let teamCount = Int(vSlider.value)
        inputFieldsView(fieldCount: teamCount)
    }
    
	
	// Обновляем все переменные
	@IBAction func doneButton(_ sender: UIButton) {
		let teamCount = Int(vSlider.value)
        inputFieldsView(fieldCount: teamCount)
    }
    
    
    @IBAction func calcButton(_ sender: Any) {
        let teamCount = Int(vSlider.value)
        inputFieldsView(fieldCount: teamCount)
    }
    
    
    // MARK: Скрываем и отображам DatePicker по тапу на ячейке
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            tappedCell1 = !tappedCell1
            tableView.reloadRows(at: [indexPath], with: .none)
//            tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        }
        
        
        if indexPath.row == 4 && data.firePlace {
             tappedCell2 = !tappedCell2
            tableView.reloadRows(at: [indexPath], with: .none)
        }
//        tableView.beginUpdates()
//        tableView.endUpdates()1§
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return (tappedCell1 ? tableView.rowHeight : 0)
        }

        if indexPath.row == 5 {
            return (tappedCell2  && data.firePlace ? tableView.rowHeight : 0)
        }
        
        // Высота ячейки с полями ввода
        if indexPath == [1, 0] {
            return 256
        }
        return tableView.rowHeight
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerText = ""
        if section == 0 {
            headerText = "Условия работы"
        }
        
        if section == 1 {
            
            headerText = SettingsData.valueUnit ? "ДАВЛЕНИЕ В ЗВЕНЕ (кгс/см\u{00B2})" : "ДАВЛЕНИЕ В ЗВЕНЕ (МПа)"
        }
//        tableView.reloadSections([0, 1], with: .automatic)
        
        return headerText
    }
    
    // Передача данных по segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewSegue" {
            guard let vc = segue.destination as? PDFPreviewViewController else { return }
            let pdfCreator = PDFCreator()
            
            if data.firePlace { // Если очаг найден
//                pdfCreator.appData = data
//                vc.documentData = pdfCreator.foundPDFCreator()
            } else {
                vc.appData = data
                vc.documentData = pdfCreator.notFoundPDFCreator(appData: data)
            }
        }
    }
}


//  расширение для автоматичесткой перевода строки запятой в точку
extension String {
    static let numberFormatter = NumberFormatter()
    func dotGuard() -> Double {
        var doubleValue: Double {
            String.numberFormatter.decimalSeparator = "."
            if let result =  String.numberFormatter.number(from: self) {
                return result.doubleValue
            } else {
                String.numberFormatter.decimalSeparator = ","
                if let result = String.numberFormatter.number(from: self) {
                    return result.doubleValue
                }
            }
            return 0
        }
        return doubleValue
    }
}

/*
extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
}
*/
