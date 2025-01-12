//
//  HeaterViewController.swift
//  ModuloTech_test
//
//  Created by Sloven Graciet on 29/03/2021.
//

import UIKit
import RxSwift
import RxCocoa

class HeaterViewController: UIViewController {
    
    var viewModel: HeaterViewModel!
    var disposeBag = DisposeBag()
    
    // MARK: UI Variables
    
    lazy var gradient: CAGradientLayer = {
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.colors = [UIColor(hexString: "#EDC10C").cgColor, UIColor(hexString: "#E05701").cgColor, UIColor(hexString: "#ED210C").cgColor]
        gradient.locations = [0.0 , NSNumber(value: viewModel.temperatureColor.value) , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.cornerRadius = 18

        self.cardView.layer.insertSublayer(gradient, at: 0)
        return gradient
    }()
    
    lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 15
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = self.viewModel.deviceName
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var modeLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var temperatureSlider: UISlider = {
        let slider = UISlider()
        
        slider.isContinuous = true
        slider.tintColor = .blue
        slider.minimumValue = HeaterViewModel.Constants.minTemperature
        slider.maximumValue = HeaterViewModel.Constants.maxTemperature
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        return slider
    }()
    
    lazy var modeSwitch: UISwitch = {
        let switchView = UISwitch()
        
        switchView.translatesAutoresizingMaskIntoConstraints = false
        
        return switchView
    }()
    
    lazy var emptyView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        return view
    }()
    
    // MARK: Life Cycle Functions
    init(viewModel: HeaterViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // init for storyboard instantiation
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        
        self.cardView.layer.insertSublayer(gradient, at: 0)
        self.updateGradient()
        
        self.bindViews()

    }
    
    func setupViews() {
        self.view.addSubview(cardView)
        
        self.cardView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.cardView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.cardView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.cardView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.6).isActive = true
        
        self.cardView.addSubview(stackView)

        self.stackView.centerXAnchor.constraint(equalTo: self.cardView.centerXAnchor).isActive = true
        self.stackView.centerYAnchor.constraint(equalTo: self.cardView.centerYAnchor).isActive = true

        self.stackView.addArrangedSubview(titleLabel)
        self.stackView.addArrangedSubview(emptyView)
        self.stackView.addArrangedSubview(temperatureLabel)
        self.stackView.addArrangedSubview(temperatureSlider)
        self.stackView.addArrangedSubview(modeLabel)
        self.stackView.addArrangedSubview(modeSwitch)
        
        self.view.backgroundColor = UIColor(named: "backgroundVC")

    }
    
    func bindViews(){
        // init and bind temperature data to slider and label
        viewModel.temperature.subscribe(onNext: { [weak self](temperature) in
            self?.viewModel.device.value.temperature = temperature
        }).disposed(by: disposeBag)
        
        self.temperatureSlider.value = viewModel.temperature.value
        self.temperatureSlider.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: {
                let step = HeaterViewModel.Constants.stepTemperature
                let value = self.temperatureSlider.value
                let roundedValue = value.round(nearest: step)
                
                self.viewModel.temperature.accept(roundedValue)
                self.updateGradient()
            }).disposed(by: disposeBag)
        
        
        viewModel.temperature.asDriver()
            .map { "Temperature: \($0) °C" }
            .drive(self.temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        //init and bind modeDevice data to switch and label
        viewModel.mode.subscribe(onNext: { [weak self](mode) in
            self?.viewModel.device.value.mode = mode
        }).disposed(by: disposeBag)
        
        self.modeSwitch.setOn(viewModel.mode.value == .On ? true : false, animated: false)
        self.modeSwitch.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: {
                
                let value: DeviceMode = self.modeSwitch.isOn ? .On : .Off
                
                self.viewModel.mode.accept(value)
            }).disposed(by: disposeBag)
        
        viewModel.mode.asDriver()
            .map { "Mode: \($0.rawValue)" }
            .drive(self.modeLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func updateGradient() {
        gradient.locations = [0.0 , NSNumber(value: viewModel.temperatureColor.value) , 1.0]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.cardView.frame.size.width, height: self.cardView.frame.size.height)
 
    }
    
}
