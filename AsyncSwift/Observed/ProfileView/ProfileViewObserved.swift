//
//  ProfileView+Observed.swift
//  AsyncSwift
//
//  Created by Kim Insub on 2022/10/16.
//

import CodeScanner
import CoreImage.CIFilterBuiltins
import Combine
import UIKit

@MainActor
final class ProfileViewObserved: ObservableObject {
    @Published var hasRegisteredProfile = false
    @Published var isLoading = true
    @Published var isShowingFriends = false
    @Published var isShowingEdit = false
    @Published var isShowingScanner = false
    @Published var isShowingUserDetail = false
    @Published var user: User = User(
        id: "",
        name: "",
        nickname: "",
        role: "",
        description: "",
        linkedInURL: "",
        profileURL: "",
        friends: []
    )

    @Published var scannedFriend: User = User(
        id: "",
        name: "",
        nickname: "",
        role: "",
        description: "",
        linkedInURL: "",
        profileURL: "",
        friends: []
    )

    var userID: String? = nil {
        didSet {
            let _ = KeyChain.shared.addItem(key: "userID", pwd: userID ?? "")
        }
    }

    init() {
        let userid = KeyChain.shared.getItem(key: "userID")
        guard userid != nil else { return }
        self.hasRegisteredProfile = true
        self.userID = userid as? String
    }

    func onAppear() {
        if hasRegisteredProfile {
            Task {
                await getUserByID()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false
                }
            }
        }
    }

    func didTapXButton() {
        isShowingScanner = false
    }

    func getQRCodeImage() -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(userID?.utf8 ?? "".utf8)
        filter.setValue(data, forKey: "inputMessage")
        if let qrCodeImage = filter.outputImage {
            if let qrCodeImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
                return UIImage(cgImage: qrCodeImage)
            }
        }
        return UIImage(systemName: "xmark") ?? UIImage()
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let success):
            let uuidString = success.string
            Task {
                await handleScanSuccess(id: uuidString)
                await getFriendByID(id: uuidString)
            }
        case .failure(let failure):
            print(failure)
        }
    }
}

private extension ProfileViewObserved {
    func handleScanSuccess(id: String) async {
        guard (UUID(uuidString: id)) != nil else { return }
        guard isNewFriend(id: id) else { return }
        user.friends.append(id)
        FirebaseManager.shared.editUser(user: self.user)
        isShowingScanner = false
        isShowingUserDetail = true
    }

    func getUserByID() async {
        FirebaseManager.shared.getUserBy(id: self.userID ?? "") { [weak self] user in
            guard let self = self else { return }
            self.user = user
        }
    }

    func getFriendByID(id: String) async {
        FirebaseManager.shared.getUserBy(id: id) { [weak self] user in
            guard let self = self else { return }
            self.scannedFriend = user
        }
    }

    func isNewFriend(id: String) -> Bool {
        return !user.friends.contains(id)
    }
}

