//
//  MainVC.swift
//  JcampViewer
//
//  Created by Lan Le on 28.03.22.
//

import UIKit
import Charts
import JcampConverter

class MainVC: UIViewController, ScanVCDelegate {

    @IBOutlet weak var chartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        
    }


    @IBAction func btnScanClicked(_ sender: Any) {
        //open scanner
        let scanVC = ScanVC(nibName: "ScanVC", bundle: nil)
        scanVC.modalPresentationStyle = .fullScreen
        scanVC.delegate = self
        self.navigationController?.present(scanVC, animated: true, completion: nil)
    }
    
    
    
    private func readJcamp(jcampurl: String) {
        let reader = JcampReader(url: jcampurl)
        if let children = reader.jcamp?.children, let firstChild = children.first {
            guard let spectra = firstChild.spectra.first else {
                return
            }
            var entries = [ChartDataEntry]()
            let xValues = spectra.xValues
            let yValues = spectra.yValues
            for (idx, xval) in xValues.enumerated() {
                let entry = ChartDataEntry(x: xval, y: yValues[idx])
                entries.append(entry)
            }
            
            let set1 = LineChartDataSet(entries: entries, label: "Test jcamp")
            set1.drawCirclesEnabled = false
            let data = LineChartData(dataSet: set1)
            chartView.data = data
        }
        else {
            guard let spectra = reader.jcamp?.spectra.first else {
                return
            }
            var entries = [ChartDataEntry]()
            let xValues = spectra.xValues
            let yValues = spectra.yValues
            for (idx, xval) in xValues.enumerated() {
                let entry = ChartDataEntry(x: xval, y: yValues[idx])
                entries.append(entry)
            }
            
            let set1 = LineChartDataSet(entries: entries, label: "Test jcamp")
            set1.drawCirclesEnabled = false
            let data = LineChartData(dataSet: set1)
            chartView.data = data
        }
        
    }
    
    // MARK: - ScanVCDelegate
    func scanSucess(data: String) {
        print(data)
        self.readJcamp(jcampurl: data)
    }

}
