class SignUpWithEmailAndPasswordFailure{
  final String message;

  const SignUpWithEmailAndPasswordFailure([ this.message= "Error creating account"]);

 factory SignUpWithEmailAndPasswordFailure.code(String code) {
    switch (code) {
      case "email-already-in-use":
        return const SignUpWithEmailAndPasswordFailure(
            "The email address is already in use by another account.");
      case "invalid-email":
        return const SignUpWithEmailAndPasswordFailure(
            "The email address is not valid.");
      case "operation-not-allowed":
        return const SignUpWithEmailAndPasswordFailure(
            "Email/password accounts are not enabled.");
      case "weak-password":
        return const SignUpWithEmailAndPasswordFailure(
            "The password is not strong enough.");
      default:
        return  const SignUpWithEmailAndPasswordFailure();
    }
 }

}