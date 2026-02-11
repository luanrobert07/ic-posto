# Guia de Debug - Erro ao Criar Conta

## 🔍 Onde Ver os Erros

### 1. Logs do Flutter (Console)
Execute o app e observe o console:
```bash
cd posto
flutter run
```

Os erros aparecerão no terminal. Procure por:
- Stack traces
- Mensagens de erro específicas
- Warnings sobre imports

### 2. Logs das Edge Functions (Supabase Dashboard)
1. Acesse: https://supabase.com/dashboard/project/gsyueuljyndlkvishpyp
2. Vá em **Edge Functions** no menu lateral
3. Clique na função **user-roles**
4. Vá na aba **Logs**
5. Tente criar uma conta novamente
6. Observe os logs em tempo real

### 3. Verificar Auth no Supabase
1. Vá em **Authentication** > **Users** no dashboard
2. Veja se o usuário foi criado
3. Se foi criado, clique nele e veja os metadados (app_metadata)

## ❗ Problema Identificado

O código Flutter ainda está usando **imports do Firebase** em vez do Supabase. Você precisa atualizar os imports.

## 🛠️ Solução Rápida

### Passo 1: Deletar arquivos gerados antigos
```bash
cd posto
find . -name "*.g.dart" -type f -delete
```

### Passo 2: Atualizar os imports

**Arquivo:** `lib/core/auth/state_management/auth_provider.dart`

Substitua:
```dart
import '../logic/auth_service.dart';
```

Por:
```dart
import '../logic/auth_service_supabase.dart';
```

---

**Arquivo:** `lib/core/auth/state_management/user_type_provider.dart`

Substitua TODO o conteúdo por:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/auth/state_management/user_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/supabase_functions_endpoints.dart';

part 'user_type_provider.g.dart';

@Riverpod(keepAlive: true)
class UserTypeNotifier extends _$UserTypeNotifier {
  @override
  UserType build() {
    Future.microtask(getUserType);
    return UserType.notLoggedIn;
  }

  Future<void> configureUserType(UserType userType, String name, String email) async {
    if (userType == UserType.patient) {
      print('Setting patient custom claim');
      await addPatientRoleAPI(name, email);
    }

    if (userType == UserType.professional) {
      print('Setting professional custom claim');
      await addProfessionalRoleAPI(name, email);
    }

    if (userType == UserType.agent) {
      print('Setting agent custom claim');
      await addAgentRoleAPI(name, email);
    }

    await getUserType();
  }

  Future<void> getUserType() async {
    print('Getting user type');
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      state = UserType.notLoggedIn;
      return;
    }

    // Refresh session to get latest metadata
    try {
      await supabase.auth.refreshSession();
    } catch (e) {
      print('Error refreshing session: $e');
    }

    final metadata = supabase.auth.currentUser?.appMetadata;

    if (metadata == null || !metadata.containsKey('user_type')) {
      print('User has no type');
      state = UserType.none;
      return;
    }

    final userType = metadata['user_type'];
    print('User type: $userType');

    if (userType == 'patient') {
      state = UserType.patient;
      return;
    }
    if (userType == 'professional') {
      state = UserType.professional;
      return;
    }
    if (userType == 'agent') {
      state = UserType.agent;
      return;
    }

    state = UserType.none;
    return;
  }
}
```

### Passo 3: Gerar código novamente
```bash
cd posto
dart run build_runner build --delete-conflicting-outputs
```

### Passo 4: Testar novamente
```bash
flutter run
```

## 🐛 Erros Comuns e Soluções

### Erro: "No authorization header"
**Causa:** Token não está sendo enviado corretamente

**Solução:** Verifique que o `supabase_functions_endpoints.dart` está usando:
```dart
'Authorization': 'Bearer ${supabase.auth.currentSession?.accessToken ?? supabase.supabaseKey}'
```

### Erro: "User already has a role assigned"
**Causa:** Você tentou criar a conta antes e já tem metadata

**Solução:**
1. Vá no Supabase Dashboard > Authentication > Users
2. Delete o usuário
3. Tente criar novamente

### Erro: "Missing required fields: action and name"
**Causa:** O payload JSON não está correto

**Solução:** Verifique em `supabase_functions_endpoints.dart` que está enviando:
```dart
await _callFunction('user-roles', {
  'action': 'addPatientRole',  // ou addProfessionalRole
  'name': name,
  'email': email,
});
```

### Erro: RLS Policy violation
**Causa:** As políticas de segurança estão bloqueando o insert

**Solução:** Já está correto! As policies permitem que usuários criem seu próprio perfil.

## 📊 Checklist de Debug

- [ ] Deletei os arquivos `.g.dart` antigos
- [ ] Atualizei `auth_provider.dart` para importar `auth_service_supabase.dart`
- [ ] Atualizei `user_type_provider.dart` para usar Supabase
- [ ] Executei `build_runner`
- [ ] Reiniciei o app Flutter
- [ ] Verifiquei os logs do console
- [ ] Verifiquei os logs das Edge Functions no Supabase Dashboard
- [ ] Verifiquei se o usuário foi criado no Authentication > Users

## 🆘 Se ainda não funcionar

Copie e cole aqui:
1. O erro completo do console Flutter
2. O erro dos logs da Edge Function
3. O que aparece no Supabase Dashboard > Authentication > Users
