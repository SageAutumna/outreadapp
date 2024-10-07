//
//  Extension+UINavigationController.swift
//  Outread
//
//  Created by iosware on 18/08/2024.
//

import UIKit

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
