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

public protocol XXSegmentedDelegate: class {
    var segmentedScrollView: UIScrollView { get }
}

public class XXSegmentedVC: UIViewController {
    
    public init(items: [XXSegmentedItem], globalScroll: Bool = true, segmentedHeight:CGFloat = 50) {
        super.init(nibName: nil, bundle: nil)
        self.globalScroll = globalScroll
        self.segmentedHeight = segmentedHeight
        segmentedViewControllers = items.map {
            let vc = $0.vc
            if globalScroll, let delegate = vc as? XXSegmentedDelegate {
                let scrollView = delegate.segmentedScrollView
                scrollView.clipsToBounds = false
                scrollView.isScrollEnabled = false
                _ = scrollView.rx.observe(CGSize.self, "contentSize")
                    .distinctUntilChanged()
                    .subscribe(onNext: { [unowned scrollView] (size) in
                        scrollView.snp.updateConstraints { (make) in
                            make.height.greaterThanOrEqualTo(size!.height)
                        }
                    })
            }
            return vc
        }
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
    
    
    private(set) var globalScroll = true
    private(set) var isSegmentedOnTop = true
    private(set) var segmentedHeight:CGFloat = 50
    
    public private(set) lazy var scrollView = UIScrollView()
    public lazy var headerView = UIView()
    
    private lazy var segmentedBtns: [UIButton] = []
    private lazy var segmentedView = UIView()
    private lazy var segmentedUnderView = UIView()
    
    private lazy var contentView = UIView()
    
    public var didSelect: ((Int) -> Void)?
    public var selectIndex: Int = 0 {
        didSet {
            didSelect?(selectIndex)
            segmentedBtns[oldValue].isSelected = false
            segmentedBtns[selectIndex].isSelected = true
            segmentedUnderView.snp.remakeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.width.equalTo(30)
                make.height.equalTo(1)
                make.centerX.equalTo(segmentedBtns[selectIndex].snp.centerX)
            }
            
            if selectController != nil {
                UIView.animate(withDuration: 0.3) {
                    self.segmentedView.layoutIfNeeded()
                }
            }
            
            selectController = segmentedViewControllers[selectIndex]
            
            if globalScroll {
                cacheOffsetY[oldValue] = scrollView.contentOffset.y
                let top = scrollView.scrollIndicatorInsets.top - segmentedHeight
                // 偏移大于顶部固定条时 还原偏移位置
                if scrollView.contentOffset.y >= top {
                    var offsetY = cacheOffsetY[selectIndex]
                    if offsetY < top {
                        offsetY = top
                    }
                    scrollView.contentOffset = CGPoint(x: 0, y: offsetY)
                }
            }
        }
    }
    
    weak private var delegate: XXSegmentedDelegate?
    private var selectController: UIViewController? {
        didSet {
            if let oldValue = oldValue {
                oldValue.removeFromParentViewController()
                oldValue.view.removeFromSuperview()
            }
            guard let selectController = selectController else {
                return
            }
            
            self.addChildViewController(selectController)
            self.contentView.addSubview(selectController.view)
            selectController.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            if globalScroll {
                delegate = selectController as? XXSegmentedDelegate
                if delegate != nil, delegate!.segmentedScrollView.mj_header != nil {
                    scrollView.delegate = self
                }else {
                    scrollView.delegate = nil
                }
            }
        }
    }
    
    private lazy var cacheOffsetY = [CGFloat](repeating: 0, count: segmentedViewControllers.count)
    public private(set) var segmentedViewControllers: [UIViewController] = [] {
        didSet {
            selectController = segmentedViewControllers[selectIndex]
        }
    }
    
    var topConstraint: NSLayoutConstraint?
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.width.height.equalToSuperview()
        }
        
        scrollView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            if self.globalScroll {
                self.topConstraint = NSLayoutConstraint(item: headerView,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem: headerView.superview,
                                                   attribute: .top,
                                                   multiplier: 1,
                                                   constant: 0)
                scrollView.addConstraint(topConstraint!)
            }else {
                make.top.equalToSuperview()
            }
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(0)
            make.width.equalTo(self.view)
        }
        
        if globalScroll {
            _ = headerView.rx.observe(CGRect.self, "bounds")
                .subscribe(onNext: { [unowned self] (bounds) in
                    let top = bounds!.size.height + CGFloat(self.segmentedHeight)
                    self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
                })
        }
        
        segmentedView.backgroundColor = .white
        scrollView.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(headerView.snp.bottom)
            if self.isSegmentedOnTop {
                // 将 segmentedView 固定在顶部的约束
                make.top.greaterThanOrEqualTo(self.view)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(segmentedHeight)
            make.width.equalTo(self.view)
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
        
        let equalHeaderView = UIView()
        equalHeaderView.isHidden = true
        scrollView.addSubview(equalHeaderView)
        equalHeaderView.snp.makeConstraints { (make) in
            make.height.equalTo(headerView)
            make.top.left.right.equalToSuperview()
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(equalHeaderView.snp.bottom).offset(segmentedHeight)
            make.left.right.width.equalToSuperview()
            if self.globalScroll {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.greaterThanOrEqualTo(self.view.snp.bottom)
            }
        }
        
        scrollView.sendSubview(toBack: contentView)
        
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
        let subScrollView = delegate!.segmentedScrollView
        if scrollView.contentOffset.y < -54 && !subScrollView.mj_header.isRefreshing {
            subScrollView.mj_header.beginRefreshing()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        if offsetY <= 0 {
            topConstraint?.constant = offsetY
            
            let subScrollView = delegate!.segmentedScrollView
            if !subScrollView.mj_header.isRefreshing {
                subScrollView.contentOffset = CGPoint(x: 0, y: offsetY)
            }
        }
    }
}
