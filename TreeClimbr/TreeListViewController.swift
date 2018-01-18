
import UIKit
import CoreLocation
import MapKit
import Firebase

class TreeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    var sourceVC = ViewController()
    var treeDistance = Double()
    var treesArr = Array<Tree>()
    var segmentState = 0
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet var barButton: UIBarButtonItem!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        barButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 20)!], for: UIControlState.normal)
        treesArr = AppData.sharedInstance.treesArr
        
        sortTableViewByDistance()
        
        FavouritesManager.loadFavourites { (success) in
            return
        }
        
        UserTreesManager.loadUserTrees { (success) in
            return
        }
        


        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue", size: 17.0)!, forKey: NSAttributedStringKey.font as NSCopying)
        segmentControl.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(true)
        
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                
                //                self.segmentControl.numberOfSegments = 1
                self.segmentControl.setEnabled(true, forSegmentAt: 1)
                self.segmentControl.setEnabled(true, forSegmentAt: 2)
            } else {
                self.segmentControl.setEnabled(false, forSegmentAt: 1)
                self.segmentControl.setEnabled(false, forSegmentAt: 2)
            }
        }
        
        switch segmentState {
        case 0:
            treesArr = hideBlockedUsers()
        case 1:
            treesArr = AppData.sharedInstance.userTreesArr
        case 2:
            treesArr = AppData.sharedInstance.favouritesArr
        default:
            treesArr = AppData.sharedInstance.treesArr
            
        }
        sortTableViewByDistance()
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
            treeDetailVC.sourceVC = self
            
        }
    }
    
    
    //MARK: Table view delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTreeTableViewCell", for: indexPath) as! BasicTreeTableViewCell
        let treeTemp = treesArr[indexPath.row]
        cell.tree = treeTemp
        cell.basicTreeInfoView.treeNameLabel.text = treeTemp.treeName
        cell.basicTreeInfoView.distanceLabel.text = "\(treeTemp.distFromUser) km"
        cell.basicTreeInfoView.favouritesCountLabel.text = "\(treeTemp.treePopularity)"
        

        treeTemp.treeComments = []
        CommentManager.loadComments(tree: treesArr[indexPath.row]) { (success) in
            cell.basicTreeInfoView.commentLabel.text = "\(treeTemp.treeComments.count) Comments"
            treeTemp.treeComments = []
        }
        cell.basicTreeInfoView.backgroundImageView.sd_setImage(with: treeTemp.treePhotoURL,

                                                         completed: { (image, error, cacheType, url) in
                                                            print("\(String(describing: image)), \(String(describing: error)), \(cacheType), \(String(describing: url))")
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return treesArr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let treeTemp = treesArr[indexPath.row]
        performSegue(withIdentifier: "toTreeDetail", sender: treeTemp)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if segmentControl.selectedSegmentIndex == 1 {
            return true
        } else {
            return false
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            UserTreesManager.deleteUserTree(tree: treesArr[indexPath.row], completion: { (success) in
                UserTreesManager.loadUserTrees(completion: { trees in
                })
                FavouritesManager.loadFavourites(completion: { trees in
                })
            })
            treesArr.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    // MARK: - Custom Functions
    
    func distanceFromUser(_ lat: Double,_ long: Double) -> Double {
        let treeLocation = CLLocationCoordinate2DMake(lat,long)
        let currentLocation = sourceVC.userCoordinate
        let treePoint = MKMapPointForCoordinate(treeLocation)
        let currentPoint = MKMapPointForCoordinate(currentLocation)
        let distance = (MKMetersBetweenMapPoints(treePoint, currentPoint) / 1000)
        let distanceRound = Double(round(10*distance)/10)
        return distanceRound
    }
    
    func sortTableViewByDistance() {
        for treeTemp in treesArr {
            let treeDist = distanceFromUser(treeTemp.treeLatitude, treeTemp.treeLongitude)
            treeTemp.distFromUser = treeDist
        }
        
        self.treesArr.sort(by: { $0.distFromUser < $1.distFromUser })
        tableView.reloadData()
    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            treesArr = hideBlockedUsers()
            sortTableViewByDistance()
            tableView.reloadData()
            navigationBar.topItem?.title = segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)
            self.segmentState = 0
        case 1:
            treesArr = AppData.sharedInstance.userTreesArr
            sortTableViewByDistance()
            tableView.reloadData()
            navigationBar.topItem?.title = segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)
            self.segmentState = 1

        case 2:
            treesArr = AppData.sharedInstance.favouritesArr
            sortTableViewByDistance()
            tableView.reloadData()
            navigationBar.topItem?.title = segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)
            self.segmentState = 2

        default:
            break
        }
    }
    
    func hideBlockedUsers() -> [Tree] {
        var hiddenUIDSet = Set <String>()
        
        treesArr = AppData.sharedInstance.treesArr
        
        for hiddenUser in AppData.sharedInstance.hiddenUsersArr {
            hiddenUIDSet.insert(hiddenUser.uid)
        }
        
        var index = 0
        for aTree in treesArr {
            if hiddenUIDSet.contains(aTree.treeCreator) {
                treesArr.remove(at: index)
            } else {
                index += 1
            }
        }
        return treesArr
    }
    
}
