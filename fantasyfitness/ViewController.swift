//
//  ViewController.swift
//  fantasyfitness
//
//  Created by Johnny Chan on 12/17/14.
//  Copyright (c) 2014 llamaface. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		if (NSClassFromString("HKHealthStore") != nil && HKHealthStore.isHealthDataAvailable()) {
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
						
						// Your interval: sum by hour
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
							(query: HKStatisticsCollectionQuery!, result: HKStatisticsCollection!, error: NSError!) -> Void in
							if error != nil {
								println(error)
								return
							}
							println(result)
							
						}


						// Get results in day format instead of small increments.
//						var sampleQuery: HKSampleQuery = HKSampleQuery(
//							sampleType: sampleType,
//							predicate: predicate,
//							limit: 0,
//							sortDescriptors: [sortDescriptor],
//							resultsHandler: { (query: HKSampleQuery!, results: [AnyObject]!, error: NSError?) -> Void in
//								if error != nil {
//									println(error)
//									return
//								}
//								for result in results as [HKQuantitySample]! {
//									println(result)
//								}
//						})
						
						

						
						// Execute the query
						healthStore.executeQuery(query)
					}
					else {
						
					}
			})
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

