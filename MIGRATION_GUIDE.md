# Migration Guide: Laravel to Node.js Backend

## Response Structure Changes

### OLD (Laravel):

```dart
// Check status code
if (response.statusCode == 200) {
  data = response.data['data'];
}
```

### NEW (Node.js):

```dart
// Check success boolean
if (response['success'] == true) {
  data = response['data'];
}
```

## Specific File Updates Required

### 1. `lib/screens/product/detail_product.dart`

Replace `destroyVariant` usage:

```dart
// OLD
.destroyVariant(id)

// NEW - Use destroyProduct instead since variants are managed as part of products
.destroyProduct(productId.toString())
```

### 2. `lib/screens/product_variant/form_variant.dart`

Replace `storeVariant` usage:

```dart
// OLD
final res = await productServices.storeVariant(body);

// NEW - Create as part of product
FormData formData = FormData.fromMap(body);
final res = await productServices.storeProduct(formData);
```

### 3. `lib/screens/product_variant/edit_variant.dart`

Replace variant methods:

```dart
// OLD
var resp = await productServices.detailVariant(widget.id);
// Check: if (resp.statusCode == 200)

// NEW
var resp = await productServices.detailProduct(widget.id.toString());
// Check: if (resp['success'] == true)

// OLD
var resp = await productServices.updateVariant(widget.id, body);

// NEW
var resp = await productServices.updateProduct(body, widget.id.toString());
```

## Product Service Method Changes

### List Products

```dart
// OLD
var products = await productServices.listProduct();
if (products.statusCode == 200) {
  list = products.data['data'];
}

// NEW
var response = await productServices.listProduct();
if (response['success'] == true) {
  // Response structure: {products: [...], pagination: {...}}
  list = response['data']['products'];
  // Access pagination: response['data']['pagination']
}
```

### Create Product

```dart
// OLD
var response = await productServices.storeProduct(formData);
if (response.statusCode == 201) { /* success */ }

// NEW
var response = await productServices.storeProduct(formData);
if (response['success'] == true) { /* success */ }
```

### Update Product

```dart
// OLD
var response = await productServices.updateProduct(body, id);
if (response.statusCode == 201) { /* success */ }

// NEW
var response = await productServices.updateProduct(body, id);
if (response['success'] == true) { /* success */ }
```

### Set Favorite

```dart
// OLD
Map<String, dynamic> body = {"favorite": item['favorite'] ? 0 : 1};
var resp = await productServices.setFavorite(body, item['id']);

// NEW - Backend handles toggle automatically
var resp = await productServices.setFavorite(item['id']);
```

### Categories

```dart
// OLD
var categories = await productServices.listCategory();
if (categories.statusCode == 200) {
  list = categories.data;
}

// NEW
var response = await productServices.listCategory();
if (response['success'] == true) {
  list = response['data']; // Already array of categories
}
```

## New Features Available

### 1. Pagination Support

```dart
var response = await productServices.listProduct(
  page: 1,
  limit: 20,
  search: 'product name',
  categoryId: 'category-id',
  isFavorite: true,
  lowStock: true,
  stockThreshold: 5
);
```

### 2. Units Dropdown

```dart
var response = await productServices.getUnits();
if (response['success'] == true) {
  List units = response['data'];
}
```

### 3. Low Stock Products

```dart
var response = await productServices.getLowStockProducts(threshold: 10);
```

### 4. Bulk Operations

```dart
var response = await productServices.bulkUpdateProducts(
  ['product-id-1', 'product-id-2'],
  {'price': 100, 'quantity': 50}
);
```

## Error Handling

All methods now return consistent error format:

```dart
var response = await productServices.someMethod();
if (response['success'] == true) {
  // Success - use response['data']
  var data = response['data'];
  var message = response['message'];
} else {
  // Error - show response['message']
  showError(response['message']);
}
```

## Field Name Changes (Backend)

- `store_id` → `storeId`
- `category_id` → `categoryId`
- `capital_price` → `capitalPrice`
- `discount_percent` → `discountPercent`
- `discount_rp` → `discountRp`
- `unit_id` → `unitId`

## Data Structure Changes

### Product Response (OLD Laravel):

```json
{
  "id": 1,
  "name": "Product",
  "category_id": 1,
  "variants": [...]
}
```

### Product Response (NEW Node.js):

```json
{
  "id": "uuid",
  "name": "Product",
  "categoryId": "uuid",
  "category": {...},
  "variants": [...],
  "store": {...}
}
```
