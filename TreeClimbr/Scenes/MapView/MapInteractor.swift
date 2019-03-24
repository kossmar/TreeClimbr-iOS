//
//  MapInteractor.swift
//  TreeClimbr
//
//  Created by Mar Koss on 2019-03-23.
//  Copyright (c) 2019 Mar Koss. All rights reserved.
//


import UIKit

protocol MapBusinessLogic
{
}

protocol MapDataStore
{
  //var name: String { get set }
}

class MapInteractor: MapBusinessLogic, MapDataStore
{
  var presenter: MapPresentationLogic?
  var worker: MapWorker?
  //var name: String = ""
  
  // MARK: Do something
  
}
