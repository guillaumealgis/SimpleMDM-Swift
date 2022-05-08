//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

#warning("FIXME: Guillaume: Useful ?")
#warning("FIXME: Guillaume: documentation in whole file")

/// The bounds of the number of elements one can get when requesting a paginated list of resources.
///
/// These values are from the [Pagination documentation](https://simplemdm.com/docs/api/#pagination) and may be subject
/// to change.
public enum PageLimit {
    /// The minimum number of resources one can request per page.
    public static let min = 1
    /// The maximum number of resources one can request per page.
    public static let max = 100
    /// The default number of resources requested per page if no limit is specified.
    ///
    /// Defined by SimpleMDM's online documentation at the time of writing.
    public static let `default` = 10
}

public struct AsyncPaginatedResources<Resource: FetchableListableResource>: AsyncSequence {
    public typealias Element = [Resource]

    public struct AsyncIterator: AsyncIteratorProtocol {
        private let pageSize: Int
        private let allResources: AsyncResources<Resource>

        init(pageSize: Int, allResources: AsyncResources<Resource>) {
            self.pageSize = pageSize
            self.allResources = allResources
        }

        public func next() async throws -> [Resource]? {
            var nextPage: [Resource] = []
            var iterator = allResources.makeAsyncIterator()
            for _ in 0 ..< pageSize {
                let nextElement = try await iterator.next()
                guard let element = nextElement else {
                    if nextPage.isEmpty {
                        return nil
                    } else {
                        return nextPage
                    }
                }
                nextPage.append(element)
            }
            return nextPage
        }
    }

    private let pageSize: Int
    private let allResources: AsyncResources<Resource>

    internal init(pageSize: Int) {
        self.pageSize = pageSize
        allResources = AsyncResources(pageSize: pageSize)
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(pageSize: pageSize, allResources: allResources)
    }
}
