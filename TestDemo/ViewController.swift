//
//  ViewController.swift
//  TestDemo
//
//  Created by snow on 2018/8/30.
//  Copyright © 2018 snow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let segmentedVC = XXSegmentedVC(items: [XXSegmentedItem(title: "test0", vc: TableVeiwVC(count: 5)),
                                                XXSegmentedItem(title: "test1", vc: TableVeiwVC(count: 10)),
                                                XXSegmentedItem(title: "test2", vc: TableVeiwVC(count: 20)),
                                                XXSegmentedItem(title: "test3", vc: TableVeiwVC(count: 30))],
                                        autoHeight: true)
        
        segmentedVC.view.backgroundColor = .red
        self.addChildViewController(segmentedVC)
        self.view.addSubview(segmentedVC.view)
        segmentedVC.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let label = UILabel()
        segmentedVC.headerView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        label.numberOfLines = 0
        label.text = "系统自带天气的结构其实不复杂啊比这个简单，一个普通的 tableview 可以实现，初始状态设置一个 contentInset 而已，顶部的城市和温度根据 tableview 的 offset 变化而变化，横向滑动的只需一个 section 就可以了"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

