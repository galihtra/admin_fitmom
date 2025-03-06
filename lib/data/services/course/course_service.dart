import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/course/course.dart';

class CourseService {
  final CollectionReference _courseRef =
      FirebaseFirestore.instance.collection('courses');

  Future<void> addCourse(Course course) async {
    await _courseRef.add(course.toMap());
  }

  Future<void> updateCourse(String id, Course course) async {
    await _courseRef.doc(id).update(course.toMap());
  }

  Future<void> deleteCourse(String id) async {
    await _courseRef.doc(id).delete();
  }

  Stream<List<Course>> getCourses() {
    return _courseRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
