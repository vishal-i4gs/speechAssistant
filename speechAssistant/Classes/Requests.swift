//
//  Requests.swift
//  speechAssistant
//
//  Created by Vishal on 01/08/20.
//

import Foundation

extension Dictionary {
	mutating func merge(dict: [Key: Value]){
		for (k, v) in dict {
			updateValue(v, forKey: k)
		}
	}
}

typealias UploadDataToGoogleCloudCompletionHandler = (
	_ fileSize:Float, _ fileName:String, _ fileUrl:String,
	_ success:Bool, _ error:Error?) -> (Void)

class Requests:RequestManager {
	
	///The  method that is used to upload the audio data to the cloud.
	///
	///- Parameters:
	///	 - mutableData : The  NSMutableData object of the audioData.
	///  - completionHandler : The completion block which contains the `fileSize`, `fileName` and `fileUrl`
	///  - fileSize : fileSize is `Float` variable which indicates the size of the file uploaded in kilobytes.
	///  - fileName : fileName is a `String` object which contains the name of the file.
	///  - fileUrl : fileUrl is a `String` object which contains the cloud url of the file.
	///  - success : success is `Bool` variable which indicates whether the API call succeded or not.
	///  - error : error is an `Error` object which will be will nil if the API call succeeded.
	///
	func uploadDataToGoogleCloud(
		_ mutableData: NSMutableData,
		metaData: [String:String],
		completionHandler: UploadDataToGoogleCloudCompletionHandler?) {
		let fileName = UUID().uuidString
		let uploadUrl = audioUploadBaseUrl+fileName
		let data = Data(referencing: mutableData)
		
		var request = URLRequest(url: URL(string: uploadUrl)!)
		request.httpMethod = "POST"
		request.addValue("audio/pcm", forHTTPHeaderField: "Content-Type")
		let uploadSession = getSession()
		request.httpBody = data
		
		// The upload task using NSURLSession
		let uploadTask = uploadSession.uploadTask(with: request, from: data) {
			(data, response, error) in
			if error == nil {
				guard data != nil else {return}
				let httpResponse = response as? HTTPURLResponse
				let statusCode = httpResponse!.statusCode;
				var jsonData = [String:String]()
				jsonData.merge(dict: metaData)
				jsonData["url"] = audioGetReqBaseUrl+fileName
				DispatchQueue.main.async {
					completionHandler?(Float(mutableData.length).BtoKb(),
														 fileName,
														 jsonData["url"]!,
														 error == nil ? true:false, error);
				}
				if statusCode == 200 || statusCode == 201 {
					self.writeToRealTimeDB(jsonData)
				}
			}
		}
		
		uploadTask.resume()
	}
	
	///The  method that is used to log the upload with related meta to firebase realtimeDB.
	///
	///- Parameters:
	///	 - postData : The post data dictionary that needs to updated.
	///
	private func writeToRealTimeDB(_ postData:[String:String]) {
		var request = URLRequest(url: URL(string: metaDataPostUrl)!)
		request.httpMethod = "POST"
		let encoded = try! JSONEncoder().encode(postData)
		request.httpBody = encoded
		let session = URLSession.shared
		let writeToRealTimeDBTask = session
			.dataTask(with: request as URLRequest) {
				data, response, error in
				if(error != nil) {
					DispatchQueue.main.async {
					}
					return
				}
		}
		writeToRealTimeDBTask.resume()
	}
	
}
