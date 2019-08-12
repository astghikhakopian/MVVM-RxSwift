//
//  FriendCellViewModel.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/11/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import Foundation

struct FriendCellViewModel {
    
    // MARK: - Public Properties
    
    let id: Int
    let firstname: String
    let lastname: String
    let phonenumber: String
}


// MARK: - Initializers

extension FriendCellViewModel {
    
    init(friendModel: FriendModel) {
        id = friendModel.id
        firstname = friendModel.firstname
        lastname = friendModel.lastname
        phonenumber = friendModel.phonenumber
    }
}
