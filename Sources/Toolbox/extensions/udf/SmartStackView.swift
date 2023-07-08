//  SmartStackView.swift
//  Created  on 30.10.2022.

import UIKit
import RxCocoa

public protocol StackableProp {
    var nibView: UIView { get }
}

public class SmartStackView: UIStackView {

    public struct Props {
        
        public var spacing: CGFloat = 8
        public var margins: CGFloat = 0
        public let stack: [StackableProp]
        
        public init(spacing: CGFloat = 8, stack: [StackableProp]) {
            self.spacing = spacing
            self.stack = stack
        }
        
        public static var initial: Props { .init(stack: []) }
        
    }; public var props: Props = .initial {
        didSet {
            render()
        }
    }
    
    func render() {
        
        self.spacing = props.spacing
        
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        props.stack
            .map(\.nibView)
            .forEach { x in
                x.layoutMargins.left = props.margins
                x.layoutMargins.right = props.margins
                addArrangedSubview(x)
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
        
        render()
    }
    
    @objc func dismiss() {
        endEditing(true)
    }
    
}

extension SmartStackView.Props: StackableProp {
    public var nibView: UIView {
        let view = SmartStackView(props: self)
        return view
    }
}
