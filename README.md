###Feature

---

- 持续悬停加载，支持上中下位置
- 短时间状态弹框，支持上中下位置，支持自定义时长，支持自定义图标
- 携带了定时器功能，线程安全，无死循环



### Requirements

----

- iOS 9.0+
- Swift4.2+



### Using

----

- 集成

```ruby
pod 'kk_toast'

// 命令
pod install
```

- 导入

```swift
import kk_toast
```

- 使用

toast

```swift
// toast
// 统一api，参数不同，效果不同
public func makeToast(_ style: ToastStyle = .activity, message: String? = nil, image: UIImage? = nil, duration: Double? = nil, alignment: ToastAlignment = .center)

// style: 弹框样式
// .loading和.activity是长时间悬停状态，其他是短时间悬停需要指定时长

// message: 弹框的文本信息

// image: 短时间悬停时可配置的图标，如果为nil使用默认的，style为.loading和.activity时无效

// duration: 短时间悬停时配置的时长，style为.loading和.activity时无效

// alignment: 悬停的位置，目前只支持三种，上中下

// 长时间弹框，有两种样式，一种是菊花一种是圆圈
// 圆圈
view.makeToast(.loading, message: "数据获取中...")
// 菊花样式
view.makeToast(.activity, message: "数据获取中...")
// 可支持上中下的位置
view.makeToast(.loading, message: "数据机制中...", alignment: .center)

// 长时间悬停需要手动调用萧山
view.hideToast()


// 指定时间弹框，然后消失
// 成功的状态，3秒后消失，在中间弹框
view.makeToast(.success, message: "加载成功", image: nil, duration: 3, alignment: .center)
```



Timer

```swift
// 需要遵守定时器协议，并且内部实现一个属性，默认需要绑定实现一个属性
class ViewController: UIViewController, KTimer{
    var timerName: String?
    ...
}

// 在指定的位置创建定时器：KTimer协议方法
timerName = execTask(start: 0, interval: DispatchTimeInterval.seconds(3), repeats: true, async: true, task: {
    print("1111111111")
})

// 如果不重复，那么interval后会自定取消
// 如果重复的，那么需要手动取消定时器，KTimer协议方法
cancelTask()
```

注意，这里默认只提供了一个定时器名称，如果想在一个类下面添加多个定时器，可自行定义定时器名称，定时器创建的api只有一个，是一样的，不一样的是取消定时器任务，需要传入对应定时器名称

```swift
cancelTask(timerName_self)
```



以上。



