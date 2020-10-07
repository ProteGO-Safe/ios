//
//  DebugTextPreviewViewController.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 07/10/2020.
//

import UIKit

final class DebugTextPreviewViewController: UIViewController {
    
    private enum Constants {
        static let closeButtonInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: .zero, right: .zero)
        static let closeButtonSize = CGSize(width: 22.0, height: 22.0)
        static let titleLabelInsets = UIEdgeInsets(top: 20, left: .zero, bottom: 15.0, right: .zero)
        static let titleFont: UIFont = .systemFont(ofSize: 18.0, weight: .bold)
        static let textViewFont: UIFont = .systemFont(ofSize: 12)
    }
    
    private let closeButton = UIButton()
    private let titleLabel = UILabel()
    private let textView = UITextView()
    private let text: String
    
    required init?(coder: NSCoder) {
        fatalError("has not been implemented yet")
    }
    
    init(with text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = text
    }
    
    private func setup() {
        view.backgroundColor = .white
        view.addSubview(textView)
        setupCloseButton()
        setupTitleLabel()
        setupTextView()
    }
    
    private func setupCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(#imageLiteral(resourceName: "close_icon"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeButtonTap), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .black
        titleLabel.font = Constants.titleFont
        titleLabel.textAlignment = .center
        titleLabel.text = DebugViewModel.Texts.previewTitle
        view.addSubview(titleLabel)
    }
    
    private func setupTextView() {
        textView.font = Constants.textViewFont
        view.addSubview(textView)
    }
    
    private func layout() {
        closeButton.snp.makeConstraints { maker in
            maker.size.equalTo(Constants.closeButtonSize)
            maker.left.top.equalToSuperview().inset(Constants.closeButtonInsets)
        }
        
        titleLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview().inset(Constants.titleLabelInsets)
        }
        
        textView.snp.makeConstraints { maker in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.top.equalTo(titleLabel.snp.bottom)
        }
    }
    
    @objc private func closeButtonTap(sender: UIButton) {
        dismiss(animated: true)
    }
         
}
