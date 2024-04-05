import 'package:ctracker/models/board.dart';

abstract class BoardRepository {
  Future<List<Board>> getAllBoards();
  Future<Board> addBoards(Board board);
  Future<void> deleteBoard(String id);
  Future<void> updateBoard(String id, Board board);
}
