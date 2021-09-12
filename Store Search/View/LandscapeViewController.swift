//
//  LandscapeViewController.swift
//  Store Search
//
//  Created by Halis  Kara on 10.09.2021.
//

import UIKit

class LandscapeViewController: UIViewController {
  @IBOutlet var scrollView: UIScrollView!
  @IBOutlet var pageControl: UIPageControl!
  var search: Search!
  private var firstTime = true
  private var downloads = [URLSessionDownloadTask]()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.removeConstraints(view.constraints)
    view.translatesAutoresizingMaskIntoConstraints = true
    pageControl.removeConstraints(pageControl.constraints)
    pageControl.translatesAutoresizingMaskIntoConstraints = true
    scrollView.removeConstraints(scrollView.constraints)
    scrollView.translatesAutoresizingMaskIntoConstraints = true
    pageControl.numberOfPages = 0
  }
  deinit {
    for task in downloads {
      task.cancel()
    }
  }
  @objc func buttonPressed(_ sender: UIButton) {
    performSegue(withIdentifier: "ShowDetail", sender: sender)

  }
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let safeFrame = view.safeAreaLayoutGuide.layoutFrame
    scrollView.frame = safeFrame
    pageControl.frame = CGRect(
      x: safeFrame.origin.x,
      y: safeFrame.size.height - pageControl.frame.size.height,
      width: safeFrame.size.width,
      height: pageControl.frame.size.height)
    if firstTime {
      firstTime = false
      switch search.state {
      case .notSearchedYet, .loading, .noResults:
        break
      case .loading:
        showSpinner()
      case .noResults:
        showNothingFoundLabel()
      case .results(let list):
        tileButtons(list)
      }
    }
  }
  private func showSpinner() {
    let spinner = UIActivityIndicatorView(style: .large)
    spinner.center = CGPoint(
      x: scrollView.bounds.midX + 0.5,
      y: scrollView.bounds.midY + 0.5)
    spinner.tag = 1000
    view.addSubview(spinner)
    spinner.startAnimating()
  }
  // MARK: - Helper Methods
  func searchResultsReceived() {
    hideSpinner()
    switch search.state {
    case .notSearchedYet, .loading:
      break
    case .noResults:
      showNothingFoundLabel()
    case .results(let list):
      tileButtons(list)
    }
  }
  private func hideSpinner() {
    view.viewWithTag(1000)?.removeFromSuperview()
  }
  private func showNothingFoundLabel() {
    let label = UILabel(frame: CGRect.zero)
    label.text = "Nothing Found"
    label.textColor = UIColor.label
    label.backgroundColor = UIColor.clear
    label.sizeToFit()
    var rect = label.frame
    rect.size.width = ceil(rect.size.width / 2) * 2
    rect.size.height = ceil(rect.size.height / 2) * 2
    label.frame = rect
    label.center = CGPoint(
      x: scrollView.bounds.midX,
      y: scrollView.bounds.midY)
    view.addSubview(label)
  }

  func tileButtons(_ searchResults: [SearchResult]) {
    let itemWidth: CGFloat = 94
    let itemHeight: CGFloat = 88
    var columnsPerPage = 0
    var rowsPerPage = 0
    var marginX: CGFloat = 0
    var marginY: CGFloat = 0
    let viewWidth = scrollView.bounds.size.width
    let viewHeight = scrollView.bounds.size.height
    // 1
    columnsPerPage = Int(viewWidth / itemWidth)
    rowsPerPage = Int(viewHeight / itemHeight)
    // 2
    marginX = (viewWidth - (CGFloat(columnsPerPage) * itemWidth)) * 0.5
    marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) * 0.5
    let buttonWidth: CGFloat = 82
    let buttonHeight: CGFloat = 82
    let paddingHorz = (itemWidth - buttonWidth) / 2
    let paddingVert = (itemHeight - buttonHeight) / 2

    var row = 0
    var column = 0
    var x = marginX
    for (index, result) in searchResults.enumerated() {
      // 1
      let button = UIButton(type: .custom)
      button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
      button.tag = 2000 + index
      button.addTarget(self,
        action: #selector(buttonPressed),
        for: .touchUpInside)
      downloadImage(for: result, andPlaceOn: button)
      //button.setTitle("\(index)", for: .normal)
      // 2
      button.frame = CGRect(
        x: x + paddingHorz,
        y: marginY + CGFloat(row) * itemHeight + paddingVert,
        width: buttonWidth,
        height: buttonHeight)
      // 3
      scrollView.addSubview(button)
      // 4
      row += 1
      if row == rowsPerPage {
        row = 0; x += itemWidth; column += 1
        if column == columnsPerPage {
          column = 0; x += marginX * 2
        }
      } }
    let buttonsPerPage = columnsPerPage * rowsPerPage
    let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
    scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth,
      height: scrollView.bounds.size.height)
    pageControl.numberOfPages = numPages
    pageControl.currentPage = 0

  }
  override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDetail" {
      if case .results(let list) = search.state {
        let detailViewController = segue.destination as! DetailViewController
        let searchResult = list[(sender as! UIButton).tag - 2000]
        detailViewController.searchResult = searchResult
      }
    }
  }

  private func downloadImage( for searchResult:SearchResult, andPlaceOn button: UIButton) {
    if let url = URL(string: searchResult.imageSmall) {
      let task = URLSession.shared.downloadTask(with: url) {
        [weak button] url, _, error in
        if error == nil,let url = url,
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
          DispatchQueue.main.async {
            if let button = button {
              button.setImage(image, for: .normal)
            }
          }
        }
      }
      task.resume()
      downloads.append(task)
    }
  }
}
extension LandscapeViewController: UIScrollViewDelegate {
  func dcrollViewDidScoll(_ scrollView: UIScrollView) {
    let width = scrollView.bounds.size.width
    let page = Int((scrollView.contentOffset.x + width / 2) / width)
    pageControl.currentPage = page
  }
  @IBAction func pageChanged(_ sender: UIPageControl) {
    scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0) }
}
