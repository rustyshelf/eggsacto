
import UIKit
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet weak var remainingTimeLabel: UILabel! {
        didSet {
            remainingTimeLabel.font = remainingTimeLabel.font.monospaced()
        }
    }
    @IBOutlet weak var timerScrollView: UIScrollView!
    
    private let pixelsPerSecond = 40 / 60 as Double
    
    private var endTime = 0 as NSTimeInterval
    private var timer: NSTimer?
    private var soundId = 0 as SystemSoundID

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
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.timerDidFire), userInfo: nil, repeats: true)
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
        
        AudioServicesPlaySystemSound(soundId)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK:- Formatting Stuff That Should Be In Another Class
    private func formatTime(time: NSTimeInterval) -> String {
        //we don't deal with hours here because we're lazy, and our timer only goes to 20, though really it should go to 11
        let minutes = floor(time / 60)
        let seconds = time % 60
        
        return NSString(format: "%1.0lf:%02.0lf", minutes, seconds) as String
    }
    
    deinit {
        if soundId != 0 {
            AudioServicesDisposeSystemSoundID(soundId)
        }
    }
}

