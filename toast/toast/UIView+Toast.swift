//
//  UIView+Toast.swift
//  MiYi
//
//  Created by 陈康 on 2018/5/3.
//  Copyright © 2018 陈康. All rights reserved.
//

import UIKit


public enum ToastAlignment {
    case top
    case center
    case bottom
}

public enum ToastStyle {
    case activity
    case loading
    case success
    case error
    case message
    case warning
    
    var image: UIImage? {
        switch self {
        case .activity:
            return UIImage(named: "toast_activity", in: bundle, compatibleWith: nil)
        case .loading:
            return UIImage(named: "toast_loading", in: bundle, compatibleWith: nil)
        case .success:
            return UIImage(named: "toast_success", in: bundle, compatibleWith: nil)
        case .error:
            return UIImage(named: "toast_error", in: bundle, compatibleWith: nil)
        case .warning:
            return UIImage(named: "toast_warn", in: bundle, compatibleWith: nil)
        case .message:
            return nil
        }
    }
    
    var bundle: Bundle {
        return Bundle(path: Bundle(for: Toast.self).resourcePath! + "/toast.bundle")!
    }
    
}
//let bundle = Bundle(path: Bundle(for: Toast.self).resourcePath! + "/Resources")

fileprivate let kScreenWidth = UIScreen.main.bounds.width
fileprivate let kScreenHeight = UIScreen.main.bounds.height
fileprivate let margin: CGFloat = 15.0
fileprivate let maxWidth: CGFloat = (kScreenWidth - 30*2)
fileprivate let minHeight: CGFloat = 50
fileprivate let loadingWidth: CGFloat = 30
fileprivate let activityWidth: CGFloat = 60
fileprivate let activityMargin: CGFloat = 10

class Toast: UIView, KTimer {
    var timerName: String?
    
    fileprivate var message: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    var imageView: UIImageView = {
        return UIImageView()
    }()
    
    var style: ToastStyle!
    
    @objc func becomActivity() {
        if style == .activity || style == .loading {
            // 开启动画
            self.stopAnimation()
            self.startAnimation()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    class func toast(_ style:ToastStyle = .activity, message: String? = nil, image: UIImage? = nil) -> Toast {
        let toast = Toast(frame: CGRect.zero)
        NotificationCenter.default.addObserver(toast, selector: #selector(becomActivity), name: UIApplication.didBecomeActiveNotification, object: nil)
        toast.style = style
        if style != .message {
            toast.addSubview(toast.imageView)
            toast.imageView.image = image ?? style.image
        }
        
        var width = activityWidth
        var height = minHeight
        let imageWidth = style != .message ? loadingWidth : 0
        if let message = message {
            toast.message.text = message
            toast.addSubview(toast.message)
            let textHeight = message.Toast_heightWithFont(font: toast.message.font, fixedWidth: maxWidth - margin * 3 - imageWidth)
            height = textHeight > height - activityMargin * 2 ? textHeight + activityMargin * 2 : height
            
            // 单行
            if height == minHeight {
                toast.message.sizeToFit()
                width = margin*2 + activityMargin + loadingWidth + toast.message.frame.size.width
            } else {
                // 多行
                width = maxWidth
            }
            
            if style == .message {
                // 纯文字
                toast.message.frame = CGRect(x: margin, y: activityMargin, width: width - margin*2 - imageWidth, height: height - activityMargin * 2)
                toast.message.textAlignment = .center
            } else {
                // 文字加图片
                toast.imageView.frame.size = CGSize(width: loadingWidth, height: loadingWidth)
                toast.imageView.frame.origin = CGPoint(x: margin, y: (height - loadingWidth)*0.5)
                toast.message.frame = CGRect(x: loadingWidth + margin + activityMargin, y: activityMargin, width: width - margin*2 - activityMargin - loadingWidth, height: height - activityMargin * 2)
            }
            
        } else {
            let imageW = width - activityMargin*2
            height = activityWidth
            toast.imageView.frame = CGRect(x: activityMargin, y: activityMargin, width: imageW, height: imageW)
        }
        toast.frame = CGRect(x: 0, y: 0, width: width, height: height)
        toast.backgroundColor = UIColor.black
        toast.layer.cornerRadius = 5
        toast.layer.shadowOffset = CGSize(width: 0, height: 3)
        toast.layer.shadowOpacity = 0.8
        toast.layer.shadowColor = UIColor.black.cgColor
        return toast
    }
    
    
    fileprivate func startAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0.0
        animation.toValue = Double.pi*2
        animation.repeatCount = MAXFLOAT
        animation.duration = style == .activity ? 1.25 : 0.75
        imageView.layer.add(animation, forKey: "transform.rotation")
    }
    
    fileprivate func stopAnimation() {
        imageView.layer.removeAnimation(forKey: "transform.rotation")
    }
}



extension UIView {
    
    private struct AssociateKeys {
        static var toastKey = "toastKey"
    }
    
    fileprivate var toast: Toast? {
        set(value) {
            objc_setAssociatedObject(self, &AssociateKeys.toastKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.toastKey) as? Toast
        }
    }
    
    public func makeToast(_ style: ToastStyle = .activity, message: String? = nil, image: UIImage? = nil, duration: Double? = nil, alignment: ToastAlignment = .center) {
        
        hideToast()
        
        let toast = Toast.toast(style, message: message, image: image)
        self.toast = toast
        
        let width = toast.frame.width
        let height = toast.frame.height
        let x = (bounds.width - width) * 0.5
        var y: CGFloat = 0.0
        if alignment == .top {
            y = 50
        }
        if alignment == .center {
            y = (bounds.height - height) * 0.5
        }
        if alignment == .bottom {
            y = bounds.height - height - 50
        }
        toast.frame = CGRect(x: x, y: y, width: width, height: height)
        
        addSubview(toast)
        
        if style == .activity || style == .loading {
            // 开启动画
            toast.startAnimation()
        }
        
        if let duration = duration {
            toast.timerName = toast.execTask(start: duration, interval: DispatchTimeInterval.seconds(Int(duration)), repeats: false, async: false) {
                if let toast = self.toast {
                    toast.stopAnimation()
                    toast.removeFromSuperview()
                    self.toast = nil
                }
            }
        }
    }
    
    public func hideToast() {
        if let toast = toast {
            toast.cancelTask()
            toast.stopAnimation()
            toast.removeFromSuperview()
            self.toast = nil
        }
    }
}


extension String {
    
    fileprivate func Toast_heightWithFont(font : UIFont = UIFont.systemFont(ofSize: 18), fixedWidth : CGFloat) -> CGFloat {
        
        guard self.count > 0 && fixedWidth > 0 else { return 0 }
        
        let size = CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context:nil)
        
        return rect.size.height
    }
}
