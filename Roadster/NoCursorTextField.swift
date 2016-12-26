//
//  NoCursorTextField.swift
//  Roadster
//
//  Created by A Ja on 12/18/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

class NoCursorTextField: UITextField {

    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }
    

}
