
import UIKit
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet weak var remainingTimeLabel: UILabel! {
        didSet {
            remainingTimeLabel.font = remainingTimeLabel.font.monospaced()
        }
    }
    @IBOutlet weak var timerScrollView: UIScrollView!
    
    private var endTime = -1 as NSTimeInterval
    private var timer: NSTimer?
    private var soundId = 0 as SystemSoundID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK:- UI Actions
    @IBAction func oneMinTapped(sender: AnyObject) {
        setTimer(1 * 2)
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
            updateEndTimeLabel(now)
            updateProgressScroll(now)
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
    
    //MARK:- UI Helpers
    private func updateEndTimeLabel(currentTime: NSTimeInterval) {
        let timeRemaining = endTime - currentTime
        
        remainingTimeLabel.text = formatTime(timeRemaining)
    }
    
    private func updateProgressScroll(currentTime: NSTimeInterval) {
        timerScrollView.contentOffset.x = 12
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

