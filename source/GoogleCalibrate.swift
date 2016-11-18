//
//  GoogleCalibrate.swift
//  SkyLovely-iOS
//
//  Created by PJ on 17/11/2016.
//  Copyright © 2016 SkyLovely Pty Ltd. All rights reserved.
//

import Foundation
import CoreTelephony

extension NSDate {
    
    // Fetch UTC time from google's servers.
    // Handy if you don't control your own server. Also useful to operate after observing `UIApplicationWillEnterForegroundNotification`.
    static func calibrate() {
        
        //Get user's country code
        var countryCode: String!
        
        countryCode = CTTelephonyNetworkInfo().subscriberCellularProvider?.isoCountryCode
        if countryCode == nil {
            countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
        }
        guard countryCode != nil else { return }
        
        countryCode = countryCode.uppercaseString
        
        // Data is from: https://en.wikipedia.org/wiki/List_of_Google_domains AND https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
        let googleUrls: [String: String] = [
            "AD":"google.ad",
            "AE":"google.ae",
            "AF":"google.com.af",
            "AG":"google.com.ag",
            "AI":"google.com.ai",
            "AL":"google.al",
            "AM":"google.am",
            "AO":"google.co.ao",
            "AR":"google.com.ar",
            "AS":"google.as",
            "AT":"google.at",
            "AU":"google.com.au",
            "AZ":"google.az",
            "BA":"google.ba",
            "BD":"google.com.bd",
            "BE":"google.be",
            "BF":"google.bf",
            "BG":"google.bg",
            "BH":"google.com.bh",
            "BI":"google.bi",
            "BJ":"google.bj",
            "BR":"google.com.br",
            "BS":"google.bs",
            "BT":"google.bt",
            "BW":"google.co.bw",
            "BY":"google.by",
            "BZ":"google.com.bz",
            "CA":"google.ca",
            "CC":"google.cc",
            "CF":"google.cf",
            "CH":"google.ch",
            "CK":"google.co.ck",
            "CL":"google.cl",
            "CM":"google.cm",
            "CN":"google.cn",
            "CO":"google.com.co",
            "CR":"google.co.cr",
            "CU":"google.com.cu",
            "CY":"google.com.cy",
            "DE":"google.de",
            "DJ":"google.dj",
            "DK":"google.dk",
            "DM":"google.dm",
            "DO":"google.com.do",
            "DZ":"google.dz",
            "EC":"google.com.ec",
            "EE":"google.ee",
            "EG":"google.com.eg",
            "ES":"google.es",
            "ET":"google.com.et",
            "FI":"google.fi",
            "FJ":"google.com.fj",
            "FR":"google.fr",
            "GA":"google.ga",
            "GB":"google.co.uk",
            "GE":"google.ge",
            "GF":"google.gf",
            "GG":"google.gg",
            "GH":"google.com.gh",
            "GI":"google.com.gi",
            "GL":"google.gl",
            "GM":"google.gm",
            "GP":"google.gp",
            "GR":"google.gr",
            "GT":"google.com.gt",
            "GY":"google.gy",
            "HK":"google.com.hk",
            "HN":"google.hn",
            "HR":"google.hr",
            "HT":"google.ht",
            "HU":"google.hu",
            "ID":"google.co.id",
            "IE":"google.ie",
            "IL":"google.co.il",
            "IM":"google.im",
            "IN":"google.co.in",
            "IO":"google.io",
            "IQ":"google.iq",
            "IS":"google.is",
            "IT":"google.it",
            "JE":"google.je",
            "JM":"google.com.jm",
            "JO":"google.jo",
            "JP":"google.co.jp",
            "KE":"google.co.ke",
            "KG":"google.kg",
            "KH":"google.com.kh",
            "KI":"google.ki",
            "KW":"google.com.kw",
            "KZ":"google.kz",
            "LB":"google.com.lb",
            "LC":"google.com.lc",
            "LI":"google.li",
            "LK":"google.lk",
            "LS":"google.co.ls",
            "LT":"google.lt",
            "LU":"google.lu",
            "LV":"google.lv",
            "LY":"google.com.ly",
            "MA":"google.co.ma",
            "ME":"google.me",
            "MG":"google.mg",
            "ML":"google.ml",
            "MM":"google.com.mm",
            "MN":"google.mn",
            "MS":"google.ms",
            "MT":"google.com.mt",
            "MU":"google.mu",
            "MV":"google.mv",
            "MW":"google.mw",
            "MX":"google.com.mx",
            "MY":"google.com.my",
            "MZ":"google.co.mz",
            "NA":"google.com.na",
            "NE":"google.ne",
            "NF":"google.com.nf",
            "NG":"google.com.ng",
            "NI":"google.com.ni",
            "NL":"google.nl",
            "NO":"google.no",
            "NP":"google.com.np",
            "NR":"google.nr",
            "NU":"google.nu",
            "NZ":"google.co.nz",
            "OM":"google.com.om",
            "PA":"google.com.pa",
            "PE":"google.com.pe",
            "PG":"google.com.pg",
            "PH":"google.com.ph",
            "PK":"google.com.pk",
            "PL":"google.pl",
            "PR":"google.com.pr",
            "PT":"google.pt",
            "PY":"google.com.py",
            "QA":"google.com.qa",
            "RO":"google.ro",
            "RS":"google.rs",
            "RW":"google.rw",
            "SA":"google.com.sa",
            "SB":"google.com.sb",
            "SC":"google.sc",
            "SE":"google.se",
            "SG":"google.com.sg",
            "SH":"google.sh",
            "SI":"google.si",
            "SK":"google.sk",
            "SL":"google.com.sl",
            "SM":"google.sm",
            "SN":"google.sn",
            "SO":"google.so",
            "SR":"google.sr",
            "ST":"google.st",
            "SV":"google.com.sv",
            "TD":"google.td",
            "TG":"google.tg",
            "TH":"google.co.th",
            "TJ":"google.com.tj",
            "TK":"google.tk",
            "TL":"google.tl",
            "TM":"google.tm",
            "TN":"google.tn",
            "TO":"google.to",
            "TR":"google.com.tr",
            "TT":"google.tt",
            "UA":"google.com.ua",
            "UG":"google.co.ug",
            "UY":"google.com.uy",
            "UZ":"google.co.uz",
            "VC":"google.com.vc",
            "VU":"google.vu",
            "WS":"google.ws",
            "ZA":"google.co.za",
            "ZM":"google.co.zm",
            "ZW":"google.co.zw",
        ]
        
        var googleUrl: String! = googleUrls[countryCode]
        if googleUrl == nil {
            googleUrl = "google.com"
        }
        googleUrl = "http://" + googleUrl

        let url = NSURL(string: googleUrl)
        let request = NSMutableURLRequest(URL:url!);
        request.HTTPMethod = "HEAD"
        
        let clientRequestTime: Int64 = NSDate.UTCToUnixNano()
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            guard error == nil else { return }
            
            //UTC server-client synchronisation
            let dateString: String = (response as! NSHTTPURLResponse).allHeaderFields["Date"] as! String

            let df = NSDateFormatter()
            df.locale = NSLocale(localeIdentifier: "en_US")
            df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
            
            NSDate.updateOffsetRaw(clientRequestTime, serverOperationDurationNano: 0, serverUTCUnixNano: Int64(df.dateFromString(dateString)!.timeIntervalSince1970 * 1_000_000_000))
        }
        
        task.resume()
    }

}