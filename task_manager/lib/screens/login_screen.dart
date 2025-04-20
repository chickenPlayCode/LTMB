import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/User.dart';
import 'package:intl/intl.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isLogin = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  DateTime? _birthDate;

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = _birthDate ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DatabaseHelper.instance;
      try {
        if (_isLogin) {
          final users = await dbHelper.getAllUsers();
          print('Users in database: ${users.map((u) => {'id': u.id, 'username': u.username, 'fullname': u.fullname}).toList()}');
          final user = users.firstWhere(
                (u) =>
            u.username == _usernameController.text &&
                u.password == _passwordController.text,
            orElse: () => User(
              id: '',
              username: '',
              password: '',
              email: '',
              createdAt: DateTime.now(),
              lastActive: DateTime.now(),
            ),
          );
          if (user.id.isNotEmpty) {
            print('Logged in user: ${user.id}, ${user.username}, ${user.fullname}');
            await dbHelper.updateUser(user.copyWith(
              lastActive: DateTime.now(),
            ));
            Navigator.pushReplacementNamed(context, '/tasks', arguments: user);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tên đăng nhập hoặc mật khẩu không đúng')),
            );
          }
        } else {
          final existingUsers = await dbHelper.getAllUsers();
          print('Existing users during registration: ${existingUsers.map((u) => {'id': u.id, 'username': u.username, 'fullname': u.fullname}).toList()}');
          if (existingUsers.any((u) => u.username == _usernameController.text)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tên đăng nhập đã tồn tại')),
            );
            return;
          }
          if (existingUsers.any((u) => u.email == _emailController.text)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email đã được sử dụng')),
            );
            return;
          }
          if (_birthDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng chọn ngày sinh')),
            );
            return;
          }
          final user = User(
            id: const Uuid().v4(),
            username: _usernameController.text,
            password: _passwordController.text,
            email: _emailController.text,
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
            birthDate: _birthDate,
            phoneNumber: _phoneNumberController.text.isEmpty ? null : _phoneNumberController.text,
            fullname: _fullnameController.text.isEmpty ? null : _fullnameController.text,
          );
          print('Registered user: ${user.id}, ${user.username}, ${user.fullname}');
          await dbHelper.createUser(user);
          Navigator.pushReplacementNamed(context, '/tasks', arguments: user);
        }
      } catch (e) {
        print('Error during login/registration: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullnameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent,
              Colors.purpleAccent,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.task_alt,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? 'Đăng Nhập' : 'Đăng Ký',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Tên đăng nhập',
                              prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên đăng nhập';
                              }
                              if (value.length < 3) {
                                return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                              }
                              return null;
                            },
                          ),
                          if (!_isLogin) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _fullnameController,
                              decoration: InputDecoration(
                                labelText: 'Tên người dùng',
                                prefixIcon: const Icon(Icons.person_outline, color: Colors.blueAccent),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập tên người dùng';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value.length < 6) {
                                return 'Mật khẩu phải có ít nhất 6 ký tự';
                              }
                              return null;
                            },
                          ),
                          if (!_isLogin) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Nhập lại mật khẩu',
                                prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.blueAccent,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: !_isConfirmPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập lại mật khẩu';
                                }
                                if (value != _passwordController.text) {
                                  return 'Mật khẩu không khớp';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Email không hợp lệ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              title: Text(
                                'Ngày sinh: ${_birthDate != null ? DateFormat.yMd().format(_birthDate!) : 'Chưa chọn'}',
                              ),
                              trailing: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                              onTap: _selectBirthDate,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneNumberController,
                              decoration: InputDecoration(
                                labelText: 'Số điện thoại (tùy chọn)',
                                prefixIcon: const Icon(Icons.phone, color: Colors.blueAccent),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                                    return 'Số điện thoại không hợp lệ';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_isLogin ? Icons.login : Icons.person_add),
                                const SizedBox(width: 8),
                                Text(
                                  _isLogin ? 'Đăng nhập' : 'Đăng ký',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _formKey.currentState?.reset();
                                _usernameController.clear();
                                _fullnameController.clear();
                                _passwordController.clear();
                                _confirmPasswordController.clear();
                                _emailController.clear();
                                _phoneNumberController.clear();
                                _birthDate = null;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Tạo tài khoản mới'
                                  : 'Đã có tài khoản? Đăng nhập',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on User {
  User copyWith({
    String? id,
    String? username,
    String? password,
    String? email,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastActive,
    DateTime? birthDate,
    String? phoneNumber,
    String? fullname,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullname: fullname ?? this.fullname,
    );
  }
}