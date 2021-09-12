//
//  ViewController.swift
//  Store Search
//
//  Created by Halis  Kara on 19.08.2021.
//

import UIKit

class SearchViewController: UIViewController {
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var tableView: UITableView!
  var landscapeVC: LandscapeViewController?
  private let search = Search()
  
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    performSearch()
  }

  @IBOutlet weak var segmentedControl: UISegmentedControl!

  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.becomeFirstResponder()
    searchBar.delegate = self
    tableView.delegate = self
    tableView.dataSource = self
    tableView.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
    var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
    cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)

    cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
  }
  override func willTransition(to newCollection: UITraitCollection,with coordinator: UIViewControllerTransitionCoordinator ){
    super.willTransition(to: newCollection, with: coordinator)
    switch newCollection.verticalSizeClass {
    case .compact:
      showLandscape(with: coordinator)
    case .regular, .unspecified:
      hideLandscape(with: coordinator)
    @unknown default:
      break
    } }

  func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
    guard landscapeVC == nil else { return }
    landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
    if let controller = landscapeVC {
      controller.search = search
      controller.view.frame = view.bounds
      controller.view.alpha = 0
      view.addSubview(controller.view)
      addChild(controller)
      coordinator.animate { _ in
        controller.view.alpha = 1
        self.searchBar.resignFirstResponder()
      } completion: { _ in
        controller.didMove(toParent: self)
        if self.presentedViewController != nil {
          self.dismiss(animated: true, completion: nil)

        }
      }

    }
  }

  func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator){
    if let controller = landscapeVC {
      controller.willMove(toParent: nil)
      coordinator.animate { _ in
        controller.view.alpha = 0
        if self.presentedViewController != nil {
          self.dismiss(animated: true, completion: nil)
        }
      } completion: { _ in
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        self.landscapeVC = nil
      }

    }
  }
}

// MARK: - SearchBar Delegates

extension SearchViewController: UISearchBarDelegate {
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    performSearch()
  }


  func performSearch() {
    if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {

      search.performSearch(for: searchBar.text!, category: category) {
        success in
        if !success {
          self.showNetworkError()
        }
        self.tableView.reloadData()
      }
    }
    tableView.reloadData()
    self.landscapeVC?.searchResultsReceived()
    searchBar.resignFirstResponder()
  }

  func showNetworkError() {
    let alert = UIAlertController(title: "Whoops....",message:"There was an error accessing the iTunes Store." + "Please try again.", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}

// MARK: - TableView Delegates

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    performSegue(withIdentifier: "ShowDetail", sender: indexPath)
  }

  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    switch search.state {
    case .notSearchedYet, .loading, .noResults:
      return nil
    case .results:
      return indexPath
    }
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDetail" {
      if case .results(let list) = search.state {
        let detailViewController = segue.destination as! DetailViewController
        let indexPath = sender as! IndexPath
        let searchResult = list[indexPath.row]
        detailViewController.searchResult = searchResult
      }
    }
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch search.state {
    case .notSearchedYet:
      return 0
    case .loading:
      return 1
    case .noResults:
      return 1
    case .results(let list):
      return list.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch search.state {
    case .notSearchedYet:
      fatalError("Should never get here")
    case .loading:
      let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    case .noResults:
      return tableView.dequeueReusableCell(
        withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
        for: indexPath)
    case .results(let list):
      let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell,
                                               for: indexPath) as! SearchResultCell
      let searchResult = list[indexPath.row]
      cell.configure(for: searchResult)
      return cell
    }
  }
}


struct TableView {
  struct CellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
    static let loadingCell = "LoadingCell"

  }
}
