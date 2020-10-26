//
//  ViewController.swift
//  ZZScollViewDemo
//
//  Created by CZZ on 2020/10/26.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.items = [self.view1Item,
                                  self.view2Item,
                                  self.view3Item,
                                  self.view4Item,
                                  self.tableViewItem,
                                  self.webItem]

        self.webView.load(URLRequest(url: URL(string: "https://www.baidu.com")!))
    }

    @IBOutlet weak var contentView: ZZScrollView!

    lazy var view1Item = ZZScrollView.Item(view: view1,
                                           inset: UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 10),
                                           minHeight: 50,
                                           fixedWidth: 200)

    lazy var view2Item = ZZScrollView.Item(view: view2,
                                           inset: UIEdgeInsets(top: 10, left: 20, bottom: 15, right: 10),
                                           minHeight: 200)

    lazy var view3Item = ZZScrollView.Item(view: view3)

    lazy var view4Item = ZZScrollView.Item(view: view4,
                                           inset: UIEdgeInsets(top: 0, left: 30, bottom: 15, right: 10),
                                           minHeight: 200)

    lazy var tableViewItem = ZZScrollView.Item(view: self.tableview)

    lazy var webItem = ZZScrollView.Item(view: self.webView)

    lazy var view1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
        return view
    }()

    lazy var view2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        view.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
        return view
    }()

    lazy var view3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.yellow
        view.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
        return view
    }()

    lazy var view4: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.green
        view.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
        return view
    }()

    lazy var tableview: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        return view
    }()

    lazy var webView = WKWebView()

}

//MARK: - TableView
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let identifier = "ViewController_Id"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        cell?.textLabel?.text = "this is table and indexPath is \(indexPath)"
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 44
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0.001
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0.001
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        return UIView()
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        return UIView()
    }
}
