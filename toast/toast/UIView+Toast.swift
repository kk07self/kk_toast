//
//  UIView+Toast.swift
//  toast
//
//  Created by 陈康 on 2018/5/3.
//  Copyright © 2018 陈康. All rights reserved.
//

import UIKit

fileprivate let kScreenWidth = UIScreen.main.bounds.width
fileprivate let kScreenHeight = UIScreen.main.bounds.height


class ToastConfig {
    static let shared = ToastConfig()
    
    // 各种样式的图标配置
    var activityImage: UIImage? = ToastStyle.activity.image
    var loadingImage: UIImage? = ToastStyle.loading.image
    var successImage: UIImage? = ToastStyle.success.image
    var errorImage: UIImage? = ToastStyle.error.image
    var waringImage: UIImage? = ToastStyle.warning.image
    
    
    // 尺寸配置
    var verticalMargin: CGFloat = 16.0
    var horizontalMargin: CGFloat = 16.0
    
    var marginOnActivity: CGFloat = 15.0
    var marginOnLoading: CGFloat = 15.0
    
    var marginOnMessageAndImage: CGFloat = 15.0
    
    // 有文字情况下图片宽度
    var imageWidthOnMessage: CGFloat = 32.0
    
    // 只有loading情况下图片宽度
    var imageWidthOnLoading: CGFloat = 80.0
    
    // 只有activity情况下图片宽度
    var imageWidthOnActivity: CGFloat = 80.0
    
    // toast的最大宽度，超过换行
    var maxWidth: CGFloat = kScreenWidth - 50.0*2
    
    // 只有一行时最小高度
    var minHeight: CGFloat = 48.0
    
    // message 信息
    var textColor: UIColor = UIColor.white
    var textFont: UIFont = UIFont.systemFont(ofSize: 14.0)
    
}


// MARK: Toast 位置样式
public enum ToastAlignment {
    case top
    case center
    case bottom
}


// MARK: Toast 样式
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
        if Bundle(for: Toast.self) == Bundle.main {
            return Bundle.main
        }
        return Bundle(path: Bundle(for: Toast.self).resourcePath! + "/toast.bundle")!
    }
    
}


// MARK: Toast Class
class Toast: UIView {
    
    fileprivate var message: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = ToastConfig.shared.textColor
        label.font = ToastConfig.shared.textFont
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate var imageView: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = .scaleAspectFit
        return imageV
    }()
    
    fileprivate var style: ToastStyle!
    
    @objc fileprivate func becomActivity() {
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
        
        var width: CGFloat = 0.0
        var height: CGFloat = ToastConfig.shared.minHeight
        
        if let message = message {
            toast.message.text = message
            toast.addSubview(toast.message)
            
            var fixedWidth: CGFloat = 0.0
            // 纯文字
            if style == .message {
                fixedWidth = ToastConfig.shared.maxWidth - ToastConfig.shared.verticalMargin * 2
            } else {
                // 有图片
                fixedWidth = ToastConfig.shared.maxWidth - ToastConfig.shared.verticalMargin * 2 - ToastConfig.shared.marginOnMessageAndImage - ToastConfig.shared.imageWidthOnMessage
            }
            
            let textHeight = message.Toast_heightWithFont(font: toast.message.font, fixedWidth: fixedWidth)
            height = textHeight > height - ToastConfig.shared.horizontalMargin * 2 ? textHeight + ToastConfig.shared.horizontalMargin * 2 : height
            
            // 单行
            if height == ToastConfig.shared.minHeight {
                toast.message.text = message
                toast.message.sizeToFit()
                width = ToastConfig.shared.verticalMargin*2 + toast.message.frame.size.width + 5
            } else {
                // 多行
                width = ToastConfig.shared.maxWidth
            }
            
            if style == .message {
                // 纯文字
                toast.message.frame = CGRect(x: ToastConfig.shared.verticalMargin, y: ToastConfig.shared.horizontalMargin, width: width - ToastConfig.shared.verticalMargin*2, height: height - ToastConfig.shared.horizontalMargin * 2)
                toast.message.textAlignment = .center
            } else {
                // 文字加图片
                width += ToastConfig.shared.imageWidthOnMessage + ToastConfig.shared.marginOnMessageAndImage
                toast.imageView.frame.size = CGSize(width: ToastConfig.shared.imageWidthOnMessage, height: ToastConfig.shared.imageWidthOnMessage)
                toast.imageView.frame.origin = CGPoint(x: ToastConfig.shared.marginOnMessageAndImage, y: (height - ToastConfig.shared.imageWidthOnMessage)*0.5)
                toast.message.frame = CGRect(x: ToastConfig.shared.marginOnMessageAndImage + ToastConfig.shared.verticalMargin + ToastConfig.shared.imageWidthOnMessage, y: ToastConfig.shared.horizontalMargin, width: width - ToastConfig.shared.verticalMargin*2 - ToastConfig.shared.imageWidthOnMessage - ToastConfig.shared.marginOnMessageAndImage, height: height - ToastConfig.shared.horizontalMargin * 2)
            }
            
        } else {
            width = toast.style == .loading ? ToastConfig.shared.imageWidthOnLoading : ToastConfig.shared.imageWidthOnActivity
            let margin = toast.style == .loading ? ToastConfig.shared.marginOnLoading : ToastConfig.shared.marginOnActivity
            let imageW = width - margin*2
            height = toast.style == .loading ? ToastConfig.shared.imageWidthOnLoading : ToastConfig.shared.imageWidthOnActivity
            toast.imageView.frame = CGRect(x: margin, y: margin, width: imageW, height: imageW)
        }
        toast.frame = CGRect(x: 0, y: 0, width: width, height: height)
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.8)
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


// MARK: api 聚集
extension UIView {
    
    /// message toast
    public func makeMessageToast(_ message: String?, duration: Double? = 2.0, alignment: ToastAlignment = .center) {
        guard let message = message else { return }
        makeToast(.message, message: message, duration: duration, alignment: alignment)
    }
    
    /// message and icon toast
    public func makeImageAndMessageToast(_ message: String?, image: UIImage?, duration: Double? = 2.0, alignment: ToastAlignment = .center) {
        guard let message = message else { return }
        makeToast(.message, message: message, image: image, duration: duration, alignment: alignment)
    }
    
    /// success and message
    public func makeSuccessToast(_ message: String?, duration: Double? = 2.0, alignment: ToastAlignment = .center) {
        makeToast(.success, message: message, duration: duration, alignment: alignment)
    }
    
    /// warning and message
    public func makeWarningToast(_ message: String?, duration: Double? = 2.0, alignment: ToastAlignment = .center) {
        makeToast(.warning, message: message, duration: duration, alignment: alignment)
    }
    
    /// error and message
    public func makeErrorToast(_ message: String?, duration: Double? = 2.0, alignment: ToastAlignment = .center) {
        makeToast(.error, message: message, duration: duration, alignment: alignment)
    }
    
    /// loading toast
    public func makeLoadingToast(_ alignment: ToastAlignment = .center) {
        makeToast(.loading, alignment: alignment)
    }
    
    /// loading and message toast
    public func makeLoadingAndMessageToast(_ message: String?, alignment: ToastAlignment = .center) {
        makeToast(.loading, message: message, alignment: alignment)
    }
    
    /// activity toast
    public func makeActivityToast(_ alignment: ToastAlignment = .center) {
        makeToast(.activity, alignment: alignment)
    }
    
    /// activity and message toast
    public func makeActivityAndMessageToast(_ message: String?, alignment: ToastAlignment = .center) {
        makeToast(.activity, message: message, alignment: alignment)
    }
    
    /// 弹框统一api
    ///
    /// - Parameters:
    ///   - style: 需要弹框的样式，loading和activity是长时间悬浮，其他是短时间弹框需要设置时长
    ///   - message: 弹框的文本信息
    ///   - image: 自定义图标
    ///   - duration: 时长，loading和activity无效
    ///   - alignment: 弹框的位置
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
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                if let toast = self.toast {
                    toast.stopAnimation()
                    toast.removeFromSuperview()
                    self.toast = nil
                }
            }
        }
    }
    
    
    /// 隐藏弹框
    public func hideToast() {
        if let toast = toast {
            toast.stopAnimation()
            toast.removeFromSuperview()
            self.toast = nil
        }
    }
}


extension UIView {
    
    private struct AssociateKeys {
        static var toastKey = "com.toast.key"
    }
    
    fileprivate var toast: Toast? {
        set(value) {
            objc_setAssociatedObject(self, &AssociateKeys.toastKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.toastKey) as? Toast
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
