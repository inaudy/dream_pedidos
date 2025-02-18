import 'package:dream_pedidos/data/models/refill_history_item.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';

abstract class StockRepository {
  /// Retrieves all stock items from the data source
  Future<List<StockItem>> getAllStockItems();

  /// Inserts multiple stock items into the data source
  Future<void> addStockItems(List<StockItem> items);

  /// Updates a single stock item in the data source
  Future<int> updateStockItem(StockItem item);

  /// Updates stock in bulk using sales data
  Future<void> bulkUpdateStock(List<Map<String, dynamic>> salesData);

  /// Resets the stock table from the backup data source
  Future<void> resetStockFromBackup();

  Future<List<RefillHistoryItem>> getRefillHistory();
  Future<void> revertRefill(int refillId);
  Future<void> saveRefillHistory(
      String itemName, double adjustedRefill, double errorPercentage);
}
