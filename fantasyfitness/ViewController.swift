//
//  ViewController.swift
//  fantasyfitness
//
//  Created by Johnny Chan on 12/17/14.
//  Copyright (c) 2014 llamaface. All rights reserved.
//

import UIKit
import HealthKit

class LLStepCell: UITableViewCell {
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var stepsLabel: UILabel!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
	var statistics: NSArray?
	
	override func viewDidLoad() {
		super.viewDidLoad()

		if (NSClassFromString("HKHealthStore") != nil && HKHealthStore.isHealthDataAvailable()) {
			SVProgressHUD.showWithStatus("Loading Data...")
			
			let healthStore: HKHealthStore = HKHealthStore()
			let objectTypes: NSSet = NSSet(object: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount))
			healthStore.requestAuthorizationToShareTypes(nil,
				readTypes: objectTypes,
				completion: { (success: Bool, error: NSError!) -> Void in
					if success {
						// Set your start and end date for your query of interest
						var startDate: NSDate = NSDate(timeIntervalSince1970: 0)
						var endDate: NSDate = NSDate()
						var anchorDate: NSDate = NSDate(timeIntervalSince1970: 0)
						
						// Use the sample type for step count
						let quantityType: HKQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
						
						// Your interval: sum by day
						var intervalComponents: NSDateComponents = NSDateComponents()
						intervalComponents.day = 1;
						
						// Create a predicate to set start/end date bounds of the query
						let predicate: NSPredicate = HKQuery.predicateForSamplesWithStartDate(
							startDate,
							endDate: endDate,
							options: HKQueryOptions.StrictStartDate)
						
						// Create a sort descriptor for sorting by start date
						let sortDescriptor: NSSortDescriptor = NSSortDescriptor(
							key: HKSampleSortIdentifierStartDate,
							ascending: true)
						
						var query: HKStatisticsCollectionQuery = HKStatisticsCollectionQuery(
							quantityType: quantityType,
							quantitySamplePredicate: predicate,
							options: HKStatisticsOptions.CumulativeSum,
							anchorDate: anchorDate,
							intervalComponents: intervalComponents)
						
						query.initialResultsHandler = {
							query, results, error in
							if error != nil {
								println(error)
								abort()
							}

							// Save copy of the statistics, then load data in the table view.
							self.statistics = results.statistics()

							dispatch_async(dispatch_get_main_queue()) {
								self.tableView.reloadData()
								SVProgressHUD.dismiss()
							}
						}

						// Execute the query
						healthStore.executeQuery(query)
					}
					else {
						dispatch_async(dispatch_get_main_queue()) {
							SVProgressHUD.dismiss()
						}
					}
			})
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: LLStepCell = tableView.dequeueReusableCellWithIdentifier("stepCell") as LLStepCell
		
		if statistics == nil {
			return cell
		}
		
		let stat: HKStatistics = statistics![indexPath.row] as HKStatistics
		
		cell.dateLabel.text = NSDateFormatter.localizedStringFromDate(
			stat.startDate,
			dateStyle: NSDateFormatterStyle.ShortStyle,
			timeStyle: NSDateFormatterStyle.ShortStyle)

		var value: Double = 0
		if let quantity = stat.sumQuantity() {
			value = quantity.doubleValueForUnit(HKUnit.countUnit())
		}
		
		cell.stepsLabel.text = String(format: "%.1f", value)
		
		return cell
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if statistics == nil {
			return 0
		}
		
		return self.statistics!.count
	}
}

