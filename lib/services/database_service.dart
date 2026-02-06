import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ USER OPERATIONS ============

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromDocument(doc) : null);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<List<UserModel>> getDiscoverUsers({
    required String currentUserId,
    required List<String> excludeIds,
    int limit = 20,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .limit(limit * 2)
          .get();

      List<UserModel> users = [];
      for (var doc in snapshot.docs) {
        UserModel user = UserModel.fromDocument(doc);
        if (user.uid == currentUserId) continue;
        if (excludeIds.contains(user.uid)) continue;
        users.add(user);
        if (users.length >= limit) break;
      }

      return users;
    } catch (e) {
      print('Error getting discover users: $e');
      return [];
    }
  }

  // ============ LIKE/MATCH OPERATIONS ============

  Future<bool> likeUser(String currentUserId, String likedUserId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'likedUsers': FieldValue.arrayUnion([likedUserId]),
      });

      UserModel? otherUser = await getUser(likedUserId);
      if (otherUser != null && otherUser.likedUsers.contains(currentUserId)) {
        await _firestore.collection('users').doc(currentUserId).update({
          'matches': FieldValue.arrayUnion([likedUserId]),
        });
        await _firestore.collection('users').doc(likedUserId).update({
          'matches': FieldValue.arrayUnion([currentUserId]),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error liking user: $e');
      return false;
    }
  }

  Future<bool> superLikeUser(String currentUserId, String likedUserId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'superLikedUsers': FieldValue.arrayUnion([likedUserId]),
        'likedUsers': FieldValue.arrayUnion([likedUserId]),
      });

      UserModel? otherUser = await getUser(likedUserId);
      if (otherUser != null && otherUser.likedUsers.contains(currentUserId)) {
        await _firestore.collection('users').doc(currentUserId).update({
          'matches': FieldValue.arrayUnion([likedUserId]),
        });
        await _firestore.collection('users').doc(likedUserId).update({
          'matches': FieldValue.arrayUnion([currentUserId]),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error super liking user: $e');
      return false;
    }
  }

  Future<void> dislikeUser(String currentUserId, String dislikedUserId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'dislikedUsers': FieldValue.arrayUnion([dislikedUserId]),
      });
    } catch (e) {
      print('Error disliking user: $e');
    }
  }

  // ============ CHAT OPERATIONS ============

  String _generateChatId(String user1Id, String user2Id) {
    List<String> ids = [user1Id, user2Id];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<String> createChat(String user1Id, String user2Id) async {
    try {
      String chatId = _generateChatId(user1Id, user2Id);

      DocumentSnapshot existingChat =
          await _firestore.collection('chats').doc(chatId).get();

      if (!existingChat.exists) {
        await _firestore.collection('chats').doc(chatId).set({
          'chatId': chatId,
          'participants': [user1Id, user2Id],
          'lastMessage': null,
          'lastMessageSenderId': null,
          'lastMessageTime': null,
          'unreadCount': {user1Id: 0, user2Id: 0},
          'isTyping': {user1Id: false, user2Id: false},
          'createdAt': Timestamp.now(),
        });
      }

      return chatId;
    } catch (e) {
      print('Error creating chat: $e');
      return _generateChatId(user1Id, user2Id);
    }
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore
          .collection('chats')
          .doc(message.chatId)
          .collection('messages')
          .doc(message.messageId)
          .set(message.toMap());

      await _firestore.collection('chats').doc(message.chatId).update({
        'lastMessage': message.content,
        'lastMessageSenderId': message.senderId,
        'lastMessageTime': Timestamp.now(),
        'unreadCount.${message.receiverId}': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromDocument(doc))
            .toList());
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });

      QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('status', isNotEqualTo: 'read')
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'status': 'read'});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> updateTypingStatus(String chatId, String userId, bool isTyping) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isTyping.$userId': isTyping,
      });
    } catch (e) {
      print('Error updating typing status: $e');
    }
  }
}