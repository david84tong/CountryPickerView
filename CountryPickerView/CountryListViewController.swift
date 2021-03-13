//
//  CountryListViewController.swift
//  CountryPickerView
//
//  Created by David Tong on 3/13/21.
//

import UIKit

public class CountryListViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var searchBarField : UITextField!
    @IBOutlet weak var searchBarView : UIView!
    @IBOutlet weak var searchIconView : UIImageView!

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

    private let defaultColor = UIColor(red: 0, green: 199/255.0, blue: 242/255.0, alpha: 1.0)

    public var searchBorderColor : UIColor = UIColor(red: 0, green: 199/255.0, blue: 242/255.0, alpha: 1.0) {
        didSet {
            searchBarView.layer.borderColor = searchBorderColor.cgColor
        }
    }

    public var searchIconColor : UIColor = UIColor(red: 0, green: 199/255.0, blue: 242/255.0, alpha: 1.0) {
        didSet {
            searchIconView.tintColor = searchIconColor
        }
    }
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        prepareTableItems()
        prepareNavItem()
    }

    private func prepareTableItems()  {
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexTrackingBackgroundColor = .clear
    }

    private func prepareNavItem() {
        navigationItem.title = dataSource.navigationTitle

        // Add a close button if this is the root view controller
        if navigationController?.viewControllers.count == 1 {
            let closeButton = dataSource.closeButtonNavigationItem
            closeButton.target = self
            closeButton.action = #selector(close)
            navigationItem.leftBarButtonItem = closeButton
        }
    }

    @objc private func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    private func setupView() {
        searchBarField.returnKeyType = .search
        searchBarField.delegate = self
        searchIconView.image = UIImage(named: "CountryPickerView.bundle/Images/ic_search_blue",
                                       in: Bundle(for: CountryPickerView.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        searchIconView.tintColor = defaultColor
        searchBarView.layer.cornerRadius = searchBarView.frame.height/2
        searchBarView.layer.masksToBounds = true
        searchBarView.layer.borderWidth = 1.0
        searchBarView.layer.borderColor = UIColor(red: 0, green: 199/255.0, blue: 242/255.0, alpha: 1.0).cgColor
    }

    func searchByKeyWord(_ query : String) {
        isSearchMode = false
        if query.count > 0 {
            isSearchMode = true
            searchResults.removeAll()
            var indexArray = [Country]()
            if showOnlyPreferredSection && hasPreferredSection,
                let array = countries[dataSource.preferredCountriesSectionTitle!] {
                indexArray = array
            } else if let array = countries[String(query.capitalized[query.startIndex])] {
                indexArray = array
            }
            searchResults.append(contentsOf: indexArray.filter({
                let name = ($0.localizedName(dataSource.localeForCountryNameInList) ?? $0.name).lowercased()
                let code = $0.code.lowercased()
                let query = query.lowercased()
                return name.hasPrefix(query) || (dataSource.showCountryCodeInList && code.hasPrefix(query))
            }))
        }
        tableView.reloadData()
    }

}

extension CountryListViewController : UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchByKeyWord(textField.text ?? "")
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let previousText:NSString = textField.text as NSString? {
            let updatedText = previousText.replacingCharacters(in: range, with: string)
            searchByKeyWord(updatedText)
        }
        return true
    }
}


extension CountryListViewController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return isSearchMode ? 1 : sectionsTitles.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? searchResults.count : countries[sectionsTitles[section]]!.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isSearchMode ? nil : sectionsTitles[section]
    }

    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isSearchMode {
            return nil
        } else {
            if hasPreferredSection {
                return Array<String>(sectionsTitles.dropFirst())
            }
            return sectionsTitles
        }
    }

    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectionsTitles.firstIndex(of: title)!
    }
}

//MARK:- UITableViewDelegate
extension CountryListViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = dataSource.sectionTitleLabelFont
            if let color = dataSource.sectionTitleLabelColor {
                header.textLabel?.textColor = color
            }
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let country = isSearchMode ? searchResults[indexPath.row]
            : countries[sectionsTitles[indexPath.section]]![indexPath.row]

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
