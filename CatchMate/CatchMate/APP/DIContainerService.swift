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
        
        let userDS = UserDataSourceImpl(tokenDataSource: tokenDS)
        let userRepositorty = UserRepositoryImpl(userDS: userDS)
        let setupUsecase = SetupUseCaseImpl(userRepository: userRepositorty)
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

        let loadPostUsecase = PostDetailUseCaseImpl(loadPostRepository: loadPostRepository, applyRepository: sendAppliesRepository)
        
        let loadUserDataSource = UserDataSourceImpl(tokenDataSource: tokenDS)
        let loadUserRepository = UserRepositoryImpl(userDS: loadUserDataSource)
        let loadUserUsecase = UserUseCaseImpl(userRepository: loadUserRepository)
        
        let tempPostDS = TempPostDataSourceImpl(tokenDataSource: tokenDS)
        let loadTempPostDS = LoadTempPostDataSourceImpl(tokenDataSource: tokenDS)
        let tempPostRepository = TempPostRepositoryImpl(tempPostDS: tempPostDS, loadTempPostDS: loadTempPostDS)
        let tempPostUsecase = TempPostUseCaseImpl(tempPostRepository: tempPostRepository)
        return AddReactor(addUsecase: addUsecase, loadPostDetailUsecase: loadPostUsecase, loadUserUsecase: loadUserUsecase, tempPostUsecase: tempPostUsecase)
    }
    
    func makePostReactor(_ postID: String) -> PostReactor {
        let loadPostDataSource = LoadPostDataSourceImpl(tokenDataSource: tokenDS)
        let loadPostRepository = LoadPostRepositoryImpl(loadPostDS: loadPostDataSource)
        let sendAppliesDataSource = SendAppiesDataSourceImpl(tokenDataSource: tokenDS)
        let sendAppliesRepository = SendAppiesRepositoryImpl(sendAppliesDS: sendAppliesDataSource)

        let loadPostUsecase = PostDetailUseCaseImpl(loadPostRepository: loadPostRepository, applyRepository: sendAppliesRepository)
        
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
        
        let blockDS = BlockManageDataSourceImpl(tokenDataSource: tokenDS)
        let blockRepo = BlockManageRepositoryImpl(blockManageDS: blockDS)
        let blockUC = BlockUserUseCaseImpl(blockManageRepo: blockRepo)
        
        return OtherUserpageReactor(user: writer, userPostUsecase: userPostListUsecase, blockUsecase: blockUC)
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
    
    func MakeChatListReactor() -> ChatListReactor {
        let loadChatListDS = LoadChatListDataSourceImpl(tokenDataSource: tokenDS)
        let loadChatListRepo = LoadChatListRepositoryImpl(chatListDataSource: loadChatListDS)
        let loadChatListUC = LoadChatListUseCaseImpl(loadChatListRepository: loadChatListRepo)
        
        return ChatListReactor(loadchatListUsecase: loadChatListUC)
    }
    
    func makeChatRoomReactor(_ chat: ChatRoomInfo) -> ChatRoomReactor {
        let loadChatUsersDS = LoadChatUsersDataSourceImpl(tokenDataSource: tokenDS)
        let loadChatUserRepo = LoadChatUsersRepositoryImpl(loadChatUserDS: loadChatUsersDS)
        let loadChatMessageDS = LoadChatMessageDataSourceImpl(tokenDataSource: tokenDS)
        let loadChatMessageRepo = LoadChatMessageRepositoryImpl(loadMessageDS: loadChatMessageDS)
        let loadChatInfoUS = LoadChatInfoUseCaseImpl(loadChatUsersRP: loadChatUserRepo, loadChatMessageRepo: loadChatMessageRepo)
        
        let updateDataSource = UpdateChatImageDataSourceImpl(tokenDataSource: tokenDS)
        let updateRepository = UpdateChatImageRepositoryImpl(updateImageDS: updateDataSource)
        let updateUsecase = UpdateChatImageUseCaseImpl(updateImageRepo: updateRepository)
        
        let exitDataSource = ExitChatRoomDataSourceImpl(tokenDataSource: tokenDS)
        let exitRepository = ExitChatRoomRepositoryImpl(exitDS: exitDataSource)
        let exitUsecase = ExitChatRoomUseCaseImpl(exitRepo: exitRepository)
        
        let exportDataSource = ExportChatUserDataSourceImpl(tokenDataSource: tokenDS)
        let exportRepository = ExportChatUserRepositoryImpl(exportDS: exportDataSource)
        let exportUsecase = ExportChatUserUseCaseImpl(exportRepo: exportRepository)
        
        return ChatRoomReactor(chat: chat, loadInfoUS: loadChatInfoUS, updateImageUS: updateUsecase, exportUS: exportUsecase, exitUS: exitUsecase)
    }
    
    func makeReportUserReactor(_ user: SimpleUser) -> ReportReactor {
        let reportDS = ReportUserDataSourceImpl(tokenDataSource: tokenDS)
        let reportRepo = ReportUserRepositoryImpl(reportUserDS: reportDS)
        let reportUC = ReportUserUseCaseImpl(reportUserRepo: reportRepo)
        
        return ReportReactor(user: user, reportUseCase: reportUC)
    }
    
    func makeBlockUserReactor() -> BlockUserReactor {
        let loadUsersDS = LoadBlockUsersDataSourceImpl(tokenDataSource: tokenDS)
        let loadUsersRepo = LoadBlockUsersRepositoryImpl(loadBlockUserDS: loadUsersDS)
        let loadUsersUC = LoadBlockUsersUseCaseImpl(loadBlockUsersRepo: loadUsersRepo)
        
        let unblockDS = BlockManageDataSourceImpl(tokenDataSource: tokenDS)
        let unblockRepo = BlockManageRepositoryImpl(blockManageDS: unblockDS)
        let unblockUC = UnBlockUserUseCaseImpl(blockManageRepo: unblockRepo)
        
        return BlockUserReactor(loadBlockUserUseCase: loadUsersUC, unBlockUseCase: unblockUC)
    }
    
    func makeCustomerServiceReactor(menu: CustomerServiceMenu) -> CustomerServiceReactor {
        let inquiriesDS = InquiriesDataSourceImpl(tokenDataSource: tokenDS)
        let inquiriesRepo = InquiriesRepositoryImpl(inquriesDS: inquiriesDS)
        let inquiriesUC = InquiriesUseCaseImpl(inquriesRepo: inquiriesRepo)
        
        return CustomerServiceReactor(menu: menu, inquiriesUsecase: inquiriesUC)
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
    
    func makeNickNameCheckUseCase() -> NicknameCheckUseCase {
        let nicknameCheckDataSource = NicknameCheckDataSourceImpl()
        let nicknameCheckRepository = NicknameCheckRepositoryImpl(nicknameDS: nicknameCheckDataSource)
        let nicknameCheckUsecase = NicknameCheckUseCaseImpl(nicknameRepository: nicknameCheckRepository)
        return nicknameCheckUsecase
    }
    
    func makeChatDetailUseCase() -> LoadChatDetailUseCase {
        let chatDetailDS = LoadChatDetailDataSourceImpl(tokenDataSource: tokenDS)
        let chatDetailRepo = LoadChatDetailRepositoryImpl(loadChatDS: chatDetailDS)
        let chatDetailUC = LoadChatDetailUseCaseImpl(loadChatRepo: chatDetailRepo)
        
        return chatDetailUC
    }
}
