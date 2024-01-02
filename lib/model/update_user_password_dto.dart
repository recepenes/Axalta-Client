class UpdateUserPasswordDto {
  String currentPassword;
  String newPassword;
  String confirmPassword;

  UpdateUserPasswordDto({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}
