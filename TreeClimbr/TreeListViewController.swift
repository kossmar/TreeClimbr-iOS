
import UIKit

class TreeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var sourceVC = ViewController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTreeDetail" {
            guard let treeDetailVC = segue.destination as? TreeDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            treeDetailVC.tree = sender as! Tree
            treeDetailVC.rootSourceVC = sourceVC
        }
    }
    
    
    //MARK: Table view delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTreeTableViewCell", for: indexPath) as! BasicTreeTableViewCell
        let treeTemp = AppData.sharedInstance.treesArr[indexPath.row]
//        cell.textLabel?.text = treeTemp.treeName
//        cell.detailTextLabel?.text = AppData.sharedInstance.treesArr[indexPath.row].treeDescription
        cell.tree = treeTemp
        cell.basicTreeInfoView.treeNameLabel.text = treeTemp.treeName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.sharedInstance.treesArr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let treeTemp = AppData.sharedInstance.treesArr[indexPath.row]
        performSegue(withIdentifier: "toTreeDetail", sender: treeTemp)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }

 
 

}
