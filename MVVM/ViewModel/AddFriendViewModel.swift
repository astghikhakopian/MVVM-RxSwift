//
//  AddFriendViewModel.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/11/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FriendViewModel {
    
    var title: BehaviorRelay<String> { get }
    var firstname: BehaviorRelay<String> { get }
    var lastname: BehaviorRelay<String> { get }
    var phonenumber: BehaviorRelay<String> { get }
    var submitButtonTapped: PublishSubject<Void> { get }
    var onShowLoadingHud: Observable<Bool> { get }
    var submitButtonEnabled: Observable<Bool> { get }
    var onNavigateBack: PublishSubject<Void>  { get }
    var onShowError: PublishSubject<SingleButtonAlert>  { get }
}

final class AddFriendViewModel: FriendViewModel {
    
    // MARK: - Public Properties
    
    var title = BehaviorRelay<String>(value: "Add Friend")
    var firstname = BehaviorRelay<String>(value: "")
    var lastname = BehaviorRelay<String>(value: "")
    var phonenumber = BehaviorRelay<String>(value: "")
    
    let onNavigateBack = PublishSubject<Void>()
    let onShowError = PublishSubject<SingleButtonAlert>()
    let disposeBag = DisposeBag()
    
    var submitButtonTapped = PublishSubject<Void>()
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
    
    init(requestManager: RequestManager = RequestManager()) {
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
        
        requestManager.postFriend(firstname: firstname.value, lastname: lastname.value, phonenumber: phonenumber.value).subscribe(
            onNext: { [weak self] success in
                guard let self = self else { return }
                
                self.loadInProgress.accept(false)
                self.submitIsAvailable.accept(false)
                
                self.onNavigateBack.onNext(())
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                
                self.loadInProgress.accept(false)
                self.submitIsAvailable.accept(false)
                
                let okAlert = SingleButtonAlert(
                    title: error.localizedDescription,
                    message: "Could not add \(self.firstname.value) \(self.lastname.value).",
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
