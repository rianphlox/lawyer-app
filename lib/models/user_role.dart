enum UserRole {
  juniorLawyer,
  seniorLawyer,
  client;

  String get displayName {
    switch (this) {
      case UserRole.juniorLawyer:
        return 'Junior Lawyer';
      case UserRole.seniorLawyer:
        return 'Senior Lawyer';
      case UserRole.client:
        return 'Client';
    }
  }

  bool get isLawyer => this == UserRole.juniorLawyer || this == UserRole.seniorLawyer;
}