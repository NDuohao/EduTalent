import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('edutalent.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 17,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        fullName TEXT,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        university TEXT,
        course TEXT,
        cgpa TEXT,
        gradYear TEXT,
        industry TEXT,
        location TEXT,
        workingHours TEXT,
        companyDetail TEXT,
        bio TEXT,
        skills TEXT,
        experience TEXT,
        phone TEXT,
        dob TEXT,
        streetAddress TEXT,
        city TEXT,
        state TEXT,
        postcode TEXT,
        educationLevel TEXT,
        latitude REAL,
        longitude REAL,
        profileImage TEXT,
        coverImage TEXT,
        isProfileComplete INTEGER DEFAULT 0
      )
    ''');

    await _createMessagesTable(db);
    await _createJobsTable(db);
    await _createApplicationsTable(db);
    
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        jobId INTEGER,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await _createSavedGraduatesTable(db);
    await _createSavedJobsTable(db);
    await _insertSeedData(db);
  }

  Future<void> _insertSeedData(DatabaseExecutor db) async {
    await db.insert('users', {
      'username': 'maybank',
      'fullName': 'Maybank',
      'email': 'contact@maybank.com',
      'password': '123',
      'role': 'corporate',
      'industry': 'Fintech & Banking',
      'location': 'Kuala Lumpur',
      'workingHours': 'Monday - Friday, 09:00 AM - 06:00 PM',
      'companyDetail': 'Maybank is among the top 5 banks in South East Asia with 2,600 branches globally.',
      'latitude': 3.1472,
      'longitude': 101.6995,
      'isProfileComplete': 1,
      'state': 'W.P. Kuala Lumpur'
    });

    await db.insert('users', {
      'username': 'intel',
      'fullName': 'Intel Malaysia',
      'email': 'hr@intel.com',
      'password': '123',
      'role': 'corporate',
      'industry': 'Manufacturing & Tech',
      'location': 'Penang',
      'workingHours': 'Monday - Friday, 08:30 AM - 05:30 PM',
      'companyDetail': 'Intel is the world\'s largest semiconductor chip manufacturer by revenue.',
      'latitude': 5.2934,
      'longitude': 100.2764,
      'isProfileComplete': 1,
      'state': 'Penang'
    });

    await db.insert('users', {
      'username': 'johndoe',
      'fullName': 'John Doe',
      'email': 'john@example.com',
      'password': '123',
      'role': 'graduate',
      'university': 'University of Malaya',
      'course': 'Computer Science',
      'cgpa': '3.90',
      'educationLevel': 'Degree',
      'skills': 'FLUTTER, DART, SQL',
      'isProfileComplete': 1,
      'state': 'Selangor'
    });

    final List<Map<String, dynamic>> res = await db.query('users', where: 'username = ?', whereArgs: ['maybank']);
    if (res.isNotEmpty) {
      int maybankId = res.first['id'];
      await db.insert('jobs', {
        'companyId': maybankId,
        'title': 'AI Data Scientist',
        'category': 'Technology & IT',
        'jobType': 'Full-time',
        'location': 'Kuala Lumpur - Bukit Bintang',
        'salaryRange': 'RM 5,500.00 - RM 8,000.00',
        'workingHours': '09:00 AM - 06:00 PM',
        'skills': 'PYTHON, MACHINE LEARNING, SQL',
        'description': 'Help Maybank build next-gen banking intelligence.',
        'latitude': 3.1472,
        'longitude': 101.6995,
      });
    }

    final List<Map<String, dynamic>> intelRes = await db.query('users', where: 'username = ?', whereArgs: ['intel']);
    if (intelRes.isNotEmpty) {
      int intelId = intelRes.first['id'];
      await db.insert('jobs', {
        'companyId': intelId,
        'title': 'Embedded Systems Engineer',
        'category': 'Engineering',
        'jobType': 'Full-time',
        'location': 'Bayan Lepas, Penang',
        'salaryRange': 'RM 4,800.00 - RM 6,500.00',
        'workingHours': '08:30 AM - 05:30 PM',
        'skills': 'C, C++, RTOS',
        'description': 'Develop cutting-edge firmware for global markets.',
        'latitude': 5.2934,
        'longitude': 100.2764,
      });
    }
  }

  Future _createSavedJobsTable(Database db) async {
    await db.execute('''
      CREATE TABLE saved_jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        jobId INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (jobId) REFERENCES jobs (id)
      )
    ''');
  }

  Future _createSavedGraduatesTable(Database db) async {
    await db.execute('''
      CREATE TABLE saved_graduates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recruiterId INTEGER NOT NULL,
        graduateId INTEGER NOT NULL,
        FOREIGN KEY (recruiterId) REFERENCES users (id),
        FOREIGN KEY (graduateId) REFERENCES users (id)
      )
    ''');
  }

  Future _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  Future _createMessagesTable(Database db) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        senderId INTEGER NOT NULL,
        receiverId INTEGER NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER DEFAULT 0
      )
    ''');
  }

  Future _createJobsTable(Database db) async {
    await db.execute('''
      CREATE TABLE jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        companyId INTEGER NOT NULL,
        title TEXT NOT NULL,
        category TEXT,
        jobType TEXT,
        location TEXT NOT NULL,
        salaryRange TEXT,
        workingHours TEXT,
        skills TEXT,
        description TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');
  }

  Future _createApplicationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE applications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jobId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        status TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (jobId) REFERENCES jobs (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }


  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN university TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN course TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN cgpa TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN gradYear TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN bio TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN skills TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN experience TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN isProfileComplete INTEGER DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN fullName TEXT');
    }
    if (oldVersion < 4) {
      await _createMessagesTable(db);
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE users ADD COLUMN industry TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN location TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN workingHours TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN companyDetail TEXT');
      await _createJobsTable(db);
    }
    if (oldVersion < 7) {
      try { await db.execute('ALTER TABLE users ADD COLUMN latitude REAL'); } catch(e) {}
      try { await db.execute('ALTER TABLE users ADD COLUMN longitude REAL'); } catch(e) {}
      try { await db.execute('ALTER TABLE jobs ADD COLUMN latitude REAL'); } catch(e) {}
      try { await db.execute('ALTER TABLE jobs ADD COLUMN longitude REAL'); } catch(e) {}
    }
    if (oldVersion < 8) {
      await _createApplicationsTable(db);
    }
    if (oldVersion < 9) {
      await _createNotificationsTable(db);
    }
    if (oldVersion < 10) {
      await _createSavedGraduatesTable(db);
    }
    if (oldVersion < 11) {
      await _createSavedJobsTable(db);
    }
    if (oldVersion < 12) {
      try { await db.execute('ALTER TABLE users ADD COLUMN dob TEXT'); } catch(e) {}
      try { await db.execute('ALTER TABLE users ADD COLUMN address TEXT'); } catch(e) {}
      try { await db.execute('ALTER TABLE users ADD COLUMN educationLevel TEXT'); } catch(e) {}
    }
    if (oldVersion < 13) {
      try { await db.execute('ALTER TABLE users ADD COLUMN streetAddress TEXT'); } catch(e) {}
      try { await db.execute('ALTER TABLE users ADD COLUMN city TEXT'); } catch(e) {}
      try { await db.execute('ALTER TABLE users ADD COLUMN state TEXT'); } catch(e) {}
      try { await db.execute('ALTER TABLE users ADD COLUMN postcode TEXT'); } catch(e) {}
      try { await db.execute('UPDATE users SET streetAddress = address WHERE address IS NOT NULL'); } catch(e) {}
    }
    if (oldVersion < 14) {
      try { await db.execute('ALTER TABLE users ADD COLUMN profileImage TEXT'); } catch(e) {}
      try { await db.execute('ALTER TABLE users ADD COLUMN coverImage TEXT'); } catch(e) {}
    }
    if (oldVersion < 15) {
      try { await db.execute('ALTER TABLE jobs ADD COLUMN category TEXT'); } catch(e) {}
    }
    if (oldVersion < 16) {
      try { await db.execute('ALTER TABLE jobs ADD COLUMN jobType TEXT'); } catch(e) {}
    }
    if (oldVersion < 17) {
      try { await db.execute('ALTER TABLE notifications ADD COLUMN jobId INTEGER'); } catch(e) {}
    }
  }

  Future<void> toggleSaveJob(int userId, int jobId) async {
    final db = await database;
    final List<Map<String, dynamic>> existing = await db.query(
      'saved_jobs',
      where: 'userId = ? AND jobId = ?',
      whereArgs: [userId, jobId],
    );

    if (existing.isEmpty) {
      await db.insert('saved_jobs', {
        'userId': userId,
        'jobId': jobId,
      });
    } else {
      await db.delete(
        'saved_jobs',
        where: 'userId = ? AND jobId = ?',
        whereArgs: [userId, jobId],
      );
    }
  }

  Future<List<int>> getSavedJobIds(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.query(
      'saved_jobs',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return res.map((m) => m['jobId'] as int).toList();
  }

  Future<List<Map<String, dynamic>>> getSavedJobs(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT j.* FROM jobs j
      JOIN saved_jobs s ON j.id = s.jobId
      WHERE s.userId = ?
    ''', [userId]);
  }

  Future<void> toggleSaveGraduate(int recruiterId, int graduateId) async {
    final db = await database;
    final List<Map<String, dynamic>> existing = await db.query(
      'saved_graduates',
      where: 'recruiterId = ? AND graduateId = ?',
      whereArgs: [recruiterId, graduateId],
    );

    if (existing.isEmpty) {
      await db.insert('saved_graduates', {
        'recruiterId': recruiterId,
        'graduateId': graduateId,
      });
    } else {
      await db.delete(
        'saved_graduates',
        where: 'recruiterId = ? AND graduateId = ?',
        whereArgs: [recruiterId, graduateId],
      );
    }
  }

  Future<List<int>> getSavedGraduateIds(int recruiterId) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.query(
      'saved_graduates',
      where: 'recruiterId = ?',
      whereArgs: [recruiterId],
    );
    return res.map((m) => m['graduateId'] as int).toList();
  }

  Future<List<Map<String, dynamic>>> getSavedGraduates(int recruiterId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT u.* FROM users u
      JOIN saved_graduates s ON u.id = s.graduateId
      WHERE s.recruiterId = ?
    ''', [recruiterId]);
  }

  Future<void> addNotification({
    required int userId,
    required String title,
    required String message,
    required String type,
    int? jobId,
  }) async {
    final db = await database;
    await db.insert('notifications', {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': 0,
      'jobId': jobId,
    });
  }

  Future<List<Map<String, dynamic>>> getGraduatesForCorporate() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM users 
      WHERE role = 'graduate' 
      AND id NOT IN (
        SELECT userId FROM applications WHERE status = 'Accepted'
      )
    ''');
  }

  Future<void> notifyAllUsersByRole(String role, String title, String message, String type) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query('users', where: 'role = ?', whereArgs: [role]);
    for (var user in users) {
      await addNotification(
        userId: user['id'],
        title: title,
        message: message,
        type: type,
      );
    }
  }

  Future<void> notifyUsersBySkillMatch({
    required String role,
    required String title,
    required String message,
    required String type,
    required String targetSkills,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query('users', where: 'role = ?', whereArgs: [role]);
    
    final List<String> jobSkillList = targetSkills.toLowerCase().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (jobSkillList.isEmpty) return;

    for (var user in users) {
      final String userSkillsStr = user['skills'] ?? '';
      if (userSkillsStr.isEmpty) continue;

      final List<String> userSkillList = userSkillsStr.toLowerCase().split(',').map((s) => s.trim()).toList();
      
      bool isMatch = userSkillList.any((uSkill) => jobSkillList.contains(uSkill));

      if (isMatch) {
        await addNotification(
          userId: user['id'],
          title: title,
          message: message,
          type: type,
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> getCompanyApplications(int companyId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT a.id, a.status, a.timestamp, a.userId as applicantId, 
             j.title as jobTitle, u.fullName as applicantName, u.university, u.cgpa
      FROM applications a
      JOIN jobs j ON a.jobId = j.id
      JOIN users u ON a.userId = u.id
      WHERE j.companyId = ?
      ORDER BY a.timestamp DESC
    ''', [companyId]);
  }

  Future<List<int>> getAppliedStudentIds(int companyId) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT DISTINCT a.userId 
      FROM applications a
      JOIN jobs j ON a.jobId = j.id
      WHERE j.companyId = ? AND a.status NOT IN ('Past Job', 'Auto-Withdrawn')
    ''', [companyId]);
    return res.map((m) => m['userId'] as int).toList();
  }

  Future<List<Map<String, dynamic>>> getCompanyJobs(int companyId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT j.*, 
             (SELECT COUNT(*) FROM applications WHERE jobId = j.id AND status IN ('Accepted', 'Past Job')) as isFilled
      FROM jobs j
      WHERE j.companyId = ?
    ''', [companyId]);
  }

  Future<List<Map<String, dynamic>>> getAllJobsWithCompany() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT j.*, u.fullName, u.industry
      FROM jobs j
      LEFT JOIN users u ON j.companyId = u.id
      WHERE j.id NOT IN (
        SELECT jobId FROM applications WHERE status IN ('Accepted', 'Past Job')
      )
    ''');
  }

  Future<List<UserModel>> getAllCompanies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ? AND latitude IS NOT NULL AND longitude IS NOT NULL',
      whereArgs: ['corporate'],
    );
    return maps.map((m) => UserModel.fromMap(m)).toList();
  }

  Future<void> updateApplicationStatus(int applicationId, String status) async {
    final db = await database;
    
    if (status == 'Accepted') {
      await db.transaction((txn) async {
        final List<Map<String, dynamic>> appRes = await txn.query(
          'applications', 
          where: 'id = ?', 
          whereArgs: [applicationId]
        );
        if (appRes.isEmpty) return;
        
        int studentId = appRes.first['userId'];
        int jobId = appRes.first['jobId'];

        await txn.update(
          'applications',
          {'status': 'Accepted'},
          where: 'id = ?',
          whereArgs: [applicationId],
        );

        await txn.update(
          'applications',
          {'status': 'Rejected (Job Filled)'},
          where: 'jobId = ? AND id != ?',
          whereArgs: [jobId, applicationId],
        );

        await txn.update(
          'applications',
          {'status': 'Auto-Withdrawn'},
          where: 'userId = ? AND id != ?',
          whereArgs: [studentId, applicationId],
        );
      });
    } else {
      await db.update(
        'applications',
        {'status': status},
        where: 'id = ?',
        whereArgs: [applicationId],
      );
    }
  }

  Future<void> cancelApplication({
    required int applicationId,
    required int userId,
    required int companyId,
    required String jobTitle,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> userRes = await txn.query(
        'users',
        columns: ['fullName', 'username'],
        where: 'id = ?',
        whereArgs: [userId],
      );
      String studentName = userRes.isNotEmpty 
          ? (userRes.first['fullName'] ?? userRes.first['username']) 
          : 'A candidate';

      await txn.insert('notifications', {
        'userId': companyId,
        'title': 'Application Withdrawn',
        'message': '$studentName has withdrawn their application for "$jobTitle".',
        'type': 'talent',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': 0,
      });

      await txn.delete(
        'applications',
        where: 'id = ?',
        whereArgs: [applicationId],
      );
    });
  }

  Future<bool> isUserCurrentlyEmployed(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.query(
      'applications',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, 'Accepted'],
    );
    return res.isNotEmpty;
  }

  Future<void> resignFromJob(int applicationId) async {
    final db = await database;
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> resigningAppRes = await txn.query(
        'applications', 
        where: 'id = ?', 
        whereArgs: [applicationId]
      );
      if (resigningAppRes.isEmpty) return;
      
      int userId = resigningAppRes.first['userId'];

      await txn.update(
        'applications',
        {'status': 'Past Job'},
        where: 'id = ?',
        whereArgs: [applicationId],
      );

      final List<Map<String, dynamic>> withdrawnApps = await txn.query(
        'applications',
        where: 'userId = ? AND status = ?',
        whereArgs: [userId, 'Auto-Withdrawn'],
      );

      for (var app in withdrawnApps) {
        int jobId = app['jobId'];
        
        final List<Map<String, dynamic>> activeHires = await txn.rawQuery('''
          SELECT id FROM applications 
          WHERE jobId = ? AND status IN ('Accepted', 'Past Job')
        ''', [jobId]);

        if (activeHires.isEmpty) {
          await txn.update(
            'applications',
            {'status': 'Applied'},
            where: 'id = ?',
            whereArgs: [app['id']],
          );

          final List<Map<String, dynamic>> jobInfo = await txn.rawQuery('''
            SELECT j.title, u.id as companyId, g.fullName as studentName
            FROM jobs j
            JOIN users u ON j.companyId = u.id
            JOIN users g ON g.id = ?
            WHERE j.id = ?
          ''', [userId, jobId]);

          if (jobInfo.isNotEmpty) {
            final info = jobInfo.first;
            await txn.insert('notifications', {
              'userId': info['companyId'],
              'title': 'Application Re-activated',
              'message': '${info['studentName']} is available again. Their application for "${info['title']}" has been restored to Applied.',
              'type': 'talent',
              'timestamp': DateTime.now().toIso8601String(),
              'isRead': 0,
            });
          }
        }
      }
    });
  }

  Future<void> updatePassword(String email, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<void> deleteJob(int jobId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('applications', where: 'jobId = ?', whereArgs: [jobId]);
      await txn.delete('saved_jobs', where: 'jobId = ?', whereArgs: [jobId]);
      await txn.delete('jobs', where: 'id = ?', whereArgs: [jobId]);
    });
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('applications');
      await txn.delete('saved_jobs');
      await txn.delete('saved_graduates');
      await txn.delete('notifications');
      await txn.delete('messages');
      await txn.delete('jobs');
      await txn.delete('users');
      
      // Re-populate seed data immediately after clearing
      await _insertSeedData(txn);
    });
  }

  Future<void> deleteUserCompletely(int userId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> user = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (user.isEmpty) return;
    
    String role = user.first['role'];
    
    await db.transaction((txn) async {
      if (role == 'corporate') {
        final List<Map<String, dynamic>> jobs = await txn.query('jobs', where: 'companyId = ?', whereArgs: [userId]);
        List<int> jobIds = jobs.map((j) => j['id'] as int).toList();
        
        if (jobIds.isNotEmpty) {
          String idPlaceholder = jobIds.map((_) => '?').join(',');
          await txn.delete('applications', where: 'jobId IN ($idPlaceholder)', whereArgs: jobIds);
          await txn.delete('saved_jobs', where: 'jobId IN ($idPlaceholder)', whereArgs: jobIds);
          await txn.delete('jobs', where: 'companyId = ?', whereArgs: [userId]);
        }
        
        await txn.delete('saved_graduates', where: 'recruiterId = ?', whereArgs: [userId]);
      } else {
        await txn.delete('applications', where: 'userId = ?', whereArgs: [userId]);
        await txn.delete('saved_jobs', where: 'userId = ?', whereArgs: [userId]);
        await txn.delete('saved_graduates', where: 'graduateId = ?', whereArgs: [userId]);
      }
      
      await txn.delete('messages', where: 'senderId = ? OR receiverId = ?', whereArgs: [userId, userId]);
      await txn.delete('notifications', where: 'userId = ?', whereArgs: [userId]);
      await txn.delete('users', where: 'id = ?', whereArgs: [userId]);
    });
  }

  Future<Map<String, dynamic>> getTalentPoolStats() async {
    final db = await database;
    final List<Map<String, dynamic>> allGrads = await db.query(
      'users', 
      where: 'role = ?', 
      whereArgs: ['graduate']
    );

    Map<String, int> courseCounts = {};
    for (var grad in allGrads) {
      String course = grad['course'] ?? 'Other';
      if (course.isEmpty) course = 'Other';
      courseCounts[course] = (courseCounts[course] ?? 0) + 1;
    }

    var sortedCourses = courseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return {
      'total': allGrads.length,
      'courses': Map.fromEntries(sortedCourses.take(3)),
    };
  }

  Future<Map<String, int>> getTopSkillsStats() async {
    final db = await database;
    final List<Map<String, dynamic>> allGrads = await db.query(
      'users', 
      columns: ['skills'],
      where: 'role = ?', 
      whereArgs: ['graduate']
    );

    Map<String, int> skillCounts = {};
    for (var grad in allGrads) {
      String skillsStr = grad['skills'] ?? '';
      if (skillsStr.isNotEmpty) {
        List<String> skills = skillsStr.split(',').map((s) => s.trim()).toList();
        for (var skill in skills) {
          if (skill.isNotEmpty) {
            skillCounts[skill] = (skillCounts[skill] ?? 0) + 1;
          }
        }
      }
    }

    var sortedSkills = skillCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedSkills.take(6));
  }

  Future<Map<String, dynamic>?> getLastMessage(int userId, int otherId) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.query(
      'messages',
      where: '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [userId, otherId, otherId, userId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
