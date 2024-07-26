//
//  PlaceFilterViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 7/14/24.
//

import UIKit
import ReactorKit
import RxSwift
import SnapKit
import FlexLayout
import PinLayout

extension Reactive where Base: PlaceFilterViewController {
    var selected: Observable<[String]> {
        return base._places.asObservable()
    }
}
final class PlaceFilterViewController: BasePickerViewController, View {
    var reactor: AddReactor
    var disposeBag: DisposeBag = DisposeBag()
    private var willAppearPublisher = PublishSubject<Void>()
    private var places: [String] = [] {
        didSet {
            _places.onNext(places)
        }
    }
    fileprivate var _places = PublishSubject<[String]>()
    private var homeTeam: Team?
    private let containerView = UIView()
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "홈 구장을 선택해주세요."
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_reguler)
        return label
    }()
    
    private let tableView = UITableView()
    private let saveButton = CMDefaultFilledButton(title: "저장")
    
    init(reactor: AddReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        willAppearPublisher.onNext(())
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        bind(reactor: reactor)
        setupUI()
    }
    
    private func setupTableView() {
        tableView.register(PlaceFilterTableViewCell.self, forCellReuseIdentifier: "PlaceFilterTableViewCell")
        tableView.tableHeaderView = UIView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    private func updateSelectedTeams(_ selectedPlace: String?) {
        guard let cells = tableView.visibleCells as? [PlaceFilterTableViewCell] else { return }
        for cell in cells {
            guard let place = cell.place else { continue }
            cell.isClicked = (place == selectedPlace)
        }
    }
    
    func bind(reactor: AddReactor) {
        willAppearPublisher
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.homeTeam = reactor.currentState.homeTeam
                vc.places = vc.homeTeam?.place ?? []
                if vc.places.isEmpty {
                    vc.tableView.isHidden = true
                    vc.containerView.isHidden = false
                    vc.warningLabel.isHidden = false
                } else {
                    vc.tableView.isHidden = false
                    vc.containerView.isHidden = true
                    vc.warningLabel.isHidden = true
                }
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.homeTeam}
            .observe(on: MainScheduler.asyncInstance)
            .compactMap{$0}
            .distinctUntilChanged()
            .subscribe { team in
                if let place = team.place, !place.isEmpty {
                    reactor.action.onNext(.changePlcase(place[0]))
                }
            }
            .disposed(by: disposeBag)
        reactor.state
            .map{$0.place}
            .bind(onNext: updateSelectedTeams)
            .disposed(by: disposeBag)
        
       _places
            .bind(to: tableView.rx.items(cellIdentifier: "PlaceFilterTableViewCell", cellType: PlaceFilterTableViewCell.self)) { row, place, cell in
                cell.setupData(place: place, isClicked: row == 0)
                cell.selectionStyle = .none
                cell.checkButton.rx.tap
                    .map { Reactor.Action.changePlcase(place) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
                print(cell.frame.height)
            }
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.addSubviews(views: [tableView, containerView, saveButton])
        containerView.addSubview(warningLabel)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.bottom.equalTo(saveButton.snp.top).offset(-30)
        }

        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.bottom.equalTo(saveButton.snp.top)
        }
        warningLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(ButtonGridSystem.getMargin())
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-34)
            make.height.equalTo(52).priority(.required)
        }
    }
}

final class PlaceFilterTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    var isClicked: Bool = false {
        didSet {
            checkPlace()
        }
    }
    var place: String?
    private let containerView = UIView()
    private let placeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        label.applyStyle(textStyle: FontSystem.bodyTitle)
        return label
    }()
    
    let checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "circle_default")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        bind()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
        contentView.frame.size.height = 50
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        return CGSize(width: size.width, height: containerView.frame.height)
    }
    
    private func checkPlace() {
        if isClicked {
            checkButton.setImage(UIImage(named: "circle_check")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            checkButton.setImage(UIImage(named: "circle_default")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    func setupData(place: String, isClicked: Bool) {
        self.place = place
        self.placeLabel.text = place
        self.isClicked = isClicked
    }

    private func bind() {
        checkButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.isClicked.toggle()
            })
            .disposed(by: disposeBag)
    }
    
    private func setUI() {
        contentView.addSubview(containerView)
        
        containerView.flex.direction(.row).justifyContent(.spaceBetween).alignContent(.center).paddingVertical(20).define { flex in
            flex.addItem(placeLabel).grow(1)
            flex.addItem(checkButton).size(20)
        }
    }
}
