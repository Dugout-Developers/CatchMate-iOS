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
    
    func returnTokenDS() -> TokenDataSource{
        return tokenDS
    }
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
        let reactor = AuthReactor(kakaoUsecase: kakaoUC, appleUsecase: appleUC, naverUsecase: naverUC, tokenDS: tokenDS)
        
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
        let editDataSource = EditPostDataSourceImpl(tokenDataSource: tokenDS)
        let addRepository = AddPostRepositoryImpl(addPostDS: addDataSource, editPostDS: editDataSource)
        let addUsecase = AddPostUseCaseImpl(addPostRepository: addRepository)
        
        let loadPostDataSource = LoadPostDataSourceImpl(tokenDataSource: tokenDS)
        let loadPostRepository = LoadPostRepositoryImpl(loadPostDS: loadPostDataSource)
        let sendAppliesDataSource = SendAppiesDataSourceImpl(tokenDataSource: tokenDS)
        let sendAppliesRepository = SendAppiesRepositoryImpl(sendAppliesDS: sendAppliesDataSource)
        let loadFavoriteListDS = LoadFavoriteListDataSourceImpl(tokenDataSource: tokenDS)
        let loadFavoriteListRepository = LoadFavoriteListRepositoryImpl(loadFavorioteListDS: loadFavoriteListDS)
        let loadPostUsecase = PostDetailUseCaseImpl(loadPostRepository: loadPostRepository, applylistRepository: sendAppliesRepository, loadFavoriteListRepository: loadFavoriteListRepository)
        
        let loadUserDataSource = UserDataSourceImpl(tokenDataSource: tokenDS)
        let loadUserRepository = UserRepositoryImpl(userDS: loadUserDataSource)
        let loadUserUsecase = UserUseCaseImpl(userRepository: loadUserRepository)
        
        let tempPostDS = TempPostDataSourceImpl(tokenDataSource: tokenDS)
        let tempPostRepository = TempPostRepositoryImpl(tempPostDS: tempPostDS)
        let tempPostUsecase = TempPostUseCaseImpl(tempPostRepository: tempPostRepository)
        return AddReactor(addUsecase: addUsecase, loadPostDetailUsecase: loadPostUsecase, loadUserUsecase: loadUserUsecase, tempPostUsecase: tempPostUsecase)
    }
    
    func makePostReactor(_ postID: String) -> PostReactor {
        let loadPostDataSource = LoadPostDataSourceImpl(tokenDataSource: tokenDS)
        let loadPostRepository = LoadPostRepositoryImpl(loadPostDS: loadPostDataSource)
        let sendAppliesDataSource = SendAppiesDataSourceImpl(tokenDataSource: tokenDS)
        let sendAppliesRepository = SendAppiesRepositoryImpl(sendAppliesDS: sendAppliesDataSource)
        let loadFavoriteListDS = LoadFavoriteListDataSourceImpl(tokenDataSource: tokenDS)
        let loadFavoriteListRepository = LoadFavoriteListRepositoryImpl(loadFavorioteListDS: loadFavoriteListDS)
        let loadPostUsecase = PostDetailUseCaseImpl(loadPostRepository: loadPostRepository, applylistRepository: sendAppliesRepository, loadFavoriteListRepository: loadFavoriteListRepository)
        
        let applyDataSource = ApplyDataSourceImpl(tokenDataSource: tokenDS)
        let applyRepository = ApplyPostRepositoryImpl(applyDS: applyDataSource)
        let applyUsecase = ApplyUseCaseImpl(applyRepository: applyRepository)
        let cancelApplyUsecase = CancelApplyUseCaseImpl(applyRepository: applyRepository)
        
        let setFavoriteDataSource = SetFavoriteDataSourceImpl(tokenDataSource: tokenDS)
        let setFavoriteRepository = SetFavoriteRepositoryImpl(setFavoriteDS: setFavoriteDataSource)
        let setFavoriteUsecase = SetFavoriteUseCaseImpl(setFavoriteRepository: setFavoriteRepository)
        
        let deletePostDS = DeletePostDataSourceImpl(tokenDataSource: tokenDS)
        let deletePostRepository = DeletePostRepositoryImpl(deletePostDS: deletePostDS)
        let postHandleUsecase = DeletePostUseCaseImpl(deleteRepository: deletePostRepository)
        
        let upPostDS = UpPostDataSourceImpl(tokenDataSource: tokenDS)
        let upPostRepository = UpPostRepositoryImpl(upPostDS: upPostDS)
        let upPostUsecase = UpPostUseCaseImpl(upPostRepository: upPostRepository)
        
        return PostReactor(postId: postID, postloadUsecase: loadPostUsecase, setfavoriteUsecase: setFavoriteUsecase, applyUsecase: applyUsecase, cancelApplyUsecase: cancelApplyUsecase, postHandleUsecase: postHandleUsecase, upPostUsecase: upPostUsecase)
    }
    
    
    func makeFavoriteReactor() -> FavoriteReactor {
        let loadFavoriteListDS = LoadFavoriteListDataSourceImpl(tokenDataSource: tokenDS)
        let loadFavoriteListRepository = LoadFavoriteListRepositoryImpl(loadFavorioteListDS: loadFavoriteListDS)
        let setFavoriteDS = SetFavoriteDataSourceImpl(tokenDataSource: tokenDS)
        let setFavoroteRepository = SetFavoriteRepositoryImpl(setFavoriteDS: setFavoriteDS)
        
        let setFavoriteUseCase = SetFavoriteUseCaseImpl(setFavoriteRepository: setFavoroteRepository)
        let loadFavoriteListUsecase = LoadFavoriteListUseCaseImpl(loadFavoriteListRepository: loadFavoriteListRepository)
        
        return FavoriteReactor(favoriteListUsecase: loadFavoriteListUsecase, setFavoriteUsecase: setFavoriteUseCase)
    }
    func makeOtherUserPageReactor(_ writer: SimpleUser) -> OtherUserpageReactor {
        let userPostListDS = UserPostLoadDataSourceImpl(tokenDataSource: tokenDS)
        let userPostListRepository = UserPostLoadRepositoryImpl(userPostDataSource: userPostListDS)
        let userPostListUsecase = UserPostLoadUseCaseImpl(userPostListRepository: userPostListRepository)
        
        return OtherUserpageReactor(user: writer, userPostUsecase: userPostListUsecase)
    }
    
    func makeMypageReactor() -> MyPageReactor {
        let userDataSource = UserDataSourceImpl(tokenDataSource: tokenDS)
        let logoutDataSource = LogoutDataSourceImpl(tokenDataSource: tokenDS)
        let userRepository = UserRepositoryImpl(userDS: userDataSource)
        let logoutRepository = LogoutRepositoryImpl(logoutDS: logoutDataSource)
        let loadCountDataSource = RecivedCountDataSourceImpl(tokenDataSource: tokenDS)
        let loadCountRepository = ReceivedCountRepositoryIml(loadCountDS: loadCountDataSource)
        
        let userUsecase = UserUseCaseImpl(userRepository: userRepository)
        let countUsecase = LoadReceivedCountUseCaseImpl(loadCountRepository: loadCountRepository)
        let logoutUsecase = LogoutUseCaseImpl(repository: logoutRepository)
        
        return MyPageReactor(userUsecase: userUsecase, logoutUsecase: logoutUsecase, loadReceivedCountUsecase: countUsecase)
    }
    
    func makeSendMateReactor() -> SendMateReactor {
        let sendAppliesDataSource = SendAppiesDataSourceImpl(tokenDataSource: tokenDS)
        let sendAppliesRepository = SendAppiesRepositoryImpl(sendAppliesDS: sendAppliesDataSource)
        let sendAppliesUsecase = LoadSendAppliesUseCaseImpl(sendAppliesRepository: sendAppliesRepository)
        
        return SendMateReactor(sendAppliesUsecase: sendAppliesUsecase)
    }
    
    func makeReciveMateReactor() -> RecevieMateReactor {
        let recivedAppliesDataSource = RecivedAppiesDataSourceImpl(tokenDataSource: tokenDS)
        let receivedAppliesRepository = RecivedAppliesRepositoryImpl(recivedAppliesDS: recivedAppliesDataSource)
        let applyManagementDataSource = ApplyManagementDataSourceImpl(tokenDataSource: tokenDS)
        let applyManagementRepository = ApplyManagementRepositoryImpl(applyManagementDS: applyManagementDataSource)
        let acceptApplyUsecase = AcceptApplyUseCaseImpl(applyManagementRepository: applyManagementRepository)
        let rejectApplyUsecase = RejectApplyUseCaseImpl(applyManagementRepository: applyManagementRepository)
        
        let loadReceivedAppliesUseCase = LoadReceivedAppliesUseCaseImpl(receivedAppliesRepository: receivedAppliesRepository)
        let loadAllReceiveAppliesUseCase = LoadAllReceiveAppliesUseCaseImpl(recivedAppliesRepository: receivedAppliesRepository)
        let applyManageUsecase = ApplyManageUseCaseImpl(acceptApplyUseCase: acceptApplyUsecase, rejectApplyUseCase: rejectApplyUsecase)
        
        return RecevieMateReactor(receivedAppliesUsecase: loadReceivedAppliesUseCase, receivedAllAppliesUsecase: loadAllReceiveAppliesUseCase, applyManageUsecase: applyManageUsecase)
    }
    
    func makeNotifiacationSettingReactor() -> AlarmSettingReactor {
        let userDataSource = UserDataSourceImpl(tokenDataSource: tokenDS)
        let userRepository = UserRepositoryImpl(userDS: userDataSource)
        let loadAlarmInfoUsecase = LoadAlarmUseCaseImpl(userRepository: userRepository)
        let setAlarmDataSource = SetAlarmDataSourceImpl(tokenDataSource: tokenDS)
        let setAlarmRepository = SetAlarmRepositoryImpl(setNotificationDS: setAlarmDataSource)
        let setAlarmUsecase = SetAlarmUseCaseImpl(setNotificationRepository: setAlarmRepository)
        
        return AlarmSettingReactor(notificationInfoUsecase: loadAlarmInfoUsecase, setNotificationUsecase: setAlarmUsecase)
    }
    
    func makeNotiListReactor() -> NotificationListReactor {
        let loadListDS = NotificationListDataSourceImpl(tokenDataSource: tokenDS)
        let loadListRepository = LoadNotificationListRepositoryImpl(loadNotificationDS: loadListDS)
        let loadListUsecase = LoadNotificationListUseCaseImpl(loadNotificationRepository: loadListRepository)
        
        let deleteDS = DeleteNotificationDataSourceImpl(tokenDataSource: tokenDS)
        let deleteRepository = DeleteNotificationRepositoryImpl(deleteNotiDS: deleteDS)
        let deleteUsecase = DeleteNotificationUseCaseImpl(deleteNotiRepository: deleteRepository)
        
        return NotificationListReactor(loadlistUsecase: loadListUsecase, deleteNotiUsecase: deleteUsecase)
    }
    
    
    // MARK: - 특정 Usecase만 필요할 때
    func makeLogoutUseCase() -> LogoutUseCase {
        let logoutDataSource = LogoutDataSourceImpl(tokenDataSource: tokenDS)
        let logoutRepository = LogoutRepositoryImpl(logoutDS: logoutDataSource)
        let logoutUsecase = LogoutUseCaseImpl(repository: logoutRepository)
        return logoutUsecase
    }
    
    func makeProfileEditUseCase() -> ProfileEditUseCase {
        let profileEditDataSource = ProfileEditDataSourceImpl(tokenDataSource: tokenDS)
        let profileEditRepository = ProfileEditRepositoryImpl(profileEditDS: profileEditDataSource)
        let profileEditUsecase = ProfileEditUseCaseImpl(repository: profileEditRepository)
        return profileEditUsecase
    }
}
