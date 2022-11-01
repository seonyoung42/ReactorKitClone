//
//  GitHubSearchViewController.swift
//  GitHubSearchClone
//
//  Created by 장선영 on 2022/11/01.
//

import UIKit
import SafariServices

import ReactorKit
import RxSwift
import RxCocoa
import RxCocoaRuntime

class GitHubSearchViewController: UIViewController, StoryboardView {

    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.isActive = true
        navigationItem.searchController = searchController
    }
    
    func bind(reactor: GitHubSearchViewReactor) {
        searchController.searchBar.rx.text
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateQuery($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
