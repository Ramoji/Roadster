//
//  ReportLocationIssueTableViewController.swift
//  Roadster
//
//  Created by EA JA on 9/1/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import Dispatch

protocol ReportLocationIssueTableViewControllerDelegate {
    func reportLocationIssueTableViewControllerDidTapCancelButton(_ reportLocationIssueTableViewController: ReportLocationIssueTableViewController)
}

class ReportLocationIssueTableViewController: UITableViewController {
    
    @IBOutlet weak var sendBarButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    var delegate: ReportLocationIssueTableViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        sendBarButton.isEnabled = false
        setupTextView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   

    @IBAction func send(_ sender: UIBarButtonItem){
        
        HTTPHelper.shared.sendEmail(recepient: "wzk014@gmail.com", sender: "", subject: "TEST", emailBody: "SENT FROM WITHIN ROADSTER!")
        
        if let navigationController = navigationController{
            let hudView = HUDView.createHUD(inView: navigationController.view, animated: true)
            hudView.text = "Sent!"
        }
        
        let delay = 0.8
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            self.dismiss(animated: true, completion: {
                self.delegate?.reportLocationIssueTableViewControllerDidTapCancelButton(self)
            })
        })
        
    }
    
    @IBAction func cancel(){
        
        delegate?.reportLocationIssueTableViewControllerDidTapCancelButton(self)
    }
    
    func setupTextView(){
        let describeIssueAttributedText = NSAttributedString(string: "In a few sentences describe the issue", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.lightGray])
        textView.attributedText = describeIssueAttributedText
    }
}

extension ReportLocationIssueTableViewController: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        if let textViewString = textView.text{
            if textViewString != "" {
                sendBarButton.isEnabled = true
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let attributedText = NSAttributedString(string: "!", attributes: [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
        textView.attributedText = attributedText
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let describeIssueAttributedText = NSAttributedString(string: "In a few sentences describe the issue", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.lightGray])
        textView.attributedText = describeIssueAttributedText
    }
    
}
