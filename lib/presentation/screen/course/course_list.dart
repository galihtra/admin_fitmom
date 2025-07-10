import 'package:admin_fitmom/presentation/screen/course/widget/floating_button_course_custom.dart';
import 'package:flutter/material.dart';
import 'package:admin_fitmom/data/model/course/course.dart';
import 'package:admin_fitmom/data/services/course/course_service.dart';
import 'package:admin_fitmom/presentation/screen/course/detail/course_detail.dart';
import 'package:admin_fitmom/presentation/screen/course/add/add_course.dart';
import 'package:admin_fitmom/core/utils/my_color.dart';

class CourseListScreen extends StatelessWidget {
  final CourseService _courseService = CourseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<List<Course>>(
          stream: _courseService.getCourses(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error loading courses',
                      style: TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final courses = snapshot.data!;
            final freeCourses = courses.where((c) => c.isFree).toList();
            final premiumCourses = courses.where((c) => !c.isFree).toList();

            return CustomScrollView(
              slivers: [
                // Premium Courses Section
                _buildCourseSection(
                    context, 'Premium Programs', premiumCourses, true),

                // Free Courses Section
                _buildCourseSection(
                    context, 'Free Programs', freeCourses, false),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
        floatingActionButton: const FloatingButtonSound());
  }

  Widget _buildCourseSection(BuildContext context, String title,
      List<Course> courses, bool isPremium) {
    if (courses.isEmpty) return const SliverToBoxAdapter();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...courses
              .map((course) => _buildCourseCard(context, course, isPremium))
              .toList(),
        ]),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course, bool isPremium) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(course: course),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: course.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          course.image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey[400]),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.fitness_center,
                            size: 40, color: Colors.grey[600]),
                      ),
              ),
              const SizedBox(width: 12),
              // Course Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Premium Badge
                        if (!course.isFree)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: MyColor.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PREMIUM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: MyColor.primaryColor,
                              ),
                            ),
                          ),
                        const Spacer(),
                        // Availability Indicator
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                course.isAvailable ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Only show member count for premium courses
                        if (!course.isFree) ...[
                          Icon(Icons.people_outline,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${course.members.length} Members',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                        const Spacer(),
                        if (course.isFinished)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
