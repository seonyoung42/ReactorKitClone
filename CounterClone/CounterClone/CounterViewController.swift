//
//  CounterViewController.swift
//  CounterClone
//
//  Created by 장선영 on 2022/11/05.
//

import UIKit
import ReactorKit
import RxCocoa

class CounterViewController: UIViewController, StoryboardView {
    
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var disposeBag: DisposeBag = DisposeBag()

    
    func bind(reactor: CounterViewModel) {
        
        // MARK: View -> ViewModel
        increaseButton.rx.tap
            .map { Reactor.Action.tapIncreaseButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        decreaseButton.rx.tap
            .map { Reactor.Action.tapDecreaseButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: ViewModel -> View
        reactor.state.map { $0.count }
            .distinctUntilChanged()
            .map { $0.description }
            .bind(to: countLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.activityView.isHidden = false
                    self?.activityView.startAnimating()
                } else {
                    self?.activityView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.alertMessage }
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] message in
                let activityVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "ok", style: .default)
                activityVC.addAction(action)
                self?.present(activityVC, animated: false)
            })
            .disposed(by: disposeBag)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.isHidden = true
    }
}
