//
//  FriendViewController.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/11/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FriendViewController: CommonViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var textFieldFirstname: UITextField!
    @IBOutlet weak var textFieldLastname: UITextField!
    @IBOutlet weak var textFieldPhoneNumber: UITextField!
    @IBOutlet weak var buttonSubmit: UIButton!
    
    
    // MARK: - Public Properties
    
    var viewModel: FriendViewModel?
    var updateFriends = PublishSubject<Void>()
    
    let disposeBag = DisposeBag()
    private var activeTextField: UITextField?
    
    
    // MARK: - Configuration
    
    override func configureSettings() {
        
        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateFriends.onCompleted()
        
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: - Private Properties
    
    func bindViewModel() {
        guard let viewModel = viewModel else {
            return
        }
        
        title = viewModel.title.value
        
        bind(textField: textFieldFirstname, to: viewModel.firstname)
        bind(textField: textFieldLastname, to: viewModel.lastname)
        bind(textField: textFieldPhoneNumber, to: viewModel.phonenumber)
        
        viewModel.submitButtonEnabled
            .bind(to: buttonSubmit.rx.isEnabled)
            .disposed(by: disposeBag)
        
        buttonSubmit.rx.tap.asObservable()
            .bind(to: viewModel.submitButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel
            .onShowLoadingHud
            .map { print($0) }
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModel
            .onNavigateBack
            .subscribe(
                onNext: { [weak self] in
                    self?.updateFriends.onNext(())
                    let _ = self?.navigationController?.popViewController(animated: true)
                }
            ).disposed(by: disposeBag)
        
        viewModel
            .onShowError
            .map { [weak self] in self?.present(alert: $0)}
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func bind(textField: UITextField, to behaviorRelay: BehaviorRelay<String>) {
        behaviorRelay.asObservable()
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
        textField.rx.text.orEmpty
            .bind(to: behaviorRelay)
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Actions
    
    @IBAction func rootViewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}


// MARK: - UITextFieldDelegate

extension FriendViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}


// MARK: - AlertContainerDelegate

extension FriendViewController: AlertContainerDelegate { }

