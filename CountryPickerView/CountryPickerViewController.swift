//
//  CountryPickerViewController.swift
//  CountryPickerView
//
//  Created by Kizito Nwose on 18/09/2017.
//  Copyright © 2017 Kizito Nwose. All rights reserved.
//

import UIKit

class CustomSearchBar: UISearchBar {

    private var searchBgColor: UIColor = UIColor.white
    var searchTextFieldBackgroundColor: UIColor = UIColor.white
    var preferredFont: UIFont = UIFont.systemFont(ofSize: 13)
    var preferredTextColor: UIColor = UIColor(red: 0, green: 199/255.0, blue: 242/255.0, alpha: 1.0)
    var otherBtnColor: UIColor = UIColor(red: 0, green: 199/255.0, blue: 242/255.0, alpha: 1.0)
    var placeholderTextColor: UIColor = UIColor.darkGray
    var drawBottomLine : Bool = false
    var isFromLocation : Bool = false


    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)

        self.frame = frame
        preferredFont = font
        preferredTextColor = textColor

        searchBarStyle = UISearchBar.Style.prominent
        isTranslucent = false
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //Remove border at bottom of search bar
        layer.masksToBounds = true
    }

    public var searchbarBackgroundColor : UIColor {
        set (newValue){
            searchBgColor = newValue
            barTintColor = searchBgColor
        }
        get {
            return searchBgColor
        }
    }


    private func searchField() -> UITextField? {
        return self.subviewOfClass(className: "UITextField") as? UITextField
    }

    private func backgroundView() -> UIView? {
        return self.subviewOfClass(className: "_UISearchBarSearchFieldBackgroundView")
    }

    override func draw(_ rect: CGRect) {
        // Drawing code

        guard let searchField = searchField() else {
            super.draw(rect)
            return
        }
        self.setPositionAdjustment(UIOffset(horizontal: 8.0, vertical: 0.0), for: UISearchBar.Icon.search)
        searchField.font = preferredFont
        searchField.textColor = preferredTextColor
        searchField.backgroundColor = searchTextFieldBackgroundColor
        let iVar = class_getInstanceVariable(UITextField.self, "_placeholderLabel")!
        let placeholderLabel = object_getIvar(searchField, iVar) as! UILabel
        placeholderLabel.textColor = placeholderTextColor

        if (!isFromLocation) {
            searchField.layer.borderColor = UIColor(red: 13/255.0, green: 209/255.0, blue: 255/255.0, alpha: 1).cgColor
        searchField.layer.borderWidth = 1
        searchField.layer.masksToBounds = true
        searchField.layer.cornerRadius = min(searchField.bounds.size.width, searchField.bounds.size.height)/2
        }

        //Magnifying glass
        if let glassIconView = searchField.leftView as? UIImageView {
            glassIconView.image = UIImage(named: "CountryPickerView.bundle/Images/ic_search_blue",
                                          in: Bundle(for: CountryPickerView.self), compatibleWith: nil)
            //Magnifying glass
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            glassIconView.tintColor = otherBtnColor
        }

        //Magnifying glass
        if  let clearIconView = searchField.value(forKey: "clearButton") as? UIButton {
            clearIconView.setImage(UIImage(named: "CountryPickerView.bundle/Images/ic_clear",
                                           in: Bundle(for: CountryPickerView.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            clearIconView.tintColor = otherBtnColor
        }

        for view in self.subviews {
            for subview in view.subviews {
                if subview.isKind(of: UIButton.self)  {
                    let cancelButton = subview as! UIButton
                    //cancelButton.titleLabel?.font = self.preferredFont
                    cancelButton.setTitle("Cancel", for: .normal)
                    if let cancelText  = cancelButton.titleLabel?.text {
                        var frame = cancelButton.frame
                        let attributes = cancelButton.titleLabel?.font != nil ? [NSAttributedString.Key.font: cancelButton.titleLabel!.font!] : [:]
                        let size = (cancelText as NSString).size(withAttributes: attributes)
                        frame.size.width += size.width
                        frame.origin.x -= size.width/2
                        cancelButton.frame = frame
                        var frameSearchField = searchField.frame
                        frameSearchField.size.width -= 10
                        searchField.frame = frameSearchField
                    }

                    break
                }
            }
        }

        if drawBottomLine == true {
            let startPoint = CGPoint.init(x : 0.0, y : frame.size.height)
            let endPoint = CGPoint.init(x: frame.size.width, y: frame.size.height)
            let path = UIBezierPath()
            path.move(to: startPoint)
            path.addLine(to: endPoint)

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0).cgColor
            shapeLayer.lineWidth = 1.0
            layer.addSublayer(shapeLayer)
        }

        super.draw(rect)
    }

}


extension UIView {

    /**
     Method on UIView that will search recursivelly in all the receiver subviews to find a subview belonging to a specific class.

     - parameter className: A string representing the class name

     - returns: The first subview of the specific class that has been found. If no subviews belong to the class, nil will be return.
     */
    func subviewOfClass (className:String) -> UIView? {

        guard let aClass = NSClassFromString(className) else {
            return nil
        }

        for subview in self.subviews {

            if subview.isKind(of : aClass) {
                return subview

            } else if let subviewOfClass = subview.subviewOfClass(className: className) {
                return subviewOfClass
            }
        }
        return nil
    }

    /**
     Method on UIView that will search recursivelly in all the receiver subviews to find all subview belonging to a specific class.

     - parameter className: A string representing the class name

     - returns: An array containing all the subviews of the specific class that have been found. If no subviews belong to the class, nil will be return.
     */
    func subviewsOfClass (className:String) -> Array<UIView>? {

        guard let aClass = NSClassFromString(className) else {
            return nil
        }
        var arrayOfViews : Array<UIView> = []

        for subview in self.subviews {

            if subview.isKind(of : aClass) {
                arrayOfViews.append(subview)

            } else if let subviewsOfClass = subview.subviewsOfClass(className: className) {
                arrayOfViews.append(contentsOf: subviewsOfClass)
            }
        }
        if arrayOfViews.count > 0 {return arrayOfViews}
        else {return nil}
    }
}

public class DSearchController: UISearchController {

    private var customSearchBar = CustomSearchBar(frame: CGRect.zero, font: UIFont.systemFont(ofSize: 18) , textColor: .black)
    override public var searchBar: UISearchBar {
        get {
            return customSearchBar
        }
    }
}

public class CountryPickerViewController: UITableViewController {

    public var searchController: DSearchController?
    fileprivate var searchResults = [Country]()
    fileprivate var isSearchMode = false
    fileprivate var sectionsTitles = [String]()
    fileprivate var countries = [String: [Country]]()
    fileprivate var hasPreferredSection: Bool {
        return dataSource.preferredCountriesSectionTitle != nil &&
            dataSource.preferredCountries.count > 0
    }
    fileprivate var showOnlyPreferredSection: Bool {
        return dataSource.showOnlyPreferredSection
    }
    internal weak var countryPickerView: CountryPickerView! {
        didSet {
            dataSource = CountryPickerViewDataSourceInternal(view: countryPickerView)
        }
    }
    
    fileprivate var dataSource: CountryPickerViewDataSourceInternal!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.autoresizesSubviews = true
        prepareTableItems()
        prepareNavItem()
        prepareSearchBar()
    }
   
}

// UI Setup
extension CountryPickerViewController {
    
    func prepareTableItems()  {
        if !showOnlyPreferredSection {
            let countriesArray = countryPickerView.usableCountries
            let locale = dataSource.localeForCountryNameInList
            
            var groupedData = Dictionary<String, [Country]>(grouping: countriesArray) {
                let name = $0.localizedName(locale) ?? $0.name
                return String(name.capitalized[name.startIndex])
            }
            groupedData.forEach{ key, value in
                groupedData[key] = value.sorted(by: { (lhs, rhs) -> Bool in
                    return lhs.localizedName(locale) ?? lhs.name < rhs.localizedName(locale) ?? rhs.name
                })
            }
            
            countries = groupedData
            sectionsTitles = groupedData.keys.sorted()
        }
        
        // Add preferred section if data is available
        if hasPreferredSection, let preferredTitle = dataSource.preferredCountriesSectionTitle {
            sectionsTitles.insert(preferredTitle, at: sectionsTitles.startIndex)
            countries[preferredTitle] = dataSource.preferredCountries
        }
        
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexTrackingBackgroundColor = .clear
    }
    
    func prepareNavItem() {
        navigationItem.title = dataSource.navigationTitle

        // Add a close button if this is the root view controller
        if navigationController?.viewControllers.count == 1 {
            let closeButton = dataSource.closeButtonNavigationItem
            closeButton.target = self
            closeButton.action = #selector(close)
            navigationItem.leftBarButtonItem = closeButton
        }
    }
    
    func prepareSearchBar() {
        let searchBarPosition = dataSource.searchBarPosition
        if searchBarPosition == .hidden  {
            return
        }
        searchController = DSearchController(searchResultsController:  nil)
        searchController?.searchBar.placeholder = "Search"
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.hidesNavigationBarDuringPresentation = searchBarPosition == .tableViewHeader
        searchController?.definesPresentationContext = true
        searchController?.searchBar.delegate = self
        searchController?.delegate = self
        searchController?.searchBar.sizeToFit()
        switch searchBarPosition {
        case .tableViewHeader: tableView.tableHeaderView = searchController?.searchBar
        case .navigationBar: navigationItem.titleView = searchController?.searchBar
        default: break
        }
    }
    
    @objc private func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

//MARK:- UITableViewDataSource
extension CountryPickerViewController {
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return isSearchMode ? 1 : sectionsTitles.count
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? searchResults.count : countries[sectionsTitles[section]]!.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: CountryTableViewCell.self)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CountryTableViewCell
            ?? CountryTableViewCell(style: .default, reuseIdentifier: identifier)
        
        let country = isSearchMode ? searchResults[indexPath.row]
            : countries[sectionsTitles[indexPath.section]]![indexPath.row]

        var name = country.localizedName(dataSource.localeForCountryNameInList) ?? country.name
        if dataSource.showCountryCodeInList {
            name = "\(name) (\(country.code))"
        }
        if dataSource.showPhoneCodeInList {
            name = "\(name) (\(country.phoneCode))"
        }
        cell.imageView?.image = country.flag
        
        cell.flgSize = dataSource.cellImageViewSize
        cell.imageView?.clipsToBounds = true

        cell.imageView?.layer.cornerRadius = dataSource.cellImageViewCornerRadius
        cell.imageView?.layer.masksToBounds = true
        
        cell.textLabel?.text = name
        cell.textLabel?.font = dataSource.cellLabelFont
        if let color = dataSource.cellLabelColor {
            cell.textLabel?.textColor = color
        }
        cell.accessoryType = country == countryPickerView.selectedCountry &&
            dataSource.showCheckmarkInList ? .checkmark : .none
        cell.separatorInset = .zero
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isSearchMode ? nil : sectionsTitles[section]
    }
    
    override public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isSearchMode {
            return nil
        } else {
            if hasPreferredSection {
                return Array<String>(sectionsTitles.dropFirst())
            }
            return sectionsTitles
        }
    }
    
    override public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectionsTitles.firstIndex(of: title)!
    }
}

//MARK:- UITableViewDelegate
extension CountryPickerViewController {

    override public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = dataSource.sectionTitleLabelFont
            if let color = dataSource.sectionTitleLabelColor {
                header.textLabel?.textColor = color
            }
        }
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let country = isSearchMode ? searchResults[indexPath.row]
            : countries[sectionsTitles[indexPath.section]]![indexPath.row]

        searchController?.isActive = false
        searchController?.dismiss(animated: false, completion: nil)
        
        let completion = {
            self.countryPickerView.selectedCountry = country
        }
        // If this is root, dismiss, else pop
        if navigationController?.viewControllers.count == 1 {
            navigationController?.dismiss(animated: true, completion: completion)
        } else {
            navigationController?.popViewController(animated: true, completion: completion)
        }
    }
}

// MARK:- UISearchResultsUpdating
extension CountryPickerViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        isSearchMode = false
        if let text = searchController.searchBar.text, text.count > 0 {
            isSearchMode = true
            searchResults.removeAll()
            
            var indexArray = [Country]()
            
            if showOnlyPreferredSection && hasPreferredSection,
                let array = countries[dataSource.preferredCountriesSectionTitle!] {
                indexArray = array
            } else if let array = countries[String(text.capitalized[text.startIndex])] {
                indexArray = array
            }

            searchResults.append(contentsOf: indexArray.filter({
                let name = ($0.localizedName(dataSource.localeForCountryNameInList) ?? $0.name).lowercased()
                let code = $0.code.lowercased()
                let query = text.lowercased()
                return name.hasPrefix(query) || (dataSource.showCountryCodeInList && code.hasPrefix(query))
            }))
        }
        tableView.reloadData()
    }
}

// MARK:- UISearchBarDelegate
extension CountryPickerViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Hide the back/left navigationItem button
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Show the back/left navigationItem button
        prepareNavItem()
        navigationItem.hidesBackButton = false
    }
}

// MARK:- UISearchControllerDelegate
// Fixes an issue where the search bar goes off screen sometimes.
extension CountryPickerViewController: UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = false
    }
}

// MARK:- CountryTableViewCell.
class CountryTableViewCell: UITableViewCell {
    
    var flgSize: CGSize = .zero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame.size = flgSize
        imageView?.center.y = contentView.center.y
    }
}


// MARK:- An internal implementation of the CountryPickerViewDataSource.
// Returns default options where necessary if the data source is not set.
class CountryPickerViewDataSourceInternal: CountryPickerViewDataSource {
    
    private unowned var view: CountryPickerView
    
    init(view: CountryPickerView) {
        self.view = view
    }
    
    var preferredCountries: [Country] {
        return view.dataSource?.preferredCountries(in: view) ?? preferredCountries(in: view)
    }
    
    var preferredCountriesSectionTitle: String? {
        return view.dataSource?.sectionTitleForPreferredCountries(in: view)
    }
    
    var showOnlyPreferredSection: Bool {
        return view.dataSource?.showOnlyPreferredSection(in: view) ?? showOnlyPreferredSection(in: view)
    }
    
    var sectionTitleLabelFont: UIFont {
        return view.dataSource?.sectionTitleLabelFont(in: view) ?? sectionTitleLabelFont(in: view)
    }

    var sectionTitleLabelColor: UIColor? {
        return view.dataSource?.sectionTitleLabelColor(in: view)
    }
    
    var cellLabelFont: UIFont {
        return view.dataSource?.cellLabelFont(in: view) ?? cellLabelFont(in: view)
    }
    
    var cellLabelColor: UIColor? {
        return view.dataSource?.cellLabelColor(in: view)
    }
    
    var cellImageViewSize: CGSize {
        return view.dataSource?.cellImageViewSize(in: view) ?? cellImageViewSize(in: view)
    }
    
    var cellImageViewCornerRadius: CGFloat {
        return view.dataSource?.cellImageViewCornerRadius(in: view) ?? cellImageViewCornerRadius(in: view)
    }
    
    var navigationTitle: String? {
        return view.dataSource?.navigationTitle(in: view)
    }
    
    var closeButtonNavigationItem: UIBarButtonItem {
        guard let button = view.dataSource?.closeButtonNavigationItem(in: view) else {
            return UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        }
        return button
    }
    
    var searchBarPosition: SearchBarPosition {
        return view.dataSource?.searchBarPosition(in: view) ?? searchBarPosition(in: view)
    }
    
    var showPhoneCodeInList: Bool {
        return view.dataSource?.showPhoneCodeInList(in: view) ?? showPhoneCodeInList(in: view)
    }
    
    var showCountryCodeInList: Bool {
        return view.dataSource?.showCountryCodeInList(in: view) ?? showCountryCodeInList(in: view)
    }
    
    var showCheckmarkInList: Bool {
        return view.dataSource?.showCheckmarkInList(in: view) ?? showCheckmarkInList(in: view)
    }
    
    var localeForCountryNameInList: Locale {
        return view.dataSource?.localeForCountryNameInList(in: view) ?? localeForCountryNameInList(in: view)
    }
    
    var excludedCountries: [Country] {
        return view.dataSource?.excludedCountries(in: view) ?? excludedCountries(in: view)
    }
}
