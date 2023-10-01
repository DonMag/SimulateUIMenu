//
//  ViewController.swift
//  SimulateUIMenu
//
//  Created by Don Mag on 9/30/23.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}


}

class MenuTestViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	
	let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	
	var myData: [Int] = []
	var reloadCount: Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		myData = Array(0...150)
		
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = .white
		collectionView.register(DonMagCollectionViewCell.self, forCellWithReuseIdentifier: "DonMagCell")
		collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
		
		view.addSubview(collectionView)
		
		let g = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			collectionView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
			collectionView.topAnchor.constraint(equalTo: g.topAnchor, constant: 80.0),
			collectionView.bottomAnchor.constraint(equalTo: g.bottomAnchor)
		])
		
		Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { t in
			self.reloadCount += 1
			self.myData.shuffle()
			self.collectionView.reloadData()
			print("collection reloaded")
		})
		
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return myData.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if indexPath.item % 5 == 1 {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DonMagCell", for: indexPath) as! DonMagCollectionViewCell
			
			cell.setup(value: myData[indexPath.item])
			cell.contentView.backgroundColor = .systemBlue
			
			cell.myCallback = { [weak self] aCell in
				guard let self = self,
					  let thisCell = aCell as? DonMagCollectionViewCell,
					  let idx = collectionView.indexPath(for: thisCell)
				else { return }
				let vc = MyMenuVC()
				vc.title = "More Menu"
				vc.menuOptions = ["Share \(myData[idx.item])"]
				vc.srcRect = collectionView.convert(thisCell.frame, to: self.view)
				vc.modalPresentationStyle = .overFullScreen
				self.present(vc, animated: false)
			}
			
			return cell
		}
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCollectionViewCell
		
		cell.setup(value: myData[indexPath.item])
		
		return cell
		
	}
}

class MyMenuVC: UIViewController {
	
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
		
		menuOptions.forEach { str in
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
			let btn = UIButton(configuration: cfg)
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
		if !bkgView.frame.contains(pt) {
			UIView.animate(withDuration: 0.3, animations: {
				self.bkgView.alpha = 0.0
			}, completion: { _ in
				self.presentingViewController?.dismiss(animated: false)
			})
		}
	}
}

class DonMagCollectionViewCell: UICollectionViewCell {
	
	var myCallback: ((UICollectionViewCell) -> ())?
	
	let moreButton: UIButton!
	
	override init(frame: CGRect) {
		moreButton = UIButton()
		super.init(frame: frame)
		
		moreButton.addTarget(self, action: #selector(btnTap(_:)), for: .touchUpInside)
		backgroundColor = UIColor.lightGray
		
		contentView.addSubview(moreButton)
		moreButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			moreButton.topAnchor.constraint(equalTo: topAnchor),
			moreButton.bottomAnchor.constraint(equalTo: bottomAnchor),
			moreButton.leadingAnchor.constraint(equalTo: leadingAnchor),
			trailingAnchor.constraint(equalTo: moreButton.trailingAnchor)
		])
	}
	
	@objc func btnTap(_ sender: Any?) {
		myCallback?(self)
	}
	
	func setup(value: Int) {
		moreButton.setTitle("\(value)", for: .normal)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class MyCollectionViewCell: UICollectionViewCell {
	let moreButton: UIButton!
	var value: Int = -1
	
	override init(frame: CGRect) {
		moreButton = UIButton()
		super.init(frame: frame)
		
		moreButton.setTitle("More", for: .normal)
		moreButton.menu = UIMenu(
			title: "More Menu",
			image: nil,
			identifier: nil,
			options: [],
			children: [
				UIAction(title: "Share") { [weak self] _ in
					guard let self else { return }
					print("Share \(self.value)")
				}
			]
		)
		moreButton.showsMenuAsPrimaryAction = true
		backgroundColor = UIColor.lightGray
		
		addSubview(moreButton)
		moreButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			moreButton.topAnchor.constraint(equalTo: topAnchor),
			moreButton.bottomAnchor.constraint(equalTo: bottomAnchor),
			moreButton.leadingAnchor.constraint(equalTo: leadingAnchor),
			trailingAnchor.constraint(equalTo: moreButton.trailingAnchor)
		])
	}
	
	func setup(value: Int) {
		moreButton.setTitle("\(value)", for: .normal)
		self.value = value
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class PaddedLabel: UILabel {
	var padding: UIEdgeInsets = .zero
	override func drawText(in rect: CGRect) {
		super.drawText(in: rect.inset(by: padding))
	}
	override var intrinsicContentSize : CGSize {
		let sz = super.intrinsicContentSize
		return CGSize(width: sz.width + padding.left + padding.right, height: sz.height + padding.top + padding.bottom)
	}
}
