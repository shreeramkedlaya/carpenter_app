import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class DatabaseService {
  Database? db;
  static bool _isDbInitialized = false;

  // Initialize the database
  Future<void> initDB() async {
    if (_isDbInitialized) return;
    try {
      var databasesPath = await getDatabasesPath();

      String path = join(databasesPath, 'carpenter_app.db');

      db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await createCarpenterAppTables(db);
          await insertMasterData(db);
        },
      );
      _isDbInitialized = true;
      print('Database initialized successfully');
    } catch (error) {
      print('Database initialization failed: $error');
    }
  }

  Future<void> createCarpenterAppTables(Database db) async {
    final createTablesQuery = '''
    CREATE TABLE IF NOT EXISTS master_table (
    key INTEGER PRIMARY KEY,
    value TEXT,
    type TEXT
);
    CREATE TABLE IF NOT EXISTS organization (
    org_id INTEGER PRIMARY KEY NOT NULL,
    org_name TEXT NOT NULL,
    enabled BOOLEAN,
    deleted BOOLEAN,
    org_address TEXT,
    last_synced_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS org_user (
    user_id INTEGER PRIMARY KEY NOT NULL,
    username TEXT,
    enabled BOOLEAN,
    deleted BOOLEAN,
    org_name TEXT,
    user_role TEXT,
    email_id TEXT,
    contact_number TEXT,
    org_logo TEXT,
    org_address TEXT,
    created_date DATE,
    first_name TEXT,
    last_synced_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS carpenter_customer (
    customer_id INTEGER PRIMARY KEY NOT NULL,
    org_id INTEGER,
    org_name TEXT,
    customer_name TEXT NOT NULL,
    contact_number TEXT,
    customer_address TEXT,
    enabled BOOLEAN,
    deleted BOOLEAN,
    created_date TIMESTAMP,
    updated_date TIMESTAMP,
    updated_by INTEGER,
    sync_status TEXT DEFAULT 'new',
    last_synced_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS carpenter_order (
    order_id INTEGER PRIMARY KEY NOT NULL,
    org_id INTEGER,
    customer_id INTEGER,
    order_details TEXT,
    order_status TEXT,
    payment_status SMALLINT,
    order_amount INTEGER,
    advance_amount INTEGER,
    due_amount INTEGER,
    order_date DATE,
    due_date DATE,
    has_job_order TEXT,
    order_priority SMALLINT,
    created_date TIMESTAMP,
    updated_date TIMESTAMP,
    updated_by INTEGER,
    sync_status TEXT DEFAULT 'new',
    last_synced_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES carpenter_customer (customer_id)
);

CREATE TABLE IF NOT EXISTS carpenter_order_docs (
    doc_id INTEGER PRIMARY KEY NOT NULL,
    order_id INTEGER,
    details_type INTEGER,
    details_data VARCHAR,
    updated_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    sync_status TEXT DEFAULT 'new',
    last_synced_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES carpenter_order (order_id)
);

CREATE TABLE IF NOT EXISTS carpenter_partner (
    partner_id INTEGER PRIMARY KEY NOT NULL,
    org_id INT,
    partner_name VARCHAR NOT NULL,
    partner_contact VARCHAR NOT NULL,
    partner_address VARCHAR,
    partner_category_id VARCHAR,
    partner_category VARCHAR,
    notes VARCHAR,
    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE,
    updated_date DATE,
    updated_by INT,
    sync_status TEXT DEFAULT 'new',
    last_synced_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS carpenter_job_order (
    job_id INTEGER PRIMARY KEY NOT NULL,
    org_id INT NOT NULL,
    order_id INT NOT NULL,
    customer_id INT,
    partner_id INT,
    job_order_details VARCHAR,
    job_due_date DATE,
    job_priority SMALLINT CHECK (job_priority IN (1, 2, 3)),
    created_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by INT,
    sync_status TEXT DEFAULT 'new',
    last_synced_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS carpenter_job_docs (
    job_doc_id INTEGER PRIMARY KEY NOT NULL,
    job_id INT NOT NULL, 
    order_id INT NOT NULL,
    details_id INT,
    details_type INT,
    details_data VARCHAR,
    shared_m BOOLEAN DEFAULT FALSE,
    shared_pt BOOLEAN DEFAULT FALSE,
    shared_mt BOOLEAN DEFAULT FALSE,
    note VARCHAR,
    sync_status TEXT DEFAULT 'new',
    last_synced_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES carpenter_job_order (job_id),
    FOREIGN KEY (order_id) REFERENCES carpenter_order (order_id)
);

CREATE TABLE IF NOT EXISTS master_table (
    key INTEGER,
    value TEXT,
    type TEXT,
    last_synced_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (key, type)
);  

CREATE TABLE IF NOT EXISTS payment_table (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT, 
    order_id INTEGER NOT NULL,                  
    payment_date DATETIME NOT NULL,             
    amount INTEGER NOT NULL,              
    payment_mode TEXT NOT NULL,                  
    reference_number TEXT,                       
    remarks TEXT,                                
    FOREIGN KEY (order_id) REFERENCES carpenter_order(order_id) 
);

  ''';

    await db.execute(createTablesQuery);
    // print('Carpenter app tables created successfully.');
  }

  Future<void> insertMasterData(Database db) async {
    try {
      // Define the structure of master data
      final Map<String, List<Map<String, dynamic>>> masterData = {
        'job_details': [
          {'id': 1, 'name': 'Furniture Making'},
          {'id': 2, 'name': 'Wood Carving'},
        ],
        'partner_categories': [
          {'id': 1, 'name': 'Timber Work'},
          {'id': 2, 'name': 'Interior Designing'},
        ],
        'job_priority': [
          {'id': 1, 'name': 'Urgent'},
          {'id': 2, 'name': 'High'},
          {'id': 3, 'name': 'Normal'},
        ],
      };

      // SQL query for inserting data
      const String insertQuery = '''
      INSERT OR IGNORE INTO master_table (key, value, type) 
      VALUES (?, ?, ?);
    ''';

      // Iterate over each category and insert
      for (final category in masterData.keys) {
        final List<Map<String, dynamic>> dataArray = masterData[category]!;
        for (final data in dataArray) {
          await db.rawInsert(insertQuery, [data['id'], data['name'], category]);
        }
      }

      print('Master data inserted successfully.');
    } catch (error) {
      print('Error inserting master data from JSON: $error');
    }
  }

// Helper to check if there is unsynced data in any table
  Future<bool> hasUnsyncedData() async {
    if (db == null) return false;

    List<String> tables = [
      'carpenter_customer',
      'carpenter_order',
      'carpenter_job_order',
      'carpenter_partner',
      'carpenter_order_docs',
      'carpenter_job_docs',
    ];

    for (String table in tables) {
      String query =
          "SELECT COUNT(*) AS count FROM $table WHERE sync_status IN ('new', 'updated');";
      try {
        List<Map<String, dynamic>> result = await db!.rawQuery(query);
        if (result.isNotEmpty && (result.first['count'] as int) > 0) {
          return true;
        }
      } catch (error) {
        print("Error checking unsynced data for table $table: $error");
      }
    }

    return false;
  }

// Setup network listener
  Future<void> setupNetworkListener() async {
    // Check initial connectivity status
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      syncDataToBackend();
    }

    // Listen for network status changes
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      // We are only interested in the first element of the list
      if (result.isNotEmpty && result.first != ConnectivityResult.none) {
        print('Device is online. Syncing data...');
        syncDataToBackend();
      } else {
        print('Device is offline.');
      }
    });
  }

// Start periodic sync
  void startPeriodicSync() {
    Timer.periodic(Duration(minutes: 5), (timer) async {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        print('Periodic sync triggered.');
        syncDataToBackend();
      }
    });
  }

// Get dropdown options
  Future<List<Map<String, dynamic>>> getDropdownOptions(String type) async {
    if (db == null) {
      print('Database not initialized');
      return [];
    }

    String query =
        "SELECT key AS id, value AS name FROM master_table WHERE type = ?";
    List<Map<String, dynamic>> result = await db!.rawQuery(query, [type]);

    return result;
  }

  Future<int> saveOrUpdateOrder(Map<String, dynamic> order) async {
    if (db == null) {
      print('Database not initialized');
      return 0;
    }

    try {
      if (order['orderId'] != null) {
        // Check if order exists
        final checkQuery =
            'SELECT order_id FROM carpenter_order WHERE order_id = ?';
        final existingOrder =
            await db!.query(checkQuery, whereArgs: [order['orderId']]);

        if (existingOrder.isNotEmpty) {
          // Update existing order
          final updateQuery = '''
        UPDATE carpenter_order 
        SET org_id = ?, customer_id = ?, order_details = ?, order_status = ?, payment_status = ?, 
            order_amount = ?, advance_amount = ?, due_amount = ?, order_date = ?, due_date = ?, has_job_order = ?, 
            order_priority = ?, sync_status = 'updated'
        WHERE order_id = ?;
      ''';
          final updateValues = [
            order['orgId'],
            order['customerId'],
            order['orderDetails'],
            order['orderStatus'],
            order['paymentStatus'],
            order['orderAmount'],
            order['advanceAmount'],
            order['dueAmount'],
            order['orderDate'],
            order['dueDate'],
            order['hasJobOrder'],
            order['orderPriority'],
            order['orderId'], // WHERE clause value
          ];
          await db?.execute(updateQuery, updateValues);
          print('Order updated successfully with ID: ${order['orderId']}');
          return order['orderId']; // Return updated orderId
        }
      }

      // Insert new order
      final insertQuery = '''
    INSERT INTO carpenter_order (
      org_id, customer_id, order_details, order_status, payment_status, order_amount, advance_amount, 
      due_amount, order_date, due_date, has_job_order, order_priority, sync_status
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'new');
  ''';
      final insertValues = [
        order['orgId'],
        order['customerId'],
        order['orderDetails'],
        order['orderStatus'],
        order['paymentStatus'],
        order['orderAmount'],
        order['advanceAmount'],
        order['dueAmount'],
        order['orderDate'],
        order['dueDate'],
        order['hasJobOrder'],
        order['orderPriority'],
      ];

      // Using execute and then retrieving the inserted row ID
      await db?.execute(insertQuery, insertValues);
      final insertIdQuery =
          'SELECT last_insert_rowid()'; // Query to get the last inserted ID
      final insertId = Sqflite.firstIntValue(await db!.rawQuery(insertIdQuery));

      print('Order saved successfully with ID: $insertId');
      return insertId ??
          0; // Return the inserted order ID, or 0 if it's not available
    } catch (error) {
      print('Error saving order: $error');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getOrderById(int orderId) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    final query = '''
      SELECT 
        o.*, 
        c.customer_name,
        c.contact_number,
        c.customer_address
      FROM 
        carpenter_order o
      LEFT JOIN 
        carpenter_customer c ON o.customer_id = c.customer_id
      WHERE 
        o.order_id = ?;
    ''';

    try {
      final orderResult = await db!.rawQuery(query, [orderId]);
      final order = orderResult.isNotEmpty ? orderResult.first : null;

      if (order != null) {
        // Fetch associated details
        final measurements =
            await getOrderDetailsByOrderId(orderId, 1); // 1 = Measurements
        final patterns =
            await getOrderDetailsByOrderId(orderId, 3); // 3 = Patterns
        final materials =
            await getOrderDetailsByOrderId(orderId, 2); // 2 = Materials
        final audio = await getOrderDetailsByOrderId(orderId, 4); // 4 = Audio

        bool hasJobOrder = false;
        List<Map<String, dynamic>>? jobOrderDetails;

        try {
          // Check if a job order exists
          hasJobOrder = await checkJobOrderExists(orderId);

          if (hasJobOrder) {
            jobOrderDetails = await getJobOrderDetails(orderId);

            // Fetch documents for each job order
            for (var job in jobOrderDetails) {
              final jobDocs = await getJobDocsByJobId(job['job_id']);
              job['documents'] = jobDocs;
            }
          }
        } catch (error) {
          print('Error fetching job order details: $error');
          hasJobOrder = false;
          jobOrderDetails = null;
        }

        return {
          ...order,
          'measurements': measurements,
          'patterns': patterns,
          'materials': materials,
          'audio': audio, // Include audio if needed
          'hasJobOrder': hasJobOrder,
          'jobOrderDetails':
              jobOrderDetails, // Include job order details with documents
        };
      } else {
        return null; // No order found
      }
    } catch (error) {
      print('Error fetching order: $error');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOrdersByCustomerId(
      int customerId) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }
    if (customerId == 0) {
      print('Customer ID is 0. Returning an empty list.');
      return [];
    }

    final query = '''
      SELECT 
        o.*, 
        c.customer_name,
        c.contact_number,
        c.customer_address
      FROM 
        carpenter_order o
      LEFT JOIN 
        carpenter_customer c ON o.customer_id = c.customer_id
      WHERE 
        o.customer_id = ?;
    ''';

    try {
      final ordersResult = await db!.rawQuery(query, [customerId]);
      final orders = ordersResult.isNotEmpty ? ordersResult : [];

      if (orders.isNotEmpty) {
        // Fetch associated details for each order
        final enrichedOrders = <Map<String, dynamic>>[];

        for (final order in orders) {
          final orderId = order['order_id'];

          final measurements =
              await getOrderDetailsByOrderId(orderId, 1); // 1 = Measurements
          final patterns =
              await getOrderDetailsByOrderId(orderId, 3); // 3 = Patterns
          final materials =
              await getOrderDetailsByOrderId(orderId, 2); // 2 = Materials
          final audio = await getOrderDetailsByOrderId(orderId, 4); // 4 = Audio

          bool hasJobOrder = false;
          List<Map<String, dynamic>>? jobOrderDetails;

          try {
            hasJobOrder = await checkJobOrderExists(orderId);

            if (hasJobOrder) {
              jobOrderDetails = await getJobOrderDetails(orderId);

              // Fetch documents for each job order
              for (var job in jobOrderDetails) {
                final jobDocs = await getJobDocsByJobId(job['job_id']);
                job['documents'] = jobDocs;
              }
            }
          } catch (error) {
            print('Error fetching job order details: $error');
            hasJobOrder = false;
            jobOrderDetails = null;
          }

          enrichedOrders.add({
            ...order,
            'measurements': measurements,
            'patterns': patterns,
            'materials': materials,
            'audio': audio, // Include audio if needed
            'hasJobOrder': hasJobOrder,
            'jobOrderDetails':
                jobOrderDetails, // Include job order details with documents
          });
        }

        return enrichedOrders;
      } else {
        return [];
      }
    } catch (error) {
      print('Error fetching orders by customer ID: $error');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getJobDocsByJobId(int jobId) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    final query = '''
  SELECT 
    job_doc_id, 
    job_id, 
    order_id, 
    details_type, 
    details_data, 
    shared_m, 
    shared_pt, 
    shared_mt, 
    note 
  FROM 
    carpenter_job_docs
  WHERE 
    job_id = ?;
''';

    try {
      final result = await db!.rawQuery(
          query, [jobId]); // Use rawQuery to run the query string directly
      return result.isNotEmpty ? result : [];
    } catch (error) {
      print('Error fetching job documents: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getJobOrderDetails(int orderId) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    final query = '''
      SELECT 
        j.*,
        p.partner_name,
        p.partner_contact,
        p.partner_address
      FROM 
        carpenter_job_order j
      LEFT JOIN 
        carpenter_partner p ON j.partner_id = p.partner_id
      WHERE 
        j.order_id = ?;
    ''';

    try {
      final result = await db!.rawQuery(query, [orderId]);
      return result.isNotEmpty ? result : [];
    } catch (error) {
      print('Error fetching job order details for Order ID $orderId: $error');
      return [];
    }
  }

  Future<bool> checkJobOrderExists(int orderId) async {
    const query =
        'SELECT COUNT(*) AS count FROM carpenter_job_order WHERE order_id = ?';

    try {
      final result = await db!.rawQuery(query, [orderId]);
      if (result.isNotEmpty && result[0]['count'] != null) {
        final count = result[0]['count'];
        return (count != null &&
            int.tryParse(count.toString()) != null &&
            int.tryParse(count.toString())! > 0);
      }
      return false;
    } catch (error) {
      print('Error checking job order existence: $error');
      return false;
    }
  }

  Future<void> runQuery(String query, [List<dynamic> values = const []]) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    try {
      await db!.execute(query, values);
    } catch (error) {
      print('Error executing query: $error');
      throw error;
    }
  }

  Future<void> deleteOrder(int orderId) async {
    print(orderId);
    if (db == null) {
      print('Database not initialized');
      return;
    }

    final deleteOrderQuery = 'DELETE FROM carpenter_order WHERE order_id = ?';
    final deleteDetailsQuery =
        'DELETE FROM carpenter_order_docs WHERE order_id = ?';

    try {
      // Deleting details
      final deleteDetailsResult =
          await db!.rawQuery(deleteDetailsQuery, [orderId]);
      print(
          'Details deleted: ${deleteDetailsResult.length}'); // Checking how many rows were deleted

      // Deleting the order
      final deleteOrderResult = await db!.rawQuery(deleteOrderQuery, [orderId]);
      print(
          'Order deleted: ${deleteOrderResult.length}'); // Checking how many rows were deleted

      // Fetch updated orders list if needed
      await getAllOrders();
    } catch (error) {
      print('Error deleting order and its details: $error');
    }
  }

// Close the database connection (for cleanup)
  Future<void> closeDatabase() async {
    if (db != null) {
      try {
        await db?.close();
        print('Database connection closed');
      } catch (error) {
        print('Error closing database: $error');
      }
    } else {
      print('Database is not initialized');
    }
  }

  Future<List<Map<String, dynamic>>> getCustomersByPhone(String phone) async {
    const query = '''
    SELECT customer_id, customer_name AS name, contact_number AS mobile, customer_address AS place
    FROM carpenter_customer WHERE contact_number = ?;
  ''';

    try {
      final result = await db!.rawQuery(query, [phone]);

      return result.isNotEmpty
          ? result.map((row) {
              return {
                'customer_id': row['customer_id'],
                'name': row['name'],
                'mobile': row['mobile'],
                'place': row['place'],
              };
            }).toList()
          : [];
    } catch (error) {
      print('Error fetching customers by phone: $error');
      return [];
    }
  }

  Future<void> saveDetails(
      int orderId, int detailsType, String detailsData) async {
    if (db == null) {
      print('Database not initialized');
      return;
    }

    try {
      // Check if the record already exists
      const checkQuery = '''
        SELECT doc_id FROM carpenter_order_docs
        WHERE order_id = ? AND details_type = ? AND details_data = ?;
      ''';
      final result = await db!
          .query(checkQuery, whereArgs: [orderId, detailsType, detailsData]);

      if (result.isNotEmpty) {
        // Update existing record and set sync_status to 'updated'
        const updateQuery = '''
      UPDATE carpenter_order_docs 
      SET updated_date = CURRENT_TIMESTAMP, sync_status = 'updated'
      WHERE doc_id = ?;
    ''';
        final docId = result[0]['doc_id'];
        await db!.execute(updateQuery, [docId]);
        print('Details updated for Order ID: $orderId, Type: $detailsType');
      } else {
        // Insert new record and set sync_status to 'new'
        const insertQuery = '''
      INSERT INTO carpenter_order_docs (order_id, details_type, details_data, updated_date, sync_status)
      VALUES (?, ?, ?, CURRENT_TIMESTAMP, 'new');
    ''';
        await db!.execute(insertQuery, [orderId, detailsType, detailsData]);
        print('Details saved for Order ID: $orderId, Type: $detailsType');
      }
    } catch (error) {
      print('Error in saveDetails: $error');
    }
  }

  Future<Map<String, dynamic>?> getImage(
      int orderId, int detailsType, String detailsData) async {
    if (db == null) {
      print('Database not initialized');
      return null;
    }

    const query = '''
    SELECT doc_id FROM carpenter_order_docs
    WHERE order_id = ? AND details_type = ? AND details_data = ?;
  ''';

    try {
      final result = await db!
          .query(query, whereArgs: [orderId, detailsType, detailsData]);
      print(
          'Query result for getImage (Order ID: $orderId, Type: $detailsType): $result');

      // Check if the result is not empty, and return the first record
      return result.isNotEmpty ? result.first : null;
    } catch (error) {
      print('Error fetching image: $error');
      return null;
    }
  }

  Future<List<String>> getOrderDetailsByOrderId(
      int orderId, int detailsType) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    const query = '''
      SELECT details_data 
      FROM carpenter_order_docs  
      WHERE order_id = ? AND details_type = ?;
    ''';

    try {
      final result = await db!.query(query, whereArgs: [orderId, detailsType]);
      print(result);
      return result.isNotEmpty
          ? List<String>.from(result.map((row) => row['details_data']))
          : [];
    } catch (error) {
      print(
          'Error fetching details of type $detailsType for order ID $orderId: $error');
      throw error;
    }
  }

  Future<List<Map>> getAllOrders() async {
    if (db == null) {
      print('Database not initialized');
      return [];
    }

    // Query to get orders with customer details
    const queryOrders = '''
    SELECT 
      o.*, 
      c.customer_name, 
      c.contact_number, 
      c.customer_address 
    FROM carpenter_order o
    LEFT JOIN carpenter_customer c ON o.customer_id = c.customer_id;
  ''';

    // Query to get order details (docs)
    const queryDetails = '''
    SELECT order_id, details_type, details_data 
    FROM carpenter_order_docs;
  ''';

    try {
      // Fetch orders
      final ordersResult = await db!.rawQuery(queryOrders);
      final orders = ordersResult.isNotEmpty
          ? List<Map<String, dynamic>>.from(ordersResult)
          : [];

      // Fetch details
      final detailsResult = await db!.rawQuery(queryDetails);
      final details = detailsResult.isNotEmpty
          ? List<Map<String, dynamic>>.from(detailsResult)
          : [];

      // Group details by order and add them to the respective orders
      final groupedOrders = orders.map((order) {
        final orderId = order['order_id'];

        // Filter details for this order
        final imageData =
            details.where((detail) => detail['order_id'] == orderId).toList();

        return {
          ...order,
          'measurements': imageData
              .where((d) => d['details_type'] == 1)
              .map((d) => d['details_data'])
              .toList(),
          'materials': imageData
              .where((d) => d['details_type'] == 2)
              .map((d) => d['details_data'])
              .toList(),
          'patterns': imageData
              .where((d) => d['details_type'] == 3)
              .map((d) => d['details_data'])
              .toList(),
          // Get the first matching audio URL or null if not found
          'audioUrl': imageData.firstWhere((d) => d['details_type'] == 4,
              orElse: () => null)?['details_data'],
        };
      }).toList();

      return groupedOrders;
    } catch (error) {
      print('Error retrieving orders and details: $error');
      return [];
    }
  }

  Future<void> clearDetails(int orderId, int detailsType) async {
    if (db == null) {
      print('Database not initialized');
      return;
    }

    const query = '''
      DELETE FROM carpenter_order_docs WHERE order_id = ? AND details_type = ?;
    ''';

    try {
      await db!.execute(query, [orderId, detailsType]);
      print('Cleared details of type $detailsType for Order ID: $orderId');
    } catch (error) {
      print(
          'Error clearing details of type $detailsType for Order ID: $orderId - $error');
    }
  }

  Future<Object?> saveOrUpdateCustomer(Map<String, dynamic> customer) async {
    if (db == null) {
      print('Database not initialized');
      return 0;
    }

    try {
      // Check if the customer already exists
      final existingCustomerResult = await db!.query(
        'carpenter_customer',
        where: 'contact_number = ?',
        whereArgs: [customer['contactNumber']],
      );

      if (existingCustomerResult.isNotEmpty) {
        // Update existing customer
        final existingCustomer = existingCustomerResult.first;
        final updateQuery = '''
          UPDATE carpenter_customer
          SET 
            customer_name = ?, 
            customer_address = ?, 
            org_id = ?, 
            org_name = ?, 
            enabled = ?, 
            deleted = ?, 
            updated_date = CURRENT_TIMESTAMP, 
            sync_status = 'updated'
          WHERE customer_id = ?;
        ''';
        final updateValues = [
          customer['name'],
          customer['address'],
          customer['orgId'],
          customer['orgName'],
          customer['enabled'],
          customer['deleted'],
          existingCustomer['customer_id'],
        ];

        await db!.rawUpdate(updateQuery, updateValues);
        print(
            'Customer updated successfully with ID: ${existingCustomer['customer_id']}');
        return existingCustomer['customer_id'];
      } else {
        // Insert new customer
        final insertQuery = '''
          INSERT INTO carpenter_customer (
            org_id, org_name, customer_name, contact_number, customer_address, enabled, deleted, created_date, sync_status
          ) VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, 'new');
        ''';
        final result = await db!.rawInsert(insertQuery, [
          customer['orgId'],
          customer['orgName'],
          customer['name'],
          customer['contactNumber'],
          customer['address'],
          customer['enabled'],
          customer['deleted'],
        ]);

        print('Customer inserted successfully with ID: $result');
        return result;
      }
    } catch (error) {
      print('Error saving customer: $error');
      throw error;
    }
  }

  Future<int> addOrUpdatePartner(Map<String, dynamic> partner) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    String query;
    List<dynamic> params;

    if (partner['partner_id'] != null) {
      // Update existing partner and set sync_status to 'updated'
      query = '''
        UPDATE carpenter_partner
        SET 
          partner_name = ?, 
          partner_contact = ?, 
          partner_address = ?, 
          partner_category_id = ?, 
          partner_category = ?, 
          notes = ?, 
          updated_date = CURRENT_TIMESTAMP, 
          sync_status = 'updated'
        WHERE partner_id = ?;
      ''';
      params = [
        partner['partner_name'],
        partner['partner_contact'],
        partner['partner_address'],
        partner['partner_category_id'] ??
            null, // Ensure null is passed if no category
        partner['partner_category'] ?? null,
        partner['notes'],
        partner['partner_id'],
      ];
    } else {
      // Insert new partner and set sync_status to 'new'
      query = '''
        INSERT INTO carpenter_partner (
          partner_name, partner_contact, partner_address, 
          partner_category_id, partner_category, notes, updated_date, sync_status
        ) VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, 'new');
      ''';
      params = [
        partner['partner_name'],
        partner['partner_contact'],
        partner['partner_address'],
        partner['partner_category_id'] ?? null,
        partner['partner_category'] ?? null,
        partner['notes'],
      ];
    }

    try {
      final result = await db!.rawInsert(query, params);
      print(partner['partner_id'] != null
          ? 'Partner updated successfully with ID: ${partner['partner_id']}'
          : 'New partner added with ID: $result');
      return result;
    } catch (error) {
      print('Error in addOrUpdatePartner: $error');
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> getPartners() async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    const query = '''
      SELECT partner_id, partner_name, partner_contact, partner_address, 
             partner_category_id, partner_category, notes
      FROM carpenter_partner 
      WHERE deleted = 0
    ''';

    final result = await db!.rawQuery(query);
    return result;
  }

  Future<List<int>> saveOrUpdateJobOrders(
      List<Map<String, dynamic>> jobOrders) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    List<int> savedJobOrderIds = [];

    try {
      for (var jobOrder in jobOrders) {
        if (jobOrder['job_id'] != null) {
          // Check if job order already exists
          final checkQuery =
              'SELECT job_id FROM carpenter_job_order WHERE job_id = ?';
          final existingJob =
              await db!.rawQuery(checkQuery, [jobOrder['job_id']]);

          if (existingJob.isNotEmpty) {
            // Update existing job order
            final updateQuery = '''
              UPDATE carpenter_job_order
              SET org_id = ?, order_id = ?, customer_id = ?, partner_id = ?, 
                  job_order_details = ?, job_due_date = ?, job_priority = ?, 
                  updated_date = CURRENT_TIMESTAMP, updated_by = ?, sync_status = 'updated'
              WHERE job_id = ?;
            ''';

            final updateValues = [
              jobOrder['org_id'],
              jobOrder['order_id'],
              jobOrder['customer_id'],
              jobOrder['partner_id'],
              jobOrder['job_order_details'],
              jobOrder['job_due_date'],
              jobOrder['job_priority'],
              jobOrder['updated_by'],
              jobOrder['job_id'],
            ];

            await db!.rawUpdate(updateQuery, updateValues);
            print(
                'Job order updated successfully with ID: ${jobOrder['job_id']}');
            savedJobOrderIds.add(jobOrder['job_id']);
            continue;
          }
        }

        // Insert new job order
        final insertQuery = '''
          INSERT INTO carpenter_job_order (
            org_id, order_id, customer_id, partner_id, job_order_details, job_due_date, 
            job_priority, created_date, updated_date, updated_by, sync_status
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'new');
        ''';

        final insertValues = [
          jobOrder['org_id'],
          jobOrder['order_id'],
          jobOrder['customer_id'],
          jobOrder['partner_id'],
          jobOrder['job_order_details'],
          jobOrder['job_due_date'],
          jobOrder['job_priority'],
          jobOrder['created_date'],
          jobOrder['updated_date'],
          jobOrder['updated_by'],
        ];

        final insertResult = await db!.rawInsert(insertQuery, insertValues);
        final newJobOrderId = insertResult;
        print('Job order saved successfully with ID: $newJobOrderId');
        savedJobOrderIds.add(newJobOrderId);
      }
    } catch (error) {
      print('Error saving job orders: $error');
    }

    return savedJobOrderIds;
  }

  Future<void> saveJobDoc(Map<String, dynamic> jobDoc) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    try {
      // Check if the document already exists
      final checkQuery = '''
        SELECT job_doc_id FROM carpenter_job_docs
        WHERE job_id = ? AND order_id = ? AND details_id = ? AND details_type = ?;
      ''';

      final existingDoc = await db!.rawQuery(checkQuery, [
        jobDoc['job_id'],
        jobDoc['order_id'],
        jobDoc['details_id'],
        jobDoc['details_type'],
      ]);

      if (existingDoc.isNotEmpty) {
        // Update existing document
        final updateQuery = '''
          UPDATE carpenter_job_docs
          SET details_data = ?, shared_m = ?, shared_pt = ?, shared_mt = ?, note = ?, sync_status = 'updated'
          WHERE job_doc_id = ?;
        ''';

        await db!.rawUpdate(updateQuery, [
          jobDoc['details_data'],
          jobDoc['shared_m'] ? 1 : 0,
          jobDoc['shared_pt'] ? 1 : 0,
          jobDoc['shared_mt'] ? 1 : 0,
          jobDoc['note'],
          existingDoc[0]['job_doc_id'],
        ]);
        print(
            'Job Document updated successfully: ${existingDoc[0]['job_doc_id']}');
      } else {
        // Insert new document
        final insertQuery = '''
          INSERT INTO carpenter_job_docs (
            job_id, order_id, details_id, details_type, details_data, 
            shared_m, shared_pt, shared_mt, note, sync_status
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'new');
        ''';

        final values = [
          jobDoc['job_id'],
          jobDoc['order_id'],
          jobDoc['details_id'],
          jobDoc['details_type'],
          jobDoc['details_data'],
          jobDoc['shared_m'] ? 1 : 0,
          jobDoc['shared_pt'] ? 1 : 0,
          jobDoc['shared_mt'] ? 1 : 0,
          jobDoc['note'],
        ];

        await db!.rawInsert(insertQuery, values);
        print('Job Document saved successfully: $jobDoc');
      }
    } catch (error) {
      print('Error saving or updating job document: $error');
      rethrow;
    }
  }

  // Fetch unsynced data based on `sync_status` and `last_synced_time`
  Future<List<Map<String, dynamic>>> getUnsyncedData(String tableName) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    final query = '''
      SELECT * FROM $tableName 
      WHERE sync_status IN ('new', 'updated') OR last_synced_time IS NULL;
    ''';

    final result = await db!.rawQuery(query);
    return result;
  }

  // Mark data as synced and update `last_synced_time`
  Future<void> markDataAsSynced(String tableName, String timestamp) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    final query = '''
      UPDATE $tableName
      SET sync_status = 'synced', last_synced_time = ?
      WHERE sync_status IN ('new', 'updated');
    ''';

    await db!.rawUpdate(query, [timestamp]);
  }

  // Fetch payments by orderId
  Future<List<Map<String, dynamic>>> getPaymentsByOrderId(int orderId) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    final query = '''
      SELECT * FROM payment_table
      WHERE order_id = ? ORDER BY payment_date DESC;
    ''';

    final result = await db!.rawQuery(query, [orderId]);
    return result;
  }

  // Save payment
  Future<void> savePayment(Map<String, dynamic> payment) async {
    if (db == null) {
      throw Exception('Database not initialized');
    }

    final query = '''
      INSERT INTO payment_table (order_id, payment_date, amount, payment_mode)
      VALUES (?, ?, ?, ?);
    ''';

    final params = [
      payment['order_id'],
      payment['date'] ?? DateTime.now().toIso8601String(),
      payment['amount'] ?? 0,
      payment['mode'] ?? 'Unknown',
    ];

    await db!.rawInsert(query, params);
    print('Payment saved: $payment');
  }

  Future<void> syncDataToBackend() async {
    if (db == null) {
      print('Database not initialized');
      return;
    }

    try {
      // Fetch unsynced data
      final customers = await getUnsyncedData('carpenter_customer');
      final orders = await getUnsyncedData('carpenter_order');
      final jobOrders = await getUnsyncedData('carpenter_job_order');
      final partners = await getUnsyncedData('carpenter_partner');
      final orderDocs = await getUnsyncedData('carpenter_order_docs');
      final jobDocs = await getUnsyncedData('carpenter_job_docs');

      // If no unsynced data, exit early
      if (customers.isEmpty &&
          orders.isEmpty &&
          jobOrders.isEmpty &&
          partners.isEmpty &&
          orderDocs.isEmpty &&
          jobDocs.isEmpty) {
        print('No unsynced data available');
        return;
      }

      // Combine data into a payload
      final payload = {
        'customers': customers,
        'orders': orders,
        'jobOrders': jobOrders,
        'partners': partners,
        'orderDocs': orderDocs,
        'jobDocs': jobDocs,
      };

      // Send data to the backend
      final url =
          'http://localhost:8080/api/sync'; // Replace with your backend endpoint
      final response = await http.post(Uri.parse(url), body: payload);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success']) {
          // Mark data as synced and update last_synced_time
          final currentTime = DateTime.now().toIso8601String();
          await markDataAsSynced('carpenter_customer', currentTime);
          await markDataAsSynced('carpenter_order', currentTime);
          await markDataAsSynced('carpenter_job_order', currentTime);
          await markDataAsSynced('carpenter_partner', currentTime);
          await markDataAsSynced('carpenter_order_docs', currentTime);
          await markDataAsSynced('carpenter_job_docs', currentTime);
          print('Data synced successfully');
        }
      } else {
        print('Error syncing data to backend: ${response.statusCode}');
      }
    } catch (error) {
      print('Error syncing data to backend: $error');
    }
  }
}
