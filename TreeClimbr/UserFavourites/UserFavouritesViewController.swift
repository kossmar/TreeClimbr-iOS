//
//  UserFavouritesViewController.swift
//  TreeClimbr
//
//  Created by Carlo Namoca on 2017-11-23.
//  Copyright © 2017 Mar Koss. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class UserFavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sourceVC = ViewController()
    var treeDistance = Double()
    var treesArr = Array<Tree>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    

    @IBAction func doneButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTreeDetail" {
            guard let treeDetailVC = segue.destination as? TreeDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            treeDetailVC.tree = sender as! Tree
            treeDetailVC.rootSourceVC = sourceVC
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.sharedInstance.favouritesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaveCell", for: indexPath) as! BasicTreeTableViewCell
        
            let treeTemp = AppData.sharedInstance.favouritesArr[indexPath.row]
            cell.tree = treeTemp
            cell.basicTreeInfoView.treeNameLabel.text = treeTemp.treeName
            cell.basicTreeInfoView.distanceLabel.text = "\(distanceFromUser(treeTemp.treeLatitude, treeTemp.treeLongitude)) km"
            cell.basicTreeInfoView.treeImageView.sd_setImage(with: treeTemp.treePhotoURL,
                                                             completed: { (image, error, cacheType, url) in
                                                                print("\(String(describing: image)), \(String(describing: error)), \(cacheType), \(String(describing: url))")
            })
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func distanceFromUser(_ lat: Double,_ long: Double) -> Double {
        let treeLocation = CLLocationCoordinate2DMake(lat,long)
        let currentLocation = sourceVC.userCoordinate
        let treePoint = MKMapPointForCoordinate(treeLocation)
        let currentPoint = MKMapPointForCoordinate(currentLocation)
        let distance = (MKMetersBetweenMapPoints(treePoint, currentPoint) / 1000)
        let distanceRound = Double(round(10*distance)/10)
        return distanceRound
    }
}
