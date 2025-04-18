import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormBasicDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FormBasicDemoState();
}

class _FormBasicDemoState extends State<FormBasicDemo> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();

  bool _obscurePassword = true;
  String? _name;
  String? _selectedCity;
  String? _gender;
  bool _isAgreed = false;
  DateTime? _selectedDate;

  final List<String> _cities = ['Hà Nội', 'TP.HCM', 'Đà Nẵng', 'Cần Thơ', 'Hải Phòng'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Đăng Ký"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField("Họ và tên", _fullnameController, Icons.person),
              SizedBox(height: 12),
              buildDatePicker(),
              SizedBox(height: 12),
              buildGenderSelection(),
              SizedBox(height: 12),
              buildTextField("Email", _emailController, Icons.email, isEmail: true),
              SizedBox(height: 12),
              buildTextField("Số điện thoại", _phoneController, Icons.phone, isPhone: true),
              SizedBox(height: 12),
              buildTextField("Mật khẩu", _passwordController, Icons.lock, isPassword: true),
              SizedBox(height: 12),
              buildTextField("Xác nhận mật khẩu", _confirmPasswordController, Icons.lock_outline,
                  isPassword: true, confirmPassword: _passwordController.text),
              SizedBox(height: 12),
              buildDropdownField(),
              SizedBox(height: 12),
              buildCheckbox(),
              SizedBox(height: 20),
              buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, IconData icon,
      {bool isPassword = false, bool isEmail = false, bool isPhone = false, String? confirmPassword}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng nhập $label';
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Email không hợp lệ';
        }
        if (isPhone && !RegExp(r'^\d{10}$').hasMatch(value)) {
          return 'Số điện thoại phải có 10 chữ số';
        }
        if (confirmPassword != null && value != confirmPassword) {
          return 'Mật khẩu không khớp';
        }
        return null;
      },
    );
  }

  Widget buildDatePicker() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Ngày sinh',
        prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          firstDate: DateTime(1900),
          lastDate: DateTime(2026),
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
          setState(() {
            _dateController.text = formattedDate;
            _selectedDate = pickedDate;
          });
        }
      },
      validator: (value) => value == null || value.isEmpty ? "Vui lòng chọn ngày sinh" : null,
    );
  }

  Widget buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Giới tính", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text('Nam'),
                value: 'male',
                groupValue: _gender,
                onChanged: (value) => setState(() => _gender = value),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text('Nữ'),
                value: 'female',
                groupValue: _gender,
                onChanged: (value) => setState(() => _gender = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDropdownField() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: "Thành phố",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      value: _selectedCity,
      items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
      onChanged: (value) => setState(() => _selectedCity = value),
      validator: (value) => value == null ? 'Vui lòng chọn thành phố' : null,
    );
  }

  Widget buildCheckbox() {
    return CheckboxListTile(
      title: Text("Đồng ý với điều khoản của ABC."),
      value: _isAgreed,
      onChanged: (value) => setState(() => _isAgreed = value!),
    );
  }

  Widget buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xin chào $_name")));
        }
      },
      child: Text("Đăng ký", style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }
}
