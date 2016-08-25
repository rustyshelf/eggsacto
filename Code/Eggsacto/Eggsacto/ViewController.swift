
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var remainingTime: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func add1MinTapped(sender: AnyObject) {
        addToTimer(1)
    }

    @IBAction func add2MinTapped(sender: AnyObject) {
        addToTimer(2)
    }
    
    @IBAction func add5MinTapped(sender: AnyObject) {
        addToTimer(5)
    }
    
    @IBAction func add12MinTapped(sender: AnyObject) {
        addToTimer(12)
    }
    
    private func addToTimer(time: NSTimeInterval) {
        //TODO make magic happen
    }
}

