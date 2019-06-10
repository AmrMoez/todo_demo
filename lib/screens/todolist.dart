import 'package:flutter/material.dart';
import 'package:todo_demo/model/todo.dart';
import 'package:todo_demo/util/dbhelper.dart';
import 'package:todo_demo/screens/tododetail.dart';

/// this class would over ride the create state to todo list state
class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoListState();
}

/// this would retrieve the data from the database
class TodoListState extends State {
  DbHelper helper = DbHelper();
  List<Todo> todos;
  int count = 0;

  @override

  /// this will get the data when we open the app
  Widget build(BuildContext context) {
    if (todos == null) {
      todos = List<Todo>();
      getData();
    }

    /// this will return a scaffold for the ui
    /// will have the btn that navigate / add
    return Scaffold(
      body: todoListItems(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Todo('', 3, ''));
        },
        tooltip: "Add new Todo",
        child: new Icon(Icons.add),
      ),
    );
  }

  /// this list view that return the items from the database
  ListView todoListItems() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        /// this is where the todo is displayed
        /// the user will be able to tap the todo to edit it
        return Card(
          color: Colors.lightBlue[100],
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getColor(this.todos[position].priority),
              child: Text(this.todos[position].priority.toString()),
            ),
            title: Text(this.todos[position].title),
            subtitle: Text(this.todos[position].date),
            onTap: () {
              debugPrint("Tapped on " + this.todos[position].id.toString());
              navigateToDetail(this.todos[position]);
            },
          ),
        );
      },
    );
  }

  /// the method that retrieve the data
  void getData() {
    final dbFuture = helper.initializeDb();
    dbFuture.then((result) {
      final todosFuture = helper.getTodos();
      todosFuture.then((result) {
        List<Todo> todoList = List<Todo>();
        count = result.length;
        for (int i = 0; i < count; i++) {
          todoList.add(Todo.fromObject(result[i]));
          debugPrint(todoList[i].title);
        }
        setState(() {
          todos = todoList;
          count = count;
        });
        debugPrint("Items " + count.toString());
      });
    });
  }

  /// this method will help assign colors to the todo
  Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.indigo[900];
        break;
      case 2:
        return Colors.indigo;
        break;
      case 3:
        return Colors.indigo[200];
        break;

      default:
        return Colors.indigo[200];
    }
  }

  /// the navigation method
  void navigateToDetail(Todo todo) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoDetail(todo)),
    );
    if (result == true) {
      getData();
    }
  }
}
