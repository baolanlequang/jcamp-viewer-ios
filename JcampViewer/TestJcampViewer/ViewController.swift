//
//  ViewController.swift
//  TestJcampViewer
//
//  Created by Lan Le on 18.02.22.
//

import UIKit
import JcampViewer

class ViewController: UIViewController {

    lazy var jcampViewer: JcampViewer = {
        let viewer = JcampViewer()
        return viewer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(jcampViewer.spectraBoardView)
        jcampViewer.spectraBoardView.center = self.view.center
        jcampViewer.spectraBoardView.frame = self.view.frame
    }


}

