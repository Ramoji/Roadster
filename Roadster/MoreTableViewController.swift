//
//  MoreTableViewController.swift
//  Roadster
//
//  Created by EA JA on 10/4/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class MoreTableViewController: UITableViewController {
    
    let moreTableViewControllerOptionList = ["User guide", "Report a new rest stop", "Rate in App Store", "Contact developer"]
    let logInLogOutList = ["Log in", "Log out"]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        tableView.backgroundView = BlurredBackgroundView(frame: self.view.bounds, addBackgroundPic: true)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.view.bounds.width)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func registerNibs(){
        let nib = UINib(nibName: "MoreTableViewControllerCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.moreTableViewControllerCell)
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if indexPath.section == 0 {
            switch indexPath.row{
            case 0:
                performSegue(withIdentifier: "userGuideTableViewControllerSegue", sender: cell)
                break
            case 1:
                performSegue(withIdentifier: "reportNewRestStopTableViewControllerSegue", sender: cell)
                break
            case 2:
                break
            case 3:
                contactDeveloper()
                break
            default:
                print("*** In defualt")
            }
        } else {
            
            switch indexPath.row{
            case 0:
                if let storyboard = storyboard{
                    let signInViewController = storyboard.instantiateViewController(withIdentifier: "signInViewController")
                    present(signInViewController, animated: true, completion: nil)
                }
                break
            case 1:
                if UserDefaults.standard.bool(forKey: DefaultKeys.signedIn){
                    
                    let logoutConfirmationAlert = UIAlertController(title: "Confirmation", message: "Are you sure you want to log out of your account?", preferredStyle: .alert)
                    let yesAlertAction = UIAlertAction(title: "Yes", style: .default){ action in
                        HTTPHelper.shared.logout{
                            let alert = UIAlertController(title: "Logged Out", message: "You have been logged out of your account", preferredStyle: .alert)
                            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    
                    let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    logoutConfirmationAlert.addAction(yesAlertAction)
                    logoutConfirmationAlert.addAction(cancelAlertAction)
                    
                    
                    present(logoutConfirmationAlert, animated: true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: nil, message: "You are not signed in", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(okAction)
                    present(alert, animated: true, completion: nil)
                }
                
                break
            default:
                print("*** In default!")
            }
            
        }
        
      tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
  
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return moreTableViewControllerOptionList.count
        } else {
            return logInLogOutList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.moreTableViewControllerCell, for: indexPath) as! MoreTableViewControllerCell
        cell.backgroundColor = UIColor.clear
        
        if indexPath.section == 0{
            
            switch indexPath.row{
            case 0:
                cell.iconImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "info"))
                break
            case 1:
                cell.iconImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "reportInfo"))
                break
            case 2:
                cell.iconImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "heart"))
                break
            case 3:
                cell.iconImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "contact"))
                break
            default:
                print("")
            }
            
            cell.label.text = moreTableViewControllerOptionList[indexPath.row]
            if indexPath.row == moreTableViewControllerOptionList.count - 1 {
                cell.separator.isHidden = true
            }
        } else {
            
            switch indexPath.row{
            case 0:
                cell.iconImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "login"))
                break
            case 1:
                cell.iconImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "logout"))
                break
            default:
                print("")
            }
            
            cell.label.text = logInLogOutList[indexPath.row]
            if indexPath.row == logInLogOutList.count - 1 {
                cell.separator.isHidden = true
            }
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return getSectionHeaderView(with: "Useful options")
        } else {
            return getSectionHeaderView(with: "Current user")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func getResizedIconImage(image: UIImage) -> UIImage{
        return image.resizeImage(CGSize(width: 40.0, height: 40.0)).withRenderingMode(.alwaysOriginal)
    }
    
    
    func getSectionHeaderView(with title: String) -> UIView{
        let sectionHeaderView = UILabel()
        let headerAttributedString = NSAttributedString(string: title.uppercased(), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.darkGray])
        sectionHeaderView.attributedText = headerAttributedString
        sectionHeaderView.sizeToFit()
        let headerViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: sectionHeaderView.bounds.height + 10))
        sectionHeaderView.translatesAutoresizingMaskIntoConstraints = false
        headerViewContainer.addSubview(sectionHeaderView)
        let headerViewTopConstraint = sectionHeaderView.centerYAnchor.constraint(equalTo: headerViewContainer.centerYAnchor)
        let headerViewLeadingConstraint = sectionHeaderView.leadingAnchor.constraint(equalTo: headerViewContainer.leadingAnchor, constant: 18.0)
        let headerViewWidthConstraint = sectionHeaderView.widthAnchor.constraint(equalToConstant: sectionHeaderView.bounds.width)
        let headerViewHeightConstraint = sectionHeaderView.heightAnchor.constraint(equalToConstant: sectionHeaderView.bounds.height)
        NSLayoutConstraint.activate([headerViewTopConstraint, headerViewLeadingConstraint, headerViewWidthConstraint, headerViewHeightConstraint])
        headerViewContainer.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
   
        
        return headerViewContainer
    }
    
   
    

    @IBAction func unwindToMoreTableViewController(segue: UIStoryboardSegue){
        
    }
    
    func contactDeveloper(){
        guard UserDefaults.standard.bool(forKey: DefaultKeys.signedIn) else {
            let signUpViewController = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.originalPresenter = self
            present(signUpViewController, animated: true, completion: nil)
            return
        }
        
        performSegue(withIdentifier: "ContactDeveloperSegue", sender: nil)
        
    }
}



