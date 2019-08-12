//
//  LocalizationManager.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/11/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import UIKit

final class LocalizationManager: NSObject {
    
    public static let sharedInstance = LocalizationManager()
    
    private override init() {
        super.init()
    }
    
    
    // MARK: - Public Properties
    
    // Returns the currnet language
    public var currentLanguage: Language {
        get {
            
            if UserDefaults.standard.string(forKey: Constants.Langauge.selectedLanguage) == nil {
                UserDefaults.standard.set(Language.english.rawValue, forKey: Constants.Langauge.selectedLanguage)
            }
            
            guard let currentLang = UserDefaults.standard.string(forKey: Constants.Langauge.selectedLanguage) else {
                fatalError("Did you set the default language for the app?")
            }
            return Language(rawValue: currentLang)!
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Constants.Langauge.selectedLanguage)
        }
    }
    
    // Returns the default language that the app will run first time
    public var defaultLanguage: Language {
        get {
            
            if UserDefaults.standard.string(forKey: Constants.Langauge.selectedLanguage) == nil {
                UserDefaults.standard.set(Language.english.rawValue, forKey: Constants.Langauge.selectedLanguage)
            }
            
            guard let defaultLanguage = UserDefaults.standard.string(forKey: Constants.Langauge.defaultLanguage) else {
                fatalError("Did you set the default language for the app ?")
            }
            return Language(rawValue: defaultLanguage)!
        }
        set {
            // swizzle the awakeFromNib from nib and localize the text in the new awakeFromNib
            UIView.localize()
            Bundle.localize()
            
            let defaultLanguage = UserDefaults.standard.string(forKey: Constants.Langauge.defaultLanguage)
            guard defaultLanguage == nil else {
                setLanguage(language: currentLanguage)
                return
            }
            
            UserDefaults.standard.set(newValue.rawValue, forKey: Constants.Langauge.defaultLanguage)
            UserDefaults.standard.set(newValue.rawValue, forKey: Constants.Langauge.selectedLanguage)
            setLanguage(language: newValue)
        }
    }
    
    
    // Returns the diriction of the language
    public var isRightToLeft: Bool {
        get {
            return isLanguageRightToLeft(language: currentLanguage)
        }
    }
    
    // Returns the app locale for use it in dates and currency
    public var appLocale: Locale {
        get {
            return Locale(identifier: currentLanguage.rawValue)
        }
    }
    
    
    // MARK: - Public Methods
    
    //
    // Set the current language for the app
    //
    // - parameter language: The language that you need from the app to run with
    //
    public func setLanguage(language: Language, rootViewController: UIViewController? = nil, animation: ((UIView) -> Void)? = nil) {
        
        // change the dircation of the views
        let semanticContentAttribute: UISemanticContentAttribute = isLanguageRightToLeft(language: language) ? .forceRightToLeft : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = semanticContentAttribute
        UITextField.appearance().semanticContentAttribute = semanticContentAttribute
        
        // set current language
        currentLanguage = language
        
        guard let rootViewController = rootViewController else {
            return
        }
        
        let snapshot = (UIApplication.shared.keyWindow?.snapshotView(afterScreenUpdates: true))!
        rootViewController.view.addSubview(snapshot);
        
        UIApplication.shared.delegate?.window??.rootViewController = rootViewController
        
        UIView.animate(withDuration: 0.5, animations: {
            animation?(snapshot)
        }) { _ in
            snapshot.removeFromSuperview()
        }
        
    }
    
    // Localize string
    func localize(_ text: String) -> String {
        return ""
//        let language = currentLanguage
//
//        let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj")
//        let bundle = Bundle(path: path!)
//
//        return NSLocalizedString(text, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    private func isLanguageRightToLeft(language: Language) -> Bool {
        return Locale.characterDirection(forLanguage: language.rawValue) == .rightToLeft
    }
    
}

enum Language: String, CaseIterable {
    case english = "en"
    case russian = "ru-RU"
    case armenian = "hy-AM"
    
    static func toArray() -> [Language] {
        var array = [Language]()
        
        for value in Language.allCases {
            array.append(value)
        }
        
        return array
    }
}


// MARK: - Swizzling

fileprivate extension UIView {
    static func localize() {
        
        let orginalSelector = #selector(awakeFromNib)
        let swizzledSelector = #selector(swizzledAwakeFromNib)
        
        let orginalMethod = class_getInstanceMethod(self, orginalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        let didAddMethod = class_addMethod(self, orginalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(orginalMethod!), method_getTypeEncoding(orginalMethod!))
        } else {
            method_exchangeImplementations(orginalMethod!, swizzledMethod!)
        }
        
    }
    
    @objc func swizzledAwakeFromNib() {
        swizzledAwakeFromNib()
        
        switch self {
        case let txtf as UITextField:
            txtf.text = txtf.text?.localiz()
            txtf.placeholder = txtf.placeholder?.localiz()
        case let lbl as UILabel:
            lbl.text = lbl.text?.localiz()
        case let btn as UIButton:
            btn.setTitle(btn.title(for: .normal)?.localiz(), for: .normal)
        default:
            break
        }
    }
}


// MARK: - Bundle extension

fileprivate extension Bundle {
    static func localize() {
        
        let orginalSelector = #selector(localizedString(forKey:value:table:))
        let swizzledSelector = #selector(customLocaLizedString(forKey:value:table:))
        
        let orginalMethod = class_getInstanceMethod(self, orginalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        let didAddMethod = class_addMethod(self, orginalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(orginalMethod!), method_getTypeEncoding(orginalMethod!))
        } else {
            method_exchangeImplementations(orginalMethod!, swizzledMethod!)
        }
    }
    
    @objc  private func customLocaLizedString(forKey key:String,value:String?,table:String?)->String{
        if let bundle = Bundle.main.path(forResource: LocalizationManager.sharedInstance.currentLanguage.rawValue, ofType: "lproj"),
            let langBundle = Bundle(path: bundle){
            return langBundle.customLocaLizedString(forKey: key, value: value, table: table)
        } else {
            return Bundle.main.customLocaLizedString(forKey: key, value: value, table: table)
        }
    }
}


// MARK: - String extension

public extension String {
    
    ///
    /// Localize the current string to the selected language
    ///
    /// - returns: The localized string
    ///
    func localiz(comment: String = "") -> String {
        guard let bundle = Bundle.main.path(forResource: LocalizationManager.sharedInstance.currentLanguage.rawValue, ofType: "lproj") else {
            return NSLocalizedString(self, comment: comment)
        }
        
        let langBundle = Bundle(path: bundle)
        return NSLocalizedString(self, tableName: nil, bundle: langBundle!, comment: comment)
    }
    
}


// MARK: - UIApplication extension

public extension UIApplication {
    // Get top view controller
    static var topViewController:UIViewController? {
        get {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            } else {
                return nil
            }
        }
    }
}

