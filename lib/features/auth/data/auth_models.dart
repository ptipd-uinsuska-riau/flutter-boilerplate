import 'package:equatable/equatable.dart';

/// Data user hasil login SSOT.
final class AuthUser extends Equatable {
  const AuthUser({
    required this.idSdm,
    required this.email,
    required this.namaSdm,
    required this.nip,
    required this.unitId,
    this.jenisSdm,
    this.picture,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        idSdm: json['id_sdm'] as String? ?? '',
        email: json['email'] as String? ?? '',
        namaSdm: json['nama_sdm'] as String? ?? '',
        nip: json['nip'] as String? ?? '',
        unitId: json['unit_id'] as String? ?? '',
        jenisSdm: json['jenis_sdm'] as String?,
        picture: json['picture'] as String?,
      );

  final String idSdm;
  final String email;
  final String namaSdm;
  final String nip;
  final String unitId;
  final String? jenisSdm;
  final String? picture;

  Map<String, dynamic> toJson() => {
        'id_sdm': idSdm,
        'email': email,
        'nama_sdm': namaSdm,
        'nip': nip,
        'unit_id': unitId,
        'jenis_sdm': jenisSdm,
        'picture': picture,
      };

  @override
  List<Object?> get props =>
      [idSdm, email, namaSdm, nip, unitId, jenisSdm, picture];
}
