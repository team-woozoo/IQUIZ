import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';

abstract interface class AuthRepository {
  /// 저장된 인증 정보로 로그인 상태를 복원하고 현재 사용자 정보를 반환
  /// 인증 정보가 없거나 만료되어 복원할 수 없으면 성공 결과로 null을 반환
  Future<Result<UserEntity?>> restore();

  /// [email]과 [password]로 로그인하고 인증 정보를 저장한 뒤 사용자 정보를 반환
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  });
  /// [email], [password], [nickname]으로 회원가입하고 생성된 사용자 ID를 반환
  Future<Result<int>> signUp({
    required String email,
    required String password,
    required String nickname,
  });
  /// 서버에 로그아웃을 요청하고 저장된 인증 정보를 삭제
  Future<Result<void>> signOut();
}
