//
//  ViewController.swift
//  toastDemo
//
//  Created by K K on 2019/1/9.
//  Copyright © 2019 K K. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    var actions = [0: "Message",
                   1: "SuccessMessage",
                   2: "WaringMessage",
                   3: "ErrorMessage",
                   4: "Loading",
                   5: "LoadingMessage",
                   6: "Activity",
                   7: "ActivityMessage",
                   8: "MessageBottom",
                   9: "MessageTop",
                   10: "LoadingBottom",
                   11: "LoadingTop",
                   12: "ActivityBottom",
                   13: "ActivityTop"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenW: CGFloat = UIScreen.main.bounds.size.width
        var y: CGFloat = 100
        for index in 0...13 {
            y = 60.0 * CGFloat(index/3) + 100.0
            let btn = UIButton()
            btn.tag = index
            btn.addTarget(self, action: #selector(onClickActionBtn(btn:)), for: .touchDown)
            btn.backgroundColor = UIColor.orange
            btn.setTitle(actions[index], for: .normal)
            btn.setTitle(actions[index], for: .highlighted)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            view.addSubview(btn)
            if index % 3 == 0 {
                btn.frame = CGRect(x: 30, y: y, width: 100, height: 44)
            } else if index % 3 == 1 {
                btn.frame = CGRect(x: (screenW - 100) * 0.5, y: y, width: 100, height: 44)
            } else {
                btn.frame = CGRect(x: (screenW - 100) - 30, y: y, width: 100, height: 44)
            }
        }
    }

    @objc func onClickActionBtn(btn: UIButton) {
        switch btn.tag {
        case 0:
            view.makeMessageToast("This is Message Toast.")
        case 1:
            view.makeSuccessToast("This is Success and Message Toast.")
        case 2:
            view.makeWarningToast("This is Warning and Message Toast.")
        case 3:
            view.makeErrorToast("This is Error and Message Toast.")
        case 4:
            view.makeLoadingToast()
        case 5:
            view.makeLoadingAndMessageToast("Loading datas...")
        case 6:
            view.makeActivityToast()
        case 7:
            view.makeActivityAndMessageToast("Loading datas...")
        case 8:
            view.makeMessageToast("This is Message Toast.", alignment: .bottom)
        case 9:
            view.makeMessageToast("This is Message Toast.", alignment: .top)
        case 10:
            view.makeLoadingToast(.bottom)
        case 11:
            view.makeLoadingToast(.top)
        case 12:
            view.makeActivityToast(.bottom)
        case 13:
            view.makeActivityToast(.top)
        default:
            break
        }
        
        guard btn.tag > 3 else { return }
        // 针对于loading and activity
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.view.hideToast()
        }
    }
}

