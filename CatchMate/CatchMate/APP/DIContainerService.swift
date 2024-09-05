//
//  DIContainerService.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit

class DIContainerService {
    static let shared = DIContainerService()
    private let tokenDS = TokenDataSourceImpl()
    private init() {}
    
    func makeAuthReactor() -> AuthReactor{
        let naverDS = NaverLoginDataSourceImpl()
        let kakaoDS = KakaoDataSourceImpl()
        let appleDS = AppleLoginDataSourceImpl()
        let fcmDS = FCMTokenDataSourceImpl()
        let serverDS = ServerLoginDataSourceImpl(tokenDataSource: tokenDS)
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
        let dataSource = SignUpDataSourceImpl(tokenDataSource: tokenDS)
        let repository = SignUpRepositoryImpl(signupDatasource: dataSource)
        let usecase = SignUpUseCaseImpl(repository: repository)
        
        return SignUpReactor(signUpModel: model, loginModel: loginModel, signupUseCase: usecase)
    }
    func makeHomeReactor() -> HomeReactor {
        let listLoadDataSource = PostListLoadDataSourceImpl(tokenDataSource: tokenDS)
        let listLoadRepository = PostListLoadRepositoryImpl(postListLoadDS: listLoadDataSource)
        let listLoadUsecase = PostListLoadUseCaseImpl(postListRepository: listLoadRepository)
        
        let favoriteListLoadDS = LoadFavoriteListDataSourceImpl(tokenDataSource: tokenDS)
        let favoriteListRepository = LoadFavoriteListRepositoryImpl(loadFavorioteListDS: favoriteListLoadDS)
        let userDS = UserDataSourceImpl(tokenDataSource: tokenDS)
        let userRepositorty = UserRepositoryImpl(userDS: userDS)
        let setupUsecase = SetupUseCaseImpl(favoriteListRepository: favoriteListRepository, userRepository: userRepositorty)
        return HomeReactor(loadPostListUsecase: listLoadUsecase, setupUsecase: setupUsecase)
    }
    func makeAddReactor() -> AddReactor {
        let addDataSource = AddPostDataSourceImpl(tokenDataSource: tokenDS)
        let addRepository = AddPostRepositoryImpl(addPostDS: addDataSource)
        let addUsecase = AddPostUseCaseImpl(addPostRepository: addRepository)
        
        let loadPostDataSource = LoadPostDataSourceImpl(tokenDataSource: tokenDS)
        let loadPostRepository = LoadPostRepositoryImpl(loadPostDS: loadPostDataSource)
        let sendAppliesDataSource = SendAppiesDataSourceImpl(tokenDataSource: tokenDS)
        let sendAppliesRepository = SendAppiesRepositoryImpl(sendAppliesDS: sendAppliesDataSource)
        let loadPostUsecase = PostDetailUseCaseImpl(loadPostRepository: loadPostRepository, applylistRepository: sendAppliesRepository)
        
        let loadUserDataSource = UserDataSourceImpl(tokenDataSource: tokenDS)
        let loadUserRepository = UserRepositoryImpl(userDS: loadUserDataSource)
        let loadUserUsecase = UserUseCaseImpl(userRepository: loadUserRepository)
        return AddReactor(addUsecase: addUsecase, loadPostDetailUsecase: loadPostUsecase, loadUserUsecase: loadUserUsecase)
    }
    
    func makePostReactor(_ postID: String) -> PostReactor {
        let loadPostDataSource = LoadPostDataSourceImpl(tokenDataSource: tokenDS)
        let loadPostRepository = LoadPostRepositoryImpl(loadPostDS: loadPostDataSource)
        let sendAppliesDataSource = SendAppiesDataSourceImpl(tokenDataSource: tokenDS)
        let sendAppliesRepository = SendAppiesRepositoryImpl(sendAppliesDS: sendAppliesDataSource)
        let loadPostUsecase = PostDetailUseCaseImpl(loadPostRepository: loadPostRepository, applylistRepository: sendAppliesRepository)
        
        let applyDataSource = ApplyDataSourceImpl(tokenDataSource: tokenDS)
        let applyRepository = ApplyPostRepositoryImpl(applyDS: applyDataSource)
        let applyUsecase = ApplyHandleUseCaseImpl(applyRepository: applyRepository)
        
        let setFavoriteDataSource = SetFavoriteDataSourceImpl(tokenDataSource: tokenDS)
        let setFavoriteRepository = SetFavoriteRepositoryImpl(setFavoriteDS: setFavoriteDataSource)
        let setFavoriteUsecase = SetFavoriteUseCaseImpl(setFavoriteRepository: setFavoriteRepository)
        
        return PostReactor(postId: postID, postloadUsecase: loadPostUsecase, setfavoriteUsecase: setFavoriteUsecase, applyHandelerUsecase: applyUsecase)
    }
    
    func makeFavoriteReactor() -> FavoriteReactor {
        let loadFavoriteListDS = LoadFavoriteListDataSourceImpl(tokenDataSource: tokenDS)
        let loadFavoriteListRepository = LoadFavoriteListRepositoryImpl(loadFavorioteListDS: loadFavoriteListDS)
        let loadFavoriteListUsecase = LoadFavoriteListUseCaseImpl(loadFavoriteListRepository: loadFavoriteListRepository)
        
        return FavoriteReactor(favoriteListUsecase: loadFavoriteListUsecase)
    }
    
    func makeMypageReactor() -> MyPageReactor {
        let userDataSource = UserDataSourceImpl(tokenDataSource: tokenDS)
        let logoutDataSource = LogoutDataSourceImpl(tokenDataSource: tokenDS)
        let userRepository = UserRepositoryImpl(userDS: userDataSource)
        let logoutRepository = LogoutRepositoryImpl(logoutDS: logoutDataSource)
        let userUsecase = UserUseCaseImpl(userRepository: userRepository)
        let logoutUsecase = LogoutUseCaseImpl(repository: logoutRepository)
        
        return MyPageReactor(userUsecase: userUsecase, logoutUsecase: logoutUsecase)
    }
    
    
    // MARK: - 특정 Usecase만 필요할 때
    func makeLogoutUseCase() -> LogoutUseCase {
        let logoutDataSource = LogoutDataSourceImpl(tokenDataSource: tokenDS)
        let logoutRepository = LogoutRepositoryImpl(logoutDS: logoutDataSource)
        let logoutUsecase = LogoutUseCaseImpl(repository: logoutRepository)
        return logoutUsecase
    }
}
