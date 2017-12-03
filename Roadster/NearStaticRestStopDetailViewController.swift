//
//  NearStaticRestStopDetailViewController.swift
//  Roadster
//
//  Created by EA JA on 8/14/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

protocol NearStaticRestStopDetailViewControllerDelegate: class {
    func nearStaticRestStopDetailViewControllerDidRequestUpdate(_ nearStaticRestStopDetailViewControllerwith: NearStaticRestStopDetailViewController, restStop: USRestStop)
    func nearStaticRestStopDetailViewControllerDidTapCloseButton(_ nearStaticRestStopDetailViewController: NearStaticRestStopDetailViewController)
}


class NearStaticRestStopDetailViewController: UIViewController {
    
    var restStop: USRestStop!
    var delegates = MulticastDelegate<NearStaticRestStopDetailViewControllerDelegate>()
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var restStopDescriptionLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var ratingImageView: UIImageView!
    
    var nearRestStopChildDetailTableViewController: NearRestStopChildDetailTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        constraintContainerView()
        
        
        
        

        latitudeLabel.text =  restStop.latitude.convertToString()
        longitudeLabel.text = restStop.longitude.convertToString()
        
        if let fullStateName = States.getFullStateName(for: restStop.state){
            restStopDescriptionLabel.text = "Rest Stop on \((restStop.routeName as NSString)) in \(fullStateName.capitalized)"
        }
        
        ratingImageView.contentMode = .scaleAspectFit
        
        closeButton.setImage(#imageLiteral(resourceName: "closeButton").resizeImage(CGSize(width: 20.0, height: 20.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        
        HTTPHelper.shared.getComments(latitude: restStop.latitude, longitude: restStop.longitude, reloadTableViewClosure: { comments, rating in
            
            guard let image = UIImage(named: "\(rating)stars") else {
                self.ratingImageView.image = #imageLiteral(resourceName: "0stars").resizeImage(CGSize(width: 100.0, height: 27.0)).withRenderingMode(.alwaysOriginal)
                return
            }
            
            self.ratingImageView.image = image.resizeImage(CGSize(width: 100.0, height: 27.0)).withRenderingMode(.alwaysOriginal)
            
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView(){
        self.view.addShadow(withCornerRadius: 15.0)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setUpView()
    }
    
    func constraintContainerView(){
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100.0)
        let leadingConstraint = containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let widthConstraint = containerView.widthAnchor.constraint(equalToConstant: self.view.bounds.width)
        let heightConstraint = containerView.heightAnchor.constraint(equalToConstant: 450.0)
        NSLayoutConstraint.activate([topConstraint, leadingConstraint, widthConstraint, heightConstraint])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifiers.nearRestStopChildDetailTableViewControllerSegueIdentifier{
            nearRestStopChildDetailTableViewController = segue.destination as! NearRestStopChildDetailTableViewController
            nearRestStopChildDetailTableViewController.restStop = self.restStop
            self.delegates.add(delegate: nearRestStopChildDetailTableViewController)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func close(_ sender: UIButton){
        delegates.invokeDelegates{
            $0.nearStaticRestStopDetailViewControllerDidTapCloseButton(self)
        }
    }

    deinit {
        print("*** Deinitialized NearStaticRestStopDetailViewController!")
    }
}
