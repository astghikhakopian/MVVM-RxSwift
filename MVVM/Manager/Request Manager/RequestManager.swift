//
//  RequestManager.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/11/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import Alamofire
import RxSwift


enum Result<T, U: Error> {
    case success(payload: T)
    case failure(U?)
}

enum EmptyResult<U: Error> {
    case success
    case failure(U?)
}


class RequestManager {
    
    
    // MARK: - GetFriends
    
    enum GetFriendsFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
    }
    
    typealias GetFriendsResult = Result<[FriendModel], GetFriendsFailureReason>
    
    func getFriends() -> Observable<[FriendModel]> {
        return Observable.create { observer -> Disposable in
            Alamofire.request("http://friendservice.herokuapp.com/listFriends").validate().responseJSON { response in
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        observer.onError(response.error ?? GetFriendsFailureReason.notFound)
                        return
                    }
                    do {
                        let friends = try JSONDecoder().decode([FriendModel].self, from: data)
                        observer.onNext(friends)
                    } catch {
                        observer.onError(error)
                    }
                case .failure(let error):
                    if let statusCode = response.response?.statusCode,
                        let reason = GetFriendsFailureReason(rawValue: statusCode) {
                        observer.onError(reason)
                    }
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    
    // MARK: - PostFriend
    
    enum PostFriendFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
    }
    
    typealias PostFriendResult = EmptyResult<PostFriendFailureReason>
    
    func postFriend(firstname: String, lastname: String, phonenumber: String) -> Observable<PostFriendResult> {
        
        let param = [
            "firstname": firstname,
            "lastname": lastname,
            "phonenumber": phonenumber
        ]
        return Observable.create { observer -> Disposable in
            Alamofire.request("https://friendservice.herokuapp.com/addFriend", method: .post, parameters: param, encoding: JSONEncoding.default).validate().responseJSON { response in
                switch response.result {
                case .success:
                    observer.onNext(.success)
                case .failure(let error):
                    if let statusCode = response.response?.statusCode,
                        let reason = GetFriendsFailureReason(rawValue: statusCode) {
                        observer.onError(reason)
                    }
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    
    // MARK: - PatchFriend
    
    enum PatchFriendFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
    }
    
    typealias PatchFriendResult = Result<FriendModel, PatchFriendFailureReason>
    
    func patchFriend(firstname: String, lastname: String, phonenumber: String, id: Int) -> Observable<PatchFriendResult> {
        let param = [
            "firstname": firstname,
            "lastname": lastname,
            "phonenumber": phonenumber
        ]
        return Observable.create { observer -> Disposable in
            Alamofire.request("https://friendservice.herokuapp.com/editFriend/\(id)", method: .patch, parameters: param, encoding: JSONEncoding.default).validate().responseJSON { response in
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        observer.onError(response.error ?? GetFriendsFailureReason.notFound)
                        return
                    }
                    do {
                        let friend = try JSONDecoder().decode(FriendModel.self, from: data)
                        observer.onNext(.success(payload: friend))
                    } catch {
                        observer.onError(error)
                    }
                case .failure(let error):
                    if let statusCode = response.response?.statusCode,
                        let reason = GetFriendsFailureReason(rawValue: statusCode) {
                        observer.onError(reason)
                    }
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    
    // MARK: - DeleteFriend
    
    enum DeleteFriendFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
    }
    
    typealias DeleteFriendResult = EmptyResult<DeleteFriendFailureReason>
    
    func deleteFriend(id: Int) -> Observable<DeleteFriendResult> {
        return Observable.create { observer -> Disposable in
            Alamofire.request("https://friendservice.herokuapp.com/editFriend/\(id)", method: .delete, encoding: JSONEncoding.default).validate().responseJSON { response in
                switch response.result {
                case .success:
                    observer.onNext(.success)
                case .failure(let error):
                    if let statusCode = response.response?.statusCode,
                        let reason = GetFriendsFailureReason(rawValue: statusCode) {
                        observer.onError(reason)
                    }
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
