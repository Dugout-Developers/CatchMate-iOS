//
//  DIContainerService.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit

class DIContainerService {
    static let shared = DIContainerService()

    private init() {}
    
    func makeAuthReactor() -> AuthReactor{
        let naverDS = NaverLoginDataSourceImpl()
        let kakaoDS = KakaoDataSourceImpl()
        let appleDS = AppleLoginDataSourceImpl()
        let fcmDS = FCMTokenDataSourceImpl()
        let serverDS = ServerLoginDataSourceImpl()
        let loginRep = SNSLoginRepositoryImpl(kakaoLoginDS: kakaoDS, naverLoginDS: naverDS, appleLoginDS: appleDS)
        let fcmRep = FCMRepositoryImpl(fcmTokenDS: fcmDS)
        let serverRep = ServerLoginRepositoryImpl(serverLoginDS: serverDS)
        let kakaoUC = KakaoLoginUseCaseImpl(snsRepository: loginRep, fcmRepository: fcmRep, serverRepository: serverRep)
        let naverUC = NaverLoginUseCaseImpl(snsRepository: loginRep, fcmRepository: fcmRep, serverRepository: serverRep)
        let appleUC = AppleLoginUseCaseImpl(snsRepository: loginRep, fcmRepository: fcmRep, serverRepository: serverRep)
        let reactor = AuthReactor(kakaoUsecase: kakaoUC, appleUsecase: appleUC, naverUsecase: naverUC)
        
        return reactor
    }
    
    func makeSignReactor(_ model: LoginModel) -> SignReactor {
        let nicknameDatasource = NicknameCheckDataSourceImpl()
        let nicknameRepository = NicknameCheckRepositoryImpl(nicknameDS: nicknameDatasource)
        let nicknameUsecase = NicknameCheckUseCaseImpl(nicknameRepository: nicknameRepository)
        return SignReactor(loginModel: model, nicknameUseCase: nicknameUsecase)
    }
    
    func makeSignUpReactor(_ model: SignUpModel, loginModel: LoginModel) -> SignUpReactor {
        let dataSource = SignUpDataSourceImpl()
        let repository = SignUpRepositoryImpl(signupDatasource: dataSource)
        let usecase = SignUpUseCaseImpl(repository: repository)
        
        return SignUpReactor(signUpModel: model, loginModel: loginModel, signupUseCase: usecase)
    }
    func makeHomeReactor() -> HomeReactor {
        let listLoadDataSource = PostListLoadDataSourceImpl()
        let listLoadRepository = PostListLoadRepositoryImpl(postListLoadDS: listLoadDataSource)
        let listLoadUsecase = PostListLoadUseCaseImpl(postListRepository: listLoadRepository)
        
        let favoriteListLoadDS = LoadFavoriteListDataSourceImpl()
        let favoriteListRepository = LoadFavoriteListRepositoryImpl(loadFavorioteListDS: favoriteListLoadDS)
        let userDS = UserDataSourceImpl()
        let userRepositorty = UserRepositoryImpl(userDS: userDS)
        let setupUsecase = SetupUseCaseImpl(favoriteListRepository: favoriteListRepository, userRepository: userRepositorty)
        return HomeReactor(loadPostListUsecase: listLoadUsecase, setupUsecase: setupUsecase)
    }
    func makeAddReactor() -> AddReactor {
        let addDataSource = AddPostDataSourceImpl()
        let addRepository = AddPostRepositoryImpl(addPostDS: addDataSource)
        let addUsecase = AddPostUseCaseImpl(addPostRepository: addRepository)
        
        let loadPostDataSource = LoadPostDataSourceImpl()
        let loadPostRepository = LoadPostRepositoryImpl(loadPostDS: loadPostDataSource)
        let loadPostUsecase = LoadPostUseCaseImpl(loadPostRepository: loadPostRepository)
        
        let loadUserDataSource = UserDataSourceImpl()
        let loadUserRepository = UserRepositoryImpl(userDS: loadUserDataSource)
        let loadUserUsecase = UserUseCaseImpl(userRepository: loadUserRepository)
        return AddReactor(addUsecase: addUsecase, loadPostDetailUsecase: loadPostUsecase, loadUserUsecase: loadUserUsecase)
    }
    
    func makePostReactor(_ postID: String) -> PostReactor {
        let loadPostDataSource = LoadPostDataSourceImpl()
        let loadPostRepository = LoadPostRepositoryImpl(loadPostDS: loadPostDataSource)
        let loadPostUsecase = LoadPostUseCaseImpl(loadPostRepository: loadPostRepository)
        
        let setFavoriteDataSource = SetFavoriteDataSourceImpl()
        let setFavoriteRepository = SetFavoriteRepositoryImpl(setFavoriteDS: setFavoriteDataSource)
        let setFavoriteUsecase = SetFavoriteUseCaseImpl(setFavoriteRepository: setFavoriteRepository)
        
        return PostReactor(postId: postID, postloadUsecase: loadPostUsecase, setfavoriteUsecase: setFavoriteUsecase)
    }
    
    func makeFavoriteReactor() -> FavoriteReactor {
        let loadFavoriteListDS = LoadFavoriteListDataSourceImpl()
        let loadFavoriteListRepository = LoadFavoriteListRepositoryImpl(loadFavorioteListDS: loadFavoriteListDS)
        let loadFavoriteListUsecase = LoadFavoriteListUseCaseImpl(loadFavoriteListRepository: loadFavoriteListRepository)
        
        return FavoriteReactor(favoriteListUsecase: loadFavoriteListUsecase)
    }
    
    func makeMypageReactor() -> MyPageReactor {
        let userDataSource = UserDataSourceImpl()
        let logoutDataSource = LogoutDataSourceImpl()
        let userRepository = UserRepositoryImpl(userDS: userDataSource)
        let logoutRepository = LogoutRepositoryImpl(lopgoutDS: logoutDataSource)
        let userUsecase = UserUseCaseImpl(userRepository: userRepository)
        let logoutUsecase = LogoutUseCaseImpl(repository: logoutRepository)
        
        return MyPageReactor(userUsecase: userUsecase, logoutUsecase: logoutUsecase)
    }
    
    
    // MARK: - 특정 Usecase만 필요할 때
    func makeLogoutUseCase() -> LogoutUseCase {
        let logoutDataSource = LogoutDataSourceImpl()
        let logoutRepository = LogoutRepositoryImpl(lopgoutDS: logoutDataSource)
        let logoutUsecase = LogoutUseCaseImpl(repository: logoutRepository)
        return logoutUsecase
    }
}
