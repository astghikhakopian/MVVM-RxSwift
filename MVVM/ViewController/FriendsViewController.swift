//
//  FriendsViewController.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/11/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import UIKit
import RxSwift

class FriendsViewController: CommonViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Public Properties
    
    let viewModel = FriendsViewModel()
    var selectFriendPayload: ReadOnce<FriendCellViewModel>?
    
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Segue
    
    private let toAddFriendViewController = "AddFriendViewController"
    private let toUpdateFriendViewController = "UpdateFriendViewController"
    
    
    // MARK: - Configuration
    
    override func configureSettings() {
        super.configureSettings()
        
        // table view
        tableView.register(UINib(nibName: FriendTableViewCell.id, bundle: nil), forCellReuseIdentifier: FriendTableViewCell.id)
        
        // viewModel

        setupTableviewDataSource()
        setupCellDeleting()
        setupCellTapHandling()
        
        viewModel
            .onShowError
            .map { [weak self] in self?.present(alert: $0)}
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModel
            .showLoadingHud
            .map { print($0) }//self?.setLoadingHud(visible: $0) }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    override func reloadData() {
        super.reloadData()
        
        viewModel.getFriends()
    }
    
    
    // MARK: - Navigation
    
    public override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case toUpdateFriendViewController:
            return !(selectFriendPayload?.isRead ?? true)
        default:
            return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case toAddFriendViewController:
            let destinationViewController = segue.destination as! FriendViewController
            destinationViewController.viewModel = AddFriendViewModel()
            destinationViewController.updateFriends.asObserver().subscribe(onNext: { [weak self] () in
                self?.viewModel.getFriends()
                }, onCompleted: {
                    print("ONCOMPLETED")
            }).disposed(by: destinationViewController.disposeBag)
        case toUpdateFriendViewController:
            let destinationViewController = segue.destination as! FriendViewController
            guard let viewModel = selectFriendPayload?.read() else { break }
            
            destinationViewController.viewModel = UpdateFriendViewModel(friendCellViewModel: viewModel)
            destinationViewController.updateFriends.asObserver().subscribe(onNext: { [weak self] () in
                self?.viewModel.getFriends()
                }, onCompleted: {
                    print("ONCOMPLETED")
            }).disposed(by: destinationViewController.disposeBag)
        default:
            break
        }
    }
    
    
    // MARK: - Private Methods
    
    private func setupTableviewDataSource() {
        viewModel.friendCells.bind(to: self.tableView.rx.items) { tableView, index, element in
            let indexPath = IndexPath(item: index, section: 0)
            switch element {
            case .normal(let viewModel):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendTableViewCell.id, for: indexPath) as? FriendTableViewCell else {
                    return UITableViewCell()
                }
                cell.viewModel = viewModel
                return cell
            case .error(let message):
                let cell = UITableViewCell()
                cell.isUserInteractionEnabled = false
                cell.textLabel?.text = message
                return cell
            case .empty:
                let cell = UITableViewCell()
                cell.isUserInteractionEnabled = false
                cell.textLabel?.text = "No data available"
                return cell
            }
        }.disposed(by: disposeBag)
    }
    
    private func setupCellDeleting() {
        tableView.rx.modelDeleted(FriendTableViewCellType.self).subscribe(
            onNext: { [weak self] friendCellType in
                if case let .normal(viewModel) = friendCellType {
                    self?.viewModel.delete(friend: viewModel)
                }
                
                if let selectedRowIndexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView?.deselectRow(at: selectedRowIndexPath, animated: true)
                }
        }).disposed(by: disposeBag)
    }
    
    private func setupCellTapHandling() {
        tableView.rx.modelSelected(FriendTableViewCellType.self).subscribe(
            onNext: { [weak self] friendCellType in
                guard let self = self else { return }
                if case let .normal(viewModel) = friendCellType {
                    self.selectFriendPayload = ReadOnce(viewModel)
                    self.performSegue(withIdentifier: self.toUpdateFriendViewController, sender: self)
                }
                if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
        }).disposed(by: disposeBag)
    }
}


// MARK: - AlertContainerDelegate

extension FriendsViewController: AlertContainerDelegate { }
