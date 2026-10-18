/// @title Catalog DAO
/// @notice Local reads and writes for users, products and favorites.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/account_tables.dart';
import '../tables/catalog_tables.dart';

part 'catalog_dao.g.dart';

/// @notice One cached product together with its seller row.
typedef ProductWithSeller = (ProductRow product, UserRow? seller);

/// @title CatalogDao
/// @notice Reactive access to the cached catalogue.
@DriftAccessor(tables: [Users, Products, Favorites])
class CatalogDao extends DatabaseAccessor<AppDatabase> with _$CatalogDaoMixin {
  /// @notice Creates the DAO.
  /// @param db Owning database.
  /// @return A new {CatalogDao} instance.
  CatalogDao(super.db);

  /// @notice Streams every cached product with its seller attached.
  /// @dev Left join, so a product whose seller row is somehow missing still
  /// renders (with a null seller) instead of disappearing from the catalogue.
  /// @return Stream of product/seller pairs in backend order.
  Stream<List<ProductWithSeller>> watchProductsWithSeller() {
    return (select(products).join(<Join<HasResultSet, dynamic>>[
      leftOuterJoin(users, users.id.equalsExp(products.sellerId)),
    ]))
        .watch()
        .map(
          (List<TypedResult> rows) => rows
              .map(
                (TypedResult row) =>
                    (row.readTable(products), row.readTableOrNull(users)),
              )
              .toList(),
        );
  }

  /// @notice Streams one cached product with its seller attached.
  /// @param id Identifier taken from {Products.id}.
  /// @return Stream of the pair, or null when the row is not cached.
  Stream<ProductWithSeller?> watchProductWithSeller(String id) {
    return (select(products).join(<Join<HasResultSet, dynamic>>[
      leftOuterJoin(users, users.id.equalsExp(products.sellerId)),
    ])
          ..where(products.id.equals(id)))
        .watchSingleOrNull()
        .map(
          (TypedResult? row) => row == null
              ? null
              : (row.readTable(products), row.readTableOrNull(users)),
        );
  }

  /// @notice Streams the listings of one seller with the seller attached.
  /// @param sellerId Identifier taken from {Users.id}.
  /// @return Stream of product/seller pairs in backend order.
  Stream<List<ProductWithSeller>> watchSellerProductsWithSeller(
    String sellerId,
  ) {
    return (select(products).join(<Join<HasResultSet, dynamic>>[
      leftOuterJoin(users, users.id.equalsExp(products.sellerId)),
    ])
          ..where(products.sellerId.equals(sellerId))
          ..orderBy(<OrderingTerm>[
            OrderingTerm.desc(products.backendUpdatedAt),
          ]))
        .watch()
        .map(
          (List<TypedResult> rows) => rows
              .map(
                (TypedResult row) =>
                    (row.readTable(products), row.readTableOrNull(users)),
              )
              .toList(),
        );
  }


  /// @notice Streams every cached product in backend order.
  /// @return Stream of product rows.
  Stream<List<ProductRow>> watchProducts() {
    return (select(products)
          ..orderBy(<OrderingTerm Function($ProductsTable)>[
            ($ProductsTable row) => OrderingTerm.desc(row.backendUpdatedAt),
          ]))
        .watch();
  }

  /// @notice Streams one cached product.
  /// @param id Identifier taken from {Products.id}.
  /// @return Stream of the matching row, or null.
  Stream<ProductRow?> watchProduct(String id) {
    return (select(products)
          ..where(($ProductsTable row) => row.id.equals(id)))
        .watchSingleOrNull();
  }

  /// @notice Streams the listings of one seller.
  /// @param sellerId Identifier taken from {Users.id}.
  /// @return Stream of product rows in backend order.
  Stream<List<ProductRow>> watchProductsBySeller(String sellerId) {
    return (select(products)
          ..where(($ProductsTable row) => row.sellerId.equals(sellerId))
          ..orderBy(<OrderingTerm Function($ProductsTable)>[
            ($ProductsTable row) => OrderingTerm.desc(row.backendUpdatedAt),
          ]))
        .watch();
  }

  /// @notice Streams every cached user.
  /// @return Stream of user rows.
  Stream<List<UserRow>> watchUsers() {
    return select(users).watch();
  }

  /// @notice Streams one cached user.
  /// @param id Identifier taken from {Users.id}.
  /// @return Stream of the matching row, or null.
  Stream<UserRow?> watchUser(String id) {
    return (select(users)..where(($UsersTable row) => row.id.equals(id)))
        .watchSingleOrNull();
  }

  /// @notice Whether the product cache has never been filled.
  /// @return Future resolving to true when no product is cached.
  Future<bool> isProductCacheEmpty() async {
    final Expression<int> count = products.id.count();
    final TypedResult row = await (selectOnly(products)..addColumns([count]))
        .getSingle();
    return (row.read(count) ?? 0) == 0;
  }

  /// @notice Replaces the whole catalogue atomically.
  /// @dev Wraps the delete and the bulk insert in one transaction so a failed
  /// refresh never leaves a half-written catalogue behind.
  /// @param userRows User companions to store.
  /// @param productRows Product companions to store.
  /// @param fetchedAt UTC millis of this refresh.
  /// @return Future completing when the transaction is durable.
  Future<void> replaceCatalog({
    required List<UsersCompanion> userRows,
    required List<ProductsCompanion> productRows,
    required int fetchedAt,
  }) {
    return transaction(() async {
      await delete(products).go();
      await batch((Batch batch) {
        batch.insertAll(users, userRows, mode: InsertMode.insertOrReplace);
        batch.insertAll(products, productRows);
      });
    });
  }

  /// @notice Streams the saved products with their seller attached.
  /// @dev Inner join on {Favorites}, ordered by save time so the favorite
  /// screen matches the order the hearts were tapped.
  /// @return Stream of product/seller pairs.
  Stream<List<ProductWithSeller>> watchFavoriteProductsWithSeller() {
    return (select(favorites).join(<Join<HasResultSet, dynamic>>[
      innerJoin(products, products.id.equalsExp(favorites.productId)),
      leftOuterJoin(users, users.id.equalsExp(products.sellerId)),
    ])
          ..orderBy(<OrderingTerm>[OrderingTerm.asc(favorites.createdAt)]))
        .watch()
        .map(
          (List<TypedResult> rows) => rows
              .map(
                (TypedResult row) =>
                    (row.readTable(products), row.readTableOrNull(users)),
              )
              .toList(),
        );
  }

  /// @notice Streams the saved favorite ids.
  /// @return Stream of product ids, oldest saved first.
  Stream<Set<String>> watchFavoriteIds() {
    return (select(favorites)
          ..orderBy(<OrderingTerm Function($FavoritesTable)>[
            ($FavoritesTable row) => OrderingTerm.asc(row.createdAt),
          ]))
        .watch()
        .map(
          (List<FavoriteRow> rows) =>
              rows.map((FavoriteRow row) => row.productId).toSet(),
        );
  }

  /// @notice Adds or removes a saved product.
  /// @param productId Catalogue item id.
  /// @param createdAt UTC millis used when inserting.
  /// @return Future completing when the toggle is durable.
  Future<void> toggleFavorite({
    required String productId,
    required int createdAt,
  }) async {
    final FavoriteRow? existing = await (select(favorites)
          ..where(($FavoritesTable row) => row.productId.equals(productId)))
        .getSingleOrNull();
    if (existing != null) {
      await (delete(favorites)
            ..where(($FavoritesTable row) => row.productId.equals(productId)))
          .go();
      return;
    }
    await into(favorites).insert(
      FavoritesCompanion.insert(productId: productId, createdAt: createdAt),
    );
  }
}
