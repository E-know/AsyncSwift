//
//  ProfileView.swift
//  AsyncSwift
//
//  Created by Kim Insub on 2022/10/16.
//

import SwiftUI


// TODO
// 1 : Enter 치면 다음 input focused 되도록 변경

struct ProfileView: View {

    @ObservedObject var observed: ProfileViewObserved

    init() {
        observed = ProfileViewObserved()
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                header
                Spacer()
                friendLinkButton
                editProfileLinkButton
            }
            .navigationTitle("Profile")
        }
    }
}

private extension ProfileView {
    @ViewBuilder
    var header: some View {
        if observed.hasRegisteredProfile {
            hasRegisteredHeader
        } else {
            registerHeader
        }
    }

    var hasRegisteredHeader: some View {
        VStack(spacing: 0) {
            customDivider
                .padding(.top, 10)
        }
    }

    var registerHeader: some View {
        VStack(spacing: 0) {
            Image("QRplaceholder")
                .frame(width: 157)
                .padding(.bottom, 50)
            Text("등록한 프로필이 없습니다.")
                .foregroundColor(.profileGray)
                .font(.body)
                .padding(.bottom, 17)
            registerLink
        }
        .padding(.top, 68)
    }

    var registerLink: some View {
        NavigationLink {
            ProfileRegisterView(hasRegisteredProfile: $observed.hasRegisteredProfile)
        } label: {
            Text("프로필 등록하기")
                .font(.headline)
        }
    }

    var friendLinkButton: some View {
        ProfileViewButton(
            title: "Friends",
            linkTo: AnyView(
                ProfileFriendsListView()
            )
        )
            .padding(.bottom, 16)
    }

    var editProfileLinkButton: some View {
        ProfileViewButton(
            title: "Edit Profile",
            linkTo: AnyView(
                ProfileRegisterView(
                    hasRegisteredProfile:
                        $observed.hasRegisteredProfile
                )
            )
        )
            .padding(.bottom, 32)
    }
}
