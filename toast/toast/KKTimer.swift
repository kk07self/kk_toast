//
//  Timer.swift
//  MeeYi
//
//  Created by K K on 2018/11/26.
//  Copyright © 2018 陈康. All rights reserved.
//

import UIKit

protocol KTimer {
    
    var timerName: String? {get set}
    func execTask(start: TimeInterval, interval: DispatchTimeInterval, repeats: Bool, async:Bool, task:(()->())?)-> String?
    func cancelTask()
    
}


extension KTimer {
    
    func execTask(start: TimeInterval, interval: DispatchTimeInterval, repeats: Bool, async: Bool, task:(()->())?)-> String? {
        return KKTimer.execTask(start: start, interval: interval, repeats: repeats, async: async, task: task)
    }
    
    func cancelTask() {
        KKTimer.cancelTask(timerName)
    }
}


fileprivate class KKTimer {
    
    private static let timer_pre = "com.ikirk"
    private static var timers = [String: DispatchSourceTimer]()
    private static var semaphore = DispatchSemaphore(value: 1)
    
    
    /// 定时器
    ///
    /// - Parameters:
    ///   - start: 开始时间
    ///   - interval: 时间间隔
    ///   - repeats: 是否重复
    ///   - async: 是否异步
    ///   - task: 任务
    /// - Returns: 定时器标识
    class func execTask(start: TimeInterval, interval: DispatchTimeInterval, repeats: Bool, async:Bool, task:(()->())?)-> String? {
        if task == nil {
            return nil
        }
        let queue = async ? DispatchQueue.global() : DispatchQueue.main
        let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        timer.schedule(deadline: .now() + start, repeating: interval)
        
        _ = semaphore.wait(timeout: .distantFuture)
        let str = "\(timer_pre)\(timers.count+1)"
        timers[str] = timer
        semaphore.signal()
        
        timer.setEventHandler {
            task?()
            if repeats == false {
                cancelTask(str)
            }
        }
        timer.resume()
        return str
    }
    
    
    /// 取消定时器
    ///
    /// - Parameter taskName: 定时器标识
    class func cancelTask(_ taskName: String?) {
        guard let key = taskName else {
            return
        }
        _ = semaphore.wait(timeout: .distantFuture)
        if let timer = timers[key] {
            timer.cancel()
        }
        semaphore.signal()
    }
}
