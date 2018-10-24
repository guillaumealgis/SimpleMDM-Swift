//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// The bounds of the number of elements one can get when requesting a paginated list of resources.
///
/// These values are from the [Pagination documentation](https://simplemdm.com/docs/api/#pagination) and may be subject
/// to change.
public enum CursorLimit: Int {
    /// The minimum number of resources one can request per page.
    case min = 1
    /// The maximum number of resources one can request per page.
    case max = 100
}

// MARK: - Cursor

/// A class used to fetch paginated lists of resources.
///
/// A cursor represents a position in the global list of all resources of one type, and encapsulate methods to move
/// forward in the list, fetching resources page by page.
///
/// Usage:
///
///     let cursor = Cursor<Device>()
///     cursor.next { result in
///         switch {
///         case let .success(devices):
///             // Do something with the devices
///         case let .failure(error):
///             // Handle the error
///         }
///     }
public class Cursor<T: ListableResource> {
    /// Weither the server has more resources available to be fetched.
    public private(set) var hasMore: Bool = true

    /// The identifier of the last resource of the last fetched page.
    internal var lastFetchedId: T.Identifier?

    private let serialQueue = DispatchQueue(label: "Cursor Queue")

    /// Fetch the next page of resources.
    ///
    /// - Parameters:
    ///   - limit: The number of resources to fetch in this page. If not provided a default number of resources will
    ///     be returned by the SimpleMDM API.
    ///   - completion: A completion handler called with a list of the fetched resources, or an error.
    func next(_ limit: Int? = nil, completion: @escaping CompletionClosure<[T]>) {
        next(SimpleMDM.shared.networking, limit, completion: completion)
    }

    /// Actual implementation of the `next(_:completion:)` method, with a injectable `Networking` parameter.
    internal func next(_ networking: Networking, _ limit: Int? = nil, completion: @escaping CompletionClosure<[T]>) {
        if let limit = limit {
            guard limit >= CursorLimit.min.rawValue && limit <= CursorLimit.max.rawValue else {
                completion(.failure(SimpleMDMError.invalidLimit(limit)))
                return
            }
        }

        serialQueue.async {
            self.fetchNextData(networking, limit: limit, completion: completion)
        }
    }

    internal func fetchNextData(_ networking: Networking, limit: Int?, completion: @escaping CompletionClosure<[T]>) {
        networking.getDataForResources(ofType: T.self, startingAfter: lastFetchedId, limit: limit) { networkingResult in
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

// MARK: - NestedResourceCursor

/// A specific Cursor for fetching resources nested in another resource type.
///
/// This is an implementation detail, and this class can be used like a regular `Cursor` instance.
public class NestedResourceCursor<Parent: IdentifiableResource, T: ListableResource>: Cursor<T>, NestedResourceAttribute {
    let parentId: Parent.Identifier

    public required init(parentId: Parent.Identifier) {
        self.parentId = parentId
        super.init()
    }

    override func fetchNextData(_ networking: Networking, limit: Int?, completion: @escaping (Result<[T]>) -> Void) {
        networking.getDataForNestedListableResources(ofType: T.self, inParent: Parent.self, withId: parentId, startingAfter: lastFetchedId, limit: limit) { networkingResult in
            self.handleNetworkingResult(networkingResult, completion: completion)
        }
    }
}
