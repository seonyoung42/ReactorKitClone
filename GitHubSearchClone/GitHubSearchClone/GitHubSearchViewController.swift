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
        
        // MARK: View -> Reactor
        
        // 서치바의 텍스트 전달하여 검색 API의 query로 사용
        searchController.searchBar.rx.text
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateQuery($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // tableView의 contentoffSet + frame.height 가 contentSize - 100 보다 큰 경우 다음 페이지 로드
        tableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let self = self else { return false }
                guard self.tableView.frame.height > 0 else { return false }
                return offset.y + self.tableView.frame.height >= self.tableView.contentSize.height - 100
            }
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // View
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self, weak reactor] indexPath in
                guard let self = self else { return }
                self.view.endEditing(true)
                self.tableView.deselectRow(at: indexPath, animated: false)
                
                guard let repo = reactor?.currentState.repos[indexPath.row] else { return }
                guard let url = URL(string: "https://github.com/\(repo)") else { return }
                let vc = SFSafariViewController(url: url)
                self.searchController.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
