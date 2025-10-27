/*
  # Create Initial Schema for Virtual Therapy App

  ## 1. New Tables
  
  ### Patient Profiles
    - `patient_profiles` - Perfis públicos e privados de pacientes
      - `id` (uuid, primary key) - ID do usuário (auth.users.id)
      - `email` (text) - Email do paciente
      - `name` (text) - Nome do paciente
      - `cpf` (text, encrypted) - CPF criptografado
      - `birth_date` (text, encrypted) - Data de nascimento criptografada
      - `phone` (text, encrypted) - Telefone criptografado
      - `public_key` (text) - Chave pública RSA para criptografia
      - `created_at` (timestamptz) - Data de criação
      - `updated_at` (timestamptz) - Data de atualização
  
  ### Professional Profiles
    - `professional_profiles` - Perfis públicos e privados de profissionais
      - `id` (uuid, primary key) - ID do usuário (auth.users.id)
      - `email` (text) - Email do profissional
      - `name` (text) - Nome do profissional
      - `cpf` (text, encrypted) - CPF criptografado
      - `phone` (text, encrypted) - Telefone criptografado
      - `specialty` (text) - Especialidade
      - `bio` (text) - Biografia
      - `registration_number` (text) - Número de registro profissional
      - `public_key` (text) - Chave pública RSA
      - `schedule_start` (time) - Horário de início do atendimento
      - `schedule_end` (time) - Horário de fim do atendimento
      - `appointment_duration` (integer) - Duração da consulta em minutos
      - `created_at` (timestamptz) - Data de criação
      - `updated_at` (timestamptz) - Data de atualização
  
  ### Schedule Exceptions
    - `schedule_exceptions` - Exceções de horário para profissionais
      - `id` (uuid, primary key)
      - `professional_id` (uuid, foreign key) - ID do profissional
      - `date` (date) - Data da exceção
      - `is_available` (boolean) - Se está disponível neste dia
      - `custom_start` (time) - Horário personalizado de início
      - `custom_end` (time) - Horário personalizado de fim
      - `created_at` (timestamptz)
  
  ### Chats
    - `chats` - Conversas entre paciente e profissional
      - `id` (uuid, primary key)
      - `patient_id` (uuid, foreign key) - ID do paciente
      - `professional_id` (uuid, foreign key) - ID do profissional
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
  
  ### Messages
    - `messages` - Mensagens dentro de chats
      - `id` (uuid, primary key)
      - `chat_id` (uuid, foreign key) - ID do chat
      - `sender_id` (uuid) - ID do remetente
      - `encrypted_content` (text) - Conteúdo criptografado da mensagem
      - `created_at` (timestamptz)
  
  ### Appointments
    - `appointments` - Agendamentos entre paciente e profissional
      - `id` (uuid, primary key)
      - `patient_id` (uuid, foreign key) - ID do paciente
      - `professional_id` (uuid, foreign key) - ID do profissional
      - `appointment_date` (date) - Data da consulta
      - `start_time` (time) - Horário de início
      - `end_time` (time) - Horário de fim
      - `status` (text) - Status: pending, confirmed, cancelled, completed
      - `notes` (text, encrypted) - Notas criptografadas
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  ## 2. Security
    - Enable RLS on all tables
    - Policies for patients to access their own data
    - Policies for professionals to access their own data
    - Policies for chat participants to access messages
    - Policies for appointment participants to access appointments
*/

-- Create patient_profiles table
CREATE TABLE IF NOT EXISTS patient_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  name text NOT NULL,
  cpf text,
  birth_date text,
  phone text,
  public_key text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create professional_profiles table
CREATE TABLE IF NOT EXISTS professional_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  name text NOT NULL,
  cpf text,
  phone text,
  specialty text,
  bio text,
  registration_number text,
  public_key text,
  schedule_start time,
  schedule_end time,
  appointment_duration integer DEFAULT 60,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create schedule_exceptions table
CREATE TABLE IF NOT EXISTS schedule_exceptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  professional_id uuid NOT NULL REFERENCES professional_profiles(id) ON DELETE CASCADE,
  date date NOT NULL,
  is_available boolean DEFAULT false,
  custom_start time,
  custom_end time,
  created_at timestamptz DEFAULT now()
);

-- Create chats table
CREATE TABLE IF NOT EXISTS chats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid NOT NULL REFERENCES patient_profiles(id) ON DELETE CASCADE,
  professional_id uuid NOT NULL REFERENCES professional_profiles(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(patient_id, professional_id)
);

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id uuid NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_id uuid NOT NULL,
  encrypted_content text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid NOT NULL REFERENCES patient_profiles(id) ON DELETE CASCADE,
  professional_id uuid NOT NULL REFERENCES professional_profiles(id) ON DELETE CASCADE,
  appointment_date date NOT NULL,
  start_time time NOT NULL,
  end_time time NOT NULL,
  status text DEFAULT 'pending',
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE patient_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedule_exceptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- Patient Profiles Policies
CREATE POLICY "Users can view their own patient profile"
  ON patient_profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own patient profile"
  ON patient_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert their own patient profile"
  ON patient_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Professional Profiles Policies
CREATE POLICY "Users can view their own professional profile"
  ON professional_profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can view all professional profiles for search"
  ON professional_profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update their own professional profile"
  ON professional_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert their own professional profile"
  ON professional_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Schedule Exceptions Policies
CREATE POLICY "Professionals can manage their schedule exceptions"
  ON schedule_exceptions FOR ALL
  TO authenticated
  USING (auth.uid() = professional_id)
  WITH CHECK (auth.uid() = professional_id);

CREATE POLICY "Patients can view professional schedule exceptions"
  ON schedule_exceptions FOR SELECT
  TO authenticated
  USING (true);

-- Chats Policies
CREATE POLICY "Chat participants can view their chats"
  ON chats FOR SELECT
  TO authenticated
  USING (auth.uid() = patient_id OR auth.uid() = professional_id);

CREATE POLICY "Users can create chats"
  ON chats FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = patient_id OR auth.uid() = professional_id);

CREATE POLICY "Chat participants can update their chats"
  ON chats FOR UPDATE
  TO authenticated
  USING (auth.uid() = patient_id OR auth.uid() = professional_id)
  WITH CHECK (auth.uid() = patient_id OR auth.uid() = professional_id);

-- Messages Policies
CREATE POLICY "Chat participants can view messages"
  ON messages FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM chats
      WHERE chats.id = messages.chat_id
      AND (chats.patient_id = auth.uid() OR chats.professional_id = auth.uid())
    )
  );

CREATE POLICY "Chat participants can send messages"
  ON messages FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM chats
      WHERE chats.id = messages.chat_id
      AND (chats.patient_id = auth.uid() OR chats.professional_id = auth.uid())
    )
    AND sender_id = auth.uid()
  );

-- Appointments Policies
CREATE POLICY "Appointment participants can view their appointments"
  ON appointments FOR SELECT
  TO authenticated
  USING (auth.uid() = patient_id OR auth.uid() = professional_id);

CREATE POLICY "Patients can create appointments"
  ON appointments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = patient_id);

CREATE POLICY "Appointment participants can update appointments"
  ON appointments FOR UPDATE
  TO authenticated
  USING (auth.uid() = patient_id OR auth.uid() = professional_id)
  WITH CHECK (auth.uid() = patient_id OR auth.uid() = professional_id);

CREATE POLICY "Appointment participants can delete appointments"
  ON appointments FOR DELETE
  TO authenticated
  USING (auth.uid() = patient_id OR auth.uid() = professional_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_chats_patient_id ON chats(patient_id);
CREATE INDEX IF NOT EXISTS idx_chats_professional_id ON chats(professional_id);
CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_professional_id ON appointments(professional_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_schedule_exceptions_professional_id ON schedule_exceptions(professional_id);
CREATE INDEX IF NOT EXISTS idx_schedule_exceptions_date ON schedule_exceptions(date);
