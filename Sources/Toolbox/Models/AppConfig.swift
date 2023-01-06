//
//  File.swift
//  
//
//  Created  on 09.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

var appConfig: App.StaticConfig!

public enum App {

    public struct StaticConfig {
        public typealias CustomErrorPresentation = (Error) -> (title: String, message: String)?
        public typealias AuthRequestHeaders = (inout [String: String]) -> Void
        public typealias CustomErrorMapper = (Error, Data) -> Error?
        
        public init(loaderImage: UIImage = UIImage(named: "spring_indicator")!,
                    customError: @escaping CustomErrorPresentation = { _ in nil },
                    debugShakeCommands: [NamedCommand] = [],
                    reduxActionDispatched: CommandWith<String> = .nop,
                    network: Network?) {
            self.loaderImage = loaderImage
            self.customError = customError
            self.debugShakeCommands = debugShakeCommands
            self.reduxActionDispatched = reduxActionDispatched
            self.network = network
        }
        
        let loaderImage: UIImage
        let customError: CustomErrorPresentation
        let debugShakeCommands: [NamedCommand]
        
        ///can be used for crashlytics logging
        let reduxActionDispatched: CommandWith<String>
        
        let network: Network?
        
        public struct Network {
            public init(
                baseNetworkURL: URLConvertible,
                networkEncoder: JSONEncoder = .init(),
                networkDecoder: JSONDecoder = .init(),
                authRequestHeaders: AuthRequestHeaders? = nil,
                customErrorMapper: CustomErrorMapper? = nil) {
                    self.baseNetworkURL = baseNetworkURL
                    self.networkEncoder = networkEncoder
                    self.networkDecoder = networkDecoder
                    self.customErrorMapper = customErrorMapper
                    self.authRequestHeaders = authRequestHeaders
                }
            
            let baseNetworkURL: URLConvertible
            let networkEncoder: JSONEncoder
            let networkDecoder: JSONDecoder
            let customErrorMapper: CustomErrorMapper?
            let authRequestHeaders: AuthRequestHeaders?
            
        }
        
    }
    
    public class Store<T: AppStateT> {
        
        public init(appStateSettingsKey: String) {
            diskStore = Setting(key: appStateSettingsKey,
                                initialValue: .default)
            memmoryStore = .init(value: diskStore.value)
            
            let _ =
            Observable.merge([
                NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification),
                NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification),
            ])
                .subscribe(onNext: { (_) in
                    self.diskStore.value = self.memmoryStore.value
                })
            
            if RunScheme.debug {
                ///debugger termination might not trigger any of AppState saving notifications.
                _ =
                memmoryStore.subscribe(onNext: { x in
                    self.diskStore.value = x
                })
            }
        }
        
        var diskStore: Setting<T>
        let memmoryStore: BehaviorRelay<T>
        
        var actions: [(String, Date, String?)] = []

        private let queue = DispatchQueue(label: "AppState mutation queue")
        
        public func dispatch<A: ReduxAction>
        (action: A, actor: CustomStringConvertible? = nil) where A.T == T {
            
            queue.async { [unowned self] in
                
                var dscr = "\(action)"
                if let x = actor?.description {
                    dscr.append(" by \(x) actor")
                }
                appConfig.reduxActionDispatched(with: dscr)
                actions.append((dscr, Date(), actor?.description))
                
                var newState = memmoryStore.value
                action.apply(to: &newState)
                
                if newState != memmoryStore.value {
                    memmoryStore.accept(newState)
                }
                
            }
            
        }

    }
    
    
}

extension App.Store {
    
    public var slice: T {
        return memmoryStore.value
    }

    public var changes: Driver<T> {
        return memmoryStore.asDriver()
    }
    
    public func logStateMutations() -> String {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm:ss"
        var str = ""
        queue.sync {
            
            for (index, (action, date, actor)) in actions.enumerated() {

                let dateStr = dateFormatterGet.string(from: date)

                str.append("\nMutation #\(index+1) at \(dateStr)\nAction: \(action)\n")
                if let x = actor {
                    str.append("By \(x)\n")
                }

            }

            actions = []
            
        }
        
        return str
    }
}

public extension App {
    static func setup<T: AppStateT>(
        _ s: App.StaticConfig,
        _ d: App.Store<T>)
    -> App.Store<T> {
        appConfig = s
        
        UIApplication.shared.applicationSupportsShakeToEdit = s.debugShakeCommands.count > 0
        if RunScheme.debug && s.network != nil {
            NetworkLoggerBridge.enableNetworkingLogging()
        }
        
        return d
    }
}

