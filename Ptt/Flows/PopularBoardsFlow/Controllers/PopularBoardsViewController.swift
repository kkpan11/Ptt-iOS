//
//  PopularBoardsViewController.swift
//  Ptt
//
//  Created by marcus fu on 2021/1/7.
//  Copyright © 2021 Ptt. All rights reserved.
//

import UIKit

protocol PopularBoardsView: BaseView {
    var onBoardSelect: ((String) -> Void)? { get set }
}

class PopularBoardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PopularBoardsView {
    
    var onBoardSelect: ((String) -> Void)?
//    private lazy var resultsTableController = configureResultsTableController()
    private var allBoards : [String]? = nil
    private var boardListDict : [String: Any]? = nil
    
    lazy var viewModel: PopularBoardsViewModel = {
        let viewModel = PopularBoardsViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    
    lazy var tableview: UITableView = {
        let tableview = UITableView()
        tableview.register(PopularBoardsTableViewCell.self, forCellReuseIdentifier: PopularBoardsTableViewCell.cellIdentifier())
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.dataSource = self
        tableview.delegate = self
        tableview.backgroundColor = GlobalAppearance.backgroundColor
        
        if #available(iOS 13.0, *) {
        } else {
            tableview.indicatorStyle = .white
        }
        tableview.estimatedRowHeight = 80.0
        tableview.separatorStyle = .none
        tableview.keyboardDismissMode = .onDrag // to dismiss from search bar
        
        return tableview
    }()
    
//    lazy var searchController : UISearchController = {
//        // For if #available(iOS 11.0, *), no need to set searchController as property (local variable is fine).
//        let searchController = UISearchController(searchResultsController: resultsTableController)
////        searchController.delegate = self
//        searchController.searchResultsUpdater = self
//        searchController.searchBar.delegate = self
//        return searchController
//    }()
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableview.setEditing(editing, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initBinding()
        setConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.start()
    }
    
    func initView() {
        title = NSLocalizedString("Popular Boards", comment: "")
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        view.backgroundColor = GlobalAppearance.backgroundColor
        definesPresentationContext = true
        
//        if #available(iOS 13.0, *) {
//            searchController.searchBar.searchTextField.textColor = UIColor(named: "textColor-240-240-247")
//            // otherwise covered in GlobalAppearance
//        }
//        if #available(iOS 11.0, *) {
//            navigationItem.searchController = searchController
//            navigationItem.hidesSearchBarWhenScrolling = false
//        } else {
//            tableview.tableHeaderView = searchController.searchBar
//            searchController.searchBar.barStyle = .black
//            tableview.backgroundView = UIView() // See: https://stackoverflow.com/questions/31463381/background-color-for-uisearchcontroller-in-uitableview
//        }
    }
    
    func initBinding() {
        viewModel.popularBoards.addObserver(fireNow: false) { [weak self] (popularBoards) in
            self?.tableview.reloadData()
        }
    }
    
    func setConstraint() {
        view.addSubview(tableview)
        NSLayoutConstraint(item: tableview, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: tableview, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint(item: tableview, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: tableview, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        }
        else {
            NSLayoutConstraint(item: tableview, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: tableview, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.popularBoards.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PopularBoardsTableViewCell.cellIdentifier()) as! PopularBoardsTableViewCell
        cell.configure(viewModel, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if index < viewModel.popularBoards.value.count {
            onBoardSelect?(viewModel.popularBoards.value[index].brdname)
        }
    }
    
//    private func configureResultsTableController() -> ResultsTableController {
//        let controller = ResultsTableController(style: .plain)
//        controller.onBoardSelect = onBoardSelect
//        return controller
//    }
}

extension PopularBoardsViewController: PopularBoardsViewModelDelegate {
    func showErrorAlert(errorMessage: String) {
        Dispatch.DispatchQueue.main.async {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: errorMessage, preferredStyle: .alert)
            let confirm = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: nil)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UITableViewCell {
    static func cellIdentifier() -> String {
        return String(describing: self)
    }
}
//
//extension PopularBoardsViewController: UISearchBarDelegate {
//
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        if boardListDict != nil {
//            return
//        }
//        resultsTableController.activityIndicator.startAnimating()
//        var array = [String]()
//        APIClient.shared.getBoardList { [weak self] (result) in
//            guard let weakSelf = self else { return }
//            switch result {
//            case .failure(error: let error):
//                DispatchQueue.main.async {
//                    weakSelf.resultsTableController.activityIndicator.stopAnimating()
//                    weakSelf.searchController.isActive = false
//                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.message, preferredStyle: .alert)
//                    let confirm = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: nil)
//                    alert.addAction(confirm)
//                    weakSelf.present(alert, animated: true, completion: nil)
//                }
//            case .success(data: let data):
//                if let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    for (key, _) in dict {
//                        array.append(key)
//                    }
//                    weakSelf.boardListDict = dict
//                }
//                weakSelf.allBoards = array
//                DispatchQueue.main.async {
//                    weakSelf.resultsTableController.activityIndicator.stopAnimating()
//                    // Update UI for current typed search text
//                    if let searchText = searchBar.text, searchText.count > 0 && weakSelf.resultsTableController.filteredBoards.count == 0 {
//                        weakSelf.updateSearchResults(for: weakSelf.searchController)
//                    }
//                }
//            }
//        }
//    }
//}

//extension PopularBoardsViewController: UISearchResultsUpdating {
//
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let searchText = searchController.searchBar.text, let allBoards = self.allBoards, let boardListDict = self.boardListDict else {
//            return
//        }
//        resultsTableController.activityIndicator.startAnimating()
//        // Note: Using GCD here is imperfect but elegant. We'll have Search API later.
//        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
//            guard let weakSelf = self else { return }
//            let filteredBoards = allBoards.filter { $0.localizedCaseInsensitiveContains(searchText) }
//            var result = [Board]()
//            for filteredBoard in filteredBoards {
//                if let boardDesc = boardListDict[filteredBoard] as? [String: Any], let desc = boardDesc["中文敘述"] as? String {
//                    result.append(Board(name: filteredBoard, title: desc))
//                }
//            }
//            weakSelf.resultsTableController.filteredBoards = result
//            DispatchQueue.main.async {
//                // Only update UI for the matching result
//                if searchText == searchController.searchBar.text {
//                    weakSelf.resultsTableController.activityIndicator.stopAnimating()
//                    weakSelf.resultsTableController.tableView.reloadData()
//                }
//            }
//        }
//    }
//}

// MARK: -

//private final class ResultsTableController : UITableViewController, FavoriteView {
//
//    var onBoardSelect: ((String) -> Void)?
//    var filteredBoards = [Board]()
//    let activityIndicator = UIActivityIndicatorView()
//
////    private let cellReuseIdentifier = "FavoriteCell"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.backgroundColor = GlobalAppearance.backgroundColor
//        if #available(iOS 13.0, *) {
//        } else {
//            tableView.indicatorStyle = .white
//        }
//        tableView.estimatedRowHeight = 80.0
//        tableView.separatorStyle = .none
//        tableView.keyboardDismissMode = .onDrag // to dismiss from search bar
//        tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
//
//        activityIndicator.color = .lightGray
//        tableView.ptt_add(subviews: [activityIndicator])
//        NSLayoutConstraint.activate([
//            activityIndicator.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 20.0),
//            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
//        ])
//    }
//
//    @objc private func addToFavorite(sender: FavoriteButton) {
//        switch sender.isSelected {
//        case false:
//            sender.isSelected = true
//            if let boardToAdded = sender.board {
//                Favorite.boards.append(boardToAdded)
//            }
//        case true:
//            sender.isSelected = false
//            if let boardToRemoved = sender.board,
//                let indexToRemoved = Favorite.boards.firstIndex(where: {$0.name == boardToRemoved.name}) {
//                Favorite.boards.remove(at: indexToRemoved)
//            }
//        }
//        NotificationCenter.default.post(name: NSNotification.Name("didUpdateFavoriteBoards"), object: nil)
//    }
//
//    // MARK: UITableViewDataSource
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredBoards.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! FavoriteTableViewCell
//        cell.favoriteButton.addTarget(self, action: #selector(addToFavorite), for: .touchUpInside)
//        let index = indexPath.row
//        if index < filteredBoards.count {
//            cell.boardName = filteredBoards[index].name
//            cell.boardTitle = filteredBoards[index].title
//            cell.favoriteButton.board = filteredBoards[index]
//        }
//        return cell
//
////        let cell = tableView.dequeueReusableCell(withIdentifier: PopularBoardsTableViewCell.cellIdentifier()) as! PopularBoardsTableViewCell
////        cell.configure(viewModel, index: indexPath.row)
////        return cell
//    }
//
//    // MARK: UITableViewDelegate
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let index = indexPath.row
//        if index < filteredBoards.count {
//            onBoardSelect?(filteredBoards[index].name)
//        }
//    }
//}
