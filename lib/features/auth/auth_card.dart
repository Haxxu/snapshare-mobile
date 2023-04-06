import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:snapshare_mobile/providers/auth_manager.dart';
import 'package:snapshare_mobile/features/shared/dialog_utils.dart';

enum AuthMode { login, register }

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'account': '',
    'password': '',
    'name': '',
    'description': '',
  };

  final _isSubmitting = ValueNotifier<bool>(false);
  // final _descriptionController = TextEditingController();
  // final _nameController = TextEditingController();
  // final _accountController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    _isSubmitting.value = true;

    try {
      if (_authMode == AuthMode.login) {
        // Login
        await context.read<AuthManager>().login(
            account: _authData['account']!, password: _authData['password']!);
      } else {
        // Register user
        await context.read<AuthManager>().register(
            account: _authData['account']!,
            password: _authData['password']!,
            description: _authData['description']!,
            name: _authData['name']!);
      }
    } catch (e) {
      // print(e.toString());
      showErrorDialog(context, e.toString());
    }

    _isSubmitting.value = false;
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.register;
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.register ? 470 : 260,
        constraints: BoxConstraints(
            minHeight: _authMode == AuthMode.register ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildAccountField(),
                _buildPasswordField(),
                if (_authMode == AuthMode.register)
                  _buildPasswordConfirmField(),
                if (_authMode == AuthMode.register) _buildNameField(),
                if (_authMode == AuthMode.register) _buildDescriptionField(),
                const SizedBox(
                  height: 20,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _isSubmitting,
                  builder: (context, isSubmitting, child) {
                    if (isSubmitting) {
                      return const CircularProgressIndicator();
                    }
                    return _buildSubmitButton();
                  },
                ),
                _buildAuthModeSwitchButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthModeSwitchButton() {
    return TextButton(
      onPressed: _switchAuthMode,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child:
          Text('${_authMode == AuthMode.login ? 'REGISTER' : 'LOGIN'} INSTEAD'),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
        textStyle: TextStyle(
          color: Theme.of(context).primaryTextTheme.titleLarge?.color,
        ),
      ),
      child: Text(_authMode == AuthMode.login ? 'LOGIN' : 'REGISTER'),
    );
  }

  Widget _buildPasswordConfirmField() {
    return TextFormField(
      enabled: _authMode == AuthMode.register,
      decoration: const InputDecoration(labelText: 'Confirm Password'),
      obscureText: true,
      validator: _authMode == AuthMode.register
          ? (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match!';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.length < 5) {
          return 'Password is too short!';
        }
        return null;
      },
      onSaved: (value) {
        _authData['password'] = value!;
      },
    );
  }

  Widget _buildAccountField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Account'),
      validator: (value) {
        if (value!.isEmpty || value.length < 2) {
          return 'Account is at least 2 characters ';
        }
        return null;
      },
      onSaved: (value) {
        _authData['account'] = value!;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Description'),
      // validator: (value) {
      //   return null;
      // },
      onSaved: (value) {
        _authData['description'] = value!;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Name'),
      validator: (value) {
        if (value!.isEmpty || value.length < 2) {
          return 'Name is at least 1 characters ';
        }
        return null;
      },
      onSaved: (value) {
        _authData['name'] = value!;
      },
    );
  }
}
