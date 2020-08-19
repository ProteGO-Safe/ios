//
//  DebugViewController.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 18/08/2020.
//

import UIKit
import SnapKit

final class DebugViewController: ViewController<DebugViewModel> {
    
    private enum Constants {
        static let closeButtonInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: .zero, right: .zero)
        static let closeButtonSize = CGSize(width: 22.0, height: 22.0)
        static let titleLabelInsets = UIEdgeInsets(top: 20, left: .zero, bottom: .zero, right: .zero)
        static let defaultStackItemSize = CGSize(width: 150.0, height: 44.0)
        static let mainStackViewInsets = UIEdgeInsets(top: .zero, left: 12.0, bottom: .zero, right: 12.0)
        static let mainStackViewSpacing: CGFloat = 10.0
        static let stackItemBorderWidth: CGFloat = 1.0
        static let titleFont: UIFont = .systemFont(ofSize: 18.0, weight: .bold)
    }
    
    private let closeButton = UIButton()
    private let titleLabel = UILabel()
    private let mainStackView = UIStackView()
    
    override func start() {
        viewModel.delegate = self
    }
    
    override func setup() {
        view.backgroundColor = .white
        setupCloseButton()
        setupTitleLabel()
        setupStackView()
        setupStackedItems()
    }
    
    override func layout() {
        closeButton.snp.makeConstraints { maker in
            maker.size.equalTo(Constants.closeButtonSize)
            maker.left.top.equalToSuperview().inset(Constants.closeButtonInsets)
        }
        
        titleLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview().inset(Constants.titleLabelInsets)
        }
        
        mainStackView.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.right.equalToSuperview().inset(Constants.mainStackViewInsets)
        }
    }
    
    private func setupCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(#imageLiteral(resourceName: "close_icon"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeButtonTap), for: .touchUpInside)
        add(subview: closeButton)
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .black
        titleLabel.font = Constants.titleFont
        titleLabel.textAlignment = .center
        titleLabel.text = DebugViewModel.Texts.title
        add(subview: titleLabel)
    }
    
    private func setupStackView() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = Constants.mainStackViewSpacing
        add(subview: mainStackView)
    }
    
    private func setupStackedItems() {
        stackButton(DebugViewModel.Texts.shareUploadedPayloadsTitle, action: .uploadPayloadsShare)
    }
    
    private func stackButton(_ title: String, action: DebugAction) {
        let item = DebugStackViewItem(type: .roundedRect)
        item.action = action
        item.layer.borderWidth = Constants.stackItemBorderWidth
        item.layer.borderColor = UIColor.systemBlue.cgColor
        item.translatesAutoresizingMaskIntoConstraints = false
        item.addTarget(self, action: #selector(stackViewItemmDidTap), for: .touchUpInside)
        decorateStackItemTitle(title: title, item: item, byAction: action)
        item.snp.makeConstraints { maker in
            maker.height.equalTo(Constants.defaultStackItemSize.height)
        }
        mainStackView.addArrangedSubview(item)
    }
    
    private func decorateStackItemTitle(title: String, item: DebugStackViewItem, byAction: DebugAction) {
        switch byAction {
        case .uploadPayloadsPreview, .uploadPayloadsShare:
            guard viewModel.numberOfPayloads > .zero else {
                item.setTitle(DebugViewModel.Texts.noUploadedPayloadsTitle, for: .normal)
                item.isEnabled = false
                return
            }
            item.setTitle("(\(viewModel.numberOfPayloads)) \(title)", for: .normal)
        default:
            item.setTitle(title, for: .normal)
        }
        
    }
    
    @objc
    private func stackViewItemmDidTap(sender: DebugStackViewItem) {
        viewModel.manage(debugAction: sender.action)
    }
    
    @objc
    private func closeButtonTap(sender: UIButton) {
        dismiss(animated: true)
    }
}

extension DebugViewController: DebugViewModelDelegate {
    func sharePayloads(fileURL: URL) {
        let activityController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        present(activityController, animated: true)
    }
}
