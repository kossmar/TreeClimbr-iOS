
import UIKit
import CoreLocation
import MapKit

class TreeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    var sourceVC = ViewController()
    var treeDistance = Double()
    var treesArr = Array<Tree>()
    
    var isFiltered = Bool()
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        navigationBar.backgroundColor = UIColor.white.withAlphaComponent(0.80)
        treesArr = AppData.sharedInstance.treesArr
        
        sortTableViewByDistance()
        
        FavouritesManager.loadFavourites { (success) in
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isFiltered = true
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func filterAction(_ sender: UIBarButtonItem) {
        if isFiltered {
            treesArr = AppData.sharedInstance.favouritesArr
            sortTableViewByDistance()
            tableView.reloadData()
            isFiltered = false
            filterButton.title = "Show All Trees"
        } else {
            treesArr = AppData.sharedInstance.treesArr
            sortTableViewByDistance()
            tableView.reloadData()
            isFiltered = true
            filterButton.title = "Show Favourites"
        }
        
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
        let treeTemp = treesArr[indexPath.row]
        cell.tree = treeTemp
        cell.basicTreeInfoView.treeNameLabel.text = treeTemp.treeName
        cell.basicTreeInfoView.distanceLabel.text = "\(treeTemp.distFromUser) km"
        
        cell.basicTreeInfoView.treeImageView.sd_setImage(with: treeTemp.treePhotoURL,
                                                         completed: { (image, error, cacheType, url) in
                                                            print("\(String(describing: image)), \(String(describing: error)), \(cacheType), \(String(describing: url))")
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered {
            return AppData.sharedInstance.favouritesArr.count
        } else {
            return AppData.sharedInstance.treesArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let treeTemp = treesArr[indexPath.row]
        performSegue(withIdentifier: "toTreeDetail", sender: treeTemp)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
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
    
    
}
