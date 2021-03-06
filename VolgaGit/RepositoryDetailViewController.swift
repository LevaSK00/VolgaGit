//
//  RepositoryDetailViewController.swift
//  VolgaGit
//
//  Created by John on 31.03.2020.
//  Copyright © 2020 Лебедев Лев. All rights reserved.
//

import UIKit
import SkeletonView

class RepositoryDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var repository: Repository?
    var model: RepositoryDetailViewModel!
    let refresher = UIRefreshControl()
    var isLoading = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImage.layer.cornerRadius = userImage.layer.bounds.height / 2
        
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        model = RepositoryDetailViewModel(self, repository: repository!)
        model.commits.bind { (commits) in
            if commits != nil {
                self.isLoading = false
                self.tableView.reloadData()
                self.tableView.addSubview(self.refresher)
            }
        }
        
        let nibName = UINib(nibName: "CommitTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CommitCell")
        
        showRepository()
    }
    
    @objc func refresh() {
        model.loadCommits {
            self.refresher.endRefreshing()
        }
    }
    
    func showRepository() {
        guard let repository = repository else { return }
        
        title = repository.name
        userNameLabel.text = repository.owner?.login
        APIManager.shared.loadImage(url: (repository.owner?.avatar_url)!) { (image) in
            self.userImage.image = image
        }
    }
}

extension RepositoryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 10 }
        return model.commitsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommitCell", for: indexPath) as! CommitTableViewCell

        if isLoading {
            cell.showAnimatedGradientSkeleton()
            
        } else {
            cell.hideSkeleton()
            cell.color = LanguageColors.getColor(for: repository!)
            cell.commit = model.getCommit(for: indexPath)
        }
        
        return cell
    }
}
