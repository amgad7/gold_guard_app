import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gold_caurd_app/firebase/user_model.dart';

class FirebaseFunction {
  static CollectionReference<UserModel> getUserCollection() {
    return FirebaseFirestore.instance
        .collection('users')
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) {
            return UserModel.fromJson(snapshot.data()!);
          },
          toFirestore: (value, _) {
            return value.toJson();
          },
        );
  }

  static Future<void> addUser(UserModel user) {
    var collection = getUserCollection();
    var docRef = collection.doc(user.id);
    user.id = docRef.id;
    return docRef.set(user);
  }

  static createUserAccount({
    required String email,
    required String password,
    required String userName,
    required String phone,
    required Function onSuccess,
    required Function onError,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      credential.user!.sendEmailVerification();
      UserModel user = UserModel(
        id: credential.user!.uid,
        email: email,
        phone: phone,
        userName: userName,
      );
      await addUser(user);
      onSuccess();
    } on FirebaseException catch (e) {
      onError(e.message ?? 'Firebase error');
    } catch (e) {
      onError('Error: $e');
    }
  }

  static login({
    required String email,
    required String password,
    required Function onSuccess,
    required Function onError,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        onSuccess();
      } else {
        onError('Login failed');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'user-not-found') {
        onError('No user found with this email');
      } else if (e.code == 'wrong-password') {
        onError('Wrong password');
      } else if (e.code == 'invalid-email') {
        onError('Invalid email format');
      } else {
        onError(e.message ?? 'Wrong email or password');
      }
    } catch (e) {
      onError('Error: $e');
    }
  }
}
