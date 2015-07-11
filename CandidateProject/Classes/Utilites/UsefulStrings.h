//
//  Strings.h
//  CandidateProject
//
//  Created by Perry Shalom on 7/10/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#ifndef CandidateProject_Strings_h
#define CandidateProject_Strings_h

// Web API call URLs
#define kFormatForGeocode @"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@"
#define kFormatForNearByPlaces @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%@&key=%@"
#define kFormatForAutocompletePlacesSearch @"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=address&language=iw&key=%@"

// Persistance keys
#define kPersistanceLastCrashKey @"PersistanceLastCrashKey"

#endif