//
//  SearchResultCellTableViewCell.swift
//  Store Search
//
//  Created by Halis  Kara on 21.08.2021.
//

import UIKit

class SearchResultCell: UITableViewCell {
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var artistNameLabel: UILabel!
  @IBOutlet var artworkImageView: UIImageView!
  var downloadTask: URLSessionDownloadTask?

  override func prepareForReuse() {
    super.prepareForReuse()
    downloadTask?.cancel()
    downloadTask = nil
  }
    override func awakeFromNib() {
        super.awakeFromNib()
      let selectedView = UIView(frame: CGRect.zero)
      selectedView.backgroundColor = UIColor(named: "SearchBar")?.withAlphaComponent(0.5)
      selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  func configure(for result: SearchResult) {
    nameLabel.text = result.name
    if result.artist.isEmpty {
      artistNameLabel.text = "Unknown"
    } else {
      artistNameLabel.text = String(format:
                                      "%@ (%@)", result.artist, result.type)
    }
    artworkImageView.image = UIImage(systemName: "square")
    if let smallUrl = URL(string: result.imageSmall) {
      downloadTask = artworkImageView.loadImage(url: smallUrl)
    }
  }
}
