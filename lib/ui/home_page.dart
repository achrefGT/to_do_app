import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/controllers/task_controller.dart';
import 'package:to_do_app/services/theme_services.dart';
import 'package:to_do_app/services/notification_services.dart';
import 'package:to_do_app/ui/theme.dart';
import 'package:to_do_app/ui/widgets/button.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../models/task.dart';
import 'add_task_bar.dart';
import 'widgets/task_tile.dart';

class HomePageUi extends ConsumerStatefulWidget {
  const HomePageUi({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePageUi> createState() => _HomePageUiState();
}

class _HomePageUiState extends ConsumerState<HomePageUi> {
  NotifyHelper notifyHelper = NotifyHelper();
  DateTime _selectedDate = DateTime.now();
  List<Task> _urgentTasks = [];

  @override
  void initState() {
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    super.initState();
  }

  Future<void> _fetchUrgentTasks() async {
    final tasks = await ref.read(taskController).getUrgentTasks(); // Fetch urgent tasks from the controller
    setState(() {
      _urgentTasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(
            height: 10,
          ),
          _showTasks(),
          _urgentTasksButton(), // Add the urgent tasks button here

        ],
      ),
    );
  }

  Widget _urgentTasksButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: MyButton(
        lable: "Urgent tasks",
        onTap: () async {
          await _fetchUrgentTasks();
          _showUrgentTasks();
        },
        color: pinkClr, // Custom color
        width: 350, // Custom width
      ),
    );
  }

  void _showUrgentTasks() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.5,
          child: _urgentTasks.isEmpty
              ? const Center(child: Text("No urgent tasks found."))
              : ListView.builder(
            itemCount: _urgentTasks.length,
            itemBuilder: (context, index) {
              final task = _urgentTasks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet before showing the task details
                  _showBottomSheet(context, task);
                },
                child: TaskTile(task),
              );
            },
          ),
        );
      },
    );
  }

  _showTasks() {
    final tasks = ref.watch(getTasksController);
    return Expanded(
      child: tasks.when(
        data: (data) {
          if (data == null || data.isEmpty) {
            return const Center(
              child: Text("Your TaskList is empty"),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(getTasksController.future),
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final reversedTask = data.reversed.toList();
                  final task = reversedTask[index];
                  print(task.toMap());
                  if (task.repeat == "Daily") {
                    DateTime date = DateFormat.jm().parse(task.startTime.toString());
                    var myTime = DateFormat("HH:mm").format(date);
                    notifyHelper.scheduledNotification(
                      int.parse(myTime.toString().split(":")[0]),
                      int.parse(myTime.toString().split(":")[1]),
                      task,
                    );
                    print("MyTime is :$myTime");
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheet(context, task);
                                },
                                child: TaskTile(task),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  if (task.date == DateFormat.yMd().format(_selectedDate)) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheet(context, task);
                                },
                                child: TaskTile(task),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            );
          }
        },
        error: (error, _) {
          return Center(
            child: Text(error.toString()),
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    final bool isDarkTheme = ref.watch(appThemeProvider).getTheme();
    showModalBottomSheet(
      clipBehavior: Clip.hardEdge,
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isDarkTheme ? darkGreyClr : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            height: task.isCompleted == true
                ? MediaQuery.of(context).size.height * 0.24
                : MediaQuery.of(context).size.height * 0.32,
            child: Column(
              children: [
                Container(
                  height: 6,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDarkTheme ? Colors.grey[600] : Colors.grey[300],
                  ),
                ),
                const Spacer(),
                task.isCompleted == true
                    ? Container()
                    : _bottomSheetButton(
                  context: context,
                  label: "Task Completed",
                  onTap: () {
                    ref.read(taskController).update(task);
                    ref.refresh(getTasksController.future);
                    Navigator.pop(context);
                  },
                  color: primaryClr,
                ),
                _bottomSheetButton(
                  context: context,
                  label: "Delete Task",
                  onTap: () {
                    ref.read(taskController).delete(task);
                    ref.refresh(getTasksController.future);
                    Navigator.pop(context);
                  },
                  color: Colors.red[300]!,
                ),
                const SizedBox(height: 20),
                _bottomSheetButton(
                  context: context,
                  label: "Close",
                  onTap: () {
                    Navigator.pop(context);
                  },
                  color: Colors.red[300]!,
                  isClose: true,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  _bottomSheetButton({
    required BuildContext context,
    required String label,
    required Function()? onTap,
    required Color color,
    bool isClose = false,
  }) {
    final bool isDarkTheme = ref.watch(appThemeProvider).getTheme();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: isClose == true ? Colors.transparent : color,
          border: Border.all(
            color: isClose == true
                ? isDarkTheme
                ? Colors.grey[600]!
                : Colors.grey[300]!
                : color,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: isClose
                ? titleStyle
                : titleStyle.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: white,
        dateTextStyle: GoogleFonts.lato().copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        dayTextStyle: GoogleFonts.lato().copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        monthTextStyle: GoogleFonts.lato().copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        onDateChange: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
      ),
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle.copyWith(
                  color: ref.watch(appThemeProvider).getTheme()
                      ? Colors.grey[400]
                      : Colors.black,
                ),
              ),
              Text(
                "Today",
                style: headingStyle,
              ),
            ],
          ),
          MyButton(
            lable: "+ Add Task",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTaskPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  AppBar _appBar() {
    final bool isDarkTheme = ref.watch(appThemeProvider).getTheme();
    final auth = AuthService();
    return AppBar(
      backgroundColor: Theme.of(context).backgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          ref.watch(appThemeProvider.notifier).setTheme(!isDarkTheme);
          notifyHelper.displayNotification(
            title: "Theme Changed",
            body: isDarkTheme
                ? "Activated Light Theme"
                : "Activated Dark Theme",
          );
        },
        child: Icon(
          isDarkTheme ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 20,
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.logout,
            size: 20,
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
          onPressed: () async {
            // Perform sign out
            await auth.signout();

            // Navigate to login screen
            goToLogin(context);
          },
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  void goToLogin(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
}
