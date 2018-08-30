//
//  TableVeiwVC.swift
//  TestDemo
//
//  Created by snow on 2018/8/30.
//  Copyright © 2018 snow. All rights reserved.
//

import UIKit
import RxCocoa

class TableVeiwVC: UIViewController {

    lazy var tableView = { () -> UITableView in
        let tableView = UITableView(frame: .zero, style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "headerView")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var count = 0
    init(count: Int) {
        super.init(nibName: nil, bundle: nil)
        self.count = count
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            debugPrint(self.tableView.contentSize)
        }
        
        tableView.isScrollEnabled = false
        tableView.snp.makeConstraints { (make) in
            make.height.equalTo(0).priority(.high)
        }
        tableView.rx.observe(CGSize.self, "contentSize")
            .distinctUntilChanged()
            .subscribe(onNext: { (size) in
                self.tableView.snp.updateConstraints { (make) in
                    make.height.equalTo(size!.height).priority(.high)
                }
            })
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}

extension TableVeiwVC: XXSegmentedDelegate {
    var segmentedScrollView: UIScrollView {
        return tableView
    }
}

extension TableVeiwVC: UITableViewDelegate {
    
}

extension TableVeiwVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = "\(indexPath.section).\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView")!
        headerView.textLabel?.text = "section:\(section)"
        return headerView
    }
    
}
