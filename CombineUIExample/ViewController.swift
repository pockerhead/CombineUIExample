//
//  ViewController.swift
//  CombineUIExample
//
//  Created by Артём Балашов on 11.04.2023.
//

import UIKit
import Combine

var timer = Timer.publish(every: 1, on: .main, in: .common)

struct WeatherVM {
	
	var dateSetter: DateSetter?
	var name: String?
	var degrees: Int?
	
}

class DateSetter {
	var completion: ((String) -> Void)
	var timeOffset: TimeInterval = 100400
	var cancellables: Set<AnyCancellable> = []
	
	init(timeOffset: TimeInterval, completion: @escaping (String) -> Void) {
		self.completion = completion
		self.timeOffset = timeOffset
		timer
			.sink { date in
				let myDate = date.addingTimeInterval(self.timeOffset)
				let f = DateFormatter()
				f.dateFormat = "dd.MM.yyyy HH:mm:ss"
				let str = f.string(from: myDate)
				completion(str)
			}
			.store(in: &cancellables)
	}
}

class ViewController: UIViewController {

	let tx1 = UITextField()
	let tx2 = UITextField()
	let tx3 = UITextField()
	var label = UILabel()
	let btn = UIButton(type: .system)
	var cancellables: Set<AnyCancellable> = .init()
	var stringPublisher: PassthroughSubject<String?, Never> = .init()
	
	var timeOffset: TimeInterval = 100400
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureUI()
		tx1.returnKeyType = .done
		timer.connect().store(in: &cancellables)
		timer.sink { date in
			let myDate = date.addingTimeInterval(self.timeOffset)
			let f = DateFormatter()
			f.dateFormat = "dd.MM.yyyy HH:mm:ss"
			let str = f.string(from: myDate)
			self.label.text = str
		}
		.store(in: &cancellables)
		Publishers.MergeMany(
			tx1.publisher(for: \.text),
			tx2.publisher(for: \.text),
			tx3.publisher(for: \.text)
		)
		.collect()
		.sink { strings in
			print(strings.compactMap({ $0 }).joined())
		}
		.store(in: &cancellables)
		stringPublisher
			.assign(to: \.label.text, on: self)
			.store(in: &cancellables)
		
		btn.addTarget(self, action: #selector(tap), for: .touchUpInside)
	}
	
	@objc func tap() {
		let vc = SecondVC()
		vc.stringPublisher3342 = self.stringPublisher
		self.present(vc, animated: true)
	}
	
	func getFuture() -> Future<String, Never> {
		return Future { promise in
			promise(.success("Hola"))
		}
	}
	
	func configureUI() {
		view.addSubview(tx1)
		tx1.backgroundColor = .red
		view.addSubview(tx2)
		tx2.backgroundColor = .red

		view.addSubview(tx3)
		tx3.backgroundColor = .red

		view.addSubview(label)
		label.textAlignment = .center
		label.text = "PLACEHOLDER"
		view.addSubview(btn)
		btn.setTitle("PRESS ME", for: .normal)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tx1.frame = .init(x: 16, y: view.safeAreaInsets.top + 20, width: view.frame.width - 32, height: 44)
		tx2.frame = .init(x: 16, y: tx1.frame.maxY + 8, width: view.frame.width - 32, height: 44)
		tx3.frame = .init(x: 16, y: tx2.frame.maxY + 8, width: view.frame.width - 32, height: 44)
		btn.frame = .init(x: 16, y: tx3.frame.maxY + 8, width: view.frame.width - 32, height: 44)
		label.frame = .init(x: 16, y: btn.frame.maxY + 8, width: view.frame.width - 32, height: 44)
	}

}

class SecondVC: UIViewController {
	let tx1 = UITextField()
	let btn = UIButton(type: .system)
	var cancellables: Set<AnyCancellable> = .init()
	var stringPublisher3342: PassthroughSubject<String?, Never>?

	var completion: ((String) -> Void)?
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		configureUI()
		btn.addTarget(self, action: #selector(tap), for: .touchUpInside)
		tx1.addTarget(self, action: #selector(editing), for: .editingChanged)
	}
	
	@objc func editing() {
		stringPublisher3342?.send(tx1.text)
	}
	
	@objc func tap() {
		self.view.endEditing(true)
		self.dismiss(animated: true)
	}
	
	func configureUI() {
		view.addSubview(tx1)
		tx1.backgroundColor = .red
		timer.sink { date in
			let f = DateFormatter()
			f.dateFormat = "dd.MM.yyyy HH:mm:ss"
			let str = f.string(from: date)
			self.tx1.text = str
		}
		.store(in: &cancellables)
		view.addSubview(btn)
		btn.setTitle("SEND TO PREVIOUS", for: .normal)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tx1.frame = .init(x: 16, y: view.safeAreaInsets.top + 20, width: view.frame.width - 32, height: 44)
		btn.frame = .init(x: 16, y: tx1.frame.maxY + 8, width: view.frame.width - 32, height: 44)
	}
}
