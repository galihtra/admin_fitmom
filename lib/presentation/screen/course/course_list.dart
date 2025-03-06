import 'package:admin_fitmom/presentation/screen/course/add/add_course.dart';
import 'package:flutter/material.dart';
import '../../../data/model/course/course.dart';
import '../../../data/services/course/course_service.dart';
import 'detail/course_detail.dart';

class CourseListScreen extends StatelessWidget {
  final CourseService _courseService = CourseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Course>>(
        stream: _courseService.getCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error loading courses'));
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 3,
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: course.image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            course.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, size: 60),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.image,
                              size: 40, color: Colors.grey[600]),
                        ),
                  title: Text(course.name,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(course.description,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailScreen(course: course),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCourseScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
