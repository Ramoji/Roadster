
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class ReportNewRestStopTableViewController: UITableViewController {

    
    @IBOutlet var closedSwitch: UISwitch!
    @IBOutlet var mileMarkerTextField: UITextField!
    var disabledFacilities = false
    var gasStation = false
    var petArea = false
    var phones = false
    var restaurant = false
    var restroom = false
    var rvFacilities = false
    var tables = false
    var vendingMachine = false
    var drinkingWater = false
    var truckParking = false
    var carParking = false
    var closed = false
    var mileMarker: String!
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.title = "Report a new rest stop"
        closedSwitch.isOn = false
        closedSwitch.addTarget(self, action: #selector(closedSwitchDidChange), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: Notification.Name.UITextFieldTextDidChange, object: mileMarkerTextField)
        
    }
    
    
    
    func closedSwitchDidChange(){
        
        closed = closedSwitch.isOn
        
    }
    
    func textFieldDidChange(){
        
        if let text = mileMarkerTextField.text{
            mileMarker = text
        } else {
            mileMarker = ""
        }
        
    }
    
 
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func submit(_ sender: UIButton){
        
        guard UserDefaults.standard.bool(forKey: DefaultKeys.signedIn) else {
            let signUpViewController = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            present(signUpViewController, animated: true, completion: nil)
            return
        }
        
        let parameters = ["disabledFacilities": disabledFacilities,
                          "gasStation": gasStation,
                          "petArea": petArea,
                          "phones": phones,
                          "restaurant": restaurant,
                          "restroom": restroom,
                          "rvFacilities": rvFacilities,
                          "tables": tables,
                          "vendingMachine": vendingMachine,
                          "drinkingWater": drinkingWater,
                          "truckParking": truckParking,
                          "carParking": carParking
                          ]
        HTTPHelper.shared.reportNewRestStopToDeveloper(with: parameters)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44.0
        
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard section == 2 else {
            
            return super.tableView(tableView, viewForHeaderInSection: section)
            
        }
        
        return getHeaderViewLabel()
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        guard section == 0 || section == 1 else {return}
        
        let headerView = view as? UITableViewHeaderFooterView
        headerView!.textLabel?.font = UIFont.systemFont(ofSize: 14)
        
    }
    
   
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == 0 || indexPath.section == 2{
            return nil
        } else {
            return indexPath
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section == 1 else {return}
        
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        
        switch indexPath.row{
            
        case 0:
            
            if cell.accessoryType == .checkmark{
                disabledFacilities = false
                cell.accessoryType = .none
            } else {
                disabledFacilities = true
                cell.accessoryType = .checkmark
            }
            break
            
        case 1:
            if cell.accessoryType == .checkmark{
                gasStation = false
                cell.accessoryType = .none
            } else {
                gasStation = true
                cell.accessoryType = .checkmark
            }
            break
            
        case 2:
            if cell.accessoryType == .checkmark{
                petArea = false
                cell.accessoryType = .none
            } else {
                petArea = true
                cell.accessoryType = .checkmark
            }
            break
        
        case 3:
            if cell.accessoryType == .checkmark{
                phones = false
                cell.accessoryType = .none
            } else {
                phones = true
                cell.accessoryType = .checkmark
            }
            break
            
        case 4:
            if cell.accessoryType == .checkmark{
                restaurant = false
                cell.accessoryType = .none
            } else {
                restaurant = true
                cell.accessoryType = .checkmark
            }
            break
            
        case 5:
            if cell.accessoryType == .checkmark{
                restroom = false
                cell.accessoryType = .none
            } else {
                restroom = true
                cell.accessoryType = .checkmark
            }
            break
            
        case 6:
            if cell.accessoryType == .checkmark{
                rvFacilities = false
                cell.accessoryType = .none
            } else {
                rvFacilities = true
                cell.accessoryType = .checkmark
            }
            break
            
        case 7:
            if cell.accessoryType == .checkmark{
                tables = false
                cell.accessoryType = .none
            } else {
                tables = true
                cell.accessoryType = .checkmark
            }
            break
            
        case 8:
            if cell.accessoryType == .checkmark{
                vendingMachine = false
                cell.accessoryType = .none
            } else {
                vendingMachine = true
                cell.accessoryType = .checkmark
            }
            break
            
        case 9:
            if cell.accessoryType == .checkmark{
                drinkingWater = false
                cell.accessoryType = .none
            } else {
                drinkingWater = true
                cell.accessoryType = .checkmark
            }
            break
            
        case 10:
            if cell.accessoryType == .checkmark{
                truckParking = false
                cell.accessoryType = .none
            } else {
                truckParking = true
                cell.accessoryType = .checkmark
            }
            break
            
        case 11:
            if cell.accessoryType == .checkmark{
                carParking = false
                cell.accessoryType = .none
            } else {
                carParking = true
                cell.accessoryType = .checkmark
            }
            break
            
        default:
            print("*** In default!")
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
      
    }
    

    func getHeaderViewLabel() -> UITextView{
        
        let headerView = UITextView()
        headerView.text = "Please tap on the options above to select the available facilities at this rest stop."
        headerView.font = UIFont.systemFont(ofSize: 14)
        headerView.textAlignment = .left
        headerView.isEditable = false
        headerView.isSelectable = false
        headerView.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)
        headerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        headerView.sizeToFit()
        return headerView
        
    }
    
}
