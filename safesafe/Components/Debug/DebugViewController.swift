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
    var closeCallback: (() -> Void)?
    
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
        stackButton(DebugViewModel.Texts.shareUploadedPayloadsTitle, action: .uploadedPayloadsShare)
        stackButton(DebugViewModel.Texts.shareLogsTitle, action: .logsShare)
        stackButton(DebugViewModel.Texts.dumpLocalStorageTitl, action: .dumpLocalstorage)
        stackButton(DebugViewModel.Texts.downloadDistrictsTitle, action: .downloadDistricts)
        if #available(iOS 13.5, *) {
            stackButton(DebugViewModel.Texts.simulateExposureRiskTitle, action: .simulateExposureRisk)
            stackButton(DebugViewModel.Texts.deleteSimulatedExposuresTitle, action: .deleteSimulatedExposures)
            stackButton(DebugViewModel.Texts.simulateRiskCheckTitle, action: .simulateRiskCheck)
            stackButton(DebugViewModel.Texts.deleteSimulatedRiskCheck, action: .deleteSimulatedRiskCheck)
        }
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
        case .uploadedPayloadsPreview, .uploadedPayloadsShare:
            guard viewModel.numberOfPayloads > .zero else {
                item.setTitle(DebugViewModel.Texts.noUploadedPayloadsTitle, for: .normal)
                item.isEnabled = false
                return
            }
            item.setTitle("(\(viewModel.numberOfPayloads)) \(title)", for: .normal)
        case .logsShare:
            guard viewModel.logExists else {
                item.setTitle(DebugViewModel.Texts.noLogsTitle, for: .normal)
                item.isEnabled = false
                return
            }
            item.setTitle(title, for: .normal)
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
        dismiss(animated: true, completion: closeCallback)
    }
}

extension DebugViewController: DebugViewModelDelegate {
    func sharePayloads(fileURL: URL) {
        let activityController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    func shareLogs(fileURL: URL) {
        let alertController = UIAlertController(title: "Pick Action", message: nil, preferredStyle: .actionSheet)
        let preview = UIAlertAction(title: "Preview", style: .default) { [weak self] _ in
            guard let data = try? Data(contentsOf: fileURL), let text = String(bytes: data, encoding: .utf8) else { return }
            self?.showTextPreview(text: text)
        }
        let share = UIAlertAction(title: "Share", style: .default) { [weak self] _ in
            let activityController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            self?.present(activityController, animated: true)
        }
        
        alertController.addAction(preview)
        alertController.addAction(share)
        
        present(alertController, animated: true)
        
    }
    
    func showTextPreview(text: String) {
        let preview = DebugTextPreviewViewController(with: text)
        present(preview, animated: true)
    }
    
    func showLocalStorageFiles(list: [String]) {
        let alertController = UIAlertController(title: "Pick storage", message: nil, preferredStyle: .actionSheet)
        for item in list {
            let action = UIAlertAction(title: item, style: .default) { [weak self] _ in
                self?.viewModel.openLocalStorage(with: item)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func showSimulatedRisksSheet(list: [RiskLevel : String]) {
        let alertController = UIAlertController(title: "Simulate Exposure Risk", message: nil, preferredStyle: .actionSheet)
        
        for (risk, title) in list {
            let action = UIAlertAction(title: title , style: .default) { [weak self] _ in
                self?.viewModel.simulateExposureRisk(riskLevel: risk)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func showAnalyzeDaysSheet(list: [AnalyzeDay : String]) {
        let alertController = UIAlertController(title: "Simulate Risk Check", message: nil, preferredStyle: .actionSheet)
        
        for (day, title) in list {
            let action = UIAlertAction(title: title , style: .default) { [weak self] _ in
                self?.viewModel.simulateRiskCheck(day: day)
            }
            alertController.addAction(action)
        }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}
