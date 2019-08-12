//
//  FriendsTableViewViewModel.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/11/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum FriendTableViewCellType {
    case normal(cellViewModel: FriendCellViewModel)
    case error(message: String)
    case empty
}

class FriendsViewModel {
    
    // MARK: - Public Properties
    
    var friendCells: Observable<[FriendTableViewCellType]> {
        return cells.asObservable()
    }
    var showLoadingHud: Observable<Bool> {
        return loadInProgress.asObservable().distinctUntilChanged()
    }
    
    let onShowError = PublishSubject<SingleButtonAlert>()
    let disposeBag = DisposeBag()
    
    
    // MARK: - Private Methods
    
    let cells = BehaviorRelay<[FriendTableViewCellType]>(value: [])
    let loadInProgress = BehaviorRelay(value: false)
    private let requestManager: RequestManager
    
    
    // MARK: - Initializers
    
    init(requestManager: RequestManager = RequestManager()) {
        self.requestManager = requestManager
    }
    
    
    // MARK: - Public Methods
    
    func getFriends() {
        loadInProgress.accept(true)
        
        requestManager.getFriends().subscribe(
            onNext: { [weak self] friends in
                self?.loadInProgress.accept(false)
                
                guard friends.count > 0 else {
                    self?.cells.accept([.empty])
                    return
                }
                self?.cells.accept(friends.compactMap { .normal(cellViewModel: FriendCellViewModel(friendModel: $0 )) })
            },
            onError: { [weak self] error in
                self?.loadInProgress.accept(false)
                self?.cells.accept([
                    .error(message: (error as? RequestManager.GetFriendsFailureReason)?.getErrorMessage() ?? "Loading failed, check network connection"
                    )]
                )
        }).disposed(by: disposeBag)
    }
    
    func deleteFriend(at index: Int) {
        switch cells.value[index] {
        case .normal(let vm):
            requestManager.deleteFriend(id: vm.id).subscribe(
                onNext: { [weak self] success in
                    self?.getFriends()
                },
                onError: { [weak self] error in
                    let okAlert = SingleButtonAlert(
                        title:(error as? RequestManager.GetFriendsFailureReason)?.getErrorMessage() ?? "Loading failed, check network connection",
                        message: "Could not remove \(vm.firstname).",
                        action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                    )
                    self?.onShowError.onNext(okAlert)
            }).disposed(by: disposeBag)
        default:
            // nop
            break
        }
    }
    
    func delete(friend vm: FriendCellViewModel) {
        requestManager.deleteFriend(id: vm.id).subscribe(
            onNext: { [weak self] success in
                self?.getFriends()
            },
            onError: { [weak self] error in
                let okAlert = SingleButtonAlert(
                    title:(error as? RequestManager.GetFriendsFailureReason)?.getErrorMessage() ?? "Loading failed, check network connection",
                    message: "Could not remove \(vm.firstname).",
                    action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                )
                self?.onShowError.onNext(okAlert)
        }).disposed(by: disposeBag)
    }
}


// MARK: - RequestManager Error Handling

fileprivate extension RequestManager.GetFriendsFailureReason {
    func getErrorMessage() -> String? {
        switch self {
        case .unAuthorized:
            return "Please login to load your friends."
        case .notFound:
            return "Could not complete request, please try again."
        }
    }
}

fileprivate extension RequestManager.DeleteFriendFailureReason {
    func getErrorMessage() -> String? {
        switch self {
        case .unAuthorized:
            return "Please login to remove friends."
        case .notFound:
            return "Friend not found."
        }
    }
}
