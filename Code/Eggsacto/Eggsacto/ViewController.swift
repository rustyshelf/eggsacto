
import UIKit
import AudioToolbox

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var remainingTimeLabel: UILabel! {
        didSet {
            remainingTimeLabel.font = remainingTimeLabel.font.monospaced()
        }
    }
    @IBOutlet weak var timerScrollView: UIScrollView!
    
    @IBOutlet weak var trailingRulerSpace: NSLayoutConstraint!
    @IBOutlet weak var leadingRulerSpace: NSLayoutConstraint!
    
    private let rulerImagePadding = 40 as CGFloat
    private let pixelsPerSecond = 40 / 60 as Double
    private let maxTimerTime = 20 * 60 as TimeInterval
    
    //1 second might seem sensible, but 200ms is going to give you a more fluid update time
    private let timerUpdateTime = 0.2
    
    private var endTime = 0 as TimeInterval
    private var timer: Timer?
    private var soundId = 0 as SystemSoundID
    
    private var userIsDraggingScrollView = false

    //MARK:- UI Actions
    @IBAction func oneMinTapped(sender: AnyObject) {
        setTimer(time: 1 * 60)
    }

    @IBAction func twoMinTapped(sender: AnyObject) {
        setTimer(time: 2 * 60)
    }
    
    @IBAction func fiveMinTapped(sender: AnyObject) {
        setTimer(time: 5 * 60)
    }
    
    @IBAction func twelveMinTapped(sender: AnyObject) {
        setTimer(time: 12 * 60)
    }
    
    override func viewDidLoad() {
        //we need the arrow to be at the right spot for various widths, so go to the middle, then go back the amount
        //our 'helpful' designer has padded the ruler
        let offset = (self.view.bounds.width / 2.0) - rulerImagePadding
        trailingRulerSpace.constant = offset
        leadingRulerSpace.constant = offset
    }
    
    //MARK:- UI Update Timer
    private func setTimer(time: TimeInterval) {
        endTime = NSDate().timeIntervalSince1970 + time
        remainingTimeLabel.layer.removeAllAnimations()
        startUIUpdateTimer()
    }
    
    private func startUIUpdateTimer() {
        stopUIUpdateTimer()
        
        timer = Timer.scheduledTimer(timeInterval: timerUpdateTime, target: self, selector: #selector(ViewController.timerDidFire), userInfo: nil, repeats: true)
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
            remainingTimeLabel.text = formatTime(time: timeRemaining)
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
        remainingTimeLabel.layer.add(flashAnimation, forKey: "opacity")
    }
    
    private func playAmazingSound() {
        guard let filePath = Bundle.main.path(forResource: "explosion-mono", ofType: "aif") else { return }

        if soundId == 0 {
            AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: filePath), &soundId)
        }
        
        //play our amazing sound
        AudioServicesPlaySystemSound(soundId)
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        userIsDraggingScrollView = true
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !userIsDraggingScrollView || scrollView.contentOffset.x < 0 { return }
        
        let newTime = min(maxTimerTime, Double(scrollView.contentOffset.x) / pixelsPerSecond)
        setTimer(time: newTime)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //the user flicked the scroll view and it's done decelerating
        userIsDraggingScrollView = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            //this handles the case where the user scrolls slowly instead of flicking
            userIsDraggingScrollView = false
        }
    }
    
    //MARK:- White Status Bar Is Dope
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Formatting Stuff That Should Be In Another Class
    private func formatTime(time: TimeInterval) -> String {
        //we don't deal with hours here because we're lazy, and our timer only goes to 20, though really it should go to 11
        let minutes = floor(time / 60)
        let seconds = floor(time.truncatingRemainder(dividingBy: 60))
        
        return NSString(format: "%1.0lf:%02.0lf", minutes, seconds) as String
    }
    
    deinit {
        if soundId != 0 {
            AudioServicesDisposeSystemSoundID(soundId)
        }
    }
}

