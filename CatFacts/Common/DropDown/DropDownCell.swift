//
//  DropDownCellTableViewCell.swift
//  DropDown
//
//  Created by Kevin Hirsch on 28/07/15.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

internal final class DropDownCell: UITableViewCell {
	
	//MARK: - Properties
	static let Nib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
	
	//UI
	@IBOutlet weak var optionLabel: UILabel!
	
	var selectedBackgroundColor: UIColor?

}

//MARK: - UI

internal extension DropDownCell {
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		backgroundColor = UIColor.clear
	}
	
	override var isSelected: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override var isHighlighted: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		setSelected(highlighted, animated: animated)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		let executeSelection: () -> Void = { [unowned self] in
			if let selectedBackgroundColor = self.selectedBackgroundColor {
				if selected {
					self.backgroundColor = selectedBackgroundColor
				} else {
					self.backgroundColor = UIColor.clear
				}
			}
		}
		
		if animated {
			UIView.animate(withDuration: 0.3, animations: {
				executeSelection()
			})
		} else {
			executeSelection()
		}
	}
	
}
