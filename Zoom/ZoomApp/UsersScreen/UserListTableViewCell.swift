//
//  UserListTableViewCell.swift
//  ZoomApp
//
//  Created by 2020 on 11.06.2021.
//

import UIKit

class UserListTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(name: String) {
        self.userNameLabel.text = name
    }

}
