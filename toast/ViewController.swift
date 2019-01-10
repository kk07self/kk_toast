//
//  ViewController.swift
//  toastDemo
//
//  Created by K K on 2019/1/9.
//  Copyright © 2019 K K. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.makeToast(.success, message: "成功了...", image: nil, duration: 5, alignment: .center)
    }
}

