//
//  UpdateFriendViewModel.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/11/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class UpdateFriendViewModel: FriendViewModel {
    
    // MARK: - Public Properties
    
    let friendId: Int
    var title = BehaviorRelay<String>(value: "Update Friend")
    var firstname = BehaviorRelay<String>(value: "")
    var lastname = BehaviorRelay<String>(value: "")
    var phonenumber = BehaviorRelay<String>(value: "")
    
    let onNavigateBack = PublishSubject<Void>()
    let onShowError = PublishSubject<SingleButtonAlert>()
    let submitButtonTapped = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    var onShowLoadingHud: Observable<Bool> {
        return loadInProgress.asObservable().distinctUntilChanged()
    }
    var submitButtonEnabled: Observable<Bool> {
        return Observable.combineLatest(firstnameValid, lastnameValid, phoneNumberValid) { $0 && $1 && $2 }
    }
    var updateSubmitButtonState: Observable<Bool> {
        return submitIsAvailable.asObservable().distinctUntilChanged()
    }
    
    
    // MARK: - Private Properties
    
    private let loadInProgress = BehaviorRelay(value: false)
    private let submitIsAvailable = BehaviorRelay(value: false)
    private let requestManager: RequestManager
    
    
    private var firstnameValid: Observable<Bool> {
        return firstname.asObservable().map { $0.count > 0 }
    }
    private var lastnameValid: Observable<Bool> {
        return lastname.asObservable().map { $0.count > 0 }
    }
    private var phoneNumberValid: Observable<Bool> {
        return phonenumber.asObservable().map { $0.count > 0 }
    }
    private var validInputData: Bool = false {
        didSet {
            if oldValue != validInputData {
                submitIsAvailable.accept(validInputData)
            }
        }
    }
    
    
    // MARK: - Initializers

    init(friendCellViewModel: FriendCellViewModel, requestManager: RequestManager = RequestManager()) {
        
        firstname.accept(friendCellViewModel.firstname)
        lastname.accept(friendCellViewModel.lastname)
        phonenumber.accept(friendCellViewModel.phonenumber)
        friendId = friendCellViewModel.id
        self.requestManager = requestManager
        
        self.submitButtonTapped.asObserver()
            .subscribe(onNext: { [weak self] in
                self?.submitFriend()
                }
            ).disposed(by: disposeBag)
    }
    
    
    // MARK: - Public Methods
    
    func submitFriend() {
        submitIsAvailable.accept(false)
        loadInProgress.accept(true)
        
        requestManager.patchFriend(firstname: firstname.value, lastname: lastname.value, phonenumber: phonenumber.value, id: friendId).subscribe(
            onNext: { [weak self] success in
                guard let self = self else { return }
                self.loadInProgress.accept(false)
                self.onNavigateBack.onNext(())
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                self.loadInProgress.accept(false)
                let okAlert = SingleButtonAlert(
                    title: (error as? RequestManager.PatchFriendFailureReason)?.localizedDescription ?? "Could not connect to server. Check your network and try again later.",
                    message: "Failed to update information.",
                    action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                )
                
                self.onShowError.onNext(okAlert)
        }).disposed(by: disposeBag)
    }
}


// MARK: - RequestManager Error Handling

private extension RequestManager.PostFriendFailureReason {
    func getErrorMessage() -> String? {
        switch self {
        case .unAuthorized:
            return "Please login to add friends friends."
        case .notFound:
            return "Failed to add friend. Please try again."
        }
    }
}
