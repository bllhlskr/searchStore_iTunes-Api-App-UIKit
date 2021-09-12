//
//  DetailViewController.swift
//  Store Search
//
//  Created by Halis  Kara on 8.09.2021.
//

import UIKit

class DetailViewController: UIViewController {
  enum AnimationStyle {
    case slide
    case fade
  }
  var dismissStyle = AnimationStyle.fade
  @IBOutlet var popupView: UIView!
  @IBOutlet var artworkImageView: UIImageView!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var artistNameLabel: UILabel!
  @IBOutlet var kindLabel: UILabel!
  @IBOutlet var genreLabel: UILabel!
  @IBOutlet var priceButton: UIButton!
  var downloadTask: URLSessionDownloadTask?
  var searchResult: SearchResult!

  @IBAction func openInStore() {
    if let url = URL(string: searchResult.storeURL) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    transitioningDelegate = self
  }

  @IBAction func close() {
    dismissStyle = .slide
    dismiss(animated:true, completion: nil)
  }
  deinit {
    print("deinit \(self)")
    downloadTask?.cancel()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    popupView.layer.cornerRadius = 10
    if searchResult != nil {
      updateUI()
    }


    let gestureRecognizer = UITapGestureRecognizer(target : self, action:#selector(close))
    gestureRecognizer.cancelsTouchesInView = false
    view.addGestureRecognizer(gestureRecognizer)
    view.backgroundColor = UIColor.clear
    let dimmingView = GradientView(frame: CGRect.zero)
    dimmingView.frame = view.bounds
    view.insertSubview(dimmingView, at: 0)
  }

  func updateUI() {
    if let largeUrl = URL(string: searchResult.imageLarge) {
      downloadTask = artworkImageView.loadImage(url: largeUrl)
    }
    nameLabel.text = searchResult.name

    if searchResult.artist.isEmpty {
      artistNameLabel.text = "unknown"
    } else {
      artistNameLabel.text = searchResult.artist
    }
    kindLabel.text = searchResult.type
    genreLabel.text = searchResult.genre
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = searchResult.currency

    let priceText: String
    if searchResult.price == 0 {
      priceText = "Free"
    } else if let text = formatter.string(from: searchResult.price as NSNumber) {
      priceText = text
    } else {
      priceText = ""
    }
    priceButton.setTitle(priceText, for: .normal)

  }
}

extension DetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,shouldReceive touch: UITouch) -> Bool {
    return (touch.view === self.view)
  }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return BounceAnimationController()
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
  {
    switch dismissStyle {
    case .slide:
      return SlideOutAnimationController()
    case .fade:
      return FadeOutAnimationController()
    }
  }
}

