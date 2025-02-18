//
//  OpenSourceListViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 2/18/25.
//

import UIKit
import SnapKit

struct OpenSourceLibrary: Codable {
    let name: String
    let version: String
    let license: String
    let copyright: String
    let url: String
    let licenseText: String
}
final class OpenSourceListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    private var libraries: [OpenSourceLibrary] = []
    private let tableView = UITableView()
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("OpenSourceLibrary")
        libraries = OpenSourceLibraryService.shared.loadLibraries()
        setupUI()
        setupTableView()
    }
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension OpenSourceListViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let library = libraries[indexPath.row]
        cell.textLabel?.text = "\(library.name) (\(library.version))"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let library = libraries[indexPath.row]
        let detailVC = OpenSourceLibraryDetailViewController(library: library)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
