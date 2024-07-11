//
//  CMDatePicker.swift
//  CatchMate
//
//  Created by 방유빈 on 7/11/24.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift

class CMDatePicker: UIView {
    fileprivate var _selectedDate = PublishSubject<Date?>()
    private let rootFlexContainer = UIView()
    private let headerView = UIView()
    private let previousButton = UIButton()
    private let nextButton = UIButton()
    private let titleLabel = UILabel()
    
    private var currentDate = Date()
    var selectedDate: Date? = Date() {
        didSet {
            _selectedDate.onNext(selectedDate)
        }
    }
    var minimumDate: Date? {
        didSet {
            collectionView.reloadData()
        }
    }
    private var daysInMonth: [Date?] = []
    private let collectionView: UICollectionView
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: 0, height: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        setupView()
        setupCollectionView()
        setupDaysInMonth()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        self.addSubview(rootFlexContainer)
        
        previousButton.setImage(UIImage(named: "cm20left_filled")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        previousButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)

        nextButton.setImage(UIImage(named: "cm20right_filled")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        updateTitleLabel()
        
        headerView.flex.direction(.row).justifyContent(.center).alignItems(.center).padding(10).define { (flex) in
            flex.addItem(previousButton)
            flex.addItem(titleLabel).marginHorizontal(12)
            flex.addItem(nextButton)
        }
        
        let daysOfWeekView = UIView()
        let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
        daysOfWeekView.flex.direction(.row).justifyContent(.spaceAround).define { (flex) in
            for day in daysOfWeek {
                let label = UILabel()
                label.text = day
                label.textAlignment = .center
                flex.addItem(label).grow(1).shrink(1).width((100 / 7)%)
            }
        }
        
        rootFlexContainer.flex.direction(.column).padding(10).define { (flex) in
            flex.addItem(headerView).height(50)
            flex.addItem(daysOfWeekView).height(30)
            flex.addItem(collectionView).grow(1)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let availableWidth = collectionView.bounds.width
            let itemWidth = availableWidth / 7
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    private func setupCollectionView() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = CGSize(width: 0, height: 0)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 12.5, right: 0)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
    }
    
    private func setupDaysInMonth() {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        
        daysInMonth.removeAll()
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        daysInMonth = Array(repeating: nil, count: firstWeekday) + range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: firstDayOfMonth) }
    }
    
    @objc private func previousMonthTapped() {
        changeMonth(by: -1)
    }
    
    @objc private func nextMonthTapped() {
        changeMonth(by: 1)
    }
    
    private func changeMonth(by value: Int) {
        let calendar = Calendar.current
        currentDate = calendar.date(byAdding: .month, value: value, to: currentDate) ?? Date()
        updateTitleLabel()
        setupDaysInMonth()
        titleLabel.flex.markDirty()
        headerView.flex.layout()
        collectionView.reloadData()
    }
    
    private func updateTitleLabel() {
        let titleString = DateHelper.shared.toString(from: currentDate, format: "M월")
        titleLabel.text = titleString
    }
}

extension CMDatePicker: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        let date = daysInMonth[indexPath.item]
        cell.configure(with: date, isCurrentDate: isCurrentDate(date), isSelectedDate: isSelectedDate(date), minimuDate: minimumDate)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let date = daysInMonth[indexPath.item] {
            if let minimumDate = minimumDate, date < minimumDate.startOfDay() {
                return
            }
            if isSelectedDate(date) {
                selectedDate = nil
            } else {
                selectedDate = date
            }
            collectionView.reloadData()
        }
    }
    
    private func isCurrentDate(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: Date())
    }
    
    private func isSelectedDate(_ date: Date?) -> Bool {
        guard let date = date, let selectedDate = selectedDate else { return false }
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
}

extension Reactive where Base: CMDatePicker {
    var selectedDate: Observable<Date?> {
        return base._selectedDate.asObservable()
    }
}



class DateCell: UICollectionViewCell {
    
    private let dateLabel = UILabel()
    private let circleView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        dateLabel.textAlignment = .center
        dateLabel.textColor = .cmHeadLineTextColor
        
        circleView.layer.cornerRadius = 16
        circleView.isHidden = true
        
        contentView.addSubview(circleView)
        contentView.addSubview(dateLabel)
        
        circleView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let circleDiameter = min(contentView.bounds.width, contentView.bounds.height) * 0.8
        circleView.layer.cornerRadius = circleDiameter / 2
        
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: circleDiameter),
            circleView.heightAnchor.constraint(equalToConstant: circleDiameter)
        ])
    }
    
    func configure(with date: Date?, isCurrentDate: Bool, isSelectedDate: Bool, minimuDate: Date?) {
        if let date = date {
            dateLabel.text = DateHelper.shared.toString(from: date, format: "d")
            dateLabel.applyStyle(textStyle: FontSystem.body01_medium)
            dateLabel.textColor = .cmHeadLineTextColor
            circleView.isHidden = true
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: date)
            if let minimuDate = minimuDate, date < minimuDate.startOfDay() {
                dateLabel.textColor = .cmNonImportantTextColor
            } else if weekday == 2 {
                dateLabel.textColor = .cmNonImportantTextColor
            } else if isSelectedDate {
                circleView.isHidden = false
                circleView.backgroundColor = .cmPrimaryColor
                dateLabel.textColor = .white
            } else if isCurrentDate {
                circleView.isHidden = false
                circleView.backgroundColor = .grayScale100
                dateLabel.textColor = .cmHeadLineTextColor
            } else {
                dateLabel.textColor = .cmHeadLineTextColor
                circleView.isHidden = true
            }
        } else {
            dateLabel.text = nil
            circleView.isHidden = true
        }
    }
}
