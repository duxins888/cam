//
//  View+Extension.swift
//  Cam
//
//  Created by Xin Du on 2023/09/06.
//

import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
