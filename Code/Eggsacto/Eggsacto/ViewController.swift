
import UIKit
import AudioToolbox

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var remainingTimeLabel: UILabel! {
        didSet {
            remainingTimeLabel.font = remainingTimeLabel.font.monospaced()
        }
    }
    @IBOutlet weak var timerScrollView: UIScrollView!
    
    private let pixelsPerSecond = 40 / 60 as Double
    private let maxTimerTime = 20 * 60 as NSTimeInterval
    
    //1 second might seem sensible, but 200ms is going to give you a more fluid update time
    private let timerUpdateTime = 0.2
    
    private var endTime = 0 as NSTimeInterval
    private var timer: NSTimer?
    private var soundId = 0 as SystemSoundID
    
    private var userIsDraggingScrollView = false

    //MARK:- UI Actions
    @IBAction func oneMinTapped(sender: AnyObject) {
        setTimer(1 * 60)
    }

    @IBAction func twoMinTapped(sender: AnyObject) {
        setTimer(2 * 60)
    }
    
    @IBAction func fiveMinTapped(sender: AnyObject) {
        setTimer(5 * 60)
    }
    
    @IBAction func twelveMinTapped(sender: AnyObject) {
        setTimer(12 * 60)
    }
    
    //MARK:- UI Update Timer
    private func setTimer(time: NSTimeInterval) {
        endTime = NSDate().timeIntervalSince1970 + time
        remainingTimeLabel.layer.removeAllAnimations()
        startUIUpdateTimer()
    }
    
    private func startUIUpdateTimer() {
        stopUIUpdateTimer()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(timerUpdateTime, target: self, selector: #selector(ViewController.timerDidFire), userInfo: nil, repeats: true)
    }
    
    private func stopUIUpdateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func timerDidFire() {
        let now = NSDate().timeIntervalSince1970
        
        if (now >= endTime) {
            eggsactoTimerDidEndTimeForFanfare()
        }
        else {
            let timeRemaining = endTime - now
            remainingTimeLabel.text = formatTime(timeRemaining)
            timerScrollView.contentOffset.x = CGFloat(timeRemaining * pixelsPerSecond)
        }
    }
    
    //MARK:- End Handling
    private func eggsactoTimerDidEndTimeForFanfare() {
        stopUIUpdateTimer()
        remainingTimeLabel.text = "0:00"
        flashTimeLabel()
        playAmazingSound()
    }
    
    private func flashTimeLabel() {
        let flashAnimation = CABasicAnimation(keyPath: "opacity")
        flashAnimation.toValue = 0.1
        flashAnimation.duration = 0.5
        flashAnimation.repeatCount = FLT_MAX
        flashAnimation.autoreverses = true
        flashAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        remainingTimeLabel.layer.addAnimation(flashAnimation, forKey: "opacity")
    }
    
    private func playAmazingSound() {
        guard let filePath = NSBundle.mainBundle().pathForResource("explosion-mono", ofType: "aif") else { return }

        if soundId == 0 {
            AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: filePath), &soundId)
        }
        
        //play our amazing sound
        AudioServicesPlaySystemSound(soundId)
        
        //vibrate the phone 3 times, don't do this at home kids
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            for _ in 1...3 {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                NSThread.sleepForTimeInterval(1)
            }
        }
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        userIsDraggingScrollView = true
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !userIsDraggingScrollView || scrollView.contentOffset.x < 0 { return }
        
        let newTime = min(maxTimerTime, Double(scrollView.contentOffset.x) / pixelsPerSecond)
        setTimer(newTime)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        //the user flicked the scroll view and it's done decelerating
        userIsDraggingScrollView = false
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            //this handles the case where the user scrolls slowly instead of flicking
            userIsDraggingScrollView = false
        }
    }
    
    //MARK:- White Status Bar Is Dope
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK:- Formatting Stuff That Should Be In Another Class
    private func formatTime(time: NSTimeInterval) -> String {
        //we don't deal with hours here because we're lazy, and our timer only goes to 20, though really it should go to 11
        let minutes = floor(time / 60)
        let seconds = floor(time % 60)
        
        return NSString(format: "%1.0lf:%02.0lf", minutes, seconds) as String
    }
    
    deinit {
        if soundId != 0 {
            AudioServicesDisposeSystemSoundID(soundId)
        }
    }
}

