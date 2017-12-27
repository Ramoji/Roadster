
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class UserGuideTableViewController: UITableViewController {

    let guideTextDictionary = ["searchFeature": "In order to use the search feature on the ‘Near By’ tab, tap on the search bar to activate the search feature. The first table row presents a few quick shortcuts to commonly searched items when on a road trip such as: grocery, gas, rest stop, food etc. tapping these icons will show the closest points of interest sorted by distance.\n\nAlternately, you can use the search bar to explicitly search for a businesses, addresses, or any other point of interest and eventually navigate to it using the navigation option.",
                               "howToFindRestStop": "There are two ways to search for a rest stop. Rest stops are organized by state and route on the ‘States’ tab. Simply navigate to the state and route you are interested. Rest stops are shown on a table while simultaneously shown on a map for you to know exactly where they situated. Tapping once on a rest stop row will show the stop on the map; however, tapping on the same row twice will take you to a new page where you can find detailed information on the rest stop. \n\nThe second way is to use the 'Near by' tab and select the 'Rest Stop' icons from the search table’s quick shortcuts. This will show you all rest stops in the 50 mile radius from your location. Simply select a rest stop on the table to get more information and navigate to it.",
                               "howToAddRestStopToFavorites": "Pages that show detailed information about a rest stop have a star icon which enables you to add a rest stop to favorites. The star icon will turn bright yellow when a rest stop is added to your favorite list. You can view and modify your favorite list on the ‘Locations’ tab.",
                               "howToAddRestStopToFrequentsList": "Pages that show detailed information about a rest stop have a circular arrow icon which enables you to add a rest stop to frequents list. The circular arrow icon will turn bright yellow when a rest stop is added to your frequent list. You can view your frequent list on the ‘Locations’ tab.", "howToAddBusinessToFavoriteList": "Once you have found the business / store you are looking for using the search feature on the ‘Near by’ tab, tap on the 'Add to favorites' row to add the business to your favorite businesses list. This list can be viewed and modified on the 'Locations' tab.",
                               "howToNavigateToARestStop": "Pages that show detailed information about a rest stop have a navigation icon. Tapping this icon will start navigation and take you to the rest stop."]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView = BlurredBackgroundView(frame: self.view.bounds, addBackgroundPic: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        
        switch cell.reuseIdentifier!{
        case "iconManual":
            performSegue(withIdentifier: "iconManualTableViewControllerSegue", sender: cell)
            break
        default:
            performSegue(withIdentifier: "howToSegue", sender: cell)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        
        if segue.identifier == "howToSegue"{
            let howToTableViewController = segue.destination as! HowToTableViewController
            guard let row = indexPath?.row else {return}
            switch row{
            case 1:
                howToTableViewController.guideImage = #imageLiteral(resourceName: "searchFeatureGuideImage").withRenderingMode(.alwaysOriginal)
                howToTableViewController.guideText = guideTextDictionary["searchFeature"]
                break
            case 2:
                howToTableViewController.guideImage = #imageLiteral(resourceName: "howToFindARestStopGuide").withRenderingMode(.alwaysOriginal)
                howToTableViewController.guideText = guideTextDictionary["howToFindRestStop"]
                break
            case 3:
                howToTableViewController.guideImage = #imageLiteral(resourceName: "howToAddRestStopToFavorites").withRenderingMode(.alwaysOriginal)
                howToTableViewController.guideText = guideTextDictionary["howToAddRestStopToFavorites"]
                break
            case 4:
                howToTableViewController.guideImage = #imageLiteral(resourceName: "howToAddRestStopToFrequentList").withRenderingMode(.alwaysOriginal)
                howToTableViewController.guideText = guideTextDictionary["howToAddRestStopToFrequentsList"]
                break
            case 5:
                howToTableViewController.guideImage = #imageLiteral(resourceName: "howToAddBusinessToFavorites").withRenderingMode(.alwaysOriginal)
                howToTableViewController.guideText = guideTextDictionary["howToAddBusinessToFavoriteList"]
                break
            case 6:
                howToTableViewController.guideImage = #imageLiteral(resourceName: "howToNavigateToARestStop").withRenderingMode(.alwaysOriginal)
                
                howToTableViewController.guideText = guideTextDictionary["howToNavigateToARestStop"]
                break
            default:
                print("")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor.clear
        return cell
        
    }
}
