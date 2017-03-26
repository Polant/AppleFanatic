//
//  String+HTMLEncoding.swift
//  AppleFanatic
//
//  Created by Anton Poltoratskyi on 26.03.17.
//
//

extension String {
    func removingHTMLEncoding() -> String {
        let result = self.replacingOccurrences(of: "+", with: " ")
        return result.removingPercentEncoding ?? result
    }
}
