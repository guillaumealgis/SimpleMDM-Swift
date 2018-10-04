//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

public enum CursorLimit: Int {
    case min = 1
    case max = 100
}

public class Cursor<T: ListableResource> {
    public private(set) var hasMore: Bool = true
    internal var lastFetchedId: T.Identifier?
    private let serialQueue = DispatchQueue(label: "Cursor Queue")

    func next(_ limit: Int? = nil, completion: @escaping CompletionClosure<[T]>) {
        if let limit = limit {
            guard limit >= CursorLimit.min.rawValue && limit <= CursorLimit.max.rawValue else {
                completion(.failure(SimpleMDMError.invalidLimit(limit)))
                return
            }
        }

        serialQueue.async {
            self.fetchNextData(limit: limit, completion: completion)
        }
    }

    internal func fetchNextData(limit: Int?, completion: @escaping CompletionClosure<[T]>) {
        SimpleMDM.shared.networking.getDataForResources(ofType: T.self, startingAfter: lastFetchedId, limit: limit) { networkingResult in
            self.handleNetworkingResult(networkingResult, completion: completion)
        }
    }

    internal func handleNetworkingResult(_ networkingResult: NetworkingResult, completion: @escaping CompletionClosure<[T]>) {
        let decoding = Decoding()
        let payloadResult = decoding.decodeNetworkingResultPayload(networkingResult, expectedPayloadType: PaginatedListPayload<T>.self)

        switch payloadResult {
        case let .success(payload):
            handleRequestSuccess(payload: payload, completion: completion)
        case let .failure(error):
            completion(.failure(error))
        }
    }

    internal func handleRequestSuccess(payload: PaginatedListPayload<T>, completion: @escaping CompletionClosure<[T]>) {
        let resources = payload.data

        guard !(payload.hasMore && resources.isEmpty) else {
            // We got an empty resource list, but the server advertised for more resources. That does not makes sense.
            return completion(.failure(SimpleMDMError.doesNotExpectMoreResources))
        }

        if let lastResource = resources.last {
            lastFetchedId = lastResource.id
        }
        hasMore = payload.hasMore

        completion(.success(resources))
    }
}

// MARK: NestedResourceCursor

public class NestedResourceCursor<Parent: IdentifiableResource, T: ListableResource>: Cursor<T>, NestedResourceAttribute {
    let parentId: Parent.Identifier

    public required init(parentId: Parent.Identifier) {
        self.parentId = parentId
        super.init()
    }

    override func fetchNextData(limit: Int?, completion: @escaping (Result<[T]>) -> Void) {
        SimpleMDM.shared.networking.getDataForNestedListableResources(ofType: T.self, inParent: Parent.self, withId: parentId, startingAfter: lastFetchedId, limit: limit) { networkingResult in
            self.handleNetworkingResult(networkingResult, completion: completion)
        }
    }
}
