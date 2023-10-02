//
//  DidSelectViewController.swift
//  SimulateUIMenu
//
//  Created by Don Mag on 10/1/23.
//

import UIKit

struct SomeDataObject {
	var title: String = ""
	var otherData: String = ""
	var bgColor: UIColor = .lightGray
}

struct MenuZoomPosition: OptionSet {
	
	// MARK: - Properties
	
	let rawValue: Int
	
	// MARK: - Options
	
	static let top		= MenuZoomPosition(rawValue: 1 << 0)
	static let bottom	= MenuZoomPosition(rawValue: 1 << 1)
	static let leading	= MenuZoomPosition(rawValue: 1 << 2)
	static let trailing	= MenuZoomPosition(rawValue: 1 << 3)
	
}


class ScratchVC: UIViewController {
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let a = (1...150).map({
			SomeDataObject(title: "\($0)",
						   otherData: "Some other data \($0)",
						   bgColor: $0 % 7 == 1 ? .red : .lightGray)
		})
		
		print(a.count)
		print()
	}
}

class ViewUIMenu: UIView {
	
	public var didSelectOption: ((Int) -> ())?
	
	public var title: String = "" {
		didSet {
			titleLabel.text = title
		}
	}
	public var menuOptions: [String] = [] {
		didSet {
			for (i, str) in menuOptions.enumerated() {
				let v = UIView()
				v.backgroundColor = .lightGray
				stackView.addArrangedSubview(v)
				v.heightAnchor.constraint(equalToConstant: UIScreen.main.scale == 2 ? 0.5 : 1.0 / 3.0).isActive = true
				
				let handler: UIButton.ConfigurationUpdateHandler = { button in
					var cfg = button.configuration
					switch button.state {
					case .highlighted:
						cfg?.baseBackgroundColor = UIColor(white: 0.0, alpha: 0.1)
					default:
						cfg?.baseBackgroundColor = .clear
					}
					button.configuration = cfg
				}
				var cfg = UIButton.Configuration.filled()
				cfg.title = str
				cfg.titleAlignment = .leading
				cfg.baseForegroundColor = .black
				cfg.cornerStyle = .fixed
				cfg.background.cornerRadius = 0.0
				cfg.contentInsets = .init(top: 12.0, leading: 16.0, bottom: 13.0, trailing: 16.0)
				let btn = UIButton(configuration: cfg, primaryAction: UIAction() { _ in
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
						self.didSelectOption?(i)
					}
				})
				btn.contentHorizontalAlignment = .leading
				btn.configurationUpdateHandler = handler
				btn.setContentCompressionResistancePriority(.required, for: .vertical)
				btn.setContentHuggingPriority(.required, for: .vertical)
				stackView.addArrangedSubview(btn)
			}
		}
	}
	
	private var bkgView: UIVisualEffectView!
	private let stackView = UIStackView()
	private let titleLabel = PaddedLabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	private func commonInit() {
		
		let blurEffect = UIBlurEffect(style: .systemMaterial)
		bkgView = UIVisualEffectView(effect: blurEffect)
		bkgView.layer.cornerRadius = 12
		bkgView.clipsToBounds = true
		
		stackView.axis = .vertical
		stackView.spacing = 0
		
		titleLabel.padding = .init(top: 10.0, left: 18.0, bottom: 8.0, right: 18.0)
		titleLabel.font = .systemFont(ofSize: 12.0, weight: .regular)
		titleLabel.textColor = .gray
		titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		titleLabel.setContentHuggingPriority(.required, for: .vertical)
		titleLabel.text = self.title
		
		stackView.addArrangedSubview(titleLabel)
				
		stackView.translatesAutoresizingMaskIntoConstraints = false
		bkgView.contentView.addSubview(stackView)
		
		bkgView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(bkgView)
		
		let g = self
		
		NSLayoutConstraint.activate([
			
			stackView.topAnchor.constraint(equalTo: bkgView.topAnchor, constant: 0.0),
			stackView.leadingAnchor.constraint(equalTo: bkgView.leadingAnchor, constant: 0.0),
			stackView.trailingAnchor.constraint(equalTo: bkgView.trailingAnchor, constant: 0.0),
			stackView.bottomAnchor.constraint(equalTo: bkgView.bottomAnchor, constant: 0.0),
			
			bkgView.topAnchor.constraint(equalTo: g.topAnchor, constant: 0.0),
			bkgView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 0.0),
			bkgView.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: 0.0),
			bkgView.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: 0.0),
			
			bkgView.widthAnchor.constraint(equalToConstant: 250.0),
			
		])

	}
	
	private var inProcess: Bool = false
//	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//		print(#function)
//		if self.bounds.contains(point) {
//			return super.hitTest(point, with: event)
//		} else {
//			// prevent this being called twice
//			if !self.inProcess {
//				self.inProcess = true
//				self.didSelectOption?(-1)
//			}
//		}
//		return self
//	}
}

class ViewDidSelectViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	
	let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	
	var myData: [Int] = []
	var reloadCount: Int = 0
	
	var theOriginalData: [SomeDataObject] = []
	var theActiveData: [SomeDataObject] = []
	
	var menuShouldZoom: Bool = true
	var menuShouldCenter: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// let's create 150 data objects (so the collection view can scroll)
		theOriginalData = (1...150).map({
			SomeDataObject(title: "\($0)",
						   otherData: "Some other data \($0)",
						   bgColor: $0 % 7 == 1 ? .systemBlue : .lightGray)
		})
		theActiveData = theOriginalData
		
		collectionView.dataSource = self
		collectionView.delegate = self
		
		collectionView.backgroundColor = .white
		collectionView.register(SimpleCollectionViewCell.self, forCellWithReuseIdentifier: "SimpleCell")
		
		// let's add
		
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(collectionView)
		
		let g = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			collectionView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
			collectionView.topAnchor.constraint(equalTo: g.topAnchor, constant: 80.0),
			collectionView.bottomAnchor.constraint(equalTo: g.bottomAnchor)
		])
		
		Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { t in
			//self.reloadCount += 1
			//self.myData.shuffle()
			self.theActiveData.shuffle()
			self.collectionView.reloadData()
			print("collection reloaded")
		})
		
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return theActiveData.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimpleCell", for: indexPath) as! SimpleCollectionViewCell
		cell.setup(value: theActiveData[indexPath.item].title)
		cell.contentView.backgroundColor = theActiveData[indexPath.item].bgColor
		return cell
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		showMenu(forCellAt: indexPath, collectionView: collectionView)
	}
	
	func showMenu(forCellAt indexPath: IndexPath, collectionView: UICollectionView) {
		
		guard let thisCell = collectionView.cellForItem(at: indexPath) else { return }
		
		let thisObject = theActiveData[indexPath.item]
		
		if let n = Int(thisObject.title) {
			self.menuShouldZoom = n % 2 == 1
		}
		print("z:", self.menuShouldZoom)
		
		let menuView = ViewUIMenu()
		menuView.title = "View Menu Title"
		menuView.menuOptions = ["Share \(theActiveData[indexPath.item].title)"]
		menuView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(menuView)
		
		var zPos: MenuZoomPosition = []
		
		if menuShouldCenter {
			NSLayoutConstraint.activate([
				menuView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
				menuView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			])
		} else {
			let srcRect: CGRect = collectionView.convert(thisCell.frame, to: self.view)
			if let lg = self.view.layoutGuides.first(where: { $0.identifier == "srcGuide" } ) {
				self.view.removeLayoutGuide(lg)
			}
			let srcGuide = UILayoutGuide()
			srcGuide.identifier = "srcGuide"
			self.view.addLayoutGuide(srcGuide)
			let g = view.safeAreaLayoutGuide
			NSLayoutConstraint.activate([
				srcGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: srcRect.origin.y),
				srcGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: srcRect.origin.x),
				srcGuide.heightAnchor.constraint(equalToConstant: srcRect.height),
				srcGuide.widthAnchor.constraint(equalToConstant: srcRect.width),

				menuView.leadingAnchor.constraint(greaterThanOrEqualTo: g.leadingAnchor, constant: 8.0),
				menuView.trailingAnchor.constraint(lessThanOrEqualTo: g.trailingAnchor, constant: -8.0),
			])
			var xc: NSLayoutConstraint!
			if srcRect.maxX > view.frame.midX {
				zPos.insert(.trailing)
				xc = menuView.trailingAnchor.constraint(equalTo: srcGuide.trailingAnchor, constant: 2.0)
			} else {
				zPos.insert(.leading)
				xc = menuView.leadingAnchor.constraint(equalTo: srcGuide.leadingAnchor, constant: -2.0)
			}
			xc.priority = .required - 1
			xc.isActive = true
			if srcRect.maxY > view.frame.midY {
				zPos.insert(.bottom)
				menuView.bottomAnchor.constraint(equalTo: srcGuide.topAnchor, constant: 2.0).isActive = true
			} else {
				zPos.insert(.top)
				menuView.topAnchor.constraint(equalTo: srcGuide.bottomAnchor, constant: -2.0).isActive = true
			}
		}
		
		menuView.alpha = 0.0
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		
		var tr = CGAffineTransform(scaleX: 1.0, y: 1.0)
		var pt: CGPoint = .zero
		var anchorPT: CGPoint = .init(x: 0.5, y: 0.5)
		var posPT: CGPoint = .zero
		
		if menuShouldZoom && !menuShouldCenter {
			pt = menuView.layer.position
			
			let w: CGFloat = menuView.frame.width * 0.5
			let h: CGFloat = menuView.frame.height * 0.5
			
			switch zPos {
			case [.top, .trailing]:
				posPT = .init(x: pt.x + w, y: pt.y - h)
				anchorPT = .init(x: 1.0, y: 0.0)
				()
			case [.bottom, .leading]:
				posPT = .init(x: pt.x - w, y: pt.y + h)
				anchorPT = .init(x: 0.0, y: 1.0)
				()
			case [.bottom, .trailing]:
				posPT = .init(x: pt.x + w, y: pt.y + h)
				anchorPT = .init(x: 1.0, y: 1.0)
				()
			default:
				posPT = .init(x: pt.x - w, y: pt.y - h)
				anchorPT = .init(x: 0.0, y: 0.0)
				()
			}

			menuView.layer.position = posPT
			menuView.layer.anchorPoint = anchorPT
			tr = CGAffineTransform(scaleX: 0.1, y: 0.1)

		}

		menuView.layer.setAffineTransform(tr)

		UIView.animate(withDuration: 0.3, animations: {
			menuView.alpha = 1.0
			menuView.layer.setAffineTransform(.identity)
		}, completion: { _ in
			if menuView.layer.anchorPoint != .init(x: 0.5, y: 0.5) {
				menuView.layer.anchorPoint = .init(x: 0.5, y: 0.5)
				menuView.layer.position = pt
			}
			()
		})

		menuView.didSelectOption = { [weak self] i in
			guard let self = self else { return }
			var tr = CGAffineTransform(scaleX: 1.0, y: 1.0)
			if self.menuShouldZoom && !self.menuShouldCenter {
				menuView.layer.position = posPT
				menuView.layer.anchorPoint = anchorPT
				tr = CGAffineTransform(scaleX: 0.1, y: 0.1)
			}
			UIView.animate(withDuration: 0.3, animations: {
				menuView.layer.setAffineTransform(tr)
				menuView.alpha = 0.0
			}, completion: { _ in
				menuView.removeFromSuperview()
				self.doSomething(forSelectedOption: i, withObject: thisObject)
			})
		}
		
	}
	
	func doSomething(forSelectedOption: Int, withObject: SomeDataObject) {
		
		// if selected option is -1
		//	the user tapped outside the menu to dismiss it
		if forSelectedOption == -1 {
			print("User cancelled menu...")
		} else {
			print("View Selected option:", forSelectedOption)
			print("Data Object:", withObject)
			print()
		}
	}
}


class DidSelectViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	
	let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	
	var myData: [Int] = []
	var reloadCount: Int = 0
	
	var theOriginalData: [SomeDataObject] = []
	var theActiveData: [SomeDataObject] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// let's create 150 data objects (so the collection view can scroll)
		theOriginalData = (1...150).map({ SomeDataObject(title: "\($0)", otherData: "Some other data \($0)")})
		theActiveData = theOriginalData
		
		collectionView.dataSource = self
		collectionView.delegate = self

		collectionView.backgroundColor = .white
		collectionView.register(SimpleCollectionViewCell.self, forCellWithReuseIdentifier: "SimpleCell")

		// let's add
		
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(collectionView)
		
		let g = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			collectionView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
			collectionView.topAnchor.constraint(equalTo: g.topAnchor, constant: 80.0),
			collectionView.bottomAnchor.constraint(equalTo: g.bottomAnchor)
		])
		
		Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { t in
			//self.reloadCount += 1
			//self.myData.shuffle()
			self.theActiveData.shuffle()
			self.collectionView.reloadData()
			print("collection reloaded")
		})
		
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return theActiveData.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimpleCell", for: indexPath) as! SimpleCollectionViewCell
		cell.setup(value: theActiveData[indexPath.item].title)
		return cell
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let thisCell = collectionView.cellForItem(at: indexPath) else { return }
		let thisObject = theActiveData[indexPath.item]
		let vc = MyUIMenuVC()
		vc.title = "More Menu"
		vc.menuOptions = ["Share \(theActiveData[indexPath.item].title)"]
		vc.srcRect = collectionView.convert(thisCell.frame, to: self.view)
		vc.modalPresentationStyle = .overFullScreen
		vc.didSelectOption = { [weak self] i in
			guard let self = self else { return }
			self.dismiss(animated: true)
			self.doSomething(forSelectedOption: i, withObject: thisObject)
		}
		self.present(vc, animated: false)
	}
	
	func doSomething(forSelectedOption: Int, withObject: SomeDataObject) {
		// if selected option is -1
		//	the user tapped outside the menu to dismiss it
		if forSelectedOption == -1 {
			print("User cancelled menu...")
		} else {
			print("Selected option:", forSelectedOption)
			print("Data Object:", withObject)
			print()
		}
	}
}

class SimpleCollectionViewCell: UICollectionViewCell {
	
	let theLabel: UILabel = {
		let v = UILabel()
		v.textAlignment = .center
		return v
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() {
		backgroundColor = UIColor.lightGray
		theLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(theLabel)
		let g = contentView.layoutMarginsGuide
		NSLayoutConstraint.activate([
			theLabel.topAnchor.constraint(equalTo: g.topAnchor),
			theLabel.bottomAnchor.constraint(equalTo: g.bottomAnchor),
			theLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor),
			theLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor)
		])
	}
	
	func setup(value: String) {
		theLabel.text = value
	}
	
}

class MyUIMenuVC: UIViewController {
	
	public var didSelectOption: ((Int) -> ())?
	
	public var menuOptions: [String] = []
	public var srcRect: CGRect = .zero
	
	var bkgView: UIVisualEffectView!
	var srcGuide = UILayoutGuide()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let blurEffect = UIBlurEffect(style: .systemMaterial)
		bkgView = UIVisualEffectView(effect: blurEffect)
		bkgView.layer.cornerRadius = 12
		bkgView.clipsToBounds = true
		
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 0
		
		let titleLabel = PaddedLabel()
		titleLabel.padding = .init(top: 10.0, left: 18.0, bottom: 8.0, right: 18.0)
		titleLabel.font = .systemFont(ofSize: 12.0, weight: .regular)
		titleLabel.textColor = .gray
		
		titleLabel.text = self.title
		
		stackView.addArrangedSubview(titleLabel)
		
		for (i, str) in menuOptions.enumerated() {
		//menuOptions.forEach { str in
			let v = UIView()
			v.backgroundColor = .lightGray
			stackView.addArrangedSubview(v)
			v.heightAnchor.constraint(equalToConstant: view.window?.windowScene?.screen.scale == 2 ? 0.5 : 0.33).isActive = true
			
			let handler: UIButton.ConfigurationUpdateHandler = { button in
				var cfg = button.configuration
				switch button.state {
				case .highlighted:
					cfg?.baseBackgroundColor = UIColor(white: 0.0, alpha: 0.1)
				default:
					cfg?.baseBackgroundColor = .clear
				}
				button.configuration = cfg
			}
			var cfg = UIButton.Configuration.filled()
			cfg.title = str
			cfg.titleAlignment = .leading
			cfg.baseForegroundColor = .black
			cfg.cornerStyle = .fixed
			cfg.background.cornerRadius = 0.0
			cfg.contentInsets = .init(top: 12.0, leading: 16.0, bottom: 13.0, trailing: 16.0)
			let btn = UIButton(configuration: cfg, primaryAction: UIAction() { _ in
				UIView.animate(withDuration: 0.3, animations: {
					self.bkgView.alpha = 0.0
				}, completion: { _ in
					self.didSelectOption?(i)
				})
			})
			btn.contentHorizontalAlignment = .leading
			btn.configurationUpdateHandler = handler
			stackView.addArrangedSubview(btn)
		}
		
		stackView.translatesAutoresizingMaskIntoConstraints = false
		bkgView.contentView.addSubview(stackView)
		
		bkgView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(bkgView)
		
		view.addLayoutGuide(srcGuide)
		
		let g = view.safeAreaLayoutGuide
		
		NSLayoutConstraint.activate([
			
			stackView.topAnchor.constraint(equalTo: bkgView.topAnchor, constant: 0.0),
			stackView.leadingAnchor.constraint(equalTo: bkgView.leadingAnchor, constant: 0.0),
			stackView.trailingAnchor.constraint(equalTo: bkgView.trailingAnchor, constant: 0.0),
			stackView.bottomAnchor.constraint(equalTo: bkgView.bottomAnchor, constant: 0.0),
			
			
			srcGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: srcRect.origin.y),
			srcGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: srcRect.origin.x),
			srcGuide.heightAnchor.constraint(equalToConstant: srcRect.height),
			srcGuide.widthAnchor.constraint(equalToConstant: srcRect.width),
			
			bkgView.widthAnchor.constraint(equalToConstant: 250.0),
			bkgView.leadingAnchor.constraint(greaterThanOrEqualTo: g.leadingAnchor, constant: 8.0),
			bkgView.trailingAnchor.constraint(lessThanOrEqualTo: g.trailingAnchor, constant: -8.0),
			
		])
		
		view.backgroundColor = .clear
		bkgView.alpha = 0.0
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		var xc: NSLayoutConstraint!
		if srcRect.maxX > view.frame.midX {
			xc = bkgView.trailingAnchor.constraint(equalTo: srcGuide.trailingAnchor, constant: 2.0)
		} else {
			xc = bkgView.leadingAnchor.constraint(equalTo: srcGuide.leadingAnchor, constant: -2.0)
		}
		xc.priority = .required - 1
		xc.isActive = true
		if srcRect.maxY > view.frame.midY {
			bkgView.bottomAnchor.constraint(equalTo: srcGuide.topAnchor, constant: 2.0).isActive = true
		} else {
			bkgView.topAnchor.constraint(equalTo: srcGuide.bottomAnchor, constant: -2.0).isActive = true
		}
		
		UIView.animate(withDuration: 0.3, animations: {
			self.bkgView.alpha = 1.0
		})
	}
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let t = touches.first else { return }
		let pt = t.location(in: self.view)
		// if touch is outside the "menu" fade-out and dismiss
		if !bkgView.frame.contains(pt) {
			UIView.animate(withDuration: 0.3, animations: {
				self.bkgView.alpha = 0.0
			}, completion: { _ in
				self.didSelectOption?(-1)
			})
		}
	}
}
