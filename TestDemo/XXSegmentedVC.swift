//
//  XXSegmentedVC.swift
//  TestDemo
//
//  Created by snow on 2018/8/30.
//  Copyright © 2018 snow. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

public struct XXSegmentedItem {
    let title: String
    let vc: UIViewController
    init(title: String, vc: UIViewController) {
        self.title = title
        self.vc = vc
    }
}

public protocol XXSegmentedDelegate {
    var segmentedScrollView: UIScrollView { get }
}

public class XXSegmentedVC: UIViewController {
    
    public init(items: [XXSegmentedItem], autoHeight: Bool = true, segmentedHeight:Int = 50) {
        super.init(nibName: nil, bundle: nil)
        self.autoHeight = autoHeight
        self.segmentedHeight = segmentedHeight
        segmentedViewControllers = items.map{ $0.vc }
        segmentedBtns = items.map({ (item) -> UIButton in
            let button = UIButton(type: .custom)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitleColor(normalColor, for: .normal)
            button.setTitleColor(selectedColor, for: .selected)
            button.setTitle(item.title, for: .normal)
            button.addTarget(self, action: #selector(segmentedAction(button:)), for: .touchDown)
            return button
        })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var normalColor = UIColor(red: CGFloat(0x1F) / 255, green: CGFloat(0x3F) / 255, blue: CGFloat(0x58) / 255, alpha: 1) {
        didSet {
            segmentedBtns.forEach { (button) in
                button.setTitleColor(normalColor, for: .normal)
            }
        }
    }
    public var selectedColor = UIColor(red: CGFloat(0x49) / 255, green: CGFloat(0xB5) / 255, blue: 1, alpha: 1) {
        didSet {
            segmentedBtns.forEach { (button) in
                button.setTitleColor(selectedColor, for: .selected)
            }
        }
    }
    
    
    private(set) var autoHeight = true
    private(set) var isSegmentedOnTop = true
    private(set) var segmentedHeight = 50
    
    private lazy var scrollView = UIScrollView()
    public lazy var headerView = UIView()
    
    private lazy var segmentedBtns: [UIButton] = []
    private lazy var segmentedView = UIView()
    private lazy var segmentedUnderView = UIView()
    
    private lazy var contentView = UIView()
    
    public var selectIndex: Int = 0 {
        didSet {
            let animate = selectController != nil
            selectController = segmentedViewControllers[selectIndex]
            segmentedBtns[oldValue].isSelected = false
            segmentedBtns[selectIndex].isSelected = true
            segmentedUnderView.snp.remakeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.width.equalTo(30)
                make.height.equalTo(1)
                make.centerX.equalTo(segmentedBtns[selectIndex].snp.centerX)
            }
            if animate {
                UIView.animate(withDuration: 0.3) {
                    self.segmentedView.layoutIfNeeded()
                }
            }
        }
    }
    private var selectController: UIViewController? {
        didSet {
            if let selectController = selectController {
                self.addChildViewController(selectController)
                self.contentView.addSubview(selectController.view)
                selectController.view.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
            oldValue?.removeFromParentViewController()
            oldValue?.view.removeFromSuperview()
        }
    }
    private var segmentedViewControllers: [UIViewController] = [] {
        didSet {
            selectController = segmentedViewControllers[selectIndex]
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.width.height.equalToSuperview()
        }
        
        scrollView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(0)
            make.width.equalTo(self.view)
//            let topConstraint0 = make.top.equalTo(self.view).constraint
            let topConstraint1 = make.top.equalToSuperview().constraint
            
//            _ = self.scrollView.rx.contentOffset
//                .map({ (contentOffset) -> Bool in
//                    return contentOffset.y > 0
//                })
//                .distinctUntilChanged()
//                .subscribe(onNext: { (isOnTop) in
//                    debugPrint(isOnTop)
//                    if isOnTop {
//                        topConstraint0.deactivate()
//                        topConstraint1.activate()
//                    }else {
//                        topConstraint1.deactivate()
//                        topConstraint0.activate()
//                    }
//                })
        }
        
        segmentedView.backgroundColor = .white
        scrollView.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(headerView.snp.bottom)
            if self.isSegmentedOnTop {
                // 将 segmentedView 固定在顶部的约束
                make.top.greaterThanOrEqualTo(self.view.snp.top)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(segmentedHeight)
            make.width.equalTo(self.view.snp.width)
        }
        let lineView = UIView()
        lineView.backgroundColor = UIColor(red: CGFloat(0xE8) / 255, green: CGFloat(0xE8) / 255, blue: CGFloat(0xE8) / 255, alpha: 1)
        segmentedView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1 / UIScreen.main.scale)
        }
        
        segmentedUnderView.backgroundColor = selectedColor
        segmentedView.addSubview(segmentedUnderView)
        
        var lastView: UIView?
        for button in self.segmentedBtns {
            self.segmentedView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.width.equalToSuperview().dividedBy(self.segmentedBtns.count)
                make.top.bottom.equalTo(0)
                if lastView == nil {
                    make.left.equalToSuperview()
                }else {
                    make.left.equalTo(lastView!.snp.right)
                }
            }
            lastView = button
        }
        lastView?.snp.makeConstraints({ (make) in
            make.right.equalToSuperview()
        })

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(segmentedHeight)
            make.left.right.width.equalToSuperview()
            if self.autoHeight {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.greaterThanOrEqualTo(self.view.snp.bottom)
            }
        }
        
        scrollView.bringSubview(toFront: segmentedView)
        
        if self.selectController == nil {
            self.selectIndex = 0
        }
    }
    
    @objc private func segmentedAction(button: UIButton) {
        let index = segmentedBtns.index(of: button)!
        if selectIndex == index {
            return
        }
        selectIndex = index
    }
    
}

extension XXSegmentedVC: UIScrollViewDelegate {
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let delegate = selectController! as? XXSegmentedDelegate else {
            return
        }
        let otherScrollView = delegate.segmentedScrollView
        if scrollView.contentOffset.y < -65 {
            otherScrollView.mj_header.beginRefreshing()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let delegate = selectController! as? XXSegmentedDelegate else {
            return
        }
        let otherScrollView = delegate.segmentedScrollView
        
        let offsetY = scrollView.contentOffset.y
        if offsetY <= 0 {
//            debugPrint(offsetY)
            if !otherScrollView.mj_header.isRefreshing {
                otherScrollView.contentOffset = CGPoint(x: otherScrollView.contentOffset.x, y: offsetY)
            }
        }
    }
}
