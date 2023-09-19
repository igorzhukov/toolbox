//  SmartStackView.swift
//  Created  on 30.10.2022.

import UIKit
import RxCocoa

//public struct StackDiff {
//
//    public let removed: [any StackableProp]
//    public let added: [any StackableProp]
//
//    public init(from: [any StackableProp], to: [any StackableProp]) {
//
//        let fromMap = Dictionary(uniqueKeysWithValues: from.map { ($0.id, $0) })
//        let toMap   = Dictionary(uniqueKeysWithValues: to.map { ($0.id, $0) })
//
//        let fromSet = Set(fromMap.keys)
//        let toSet = Set(toMap.keys)
//
//        removed = fromSet.subtracting(toSet).map { fromMap[$0]! }
//        added = toSet.subtracting(fromSet).map { toMap[$0]! }
//
//    }
//
//}

public protocol StackableProp {
    var nibView: UIView { get }
}

public protocol StackableView {
    associatedtype T: StackableProp
    var props: T { get set }
}

@resultBuilder
public struct StackBuilder {
    
    public static func buildExpression(_ expression: (any StackableProp)?) -> [any StackableProp] {
        return expression.map { [$0] } ?? []
    }
    
    static func buildBlock(_ components: [any StackableProp]...) -> [any StackableProp] {
        components.flatMap { $0 }
    }
    
    static func buildEither(first component: [StackableProp]) -> [StackableProp] {
        component
    }
    
    static func buildEither(second component: [StackableProp]) -> [StackableProp] {
        component
    }
    
    static func buildOptional(_ component: [StackableProp]?) -> [StackableProp] {
        component ?? []
    }
    
}

public class SmartStackView: UIStackView, StackableView {

    public struct Props {
        
        public var spacing: CGFloat = 8
        public var margins: CGFloat = 0
        public var axis: NSLayoutConstraint.Axis = .vertical
        public let keyboardJump: Bool
        public let stack: [any StackableProp]
        
        public init(spacing: CGFloat = 8, margins: CGFloat = 0,
                    axis: NSLayoutConstraint.Axis = .vertical, keyboardJump: Bool = false,
                    @StackBuilder stack: () -> [any StackableProp]) {
            self.spacing = spacing
            self.margins = margins
            self.axis = axis
            self.keyboardJump = keyboardJump
            self.stack = stack()
        }
        
        public static var initial: Props { .init(stack: { } ) }
        
    }; public var props: Props = .initial {
        didSet {
            render(oldValue: oldValue)
        }
    }
    
    func render(oldValue: Props) {
        
        self.spacing = props.spacing
        axis = props.axis
        layoutMargins = .init(top: 0, left: props.margins,
                              bottom: 0, right: props.margins)
        
        func superMap<T: StackableView, U: StackableProp>( view: inout T, prop: U) -> Bool {
            
            if let p = prop as? T.T {
                view.props = p
                return true
            } else {
                return false
            }
        }
        
        var binded = false
        for (view, prop) in zip(arrangedSubviews, props.stack) {
            guard var x = view as? any StackableView else {
                binded = false
                break;
            }
            
            binded = superMap(view: &x, prop: prop)
            if !binded { break; }
        }
        
        if binded == false {
            arrangedSubviews.forEach { $0.removeFromSuperview() }
            props.stack
                .map(\.nibView)
                .forEach { x in
                    addArrangedSubview(x)
                }
        }
        
    }
    
    public init(props: Props) {
        super.init(frame: .zero)
        self.props = props
        
        setUp()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        setUp()
    }
    
    func setUp() {
        
        isLayoutMarginsRelativeArrangement = true
        
        rx.keyboadChange
            .map(\.height)
            .startWith(0)
            .pairwise()
            .map { (prev, current) in
                (current, current - prev)
            }
            .bind { [unowned self] (h, dh) in
                guard self.props.keyboardJump else { return; }
                
                self.layoutMargins.bottom = h
                if let sv = superview as? UIScrollView,
                    dh > 0 {
                    var co = sv.contentOffset
                    co.y += dh
                    sv.setContentOffset(co, animated: true)
                }
            }
            .disposed(by: rx.disposeBag)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismiss)))
        
        render( oldValue: .initial )
    }
    
    @objc func dismiss() {
        endEditing(true)
    }
    
}

extension SmartStackView.Props: StackableProp {
    public var nibView: UIView {
        let view = SmartStackView(props: self)
        view.props = self
        return view
    }
}
