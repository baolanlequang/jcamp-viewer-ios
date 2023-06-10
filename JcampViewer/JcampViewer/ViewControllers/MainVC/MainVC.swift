//
//  MainVC.swift
//  JcampViewer
//
//  Created by Lan Le on 28.03.22.
//

import UIKit
import DGCharts
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
        let jcamp = Jcamp(jcampurl)
        
        let colors = ChartColorTemplates.colorful()[0...4]
        
        var dataSets: [ChartDataSet] = []
        for (specIdx, spectrum) in jcamp.spectra.enumerated() {
            var entries = [ChartDataEntry]()
            let xValues = spectrum.getListX()
            let yValues = spectrum.getListY()
            for (idx, xval) in xValues.enumerated() {
                let entry = ChartDataEntry(x: xval, y: yValues[idx])
                entries.append(entry)
            }
            
            let set = LineChartDataSet(entries: entries, label: "Test jcamp \(specIdx+1)")
            set.drawCirclesEnabled = false
            let color = colors[specIdx % colors.count]
            set.setColor(color)
            
            dataSets.append(set)
        }
        
        let data = LineChartData(dataSets: dataSets)
        self.chartView.data = data
    }
    
    // MARK: - ScanVCDelegate
    func scanSucess(data: String) {
        self.readJcamp(jcampurl: data)
    }

}
