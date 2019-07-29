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
    func loadTrees(request: Map.LoadTrees.Request)
}

protocol MapDataStore
{
}

class MapInteractor: MapBusinessLogic, MapDataStore
{
    var presenter: MapPresentationLogic?
    var worker: MapWorker?
    
    // MARK: Load Trees
    
    func loadTrees(request: Map.LoadTrees.Request)
    {
        
    }
}
