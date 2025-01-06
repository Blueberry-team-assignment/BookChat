import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/feature/book_home/book_talk_screen.dart'; 

class Bottom extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(color: Colors.blueGrey,
        child: Container(height: 50,
            child: TabBar(labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.transparent,
              onTap: (index) {
                if (index == 0) {
                  ref.read(refreshProvider.notifier).state++;
                }
              },
              tabs: <Widget>[
                Tab(icon: Icon(Icons.book, size: 18),
                    child: Text('book talk', style: TextStyle(fontSize: 9),
                    )
                ),
                Tab(icon: Icon(Icons.search, size: 18),
                    child: Text('+', style: TextStyle(fontSize: 9),
                    )
                ),
                Tab(icon: Icon(Icons.home, size: 18),
                    child: Text('my page', style: TextStyle(fontSize: 9),
                    )
                ),
              ],)));
  }
}