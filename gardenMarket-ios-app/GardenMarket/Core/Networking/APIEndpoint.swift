import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIEndpoint {
    // Auth
    case login(email: String, password: String)
    case register(email: String, password: String, role: String)
    case refreshToken(token: String)
    case me

    // Profile
    case getProfile
    case updateProfile(ProfileUpdate)
    case upgrade
    case onboardingStatus

    // Listings
    case listListings(ListingFilter?)
    case getListing(id: Int)
    case createListing(CreateListingRequest)
    case updateListing(id: Int, UpdateListingRequest)

    // Plants
    case listPlants
    case createPlant(CreatePlantRequest)
    case updatePlant(id: Int, CreatePlantRequest)

    // Gardener
    case listGardeners
    case getGardener(id: Int)
    case updateGardener(id: Int, UpdateGardenerRequest)

    // Cart
    case getCart
    case addToCart(listingId: Int, quantity: Int)
    case removeCartItem(id: Int)

    // Orders
    case listOrders
    case createOrder(centerId: Int, pickupWindow: String, pickupDate: String?)
    case getOrder(id: Int)
    case mockPay(orderId: Int)
    case gardenerOrders

    // Centers
    case listCenters

    var path: String {
        switch self {
        case .login: return "/api/accounts/login/"
        case .register: return "/api/accounts/register/"
        case .refreshToken: return "/api/accounts/token/refresh/"
        case .me: return "/api/accounts/me/"
        case .getProfile, .updateProfile: return "/api/accounts/profile/"
        case .upgrade: return "/api/accounts/upgrade/"
        case .onboardingStatus: return "/api/accounts/onboarding/"
        case .listListings, .createListing: return "/api/listings/"
        case .getListing(let id), .updateListing(let id, _): return "/api/listings/\(id)/"
        case .listPlants, .createPlant: return "/api/plants/"
        case .updatePlant(let id, _): return "/api/plants/\(id)/"
        case .listGardeners: return "/api/gardeners/"
        case .getGardener(let id), .updateGardener(let id, _): return "/api/gardeners/\(id)/"
        case .getCart, .addToCart: return "/api/cart/"
        case .removeCartItem(let id): return "/api/cart/\(id)/"
        case .listOrders, .createOrder: return "/api/orders/"
        case .getOrder(let id): return "/api/orders/\(id)/"
        case .mockPay(let orderId): return "/api/orders/\(orderId)/mock_pay/"
        case .gardenerOrders: return "/api/orders/gardener/"
        case .listCenters: return "/api/centers/"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .register, .refreshToken, .upgrade, .createListing,
             .createPlant, .addToCart, .createOrder, .mockPay:
            return .post
        case .updateProfile, .updateListing, .updatePlant, .updateGardener:
            return .patch
        case .removeCartItem:
            return .delete
        default:
            return .get
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .register(let email, let password, let role):
            return ["email": email, "password": password, "role": role]
        case .refreshToken(let token):
            return ["refresh": token]
        case .updateProfile(let update):
            return update
        case .createListing(let req):
            return req
        case .updateListing(_, let req):
            return req
        case .createPlant(let req):
            return req
        case .updatePlant(_, let req):
            return req
        case .updateGardener(_, let req):
            return req
        case .addToCart(let listingId, let quantity):
            return ["listing": listingId, "quantity": quantity]
        case .createOrder(let centerId, let pickupWindow, let pickupDate):
            var body: [String: String] = [
                "distribution_center": String(centerId),
                "pickup_window": pickupWindow,
            ]
            if let date = pickupDate { body["pickup_date"] = date }
            return body
        default:
            return nil
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .listListings(let filter):
            guard let filter else { return nil }
            return filter.queryItems
        default:
            return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login, .register, .refreshToken, .listCenters:
            return false
        case .listListings, .getListing:
            return false
        default:
            return true
        }
    }
}
