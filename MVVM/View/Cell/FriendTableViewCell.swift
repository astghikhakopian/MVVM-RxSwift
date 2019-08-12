//
//  FriendTableViewCell.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/11/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    static let id = "FriendTableViewCell"
    
    // MARK: - Outlets
    
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    
    
    // MARK: - Public Properties
    
    public var viewModel: FriendCellViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        fullNameLabel.text = viewModel.firstname + viewModel.lastname
        phoneNumberLabel.text = viewModel.phonenumber
    }
}
