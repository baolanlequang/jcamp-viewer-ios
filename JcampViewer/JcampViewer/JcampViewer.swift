//
//  JcampViewer.swift
//  JcampViewer
//
//  Created by Lan Le on 18.02.22.
//

import Foundation

public class JcampViewer {
    
    public var spectraBoardView: SpectraBoardView!
    
    public init() {
        spectraBoardView = SpectraBoardView()
        spectraBoardView.backgroundColor = .systemBlue
    }
}
