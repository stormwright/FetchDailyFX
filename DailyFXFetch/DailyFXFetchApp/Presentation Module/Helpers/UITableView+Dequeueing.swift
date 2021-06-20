//
// UITableView+Dequeueing.swift
// Created by Mikayil M on 20/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
