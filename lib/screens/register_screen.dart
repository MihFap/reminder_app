import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RegisterScreen({super.key});

  void register(BuildContext context) {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      Navigator.pop(context); // Quay về đăng nhập
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập thông tin đầy đủ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ảnh nền
          Positioned.fill(
            child: Image.asset(
              'assets/anhnen.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Nội dung giao diện đăng ký
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              'Tạo Tài Khoản',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              'Nhập thông tin để đăng ký',
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildInputField(Icons.email, 'EMAIL', emailController),
                          const SizedBox(height: 20),
                          _buildInputField(Icons.lock, 'PASSWORD', passwordController, obscure: true),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () => register(context),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text(
                              'ĐĂNG KÝ',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: 'Bạn đã có tài khoản? ',
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'Đăng Nhập',
                                style: TextStyle(color: Colors.green),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(IconData icon, String label, TextEditingController controller, {bool obscure = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          color: Colors.black, // Màu chữ nhập vào
        ),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.black), // Màu icon
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black, // Màu label
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}