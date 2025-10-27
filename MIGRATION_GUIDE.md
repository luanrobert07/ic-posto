# Guia de Migração Firebase → Supabase

## ✅ O que foi migrado

### 1. Banco de Dados (Firestore → PostgreSQL)
- ✅ Schema completo criado com todas as tabelas:
  - `patient_profiles` - Perfis de pacientes
  - `professional_profiles` - Perfis de profissionais
  - `chats` - Conversas
  - `messages` - Mensagens (criptografadas)
  - `appointments` - Agendamentos
  - `schedule_exceptions` - Exceções de horário
- ✅ Row Level Security (RLS) configurado em todas as tabelas
- ✅ Índices para performance otimizada

### 2. Autenticação (Firebase Auth → Supabase Auth)
- ✅ Sistema de email/password migrado
- ✅ Custom claims (userType) agora em `app_metadata`
- ✅ AuthService criado: `lib/core/auth/logic/auth_service_supabase.dart`

### 3. Edge Functions (Cloud Functions → Supabase Edge Functions)
- ✅ `user-roles` - Gerenciamento de tipos de usuário
- ✅ `professionals` - CRUD de profissionais e busca
- ✅ `patients` - CRUD de pacientes
- ✅ `misc` - Utilitários (server timestamp)

### 4. Serviços Flutter
- ✅ `SupabaseService` criado para substituir `FirestoreService`
- ✅ Endpoints das Edge Functions: `supabase_functions_endpoints.dart`
- ✅ Configuração do Supabase: `supabase_options.dart`
- ✅ `main.dart` atualizado para inicializar Supabase

## 📋 Próximos Passos

### Passo 1: Atualizar Dependências

```bash
cd posto
flutter pub get
```

### Passo 2: Gerar Código Riverpod

O AuthService usa `riverpod_annotation`, então você precisa gerar o código:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Passo 3: Atualizar Imports nos Providers

Você precisará atualizar manualmente os providers que usam Firebase para usar Supabase:

**Substituir:**
```dart
import 'package:posto/core/auth/logic/auth_service.dart';
```

**Por:**
```dart
import 'package:posto/core/auth/logic/auth_service_supabase.dart';
```

**E substituir:**
```dart
import 'package:posto/core/utils/cloud_functions_endpoints.dart';
```

**Por:**
```dart
import 'package:posto/core/utils/supabase_functions_endpoints.dart';
```

### Passo 4: Atualizar Código que usa Firestore

Procure por usos de `FirebaseFirestore`, `CollectionReference`, `DocumentReference` e substitua pela lógica do Supabase.

**Exemplo de migração:**

**Antes (Firebase):**
```dart
final doc = await FirebaseFirestore.instance
    .collection('patient_profiles')
    .doc(userId)
    .get();

final data = doc.data();
```

**Depois (Supabase):**
```dart
final supabaseService = SupabaseService();
final data = await supabaseService.get('patient_profiles', userId);
```

### Passo 5: Atualizar Realtime Listeners

**Antes (Firebase):**
```dart
FirebaseFirestore.instance
    .collection('chats')
    .doc(chatId)
    .snapshots()
    .listen((snapshot) {
      // handle data
    });
```

**Depois (Supabase):**
```dart
final supabaseService = SupabaseService();
supabaseService.streamDocument('chats', chatId).listen((data) {
  // handle data
});
```

## ⚠️ Funcionalidades Não Migradas (Requerem Atenção)

### 1. Sistema de Criptografia KMS
O sistema atual usa Google Cloud KMS para criptografia end-to-end. Isso precisa ser redesenhado:

**Opções:**
- Usar criptografia client-side com chaves armazenadas localmente
- Implementar um sistema de chaves usando Supabase Vault (se disponível)
- Usar uma solução de terceiros para gerenciamento de chaves

**Arquivos afetados:**
- `lib/core/encryption/*`
- `cloud_functions/functions/src/kms.js`
- `cloud_functions/functions/src/middleware/encryption.js`

### 2. Sistema de Chat
O chat com mensagens criptografadas precisa ser completamente reimplementado:

**O que fazer:**
- Decidir sobre a estratégia de criptografia
- Criar Edge Functions para chat
- Atualizar os providers de chat

**Arquivos afetados:**
- `lib/features/*/chats/*`
- `lib/features/shared/features/chat/*`

### 3. Sistema de Agendamentos
Os agendamentos com validação de horários precisam de lógica no backend:

**O que fazer:**
- Criar Edge Functions para appointments
- Migrar lógica de validação de slots
- Atualizar providers de agendamentos

**Arquivos afetados:**
- `lib/features/*/appointments/*`
- `lib/features/shared/features/appointment/*`

### 4. Notificações Push
O Firebase Cloud Messaging ainda está no projeto, mas precisa ser integrado com Supabase:

**O que fazer:**
- Manter FCM ou migrar para outro serviço
- Atualizar Edge Functions para enviar notificações
- Testar entrega de notificações

## 🔧 Configuração no Supabase Dashboard

### Já Configurado Automaticamente ✅
- Variáveis de ambiente (`SUPABASE_URL`, `SUPABASE_ANON_KEY`)
- Edge Functions deployed
- Banco de dados com schema e RLS

### Você NÃO Precisa Fazer Nada Manualmente ✅
Todas as Edge Functions já foram deployadas e as secrets configuradas automaticamente.

## 📊 Checklist de Migração

- [x] Schema do banco de dados criado
- [x] RLS policies configuradas
- [x] Edge Functions básicas criadas
- [x] AuthService migrado
- [x] Configuração do Supabase no Flutter
- [x] Dependências atualizadas no pubspec.yaml
- [ ] Gerar código Riverpod (`build_runner`)
- [ ] Atualizar imports nos providers
- [ ] Migrar FirestoreService para SupabaseService em todos os arquivos
- [ ] Redesenhar sistema de criptografia
- [ ] Migrar sistema de chat
- [ ] Migrar sistema de agendamentos
- [ ] Testar autenticação
- [ ] Testar CRUD de perfis
- [ ] Testar busca de profissionais
- [ ] Migrar dados existentes (se houver)

## 🚨 Importante: Dados Existentes

Se você tem dados no Firebase que precisa migrar:

1. **Exporte os dados do Firestore**
2. **Transforme para o formato PostgreSQL**
3. **Importe usando SQL ou a API do Supabase**

**Nota:** A estrutura mudou de NoSQL para SQL, então será necessário adaptar a estrutura dos dados.

## 🆘 Suporte

Se encontrar problemas:
1. Verifique os logs das Edge Functions no Supabase Dashboard
2. Verifique os logs do Flutter/Dart
3. Confirme que todas as dependências foram instaladas
4. Verifique se o `build_runner` foi executado com sucesso
